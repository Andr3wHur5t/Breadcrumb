//
//  BCAWallet.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCAAddress.h"
#import "BCAmount.h"

/*!
 @brief An abstract interface to a breadcrumb wallet.
 */
@interface BCAWallet : NSObject
#pragma mark Construction
/*!
 @brief Constructs a new wallet.

 @discussion This should only be used when constructing a new wallet.

 @return The newly generated wallet.
 */
- (instancetype)initNew;

#pragma mark Wallet Info
/*!
 @brief The current known balance of the wallet.
 */
@property(weak, nonatomic, readonly) BCAmount *balance;

/*!
 @brief The current address of the wallet.
 */
@property(weak, nonatomic, readonly) BCAAddress *currentAddress;

#pragma mark Transactions
/*!
 @brief Sends the inputted amount to the address, and invokes the callback with
 any errors.

 @param amount  The amount to send.
 @param address  The address to send the amount to.
 @param callback The callback to call when the operation completes or fails
 */
- (void)send:(BCAmount *)amount
              to:(BCAAddress *)address
    withCallback:(void (^)(NSError *))callback;

@end
