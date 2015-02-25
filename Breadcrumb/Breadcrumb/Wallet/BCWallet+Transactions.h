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

static const uint64_t kBCStandardFeePerKB = 20000;

@interface BCWallet (Transactions)

/*!
 @brief Sends the inputted amount to the address, and invokes the callback with
 any errors.

 @param amount  The amount to send in satoshi.
 @param address  The address to send the amount to.
 @param callback The callback to call when the operation completes or fails
 */
- (void)send:(uint64_t)amount
               to:(BCAddress *)address
         feePerKB:(uint64_t)feePerKB
    usingPassword:(NSData *)password
     withCallback:(void (^)(NSData *, NSError *))callback;

/*!
 @brief Sends the inputted amount to the address, and invokes the callback with
 any errors.

 @param amount  The amount to send in satoshi.
 @param address  The address to send the amount to.
 @param callback The callback to call when the operation completes or fails
 */
- (void)send:(uint64_t)amount
               to:(BCAddress *)address
    usingPassword:(NSData *)password
     withCallback:(void (^)(NSData *, NSError *))callback;

/*!
 @brief Sends the inputted amount to the address, and invokes the callback with
 any errors.

 @param amount  The amount to send in satoshi.
 @param address  The address to send the amount to.
 */
- (void)send:(uint64_t)amount
               to:(BCAddress *)address
    usingPassword:(NSData *)password;

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
