//
//  BCAWallet.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCAWallet.h"

@implementation BCAWallet
#pragma mark Construction

- (instancetype)initNew {
  NSAssert(FALSE, @"Called method on abstract class.");
  return NULL;
}

#pragma mark Wallet Info

- (NSNumber *)balance {
  NSAssert(FALSE, @"Called method on abstract class.");
  return NULL;
}

- (BCAddress *)currentAddress {
  NSAssert(FALSE, @"Called method on abstract class.");
  return NULL;
}

#pragma mark Transactions

- (void)send:(NSNumber *)amount
              to:(BCAddress *)address
    withCallback:(void (^)(NSError *))callback {
  NSAssert(FALSE, @"Called method on abstract class.");
}

#pragma mark Debugging

- (NSString *)debugDescription {
  return [self description];
}

- (NSString *)description {
  return [NSString
      stringWithFormat:@"'%@' with '%@'", self.currentAddress, self.balance];
}

@end
