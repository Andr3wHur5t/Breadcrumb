//
//  BCWallet+Restoration.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import "BCWallet.h"

@interface BCWallet (Restoration)
#pragma mark Construction
/*!
 @brief Constructs the wallet using the inputted restoration data.

 @param privInfo The wallets private info.
 @param pubInfo  The wallets public info.
 @param password The password data used in the creation of the wallet.
 */
- (instancetype)initUsingPrivateInfo:(NSDictionary *)privInfo
                          publicInfo:(NSDictionary *)pubInfo
                         andPassword:(NSData *)password;

#pragma mark Info
/*!
 @brief Gets the wallets private information in its password protected format to
 be used in restoration.

 @return Dictionary with the wallets private info password protected.
 */
- (NSDictionary *)privateInfo;

/*!
 @brief Public wallet info to be used for restoration.

 @return Public information about the wallet in clear text.
 */
- (NSDictionary *)publicInfo;

@end
