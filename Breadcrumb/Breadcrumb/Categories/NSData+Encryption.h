//
//  NSData+Encryption.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import <Foundation/Foundation.h>

@interface NSData (Encryption)

#pragma mark AES
/*!
 @brief Encrypts the data with AES 256 using the inputted key.

 @param key The key to encrypt the data with.
 */
- (NSData *)AES256Encrypt:(NSData *)key;

/*!
 @brief Decrypts the data with AES 256 using the inputted key.

 @param key The key to decrypt the data with.
 */
- (NSData *)AES256Decrypt:(NSData *)key;

- (NSData *)AES256ETMEncrypt:(NSData *)key;
- (NSData *)AES256ETMDecrypt:(NSData *)key;

#pragma mark Scrypt
/*!
 @brief Scrypts the inputed password with the salt, and the output length.

 @param password The password to to derive from.
 @param salt     The salt to use.
 @param length   The output length.
 */
+ (NSData *)scryptPassword:(NSData *)password
                 usingSalt:(NSData *)salt
          withOutputLength:(NSUInteger)length;

/*!
 @brief Scrypts the inputed password with the inputted algorithm parameters.

 @param password The password to to derive from.
 @param salt     The salt to use.
 @param n        The work factor of the algorithm.
 @param r        The block size of the algorithm.
 @param p        The paralyzation factor of the algorithm.
 @param length   The byte length of the output.
 */
+ (NSData *)scryptPassword:(NSData *)password
                 usingSalt:(NSData *)salt
                workFactor:(uint64_t)n
                 blockSize:(uint32_t)r
     parallelizationFactor:(uint32_t)p
          withOutputLength:(NSUInteger)length;

#pragma mark Sec Random

+ (NSData *)pseudoRandomDataWithLength:(NSUInteger)length;

@end
