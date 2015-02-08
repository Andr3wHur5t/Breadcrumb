//
//  BCAmount.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCAmount.h"

@implementation NSNumber (BCAmount)

- (NSNumber *)toSatoshi {
  unsigned long long value = [self unsignedLongLongValue];
  return [NSNumber numberWithUnsignedLong:value];
}

- (NSNumber *)toBits {
  unsigned long long value = [self unsignedLongLongValue];
  return [NSNumber numberWithUnsignedLong:value];
}

- (NSNumber *)toBitcoin {
  unsigned long long value = [self unsignedLongLongValue];
  return [NSNumber numberWithUnsignedLong:value];
}

@end