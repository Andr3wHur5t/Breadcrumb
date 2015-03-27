//
//  BCTransactionOutput.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import <Foundation/Foundation.h>
#import "BCAddress.h"
#import "BCScript.h"

@interface BCTransactionOutput : NSObject

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithData:(NSData *)data
                    atOffset:(NSUInteger)offset
                  withLength:(NSUInteger *)length;

- (instancetype)initWithScript:(BCScript *)script andValue:(uint64_t)value;

+ (instancetype)outputWithData:(NSData *)data;

+ (instancetype)outputWithScript:(BCScript *)script andValue:(uint64_t)value;

+ (instancetype)standardOutputForAmount:(uint64_t)amount
                              toAddress:(BCAddress *)address
                                forCoin:(BCCoin *)coin;

#pragma mark Metadata
/*!
 @brief The amount the output is for.
 */
@property(assign, nonatomic, readonly) uint64_t value;

/*!
 @brief The transactions script.
 */
@property(strong, nonatomic, readonly) BCScript *script;

#pragma mark Fee Calculation

- (NSUInteger)size;

#pragma mark Representations

/*!
 @brief Gets a human readable string representation the transaction output.
 */
- (NSString *)toString;

/*!
 @brief Converts the transaction output to its data representation.
 */
- (NSData *)toData;

@end
