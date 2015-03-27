//
//  BCWallet+Transactions.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import "_BCWallet.h"

// Errors
static NSString *const kBCWalletError_Domain =
    @"com.breadcrumb.transactionBuilder";

@implementation BCWallet (Transactions)
#pragma mark Transactions

- (void)send:(uint64_t)amount
               to:(BCAddress *)address
    usingPassword:(NSData *)password
     withCallback:(void (^)(NSData *, NSError *))callback {
  [self send:amount
                 to:address
           feePerKB:kBCStandardFeePerKB
      usingPassword:password
       withCallback:callback];
}

- (void)send:(uint64_t)amount
               to:(BCAddress *)address
    usingPassword:(NSData *)password {
  [self send:amount
                 to:address
           feePerKB:kBCStandardFeePerKB
      usingPassword:password
       withCallback:NULL];
}

- (void)send:(uint64_t)amount
               to:(BCAddress *)address
         feePerKB:(uint64_t)feePerKB
    usingPassword:(NSData *)password
     withCallback:(void (^)(NSData *, NSError *))callback {
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  if (![address isKindOfClass:[BCAddress class]]) return;
  @autoreleasepool {
    __block uint64_t sAmount = amount;
    __block BCAddress *sAddress = address;
    void (^sCallback)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
      if (callback)
        dispatch_async(dispatch_get_main_queue(), ^{
          callback(data, error);
        });
    };

    // Validate password
    if (![password isKindOfClass:[NSData class]]) return;

    // Ensure we have the required funds
    [self getBalance:^(uint64_t balance, NSError *error) {
      if ([error isKindOfClass:[NSError class]]) {
        sCallback(NULL, error);
        return;
      }
      if (balance <= sAmount) {
        sCallback(NULL, [[self class] InsufficientFundsForTransactionError]);
        return;
      }

      dispatch_async(self.queue, ^{
        if (![self.addressManager.coin typeIsValidForCoin:address]) {
          sCallback(
              NULL,
              [[self class]
                  addressInvalidForCoinError:[self.addressManager.coin class]]);
          return;
        }

        // Get the key
        NSData *key = [[self class] _keyFromPassword:password];
        if (![key isKindOfClass:[NSData class]]) {
          sCallback(NULL, [[self class] failedToSignTransactionError]);
          return;
        }

        // Create Unsigned transaction, and Sign
        [self
            _unsignedTransactionForAmount:sAmount
                                 feePerKB:feePerKB
                                       to:sAddress
                             withCallback:[self  // Set the callback to sign the
                                                 // transaction
                                              _signTransactionBlockForCallback:
                                                  sCallback andKey:key]];
      });
    }];
  }
}

- (void)_unsignedTransactionForAmount:(uint64_t)amount
                             feePerKB:(uint64_t)feePerKB
                                   to:(BCAddress *)address
                         withCallback:(void (^)(BCMutableTransaction *,
                                                NSError *))callback {
  __block uint64_t sAmount, sFee;
  __block BCAddress *sAddress;
  __block void (^sCallback)(BCMutableTransaction *, NSError *);
  if (!callback || ![address isKindOfClass:[BCAddress class]]) return;

  sAmount = amount;
  sFee = feePerKB;
  sAddress = address;
  sCallback = callback;

  // Get UTXOs optimized for the specified amount from our provider so we can
  // build the transaction.
  [self.provider
      UTXOforAmount:amount
       andAddresses:self.addressManager  // Pass the address manager so they can
                                         // get the right addresses
       withCallback:^(NSArray *UTXOs, NSError *error) {
         NSError *transactionBuildingError;
         BCMutableTransaction *transaction;

         if ([error isKindOfClass:[NSError class]]) {
           // Report error
           sCallback(NULL, error);

         } else if ([UTXOs isKindOfClass:[NSArray class]]) {
           // Build the transaction with the inputted UTXOs
           transaction = [BCMutableTransaction
               buildTransactionWith:UTXOs
                          forAmount:sAmount
                                 to:sAddress
                            feePerK:sFee
                      changeAddress:self.addressManager.firstUnusedInternal
                          withError:&transactionBuildingError
                            andCoin:self.coin];

           if ([transactionBuildingError isKindOfClass:[NSError class]]) {
             callback(NULL, transactionBuildingError);
             return;
           }

           // Report the unsigned transaction
           sCallback(transaction, NULL);
         } else {
           // Report failure
           sCallback(NULL, [[self class] failedToRetriveUTXOsError]);
         }
       }];
}

- (void (^)(id, NSError *))_signTransactionBlockForCallback:
                               (void (^)(NSData *, NSError *))callback
                                                     andKey:(NSData *)key {
  @autoreleasepool {
    __block void (^sCallback)(NSData *, NSError *);
    NSParameterAssert(
        [(id)callback isKindOfClass:NSClassFromString(@"NSBlock")]);
    if (![(id)callback isKindOfClass:NSClassFromString(@"NSBlock")])
      return NULL;

    // Set Block Safe vars
    sCallback = callback;

    return ^(BCMutableTransaction *unsignedTransaction, NSError *error) {
      BCMutableTransaction *signedTransaction;
      NSError *signingError;

      // Get Status
      if ([error isKindOfClass:[NSError class]]) {
        // The operation failed report error
        sCallback(NULL, error);

      } else if ([unsignedTransaction
                     isKindOfClass:[BCMutableTransaction class]]) {
        // We Created the unsigned transaction, we need to sign it
        signedTransaction = [self _signTransaction:unsignedTransaction
                                           withKey:key
                                          andError:&signingError];
        if ([signingError isKindOfClass:[NSError class]]) {
          // We Failed to sign the transaction  report and stop.
          sCallback(NULL, signingError);
          return;
        }

        // Publish the transaction to the provider.
        [self.provider publishTransaction:signedTransaction
                                  forCoin:self.addressManager.coin
                           withCompletion:sCallback];
      } else {
        // Failed to create an unsigned transaction
        sCallback(NULL, [[self class] failedToCreateUnsignedTransactionError]);
      }
    };
  }
}

#pragma mark Errors

+ (NSError *)InsufficientFundsForTransactionError {
  return [NSError errorWithDomain:kBCWalletError_Domain
                             code:12
                         userInfo:@{
                           NSLocalizedDescriptionKey : @"Insufficient Funds."
                         }];
}

+ (NSError *)failedToCreateUnsignedTransactionError {
  return [NSError errorWithDomain:kBCWalletError_Domain
                             code:13
                         userInfo:@{
                           NSLocalizedDescriptionKey :
                               @"Failed to create unsigned transaction."
                         }];
}

+ (NSError *)failedToRetriveUTXOsError {
  return
      [NSError errorWithDomain:kBCWalletError_Domain
                          code:14
                      userInfo:@{
                        NSLocalizedDescriptionKey : @"Failed to retrive UTXOs."
                      }];
}

+ (NSError *)failedToSignTransactionError {
  return [NSError
      errorWithDomain:kBCWalletError_Domain
                 code:15
             userInfo:@{
               NSLocalizedDescriptionKey : @"Failed to sign transaction."
             }];
}

+ (NSError *)addressInvalidForCoinError:(Class)coinClass {
  return [NSError
      errorWithDomain:kBCWalletError_Domain
                 code:18
             userInfo:@{
               NSLocalizedDescriptionKey : [NSString
                   stringWithFormat:
                       @"Address type code is invalid for wallet coin. (%@)",
                       NSStringFromClass(coinClass)]

             }];
}

@end
