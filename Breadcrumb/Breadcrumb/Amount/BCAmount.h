//
//  BCAmount.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import <Foundation/Foundation.h>

static const uint64_t kBCAmountBits = 1e2;
static const uint64_t kBCAmountmBTC = 1e5;
static const uint64_t kBCAmountBTC = 1e8;

typedef enum : NSUInteger {
                 BCUnitType_Satoshi,
                 BCUnitType_Bits,
                 BCUnitType_mBTC,
                 BCUnitType_BTC,
               } BCUnitType;

/*!
 @brief A set of class methods for easy to read conversions of amounts of BTC.
 */
@interface BCAmount : NSObject
#pragma mark Satoshi
/*!
 @brief Converts the amount of satoshi to bits.

 @param satoshi The amount of satoshi to convert.
 */
+ (CGFloat)satoshiToBits:(uint64_t)satoshi;

/*!
 @brief Converts the amount of satoshi to mBTC.
 
 @param satoshi The amount of satoshi to convert.
 */
+ (CGFloat)satoshiTomBTC:(uint64_t)satoshi;

/*!
 @brief Converts the inputted amount of satoshi to BTC.

 @param satoshi The amount of satoshi to convert.
 */
+ (CGFloat)satoshiToBTC:(uint64_t)satoshi;

/*!
 @brief Pretty prints the inputed amount of satoshi

 @param satoshi The satoshi amount to pretty print.
 */
+ (NSString *)prettyPrint:(uint64_t)satoshi;

/*!
 @brief Gets the best sutited uint

 @param satoshi The amount to get the unit for.

 @return The best suited unit for pretty printing.
 */
+ (BCUnitType)perferedUnitFor:(uint64_t)satoshi;

#pragma mark Common Conversions
/*!
 @brief Converts the inputted number of bits into satoshi

 @param Bits The bits to convert.
 */
+ (uint64_t)Bits:(CGFloat)Bits;

/*!
 @brief Converts the inputted number of bits into satoshi

 @param Bits The bits to convert.
 */
+ (uint64_t)mBTC:(CGFloat)mBTC;

/*!
 @brief Converts the inputted number of BTC into satoshi

 @param btc The BTC to convert.
 */
+ (uint64_t)BTC:(CGFloat)btc;

@end