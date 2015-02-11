//
//  BCTransactionOutput.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
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

- (instancetype)initWithScript:(BCScript *)script andValue:(NSNumber *)value;

+ (instancetype)outputWithData:(NSData *)data;

+ (instancetype)outputWithScript:(BCScript *)script andValue:(NSNumber *)value;

+ (instancetype)standardOutputForAmount:(NSNumber *)amount
                              toAddress:(BCAddress *)address;

#pragma mark Metadata
/*!
 @brief The amount the output is for.
 */
@property(strong, nonatomic, readonly) NSNumber *value;

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
