//
//  BCWallet.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
// IDEA: Risk mitigation by separating funds into different accounts in HD while
// cacheing account roots, and only access/generate when necessary.
//
// This interface is designed to reduce interaction with security mechanisms, so
// that developers unfamiliar security principles can still use the wallet with
// some sense of security. Because these operations tend to be long running >1ms
// all of these interfaces will dispatch to the wallets queue, and call back
// on the main queue using the callback.
//
// Synchronous interfaces are available in _BCWallet.h these interfaces should
// be dispatched on the wallets queue.

#import <Breadcrumb/Breadcrumb.h>

/*!
 @brief Simple interface into basic bitcoin wallet functions through different
 providers.
 */
@interface BCWallet : BCAWallet
#pragma mark Construction
/*!
 @brief Constructs a new wallet by generating a mnemonic phrase, and using it
 as the seed for the wallets' root.

 @param password The password data to protect the wallets private info with.
 */
- (instancetype)initNewWithPassword:(NSData *)password;

/*!
 @brief Constructs a new wallet using the inputed phrase, and password data.

 @param phrase   The mnemonic phrase to use when generating the wallet.
 @param password The password data to be used in generation.
 */
- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                            andPassword:(NSData *)password;

#pragma mark Info Retrieval
/*!
 @brief Gets the mnemonic phrase used to generate the root wallet key, this
 should be given to the user so they can recover their wallet.

 @discussion This value MUST be secured; if stolen you can generate the users
 root private key, and spend all of the users bitcoin.

 @param password The password used in the generation of the wallet.
 @param callback The callback to call with the mnemonic phrase, if value is null
 it is safe to assume incorrect password.
 */
- (void)mnemonicPhraseWithPassword:(NSData *)password
                     usingCallback:(void (^)(NSString *))callback;

/*!
 @brief This gets the key sequence, and gives you the memory key to access the
 sub keys private keys.

 @param password The password used to secure the wallet.
 @param callback The callback which
 */
- (void)keySequenceWithPassword:(NSData *)password
                  usingCallback:(void (^)(BCKeySequence *sequence,
                                          NSData *memoryKey))callback;

#pragma mark Addresses

#pragma mark Delegate Classes
/*!
 @brief The class to be used as the provider object.

 @discussion You should be able to simply override this with your own class, and
 use that as your new provider.
 */
+ (Class)defaultProvider;

@end
