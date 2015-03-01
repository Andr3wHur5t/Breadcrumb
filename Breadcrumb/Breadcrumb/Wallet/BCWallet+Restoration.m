//
//  BCWallet+Restoration.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import "BCWallet+Restoration.h"
#import "_BCWallet.h"

@implementation BCWallet (Restoration)
#pragma mark Construction

+ (void)initUsingPrivateInfo:(NSDictionary *)privInfo
                  publicInfo:(NSDictionary *)pubInfo
                    password:(NSData *)password
              withCompletion:(void (^)(id))completion {
  @autoreleasepool {
    // TODO: Process info and restore
    return;
  }
}

#pragma mark Restoration Data Retrieval

#pragma mark Utilities

+ (NSDictionary *)privateInfoWithEncryptedSeed:(NSData *)seed
                             encryptedMnemonic:(NSData *)mnemonic {
  @autoreleasepool {
    NSParameterAssert([seed isKindOfClass:[NSData class]]);
    NSParameterAssert([mnemonic isKindOfClass:[NSData class]]);
    if (![seed isKindOfClass:[NSData class]] ||
        ![mnemonic isKindOfClass:[NSData class]])
      return NULL;
    return @{kBCRestoration_Seed : seed, kBCRestoration_Mnemonic : mnemonic};
  }
}
@end
