//
//  BCCoin.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "BCCoin.h"
#import "BCAddress.h"

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

- (BOOL)typeIsValidForCoin:(BCAddress *)address {
  NSAssert(false, @"Abstract Method!");
  return FALSE;
}

- (uint32_t)coinId {
  return 0x80000000;
}

- (uint8_t)P2SHCode {
  return 0x05;
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

- (BOOL)typeIsValidForCoin:(BCAddress *)address {
  if (![address isKindOfClass:[BCAddress class]]) return FALSE;
  // Dialaowing test net addresses, and private keys. https://en.bitcoin.it/wiki/List_of_address_prefixes
  return (address.typeCode == 0x00 || address.typeCode == 0x05) &&
         (address.typeCode != 111 || address.typeCode != 196 ||
          address.typeCode != 239 || address.typeCode != 128);
}

- (uint32_t)coinId {
  return 0x80000000;
}

- (uint8_t)P2SHCode {
  return 0x05;
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

- (BOOL)typeIsValidForCoin:(BCAddress *)address {
  if (![address isKindOfClass:[BCAddress class]]) return FALSE;
  // Must be one of the regestered values https://en.bitcoin.it/wiki/List_of_address_prefixes
  return address.typeCode == 111 || address.typeCode == 196;
}

- (uint32_t)coinId {
  return 0x80000001;
}


- (uint8_t)P2SHCode {
  return 196;
}

@end
