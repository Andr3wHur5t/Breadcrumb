//
//  BCScript+DefaultScripts.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCScript.h"
#import "BCAddress.h"

@interface BCScript (DefaultScripts)

#pragma mark Transactions
/*!
 @brief Creates a standard transaction script using the inputted address.

 @param address The output address for the transaction.
 */
+ (instancetype)standardTransactionScript:(BCAddress *)address;

#pragma mark Messages

@end
