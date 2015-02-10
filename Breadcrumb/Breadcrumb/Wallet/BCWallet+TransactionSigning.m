//
//  BCWallet+TransactionSigning.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet+TransactionSigning.h"
#import "NSData+ConversionUtilties.h"

@implementation BCWallet (_TransactionSigning)

- (BCMutableTransaction *)_signTransaction:(BCMutableTransaction *)transaction
                                   withKey:(NSData *)key {
  @autoreleasepool {  // Ensure immediate deallocation of sensitive data.
    // TODO: sign the inputted transaction with the related keys.
    return NULL;  // transaction;
  }
}

#pragma mark Old
// sign any inputs in the given transaction that can be signed using private
// keys from the wallet
//- (BOOL)signTransaction:(BRTransaction *)transaction withPrompt:(NSString
//*)authprompt
//{
//  @autoreleasepool { // @autoreleasepool ensures sensitive data will be
//  dealocated immediately
//    int64_t amount = [self amountSentByTransaction:transaction] - [self
//    amountReceivedFromTransaction:transaction];
//    NSData *seed = self.seed(authprompt, (amount > 0) ? amount : 0);
//    NSMutableArray *pkeys = [NSMutableArray array];
//    NSMutableOrderedSet *externalIndexes = [NSMutableOrderedSet orderedSet],
//    *internalIndexes = [NSMutableOrderedSet orderedSet];
//
//    if (! seed) return YES; // user canceled authentication
//
//    for (NSString *addr in transaction.inputAddresses) {
//      [internalIndexes addObject:@([self.internalAddresses
//      indexOfObject:addr])];
//      [externalIndexes addObject:@([self.externalAddresses
//      indexOfObject:addr])];
//    }
//
//    [internalIndexes removeObject:@(NSNotFound)];
//    [externalIndexes removeObject:@(NSNotFound)];
//    [pkeys addObjectsFromArray:[self.sequence privateKeys:[externalIndexes
//    array] internal:NO fromSeed:seed]];
//    [pkeys addObjectsFromArray:[self.sequence privateKeys:[internalIndexes
//    array] internal:YES fromSeed:seed]];
//
//    [transaction signWithPrivateKeys:pkeys];
//
//    return [transaction isSigned];
//  }
//}

@end

@implementation BCWallet (_SecurityUtilities)

+ (NSData *)_keyFromPassword:(NSData *)password {
  @autoreleasepool {
    NSData *keyData;
    keyData = [NSData scryptPassword:password
                           usingSalt:[self _saltData]
                    withOutputLength:32];

    return keyData;
  }
}

+ (NSData *)_saltData {
  // TODO: Get salt on a per device basis
  return @"0X0X0X0XEFFF".hexToData;
}
@end
