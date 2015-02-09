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
 @param spent         The amount spent of the transaction.
 @param confirmations The number of confirmations of the transaction.
 @param isSigned      States if the transaction has been signed.
 */
- (instancetype)initWithAddresses:(NSArray *)addresses
                           script:(BCScript *)script
                             hash:(NSString *)hash
                            value:(NSNumber *)value
                            spent:(NSNumber *)spent
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
@property(strong, nonatomic, readonly) NSString *hash;

/*!
 @brief The value of the transaction.
 */
@property(strong, nonatomic, readonly) NSNumber *value;

/*!
 @brief The amount of this transaction has been spent.
 */
@property(strong, nonatomic, readonly) NSNumber *spent;

/*!
 @brief The number of confirmations the transaction has.

 @discussion This is an optional value, it may return NULL.
 */
@property(strong, nonatomic, readonly) NSNumber *confirmations;

/*!
 @brief States if the transaction has been signed.
 */
@property(assign, nonatomic, readonly) BOOL isSigned;

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
