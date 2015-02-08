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
  // TODO: Get our public addresses.
  [self.provider UTXOforAmount:amount
                  andAddresses:@[ @"1K4nPxBMy6sv7jssTvDLJWk1ADHBZEoUVb" ]
                  withCallback:callback];
}

- (void)unsignedTransactionForAmount:(NSNumber *)amount
                                  to:(BCAddress *)address
                        withCallback:(void (^)(BCTransaction *,
                                               NSError *))callback {
  __block NSNumber *sAmount;
  __block BCAddress *sAddress;
  __block void (^sCallback)(BCTransaction *, NSError *);

  sAmount = amount;
  sAddress = address;
  sCallback = callback;
  [self UTXOforAmount:amount
         withCallback:^(NSArray *UTXOs, NSError *error) {
             id transaction;
             if ([error isKindOfClass:[NSError class]]) {
               sCallback(NULL, error);

             } else if ([UTXOs isKindOfClass:[NSArray class]]) {
               // We got UTXOs build transaction
               transaction =
                   [BCTransaction buildTransactionWith:UTXOs
                                             forAmount:sAmount
                                                    to:sAddress
                                                feePerK:@6000
                                     withChangeAddress:self.currentAddress];

               if (![transaction isKindOfClass:[NSObject class]]) {
                 sCallback(
                     NULL,
                     [[self class] failedToCreateUnsignedTransactionError]);
                 return;
               }
               sCallback(transaction, NULL);

             } else {
               sCallback(NULL, [[self class] failedToRetriveUTXOsError]);
             }
         }];
}

- (BCTransaction *)signTransaction:(BCTransaction *)transaction {
  @autoreleasepool {  // Ensure immediate deallocation of sensitive data.
    // TODO: build the unsigned transaction.
    return NULL;
  }
}

- (void)publishTransaction:(id)transaction
            withCompletion:(void (^)(NSError *))completion {
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
