//
//  BCAWallet.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCAProvider.h"
#import "BCAddress.h"
#import "BCAmount.h"

/*!
 @brief An abstract interface to a breadcrumb wallet.
 */
@interface BCAWallet : NSObject

#pragma mark Wallet Info
/*!
 @brief The wallets network interface provider.
 */
@property(strong, nonatomic, readonly) BCAProvider *provider;

/*!
 @brief The current known balance of the wallet.
 */
@property(weak, nonatomic, readonly) NSNumber *balance;

/*!
 @brief The current address of the wallet.
 */
@property(weak, nonatomic, readonly) BCAddress *currentAddress;

#pragma mark Transactions
/*!
 @brief Sends the inputted amount to the address, and invokes the callback with
 any errors.

 @param amount  The amount to send.
 @param address  The address to send the amount to.
 @param callback The callback to call when the operation completes or fails
 */
- (void)send:(NSNumber *)amount
               to:(BCAddress *)address
    usingPassword:(NSData *)password
     withCallback:(void (^)(NSError *))callback;

@end
