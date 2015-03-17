//
//  BCScript.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import <Foundation/Foundation.h>
#import "BCScriptOpCodes.h"
#import "BCAddress.h"

/*!
 @brief Script types
 */
typedef enum : NSUInteger {
                 /*!
                  @brief Pay to public key hash (bitcoin address).

                  @discussion OP_DUP OP_HASH160 <20 bytes of public key hash>
                  OP_EQUALVERIFY OP_CHECKSIG
                  */
                 BCScriptType_P2PKH = 0,

                 /*!
                  @brief Pay to script hash.

                  @discussion OP_HASH160 <20 bytes of script hash> OP_EQUAL
                  */
                 BCScriptType_P2SH,

                 /*!
                  @brief Pay to public key.

                  @discussion <33 or 65 bytes of public key> OP_CHECKSIG
                  */
                 BCScriptType_P2PK,

                 /*!
                  @brief Multi signiture.

                  @discussion OP_<m> [n <public key>s] OP_<n> OP_CHECKMULTISIG
                  */
                 BCScriptType_MofN,

                 /*!
                  @brief Op return script to push arbitrary data to the block
                  chain. (Unspendable)

                  @discussion OP_RETURN <message>
                  */
                 BCScriptType_OPReturn,

                 /*!
                  @brief A non standard transaction. (Unspendable)
                  */
                 BCScriptType_NonStandard
               } BCScriptType;

/*!
 @brief A immutable bitcoin script.

 @discussion This is best used to store bitcoin scripts.
 */
@interface BCScript : NSObject
#pragma mark Construction
/*!
 @brief Makes a script with the inputted data.

 @param data The script data to construct with
 */
- (instancetype)initWithData:(NSData *)data;

/*!
 @brief Makes a script with the inputted data.

 @param data The script data to construct with
 */
+ (instancetype)scriptWithData:(NSData *)data;

/*!
 @brief Makes a script.
 */
+ (instancetype)script;

#pragma mark Representations
/*!
 @brief Gets the bytes representing the script.

 @return The NSData managed bytes.
 */
- (NSData *)toData;

/*!
 @brief Gets the string representation of the script.

 @return The string representation.
 */
- (NSString *)toString;

@property(assign, nonatomic, readonly) BCScriptType type;

@property(strong, nonatomic, readonly) NSArray *elements;


- (BCAddress *)P2SHAddressForCoin:(BCCoin *)coin;

@end

/*!
 @brief A mutable bitcoin script.

 @discussion This is best used for writing bitcoin scripts.
 */
@interface BCMutableScript : BCScript
#pragma mark Mutation
/*!
 @brief Writes the inputted op code to the buffer.

 @param opCode The opcode to write to the buffer.
 */
- (void)writeOpCode:(BCScriptOpCode)opCode;

/*!
 @brief Writes the bytes the data represents.

 @param bytes The bytes to write.
 */
- (void)writeBytes:(NSData *)bytes;

@end
