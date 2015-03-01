//
//  BCWallet.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//
// This interface is designed to reduce interaction with security mechanisms, so
// that developers unfamiliar security principles can still use the wallet with
// some sense of security. Because these operations tend to be long running >1ms
// all of these interfaces will dispatch to the wallets queue, and call back
// on the main queue using the callback.
//
// Synchronous interfaces are available in _BCWallet.h these interfaces should
// be dispatched on the wallets queue.

#import <Foundation/Foundation.h>
#import "BCAProvider.h"
#import "BCCoin.h"
#import "BCAddress.h"

/*!
 @brief Simple interface into basic bitcoin wallet functions through different
 providers.
 */
@interface BCWallet : NSObject
#pragma mark Construction

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param password The password to protect the wallets secrets with.
 @param provider The provider which will comunicate with the network.
 */
- (instancetype)initNewWithPassword:(NSData *)password
                        andProvider:(BCAProvider *)provider;

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param password The password to protect the wallets secrets with.
 @param coin          The coin the wallet is for.
 */
- (instancetype)initNewWithPassword:(NSData *)password andCoin:(BCCoin *)coin;

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param password      The password to protect the wallets secrets with.
 @param coin          The coin the wallet is for.
 @param provider      The provider which will comunicate with the network.
 @param sequenceType  The HD sequence the wallet should conform to.
 @param callback      The callback the wallet should call when it finishes
 generating.
 */
- (instancetype)initNewWithPassword:(NSData *)password
                               coin:(BCCoin *)coin
                        andCallback:(void (^)(NSError *))callback;

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param password      The password to protect the wallets secrets with.
 @param coin          The coin the wallet is for.
 @param provider      The provider which will comunicate with the network.
 @param sequenceType  The HD sequence the wallet should conform to.
 @param callback      The callback the wallet should call when it finishes
 generating.
 */
- (instancetype)initNewWithPassword:(NSData *)password
                               coin:(BCCoin *)coin
                           provider:(BCAProvider *)provider
                       sequenceType:(BCKeySequenceType)sequenceType
                        andCallback:(void (^)(NSError *))callback;

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param phrase        The mnemonic phrase that the wallet should generate its'
 seed with.
 @param password      The password to protect the wallets secrets with.
 @param provider      The provider which will comunicate with the network.
 @param callback      The callback the wallet should call when it finishes
 generating.
 */
- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                               provider:(BCAProvider *)provider
                               password:(NSData *)password
                            andCallback:(void (^)(NSError *))callback;

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param phrase        The mnemonic phrase that the wallet should generate its'
 seed with.
 @param password      The password to protect the wallets secrets with.
  @param coin          The coin the wallet is for.
 @param callback      The callback the wallet should call when it finishes
 generating.
 */
- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                               password:(NSData *)password
                                   coin:(BCCoin *)coin
                            andCallback:(void (^)(NSError *))callback;

/*!
 @brief Constructs a wallet with a new mnemonic phrase using the provided
 password to protect the wallet in memory, and the provider to comunicate with
 the bitcoin network.

 @param phrase        The mnemonic phrase that the wallet should generate its'
 seed with.
 @param coin          The coin the wallet is for.
 @param password      The password to protect the wallets secrets with.
 @param provider      The provider which will comunicate with the network.
 @param sequenceType  The HD sequence the wallet should conform to.
 @param callback      The callback the wallet should call when it finishes
 generating.
 */
- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                                   coin:(BCCoin *)coin
                               provider:(BCAProvider *)provider
                           sequenceType:(BCKeySequenceType)sequenceType
                               password:(NSData *)password
                            andCallback:(void (^)(NSError *))callback;

#pragma mark Info
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

/*!
 @brief Synchronizes the wallets state with the network/server via the provider.
 */
- (void)synchronize:(void (^)(NSError *))callback;

/*!
 @brief Gets the current recive address from the address manager.

 @param callback The callback which will be called with the address.
 */
- (void)getCurrentAddress:(void (^)(BCAddress *))callback;

/*!
 @brief  Gets the balance of the wallet from it's provider.

 @param callback The callback to call with the balance, or error.
 */
- (void)getBalance:(void (^)(uint64_t, NSError *))callback;

/*!
 @brief The coin the wallet works with.

 @discussion The coin is simply a configuration object.
 */
@property(weak, nonatomic, readonly) BCCoin *coin;

/*!
 @brief The wallets network interface provider.
 */
@property(strong, nonatomic, readonly) BCAProvider *provider;

@end
