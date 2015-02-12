//
//  BCsecp256k1.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/11/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCsecp256k1.h"

@implementation BCsecp256k1
#pragma mark Construction

- (instancetype)init {
  NSAssert(false, @"MUST use shared instance of BCsecp256k1.");
  return NULL;
}

- (instancetype)_init {
  self = [super init];
  if (self) {
  }
  return self;
}

#pragma mark Operations

- (NSData *)publicKeyFromKey:(NSData *)privateKey {
  @autoreleasepool {
    return NULL;
  }
}

- (NSData *)signData:(NSData *)data withKey:(NSData *)key {
  @autoreleasepool {
    return data;
  }
}
#pragma mark Shared access

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static BCsecp256k1 *instance;
  dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] _init]; });
  return instance;
}
@end
