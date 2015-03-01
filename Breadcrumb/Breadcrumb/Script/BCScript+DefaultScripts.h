//
//  BCScript+DefaultScripts.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
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
