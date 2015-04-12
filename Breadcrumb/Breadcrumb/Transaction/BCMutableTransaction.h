//
//  BCMutableTransaction.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import <Foundation/Foundation.h>
#import "BCTransactionInput.h"
#import "BCTransactionOutput.h"

@interface BCMutableTransaction : NSObject
#pragma mark Construction
/*!
 @brief Constructs a new mutable transaction.
 */
+ (instancetype)mutableTransaction;

- (instancetype)initWithData:(NSData *)data;

#pragma mark Configuration
/*!
 @brief The input transactions.
 */
@property(strong, nonatomic, readonly) NSMutableArray *inputs;

/*!
 @brief The output transactions.
 */
@property(strong, nonatomic, readonly) NSMutableArray *outputs;

/*!
 @brief The lock time of the transaction
 */
@property(assign, nonatomic, readwrite) uint32_t lockTime;

#pragma mark Metadata

/*!
 @brief Extra data about the transaction

 @discussion This is usefull when passing info to the provider object.
 */
@property(strong, nonatomic, readwrite) id extra;

#pragma mark mutation
/*!
 @brief Adds an input object to the transaction.

 @param input The input to add.
 */
- (void)addInput:(BCTransactionInput *)input;

/*!
 @brief Adds an output object to the transaction.

 @param output The output to add.
 */
- (void)addOutput:(BCTransactionOutput *)output;

#pragma mark Representations

/*!
 @brief Pretty prints the transaction.
 */
- (NSString *)toString;

/*!
 @brief Converts the transaction to its binary representation.
 */
- (NSData *)toData;

#pragma mark Transaction Building

/*!
 @brief Builds a transaction with the inputed UTXOs, amount, and output address.

 @param utxos         Unsigned transactions to use as inputs.
 @param amount        The amount the transaction is for.
 @param address       The address the transaction will send the amount to.
 @param error         Where to put the error message from the transaction
 builder.

 @return The built unsigned transaction.
 */
+ (BCMutableTransaction *)buildTransactionWith:(NSArray *)utxos
                                     forAmount:(uint64_t)amount
                                            to:(BCAddress *)address
                                       feePerK:(uint64_t)feePerK
                                 changeAddress:(BCAddress *)changeAddress
                                     withError:(NSError **)error
                                       andCoin:(BCCoin *)coin;
@end
