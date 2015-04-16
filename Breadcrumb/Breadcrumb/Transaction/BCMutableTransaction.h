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

static const uint64_t kBCStandardFee = 10000;
static const uint64_t kBCDefaultDustThreshold = 2100;  // 21 bits ;)

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
 @brief The value of all inputs in the transaction
 */
@property(nonatomic, readonly) uint64_t value;

/*!
 @brief The fee for this transaction.
 */
@property(nonatomic, readonly) uint64_t fee;

/*!
 @brief Extra data about the transaction

 @discussion This is useful when passing info to the provider object.
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

#pragma mark UTXO Selection

/*!
 @brief This takes a set of UTXOs and sorts them by their score.

 @param utxos      The utxos to score.
 @param scoreBlock The block used to give the score of the transaction.

 @return A sorted array of transactions.
 */
+ (NSArray *)inputsFromUTXOs:(NSArray *)utxos
               andScoreBlock:(uint64_t (^)(BCTransaction *tx,
                                           BOOL isCommitted))scoreBlock;

/*!
 @brief This scores transactions for their usability with other transactions
 passed into this block.

 @param targetAddress The address of the target wallet. (The one you want to
 send btc too)
 */
+ (uint64_t (^)(BCTransaction *tx, BOOL isCommitted))scoreBlockForTargetAddress:
        (BCAddress *)targetAddress;

#pragma mark Output Creation

/*!
 @brief Creates a set standard set of outputs baed on the input values.

 @param inputAmount         The amount available in transaction inputs.
 @param targetOutputAmount  The amount you want to send to the target address.
 @param feeBlock            The block used to calculate the fees.
 @param changeDustTolerance The threshold which stats the smallest change amount
 you will except.
 @param targetAddress       The address you want to send to.
 @param changeAddress       The address you want the change sent to.
 @param coin                The coin the scripts should be built for.

 @return An array of outputs to be used in a transaction.
 */
+ (NSArray *)outputsForInputAmount:(uint64_t)inputAmount
                targetOutputAmount:(uint64_t)targetOutputAmount
                          feeBlock:
                              (uint64_t (^)(NSUInteger outputByteSize))feeBlock
               changeDustTolerance:(uint64_t)changeDustTolerance
                     targetAddress:(BCAddress *)targetAddress
                     changeAddress:(BCAddress *)changeAddress
                           andCoin:(BCCoin *)coin;

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

/*!
 @brief Builds a standard optimized transaction with the given set of
 parameters.

 @param utxos         The unoptimized UTXOs to use.
 @param amount        The amount to send to the target address.
 @param address       The address you want to send to.
 @param dustTolerance The threshold of which you don't want change for.
 @param feeBlock      The block used to calculate the fee.
 @param changeAddress The change address you want sent back to.
 @param error         The error to report the status of transaction building.
 @param coin          The coin used for scripts.

 @return The built unsigned transaction.
 */
+ (BCMutableTransaction *)
    buildTransactionWith:(NSArray *)utxos
               forAmount:(uint64_t)amount
                      to:(BCAddress *)address
           dustTolerance:(uint64_t)dustTolerance
            feeCalcBlock:(uint64_t (^)(NSUInteger inputByteLength,
                                       NSUInteger outputByteLength))feeBlock
           changeAddress:(BCAddress *)changeAddress
               withError:(NSError **)error
                 andCoin:(BCCoin *)coin;

/*!
 @brief Constructs a transaction with the array of inputs and outputs.

 @param inputs  The array of inputs for the transaction
 @param outputs The array of outputs for the transaction.
 */
+ (BCMutableTransaction *)buildTransactionWithInputs:(NSArray *)inputs
                                          andOutputs:(NSArray *)outputs;

#pragma mark Fee Calculation

/*!
 @brief The default fee calculation block.

 @param feePerKb The fee per kilobyte of data to use.
 */
+ (uint64_t (^)(NSUInteger, NSUInteger))defaultFeeBlock:(uint64_t)feePerKb;

@end
