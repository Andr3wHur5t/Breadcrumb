//
//  BCWallet+Transactions.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "_BCWallet.h"

// Errors
static NSString *const kBCWalletError_Domain =
    @"com.breadcrumb.transactionBuilder";
static NSString *const kBCWalletError_FailedToSign =
    @"Failed to sign transaction.";

@implementation BCWallet (Transactions)
#pragma mark Transactions

- (void)send:(NSNumber *)amount
               to:(BCAddress *)address
    usingPassword:(NSData *)password
     withCallback:(void (^)(NSError *))callback {
  NSParameterAssert([amount isKindOfClass:[NSNumber class]]);
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  NSParameterAssert([(id)callback isKindOfClass:NSClassFromString(@"NSBlock")]);
  if (![amount isKindOfClass:[NSNumber class]] ||
      ![address isKindOfClass:[BCAddress class]] ||
      ![(id)callback isKindOfClass:NSClassFromString(@"NSBlock")])
    return;
  @autoreleasepool {
    __block NSNumber *sAmount = amount;
    __block BCAddress *sAddress = address;
    void (^sCallback)(NSError *) = callback;

    dispatch_async(self.queue, ^{
        // Get the key
        NSData *key = [[self class] _keyFromPassword:password];
        if (![key isKindOfClass:[NSData class]]) {
          sCallback([[self class] failedToSignTransactionError]);
          return;
        }

        // Create Unsigned transaction, and Sign
        [self
            _unsignedTransactionForAmount:sAmount
                                       to:sAddress
                             withCallback:[self  // Set the callback to sign the
                                                 // transaction
                                              _signTransactionBlockForCallback:
                                                  sCallback andKey:key]];
    });
  }
}

- (void)_unsignedTransactionForAmount:(NSNumber *)amount
                                   to:(BCAddress *)address
                         withCallback:(void (^)(BCMutableTransaction *,
                                                NSError *))callback {
  __block NSNumber *sAmount;
  __block BCAddress *sAddress;
  __block void (^sCallback)(BCMutableTransaction *, NSError *);
  // TODO: Validate Input

  sAmount = amount;
  sAddress = address;
  sCallback = callback;

  // Get UTXOs optimized for the specified amount from our provider so we can
  // build the transaction.
  [self.provider
      UTXOforAmount:amount
       andAddresses:@[ @"1K4nPxBMy6sv7jssTvDLJWk1ADHBZEoUVb" ]
       withCallback:^(NSArray *UTXOs, NSError *error) {
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
                              feePerK:@10000  // Get Fee from wallet settings
                    withChangeAddress:self.currentAddress];

             // Check if we failed
             if (![transaction isKindOfClass:[BCMutableTransaction class]]) {
               sCallback(NULL,
                         [[self class] failedToCreateUnsignedTransactionError]);
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
                               (void (^)(NSError *))callback
                                                     andKey:(NSData *)key {
  @autoreleasepool {
    __block void (^sCallback)(NSError *);
    NSParameterAssert(
        [(id)callback isKindOfClass:NSClassFromString(@"NSBlock")]);
    if (![(id)callback isKindOfClass:NSClassFromString(@"NSBlock")])
      return NULL;

    // Set Block Safe vars
    sCallback = callback;

    return ^(BCMutableTransaction *unsignedTransaction, NSError *error) {
        BCMutableTransaction *signedTransaction;

        // Get Status
        if ([error isKindOfClass:[NSError class]]) {
          // The operation failed report error
          sCallback(error);

        } else if ([unsignedTransaction
                       isKindOfClass:[BCMutableTransaction class]]) {
          // We Created the unsigned transaction, we need to sign it
          signedTransaction =
              [self _signTransaction:unsignedTransaction withKey:key];
          if (![signedTransaction isKindOfClass:[BCMutableTransaction class]]) {
            // We Failed to sign the transaction  report and stop.
            sCallback([[self class] failedToSignTransactionError]);
            return;
          }

          // Publish the transaction to the provider.
          [self.provider publishTransaction:signedTransaction
                             withCompletion:sCallback];

        } else {
          // Failed to create an unsigned transaction
          sCallback([[self class] failedToCreateUnsignedTransactionError]);
        }
    };
  }
}

#pragma mark Errors

+ (NSError *)failedToCreateUnsignedTransactionError {
  return [NSError errorWithDomain:kBCWalletError_Domain
                             code:3
                         userInfo:@{
                           NSLocalizedDescriptionKey :
                               @"Failed to create unsigned transaction."
                         }];
}

+ (NSError *)failedToRetriveUTXOsError {
  return
      [NSError errorWithDomain:kBCWalletError_Domain
                          code:4
                      userInfo:@{
                        NSLocalizedDescriptionKey : @"Failed to retrive UTXOs."
                      }];
}

+ (NSError *)failedToSignTransactionError {
  return
      [NSError errorWithDomain:kBCWalletError_Domain
                          code:5
                      userInfo:@{
                        NSLocalizedDescriptionKey : kBCWalletError_FailedToSign
                      }];
}

@end
