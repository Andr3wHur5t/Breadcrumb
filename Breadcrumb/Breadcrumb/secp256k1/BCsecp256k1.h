//
//  BCsecp256k1.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/11/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import <Foundation/Foundation.h>
#import "tommath.h"

/*!
 @brief This is a helper class for secp256k1 functions.

 @discussion you should always use the shared instance of this class, there is
 no reason to have more than one instance of this.

 This is an abstraction of https://github.com/bitcoin/secp256k1
 */
@interface BCsecp256k1 : NSObject
#pragma mark Operations
/*!
 @brief Derives a public key for the given private key.

 @param privateKey The private key to generate the public key from.
 */
- (NSData *)publicKeyFromKey:(NSData *)privateKey compressed:(BOOL)compressed;

/*!
 @brief Signs the inputted hash with the inputed private key.

 @param hash The 32 byte hash to sign,
 @param key  The 32 byte key to sign the hash with.
 */
- (NSData *)signatureForHash:(NSData *)hash withPrivateKey:(NSData *)key;

/*!
 @brief Checks if the signature is valid given the signed data, the origin data,
 and the public key.

 @param signature The signed data.
 @param hash      The origin data before it was signed.
 @param publicKey The public key of the key pair that signed the data.
 */
- (BOOL)signature:(NSData *)signature
             originHash:(NSData *)hash
    isValidForPublicKey:(NSData *)publicKey;

#pragma mark Public Key Tweeks

- (NSData *)publicKey:(NSData *)publicKey add:(NSData *)tweek;

- (NSData *)privateKey:(NSData *)privateKey add:(NSData *)tweek;

#pragma mark Shared access

/*!
 @brief This is the instance you should use for secp256k1 operations. First call
 can take (10-100ms)

 @discussion First access of this instance allocates memory for secp256k1
 operations, upon deallocation of this instance memory for the c library will
 be also deallocated.
 */
+ (instancetype)sharedInstance;

#pragma mark Utilities
+ (NSData *)pseudoRandomDataWithLength:(NSUInteger)length;
+ (mp_int)curveOrder;
@end
