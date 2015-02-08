//
//  BCScript.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCScriptOpCodes.h"

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
