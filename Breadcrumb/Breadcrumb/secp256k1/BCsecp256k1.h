//
//  BCsecp256k1.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/11/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (NSData *)publicKeyFromKey:(NSData *)privateKey;

/*!
 @brief Signs the inputted hash with the inputed private key.
 
 @param hash The 32 byte hash to sign,
 @param key  The 32 byte key to sign the hash with.
 
 @return <#return value description#>
 */
- (NSData *)signitureForHash:(NSData *)hash withPrivateKey:(NSData *)key;

- (BOOL)signiture:(NSData *)signiture isValidForPublicKey:(NSData *)publicKey;

- (BOOL)signiture:(NSData *)signiture
              orginHash:(NSData *)hash
    isValidForPublicKey:(NSData *)publicKey;
#pragma mark Shared access

/*!
 @brief This is the instance you should use for secp256k1 operations. First call
 can take (10-100ms)

 @discussion First access of this instance allocates memory for secp256k1
 operations, appon deallocation of this instance memory for the c library will
 be also deallcated.
 */
+ (instancetype)sharedInstance;

@end
