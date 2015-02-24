//
//  BCCoin.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCCoin.h"

@implementation BCCoin

#pragma mark Address Info
/*!
 @brief Gets the correct address type code for the specified string.

 @param flags The flags indicating the address type information

 @return The type code that should be used for the address with the specified
 flag.
 */
- (uint8_t)addressTypeForFlags:(NSUInteger)flags {
  NSAssert(false, @"Abstract Method!");
  return UINT8_MAX;
}

- (uint32_t)coinId {
  return 0x80000000;
}

#pragma mark Default Coins

+ (instancetype)MainNetBitcoin {
  static dispatch_once_t onceToken;
  static BCCoin *coin;
  dispatch_once(&onceToken, ^{ coin = [[BCMainNetBitcoin alloc] init]; });
  return coin;
}

+ (instancetype)TestNet3Bitcoin {
  static dispatch_once_t onceToken;
  static BCCoin *coin;
  dispatch_once(&onceToken, ^{ coin = [[BCTestNet3Bitcoin alloc] init]; });
  return coin;
}

@end

@implementation BCMainNetBitcoin

- (uint8_t)addressTypeForFlags:(NSUInteger)flags {
  switch (flags) {
    default:
      return 0x00;
      break;
  }
}

- (uint32_t)coinId {
  return 0x80000000;
}

@end

@implementation BCTestNet3Bitcoin

- (uint8_t)addressTypeForFlags:(NSUInteger)flags {
  switch (flags) {
    default:
      return 111;
      break;
  }
}

- (uint32_t)coinId {
  return 0x80000001;
}

@end
