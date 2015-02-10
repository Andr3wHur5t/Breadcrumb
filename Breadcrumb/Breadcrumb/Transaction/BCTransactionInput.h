//
//  BCTransactionInput.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCTransaction.h"

@interface BCTransactionInput : NSObject
#pragma mark Construction
/*!
 @brief Constructs the transaction input with its binary representation, as
 defined by the bitcoin protocol.

 @param data The binary representation to construct with.
 */
- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithTransaction:(BCTransaction *)transaction;

#pragma mark Meta Data
/*!
 @brief The previous outputs hash.
 */
@property(strong, nonatomic, readonly) NSData *previousOutputHash;

/*!
 @brief The previous outputs index.
 */
@property(assign, nonatomic, readonly) uint32_t previousOutputIndex;

/*!
 @brief The script containing the signature.
 */
@property(strong, nonatomic, readonly) BCScript *scriptSig;

/*!
 @brief The sequence value for the input, this is used to update unlocked
 transactions though the network currently doesn't support it.
 */
@property(assign, nonatomic, readonly) uint32_t sequence;

/*!
 @brief States if the transaction has been signed.
 */
@property(assign, nonatomic, readonly) BOOL isSigned;

#pragma mark Fee Calculation

- (NSUInteger)size;

#pragma mark Representations

- (NSString *)toString;

/*!
 @brief This gets the input in its binary representation as defined by the
 bitcoin protocol.
 */
- (NSData *)toData;

@end
