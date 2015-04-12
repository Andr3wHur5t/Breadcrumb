//
//  BCAddressManager.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/19/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import <Foundation/Foundation.h>
#import "BCKeySequence.h"
#import "BCAMMasterKey.h"
#import "BCCoin.h"

/*!
 @brief This manages a wallets addresses.

 @discussion This Oversees what addresses should be used, and thus what keys in
 the key sequence should be used for signing transactions.

 According to the current configuration of the manager.
 */
@interface BCAddressManager : NSObject
#pragma mark Construction

/*!
 @brief Constructs a address manager with the given configuration.

 @param wallet   The wallet to manage addresses for.
 @param coinType The coin type defining wallet info for.
 @param preferred The preferred key path.
 @param mode     The mode of the wallet.
 */
- (instancetype)initWithKeySequence:(BCKeySequence *)keys
                           coinType:(BCCoin *)coinType
                      preferredPath:(BCKeySequenceType)preferred
                       andMemoryKey:(NSData *)memoryKey;

#pragma mark Configuration
/*!
 @brief The keys the wallet manages
 */
@property(weak, nonatomic, readonly) BCKeySequence *keySequence;

/*!
 @brief The coin the addresses are for.

 @discussion This is my method of supporting different 'environments' such as
 TestNet3, MainNet, and other alt-currencies which are close enough to bitcoin
 that they still work with this wallet.
 */
@property(strong, nonatomic, readonly) BCCoin *coin;

/*!
 @brief The preferred sequence type of the address manager.
 */
@property(assign, nonatomic, readonly) BCKeySequenceType preferredSequenceType;

#pragma mark Address Retrieval

/*!
 @brief This is the last known unused external address retrieved. May need to be
 synchronized.

 @discussion This is the last retrieved unused external chain address.

 External addresses are used for receiving money from other parties, they
 shouldn't be used as change addresses.
 */
@property(strong, nonatomic, readonly) BCAddress *firstUnusedExternal;

/*!
 @brief This is the last know unused internal(change) address retrieved. May
need
to be synchronized.

 @discussion This is the last retrieved unused internal chain address.

 Internal addresses are used for change addresses in transactions, they
shouldn't be given to third parties.

 */
@property(strong, nonatomic, readonly) BCAddress *firstUnusedInternal;

#pragma mark Master Keys

// This system actually works with multiple sequences, and it will slowly
// migrate your money into the preferred sequence.
@property(strong, nonatomic, readonly) BCAMMasterKey *bip44Internal;
@property(strong, nonatomic, readonly) BCAMMasterKey *bip44External;

@property(strong, nonatomic, readonly) BCAMMasterKey *bip32Internal;
@property(strong, nonatomic, readonly) BCAMMasterKey *bip32External;

#pragma mark Key Pair retrieval.

/*!
 @brief This gets the key pair for the specified address if any in the
 key sequence..

 @param address The address to get the key pair for.
 */
- (BCKeyPair *)keyPairForAddress:(BCAddress *)address
                  usingMemoryKey:(NSData *)memoryKey;

- (NSArray *)keyPairsForScript:(BCScript *)script
                usingMemoryKey:(NSData *)memoryKey;


#pragma mark Checks
/*!
 @brief Checks if the inputted address is in the cache.
 
 @param address The address to check for.
 */
- (BOOL)hasAddressInCache:(BCAddress *)address;

@end
