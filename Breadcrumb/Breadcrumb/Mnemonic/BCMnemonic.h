//
//  BCMnemonic.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//
//  This really should be an object, I will change this later.

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
+ (NSString *)mnemonicFromEntropy:(NSData *)data;

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

#pragma mark Conversion

/*!
 @brief Derives a seed key from the inputted phrase, and passphrase.

 @param phrase     The BIP39 compliant phrase.
 @param passphrase The passphrase for the sequence (SALT).

 @return The seed key to use.
 */
+ (NSData *)keyFromPhrase:(NSString *)phrase
           withPassphrase:(NSString *)passphrase;

+ (BOOL)wordIsValid:(NSString *)word;

@end
