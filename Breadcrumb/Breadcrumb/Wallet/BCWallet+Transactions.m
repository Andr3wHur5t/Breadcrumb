//
//  BCWallet+Transactions.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet+Transactions.h"

@implementation BCWallet (Transactions)

- (void)UTXOforAmount:(NSNumber *)amount
         withCallback:(void (^)(NSArray *, NSError *))callback {
  // TODO: Get our public addresses for UTXOs
  [self.provider UTXOforAmount:amount
                  andAddresses:@[ @"1K4nPxBMy6sv7jssTvDLJWk1ADHBZEoUVb" ]
                  withCallback:callback];
}

- (void)unsignedTransactionForAmount:(NSNumber *)amount
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
  // Get UTXOs optimized for the specified ammount from our provider so we can
  // build the transaction.
  [self UTXOforAmount:amount
         withCallback:^(NSArray *UTXOs, NSError *error) {
             BCTransaction *transaction;

             if ([error isKindOfClass:[NSError class]]) {
               // Report error
               sCallback(NULL, error);

             } else if ([UTXOs isKindOfClass:[NSArray class]]) {
               // Build the reansaction with the inputted UTXOs
               transaction = [BCMutableTransaction
                   buildTransactionWith:UTXOs
                              forAmount:sAmount
                                     to:sAddress
                                feePerK:@6000  // Get Fee from wallet settings
                      withChangeAddress:self.currentAddress];

               // Check if we failed
               if (![transaction isKindOfClass:[BCTransaction class]]) {
                 sCallback(
                     NULL,
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

- (BCTransaction *)signTransaction:(BCTransaction *)transaction {
  @autoreleasepool {  // Ensure immediate deallocation of sensitive data.
    // TODO: sign the inputted transaction with the related keys.
    return NULL;
  }
}

- (void)publishTransaction:(id)transaction
            withCompletion:(void (^)(NSError *))completion {
  // Publish the reansaction to the network through our provider
  [self.provider publishTransaction:transaction withCompletion:completion];
}

#pragma mark Errors

+ (NSError *)failedToCreateUnsignedTransactionError {
  return [NSError errorWithDomain:@"com.breadcrumb.transactionBuilder"
                             code:2
                         userInfo:@{
                           NSLocalizedDescriptionKey :
                               @"Failed to create unsigned transaction."
                         }];
}

+ (NSError *)failedToRetriveUTXOsError {
  return
      [NSError errorWithDomain:@"com.breadcrumb.transactionBuilder"
                          code:2
                      userInfo:@{
                        NSLocalizedDescriptionKey : @"Failed to retrive UTXOs."
                      }];
}
@end
