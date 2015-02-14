//
//  NSString+Base58.h
//  Breadcrumb
//
//  Adapted by Andrew Hurst on 2/13/15.
//
//  Created by Aaron Voisine on 5/13/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#define BITCOIN_PUBKEY_ADDRESS 0
#define BITCOIN_SCRIPT_ADDRESS 5
#define BITCOIN_PUBKEY_ADDRESS_TEST 111
#define BITCOIN_SCRIPT_ADDRESS_TEST 196
#define BITCOIN_PRIVKEY 128
#define BITCOIN_PRIVKEY_TEST 239

@interface NSString (BCBase58)
#pragma mark Encoding
/*!
 @brief Encodes the inputted data into raw base 58 format

 @param data The data to encode into raw base 58
 */
+ (NSString *)base58WithData:(NSData *)data;

/*!
 @brief Encodes the inputted data into base58 check format.

 @param data The data to encode into base58 check format.
 */
+ (NSString *)base58checkWithData:(NSData *)data;

/*!
 @brief Encodes a hex string into a bas358 check string.
 */
- (NSString *)hexToBase58check;

/*!
 @brief Encodes the inputted data into a hex string.

 @param data The data to encode into a hex string
 */
+ (NSString *)hexWithData:(NSData *)data;

/*!
 @brief Encodes hex into a raw base58 string.
 */
- (NSString *)hexToBase58;

#pragma mark Decoding
/*!
 @brief Decodes a raw base58 encoded string into data.
 */
- (NSData *)base58ToData;

/*!
 @brief Decodes a base58 check encoded string into data.
 */
- (NSData *)base58checkToData;

/*!
 @brief Decodes a base 58 check string into a hex string.
 */
- (NSString *)base58checkToHex;

/*!
 @brief Decodes base58 to hex.
 */
- (NSString *)base58ToHex;

/*!
 @brief Decodes a hex string into data.
 */
- (NSData *)hexToData;

- (NSData *)addressToHash160;

#pragma mark Validity Checks

/*!
 @brief Checks if the string is a valid bitcoin address
 */
//- (BOOL)isValidBitcoinAddress;

/*!
 @brief Checks if the string is a valid private key.
 */
//- (BOOL)isValidBitcoinPrivateKey;

/*!
 @brief Checks if the key is a valid BIP38 key.

 @discussion BIP38 encrypted keys:
 https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki
 */
//- (BOOL)isValidBitcoinBIP38Key;

@end

@interface NSData (BCBase58)

- (NSString *)base58Encoding;
+ (NSData *)fromBase58:(NSString *)base58Encoding;
- (NSString *)base58CheckEncoding;
+ (NSData *)fromBase58Check:(NSString *)base58CheckEncoding;
- (NSString *)toHex;
+ (NSData *)fromHex:(NSString *)hex;
@end
