//
//  BCMutableTransaction.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
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

 @discussion This optimizes transaction will target the smallest UTXOs first to
 attempt to reduce the number of UTXO.

 @param utxos         Unsigned transactions to use as inputs.
 @param amount        The amount the transaction is for.
 @param address       The address the transaction will send the amount to.

 @return The built unsigned transaction.
 */
+ (instancetype)buildTransactionWith:(NSArray *)utxos
                           forAmount:(NSNumber *)amount
                                  to:(BCAddress *)address
                             feePerK:(NSNumber *)feePerK
                   withChangeAddress:(BCAddress *)changeAddress;

@end
