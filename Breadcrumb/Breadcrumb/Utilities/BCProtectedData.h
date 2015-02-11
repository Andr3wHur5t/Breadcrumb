//
//  BCProtectedData.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
// This is my attempt to reduce surface area of attack, This should be used for
// all protected data stored in memory. Assuming this goes under review we
// should just need to worry about key management, and Input validation.

#import <Foundation/Foundation.h>

/*!
 @brief Standard interface for protecting arbitrary data in memory using a key.

 @discussion This will protect NSData in memory by AES256 encrypting it using
 the inputted memory key, for this to have any effect you MUST generate a strong
 memory key, and keep that key protected.

  You SHOULD never directly use a user inputted password as a key unless passed
 through a key derivation algorithm first. You should consider using Scrypt
 (Preferred), or PBKDF2 as you key derivation methods.
 */
@interface BCProtectedData : NSObject
#pragma mark Construction
/*!
 @brief Constructs a protected memory object with

 @discussion This will protect NSData in memory by AES256 encrypting it using
 the inputted memory key, for this to have any effect you MUST generate a strong
 memory key, and keep that key protected.

 You SHOULD never directly use a user inputted password as a key unless passed
 through a key derivation algorithm first. You should consider using Scrypt
 (Preferred), or PBKDF2 as you key derivation methods.

 @param data      The data which should be protected.
 @param memoryKey The key used to protect the data.
 */
- (instancetype)initData:(NSData *)data withMemoryKey:(NSData *)memoryKey;

/*!
 @brief Constructs a protected memory object with

 @discussion This will protect NSData in memory by AES256 encrypting it using
 the inputted memory key, for this to have any effect you MUST generate a strong
 memory key, and keep that key protected.

 You SHOULD never directly use a user inputted password as a key unless passed
 through a key derivation algorithm first. You should consider using Scrypt
 (Preferred), or PBKDF2 as you key derivation methods.

 @param data      The data which should be protected.
 @param memoryKey The key used to protect the data.
 */
+ (instancetype)protectedData:(NSData *)data withMemoryKey:(NSData *)memoryKey;

#pragma mark Retrieval

/*!
 @brief The protected datas' cypher text.
 */
@property(strong, nonatomic, readonly) NSData *cypherText;

/*!
 @brief Retrieves the protected data in the clear, using the inputted memory key
 to decrypt the data.

 @param memoryKey The key used to decrypt the protected memory.

 @return A copy of the protected data in the clear, or NULL if the memory key
 was incorrect.
 */
- (NSData *)dataUsingMemoryKey:(NSData *)memoryKey;

#pragma mark Algorithm
/*!
 @brief Verifies that the key is valid for the used algorithm.

 @param key The key to verify.
 */
+ (BOOL)keyIsValidForAlgorithm:(NSData *)key;

@end

@interface NSData (BCProtectedData)

/*!
 @brief Gets the current data protected with the inputted key.

 @discussion This will protect NSData in memory by AES256 encrypting it using
 the inputted memory key, for this to have any effect you MUST generate a strong
 memory key, and keep that key protected.

 You SHOULD never directly use a user inputted password as a key unless passed
 through a key derivation algorithm first. You should consider using Scrypt
 (Preferred), or PBKDF2 as you key derivation methods.

 @param key The key used to protect the data.
 */
- (BCProtectedData *)protectedWithKey:(NSData *)key;

@end
