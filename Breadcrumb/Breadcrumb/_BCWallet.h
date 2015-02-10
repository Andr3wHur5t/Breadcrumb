//
//  _BCWallet.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet.h"
#import "BCProviderChain.h"
#import "NSData+Encryption.h"
#import "BCWallet+Transactions.h"
#import "BCWallet+TransactionSigning.h"
#import "BreadcrumbCore.h"



// Queue Label
static const char *kBCWalletQueueLabel = "com.Breadcrumb.wallet";

// Restoration Keys
static NSString *const kBCRestoration_Seed = @"seed";
static NSString *const kBCRestoration_Mnemonic = @"mnemonic";

@interface BCWallet () {
  // Because the information in the wallet is protected using a scrypt derived key we need to have a background queue so we dont block the main queue. We also want user operations execute in order
  dispatch_queue_t __queue;
}

/*!
 @brief The cypher text of the mnemonic key.
 */
@property(strong, nonatomic, readonly) NSData *mnemonicCypherText;

/*!
 @brief The cypher text of the seed.
 */
@property(strong, nonatomic, readonly) NSData *seedCypherText;

#pragma mark HD
/*!
 @brief The master public key of the BIP32 hierarchal wallet.
 */
@property(strong, nonatomic, readonly) NSData *masterPublicKey;

/*!
 @brief The BIP32 sequence utility object.

 @discussion I see no reason for this to be in a instance object, I will change
 its' methods into class methods.
 */
@property(strong, nonatomic, readonly) BRBIP32Sequence *keySequence;

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

#pragma mark Queue

/*!
 @brief The queue which wallet operations are performed.
 */
@property(nonatomic, readonly) dispatch_queue_t queue;


@end
