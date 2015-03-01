//
//  BCPublicKey.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import <Foundation/Foundation.h>
#import "BCAddress.h"
#import "BCCoin.h"

@interface BCPublicKey : NSObject
#pragma mark Construction
/*!
 @brief Constructs the public key with the inputted key.

 @param data The data of the key to use as the public key.
 */
- (instancetype)initWithData:(NSData *)data;

#pragma mark Configuration
/*!
 @brief The public keys data.
 */
@property(strong, nonatomic, readonly) NSData *data;

/*!
 @brief The public keys address.
 */
- (BCAddress *)addressForCoin:(BCCoin *)coin;

#pragma mark Comparison

- (BOOL)isEqualToData:(NSData *)data;
@end

/*!
 @brief This a public key which can derive non-hardened child public keys.
 */
@interface BCDerivablePublicKey : BCPublicKey
#pragma mark Construction
/*!
 @brief Constructs the public key with the inputted key.

 @param data The data of the key to use as the public key.
 */
- (instancetype)initWithData:(NSData *)data andChainCode:(NSData *)chainCode;

#pragma mark Configuration
/*!
 @brief The chain code to use when deriving child keys.
 */
@property(strong, nonatomic, readonly) NSData *chainCode;

#pragma mark Derivation
/*!
 @brief Gets the child public key at the specified index.

 @param index The index of the child key to get.

 @return The resulting public key.
 */
- (BCPublicKey *)childKeyAtIndex:(uint32_t)index;

@end
