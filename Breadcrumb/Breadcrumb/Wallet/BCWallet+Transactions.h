//
//  BCWallet+Transactions.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet.h"
#import "BCTransaction.h"
#import "BCMutableTransaction.h"

@interface BCWallet (Transactions)
/*!
 @brief Creates a transaction for the current wallet at the specified amount to
 the specified address.

 @param amount    The amount to make transaction is for.
 @param feePerKB  The fee to give to the miner per kb of the transaction.
 @param address   The address of the person to send the transaction to.
 @param callback  The callback to call with the unsigned transaction, or an
 operational error.
 */
- (void)_unsignedTransactionForAmount:(uint64_t)amount
                             feePerKB:(uint64_t)feePerKB
                                   to:(BCAddress *)address
                         withCallback:(void (^)(BCMutableTransaction *,
                                                NSError *))callback;
@end
