//
//  BCAmount.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (BCAmount)

/*!
 @brief Gets a copy of the current number as an amount in Satoshi.
 */
- (NSNumber *)toSatoshi;

/*!
 @brief Gets a copy of the current number as an amount in Bits.
 */
- (NSNumber *)toBits;

/*!
 @brief Gets a copy of the current number as an amount in Bitcoin.
 */
- (NSNumber *)toBitcoin;

@end