//
//  BCKeyPair.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCAddress.h"

@interface BCKeyPair : NSObject
#pragma mark Construction
/*!
 @brief Constructs a key pair with the inputted keys.

 @param privateKey The private key for the key pair.
 @param memoryKey  The key to encrypt the private key with while it is in
 memory.
 */
- (instancetype)initWithPrivateKey:(NSData *)privateKey
                      andMemoryKey:(NSData *)memoryKey;

#pragma mark Public Info
/*!
 @brief The bitcoin address of the keypair.
 */
@property(strong, nonatomic, readonly) BCAddress *address;

/*!
 @brief The public key of the keypair.
 */
@property(strong, nonatomic, readonly) NSData *publicKey;

#pragma mark Private Info
/*!
 @brief Decrypts, and retrives the private key from memory.

 @param memoryKey The key used to encrypt the private key in memory.

 @return The clear text private key, or NULL if the operation failed.
 */
- (NSData *)privateKeyUsingMemoryKey:(NSData *)memoryKey;

#pragma mark Child Retrieval
/*!
 @brief Gets the internal key pair for the specified index of the key sequence.

 @param index The index of the internal key pair to retrieve.

 @return The internal key pair for the specified index, or NULL if invalid.
 */
- (BCKeyPair *)internalKeyPairAt:(NSUInteger)index;

/*!
 @brief Gets the external key pair for the specified index of the key sequence.

 @param index The index of the external key pair to retrieve.

 @return The external key pair for the specified index, or NULL if invalid.
 */
- (BCKeyPair *)externalKeyPairAt:(NSUInteger)index;

#pragma mark Siging Operations

/*!
 @brief Signs the inputed data with the key pairs private key.

 @param data      The data to sign.
 @param memoryKey The key used to encrypt the private key in memory.

 @return The signed data or NULL if invalid.
 */
- (NSData *)signHash:(NSData *)hash withMemoryKey:(NSData *)memoryKey;

- (BOOL)didSign:(NSData *)signedData withOriginalHash:(NSData *)hash;

@end