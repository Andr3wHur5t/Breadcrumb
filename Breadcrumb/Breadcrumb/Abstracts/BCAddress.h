//
//  BCAddress.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : uint8_t {
                 BCAddressType_Old = 0x00,
                 BCAddressType_New = 0x05
               } BCAddressType;

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
 @brief The type of address.

 @discussion This is stated by the first byte of the decoded address, New
 addresses use new technologies like multi-singiture.
 */
@property(assign, nonatomic, readonly) BCAddressType type;

#pragma mark Conversion

/*!
 @brief Converts a public key into a base 58checked address using the old
 version byte.

 @discussion Converts a public key into an addres by getting the has of the
 address (SHA256 + RIPMD160) then base 58 check encoding it.

 @param publicKey The public key to convert into a address.
 */
+ (BCAddress *)addressFromPublicKey:(NSData *)publicKey;

#pragma mark Checks

- (BOOL)isEqualExcludingVersion:(BCAddress *)address;

@end

@interface NSString (BCAddress)

- (BCAddress *)toBitcoinAddress;

@end
