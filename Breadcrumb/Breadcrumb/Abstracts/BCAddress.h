//
//  BCAddress.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import <Foundation/Foundation.h>

@class BCCoin;

@interface BCAddress : NSObject

#pragma mark Construction
/*!
 @brief Constructs a address object with the bitcoin address string.

 @param addressString The address string to construct the object with.
 */
- (instancetype)initWithAddressString:(NSString *)addressString;

/*!
 @brief Constructs a address object with the bitcoin address string.

 @param addressString The address string to construct the object with.
 */
+ (instancetype)addressWithString:(NSString *)address;

#pragma mark Info
/*!
 @brief Converts the address to a string.
 */
- (NSString *)toString;

/*!
 @brief Converts the address to data.
 */
- (NSData *)toData;

/*!
 @brief Converts the address to data excluding its type byte.
 */
- (NSData *)toDataWithoutType;

/*!
 @brief The code representing the type.
 */
@property(assign, nonatomic, readonly) uint8_t typeCode;

#pragma mark Conversion
/*!
 @brief Converts a public key into a base 58checked address using the old
 version byte.

 @discussion Converts a public key into an address by getting the has of the
 address (SHA256 + RIPMD160) then base 58 check encoding it.

 @param publicKey The public key to convert into a address.
 */
+ (BCAddress *)addressFromPublicKey:(NSData *)publicKey
                          usingCoin:(BCCoin *)coin;

#pragma mark Checks
/*!
 @brief Checks if addresses are equivalent besides for their type.

 @param address The address to compare.

 @return True if addresses data excluding the version byte is the same,
 otherwise false.
 */
- (BOOL)isEqualExcludingVersion:(BCAddress *)address;

@end

@interface NSString (BCAddress)
/*!
 @brief Attempts to convert a base58 encoded address into a native form.
 */
- (BCAddress *)toBitcoinAddress;

@end
