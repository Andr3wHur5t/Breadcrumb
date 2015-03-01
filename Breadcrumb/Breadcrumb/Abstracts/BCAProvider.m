//
//  BCAProvider.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "BCAProvider.h"

@implementation BCAProvider

- (void)UTXOforAmount:(uint64_t)amount
         andAddresses:(BCAddressManager *)addresses
         withCallback:(void (^)(NSArray *, NSError *))callback {
  NSAssert(FALSE, @"Called method on abstract class.");
}

- (void)publishTransaction:(BCMutableTransaction *)transaction
                   forCoin:(BCCoin *)coin
            withCompletion:(void (^)(NSData *,NSError *))completion {
  NSAssert(FALSE, @"Called method on abstract class.");
}

- (void)syncAddressManager:(BCAddressManager *)addressManager withCallback:(void(^)(NSError *))callback {
  NSAssert(FALSE, @"Called method on abstract class.");
}

- (void)getBalanceForAddressManager:(BCAddressManager *)addressManager
                       withCallback:(void (^)(uint64_t, NSError *))callback {
  NSAssert(FALSE, @"Called method on abstract class.");
}

@end
