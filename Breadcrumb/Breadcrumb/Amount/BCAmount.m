//
//  BCAmount.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "BCAmount.h"

@implementation BCAmount

#pragma mark Satoshi

+ (CGFloat)satoshiToBits:(uint64_t)satoshi {
  return (CGFloat)satoshi / (CGFloat)kBCAmountBits;
}

+ (uint64_t)satoshiTomBTC:(uint64_t)satoshi {
  return (CGFloat)satoshi / (CGFloat)kBCAmountmBTC;
}

+ (CGFloat)satoshiToBTC:(uint64_t)satoshi {
  return (CGFloat)satoshi / (CGFloat)kBCAmountBTC;
}

+ (NSString *)prettyPrint:(uint64_t)satoshi {
  CGFloat amount;
  BCUnitType unit = [self perferedUnitFor:satoshi];

  switch (unit) {
    case BCUnitType_Bits:
      amount = [self satoshiToBits:satoshi];
      break;
    case BCUnitType_mBTC:
      amount = [self satoshiTomBTC:satoshi];
      break;
    case BCUnitType_BTC:
      amount = [self satoshiToBTC:satoshi];
      break;
    default:
      amount = satoshi;
      break;
  }

  return
      [NSString stringWithFormat:@"%@%@", @(amount), [self symbolForUnit:unit]];
}

+ (BCUnitType)perferedUnitFor:(uint64_t)satoshi {
  if (satoshi < kBCAmountBits)
    return BCUnitType_Satoshi;
  else if (satoshi < kBCAmountmBTC)
    return BCUnitType_Bits;
  else if (satoshi < kBCAmountBTC)
    return BCUnitType_mBTC;
  else
    return BCUnitType_BTC;
}

+ (NSString *)symbolForUnit:(BCUnitType)unit {
  switch (unit) {
    case BCUnitType_Satoshi:
      return @"s";
      break;
    case BCUnitType_Bits:
      return @"ƀ";
      break;
    case BCUnitType_mBTC:
      return @"mBTC";
      break;
    case BCUnitType_BTC:
      return @"Ƀ";
      break;
    default:
      return @"???";
      break;
  }
}

#pragma mark Common Conversions

+ (uint64_t)Bits:(CGFloat)Bits {
  return Bits * kBCAmountBits;
}

+ (uint64_t)mBTC:(CGFloat)mBTC {
  return mBTC * kBCAmountmBTC;
}

+ (uint64_t)BTC:(CGFloat)btc {
  return btc * kBCAmountBTC;
}

@end