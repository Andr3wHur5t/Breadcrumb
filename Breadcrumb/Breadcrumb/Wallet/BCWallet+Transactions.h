//
//  BCWallet+Transactions.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet.h"
#import "BCTransaction.h"

@interface BCWallet (Transactions)
/*!
 @brief Gets UTXOs (unspent transaction outputs) for a transaction with the
 specified amount from the wallets provider.

 @param amount    The minimum amount that the sum of UTXO should equal to.
 @param callback  The callback to call with the resulting UTXOs, or operation
 errors.
 */
- (void)UTXOforAmount:(NSNumber *)amount
         withCallback:(void (^)(NSArray *, NSError *))callback;

/*!
 @brief Creates a transaction for the current wallet at the specified amount to
 the specified address.

 @param amount  The amount to make transaction is for.
 @param address The address of the person to send the transaction to.
 @param callback The callback to call with the unsigned transaction, or an
 operational error.
 */
- (void)unsignedTransactionForAmount:(NSNumber *)amount
                                  to:(BCAddress *)address
                        withCallback:
                            (void (^)(BCTransaction *, NSError *))callback;

/*!
 @brief Signs the inputted transaction.

 @param transaction The transaction to sign.

 @return The signed transaction.
 */
- (BCTransaction *)signTransaction:(BCTransaction *)transaction;

/*!
 @brief Publishes the transaction to the wallets provider.

 @param transaction   The transaction to publish.
 @param completion    The completion to call when the operation completes, or
 fails.
 */
- (void)publishTransaction:(BCTransaction *)transaction
            withCompletion:(void (^)(NSError *))completion;

#pragma mark Errors

+ (NSError *)failedToCreateUnsignedTransactionError;
+ (NSError *)failedToRetriveUTXOsError;
@end
