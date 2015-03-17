//
//  Breadcrumb.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/4/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import <UIKit/UIKit.h>

//! Project version number for Breadcrumb.
FOUNDATION_EXPORT double BreadcrumbVersionNumber;

//! Project version string for Breadcrumb.
FOUNDATION_EXPORT const unsigned char BreadcrumbVersionString[];

// In this header, you should import all the public headers of your framework
// using statements like #import <Breadcrumb/PublicHeader.h>

#pragma mark Utilities
#import <Breadcrumb/BCMnemonic.h>
#import <Breadcrumb/BCProtectedData.h>
#import <Breadcrumb/BCKeyPair.h>
#import <Breadcrumb/BCKeySequence.h>

#pragma mark Scripts
#import <Breadcrumb/BCScript.h>
#import <Breadcrumb/BCScript+DefaultScripts.h>

#pragma mark Concrete Interfaces
#import <Breadcrumb/BCAmount.h>
#import <Breadcrumb/BCAddress.h>

#pragma mark Transaction Interfaces
#import <Breadcrumb/BCTransaction.h>

#pragma mark Wallets
#import <Breadcrumb/BCWallet.h>
#import <Breadcrumb/BCWallet+Transactions.h>


#pragma mark Providers
#import <Breadcrumb/BCAProvider.h>
#import <Breadcrumb/BCProviderChain.h>

#import <Breadcrumb/BreadcrumbCore.h>