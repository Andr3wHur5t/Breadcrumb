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

- (instancetype)initWithData:(NSData *)data
                    atOffset:(NSUInteger)offset
                  withLength:(NSUInteger *)length;

- (instancetype)initWithTransaction:(BCTransaction *)transaction;

- (instancetype)initWithHash:(NSData *)hash
               previousIndex:(uint32_t)index
                      script:(BCScript *)script
                     address:(BCAddress *)address
                 andSequence:(uint32_t)sequence;

#pragma mark Meta Data

/*!
 @brief This is the address which must sign the transaction.

 @discussion This is the address which has ownership for the transaction. In the
 future when we support multi signature this will need to be an array of
 addresses.

 NOTE: this can be null, because it can not be directly retrieved from parsing a
 raw transaction input.
 */
@property(strong, nonatomic, readonly) BCAddress *controllingAddress;

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
