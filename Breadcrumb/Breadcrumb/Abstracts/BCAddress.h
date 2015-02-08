//
//  BCAddress.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end

@interface NSString (BCAddress)

- (BCAddress *)toBitcoinAddress;

@end
