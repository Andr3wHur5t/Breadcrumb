//
//  _BCWallet.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet.h"
#import "BCProviderChain.h"
#import "BCProtectedData.h"
#import "BCKeySequence.h"

#import "BCWallet+Transactions.h"
#import "BCWallet+TransactionSigning.h"
#import "BCWallet+Restoration.h"

#import "BreadcrumbCore.h"

// Queue Label
static const char *kBCWalletQueueLabel = "com.Breadcrumb.wallet";

// Restoration Keys
static NSString *const kBCRestoration_Seed = @"seed";
static NSString *const kBCRestoration_Mnemonic = @"mnemonic";

@interface BCWallet () {
  // Because the information in the wallet is protected using a scrypt derived
  // key we need to have a background queue so we don't block the main queue. We
  // also want user operations execute in order
  dispatch_queue_t __queue;
}

#pragma mark Protected Data
/*!
 @brief The protected data of the mnemonic phrase.

 @discussion This is protected with AES256 using a scrypt key derived from the
 entered passphrase, its' cypher text is managed by the protected data object.
 The data retrieved from the protected data manager has a secure allocator,
 reallocator, and deallocator.
 */
@property(strong, nonatomic, readonly) BCProtectedData *protectedMnemonic;

#pragma mark Keys
/*!
 @brief This manages HD key pairs, and their children.

 @discussion This maintains the lifecycle of the master key pair, and its
 children.
 */
@property(strong, nonatomic, readonly) BCKeySequence *keys;

#pragma mark Queue
/*!
 @brief The queue which wallet operations are performed.
 */
@property(nonatomic, readonly) dispatch_queue_t queue;

@end
