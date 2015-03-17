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

/*!
 @brief Creates a multi-signiture reedem script for the provided inputs

 @param pubkeys       The public keys in order of signing.
 @param minSignitures The mimumum number of signitures.

 @return The mulit-signiture reedeem script.
 */
+ (instancetype)multisigScriptWithPubkeys:(NSArray *)pubkeys
                     andMinumumSignitures:(uint8_t)minSignitures;

#pragma mark Messages
/*!
 @brief Creates an op return script with the specified data.

 @param data The data to put in the op return script.
 */
+ (instancetype)opReturnScriptWithData:(NSData *)data;

@end
