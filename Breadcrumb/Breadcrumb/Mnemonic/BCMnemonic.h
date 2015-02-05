//
//  BCMnemonic.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @brief Utility class for mnemonic BIP39 generation, processing, and conversion.

 @discussion https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
 */
@interface BCMnemonic : NSObject
#pragma mark Generation

/*!
 @brief Generates a BIP39 compliant mnemonic using data from a
 cryptographic random number generator.

 @return The resulting random mnemonic.
 */
+ (NSString *)newMnemonic;

/*!
 @brief Generates a BIP39 compliant mnemonic from the inputted data.

 @param data The data to construct the mnemonic from.

 @discussion The seed data should be random, using a cryptographic random number
 generator.

 @return The resulting mnemonic.
 */
+ (NSString *)mnemonicFromSeedData:(NSData *)data;

#pragma mark Processing
/*!
 @brief Sanitizes the inputed mnemonic phrase.

 @param phrase The phrase to sanitize

 @return The sanitized phrase, or NULL if the inputted phrase was invalid.
 */
+ (NSString *)sanitizePhrase:(NSString *)phrase;

/*!
 @brief Decodes the inputted mnemonic phrase into data.

 @param phrase The mnemonic phrase to decode into data.

 @return the decoded value, or NULL if the inputted value is invalid.
 */
+ (NSData *)decodePhrase:(NSString *)phrase;

/*!
 @brief Encodes the inputed data into a mnemonic phrase.

 @param phraseData The data to encode into a phrase, MUST be a multiple of 32
 bits.

 @return The resulting mnemonic phrase, or NULL if the process failed.
 */
+ (NSString *)encodeData:(NSData *)phraseData;

@end
