//
//  BCTransaction.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/7/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCAddress.h"
#import "BCScript.h"

/*!
 @brief Immutable Transaction object.
 */
@interface BCTransaction : NSObject
#pragma mark Construction
/*!
 @brief Constructs the transaction object with the inputted metadata.

 @param addresses     The addresses for the transaction.
 @param script        The transactions script.
 @param hash          The hash of the transaction object.
 @param value         The value of the transaction.
 @param confirmations The number of confirmations of the transaction.
 @param isSigned      States if the transaction has been signed.
 */
- (instancetype)initWithAddresses:(NSArray *)addresses
                           script:(BCScript *)script
                             hash:(NSData *)hash
                      outputIndex:(uint32_t)outputIndex
                            value:(uint64_t)value
                    confirmations:(NSNumber *)confirmations
                        andSigned:(BOOL)isSigned;

#pragma mark Metadata
/*!
 @brief The addresses for the transaction.
 */
@property(strong, nonatomic, readonly) NSArray *addresses;

/*!
 @brief The transactions script data.
 */
@property(strong, nonatomic, readonly) BCScript *script;

/*!
 @brief The transactions hash.
 */
@property(strong, nonatomic, readonly) NSData *hash;

@property(assign, nonatomic, readonly) uint32_t outputIndex;

/*!
 @brief The value of the transaction.
 */
@property(assign, nonatomic, readonly) uint64_t value;

/*!
 @brief The number of confirmations the transaction has.

 @discussion This is an optional value, it may return NULL.
 */
@property(strong, nonatomic, readonly) NSNumber *confirmations;

/*!
 @brief States if the transaction has been signed.
 */
@property(assign, nonatomic, readonly) BOOL isSigned;

@end
