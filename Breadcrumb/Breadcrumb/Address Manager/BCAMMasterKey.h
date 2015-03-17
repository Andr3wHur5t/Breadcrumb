//
//  BCAMMasterKey.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/22/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import <Foundation/Foundation.h>
#import "BCKeyPair.h"

@interface BCAMMasterKey : NSObject
#pragma mark Construction
/*!
 @brief Constructs the master key from the provided key.

 @param key The key to construct with.
 */
- (instancetype)initWithKeyPair:(BCKeyPair *)key andCoin:(BCCoin *)coin;

#pragma mark Metadata
/*!
 @brief This is the key representing the master key.
 */
@property(strong, nonatomic, readonly) BCKeyPair *key;

/*!
 @brief The coin to use in generation
 */
@property(strong, nonatomic, readonly) BCCoin *coin;

/*!
 @brief This stats the index which was last used, setting this value causes
 addresses to be generated.
 */
@property(assign, nonatomic, readwrite) uint16_t lastUsedIndex;

/*!
 @brief These are the addresses related to the key.
 */
@property(strong, nonatomic, readonly) NSMutableArray *addresses;

/*!
 @brief The first unused address.
 */
@property(weak, nonatomic, readonly) BCAddress *firstUnusedAddress;

#pragma mark Retrieval
/*!
 @brief Retrieves the key pair with the associated address if any.

 @param address   The address to get the key for.
 @param memoryKey The memory key to use in protecting the key.
 */
- (BCKeyPair *)keyPairForAddress:(BCAddress *)address
                   withMemoryKey:(NSData *)memoryKey;

- (BCAddress *)addressAtIndex:(uint16_t)index;
- (void)expandAddressToIndex:(uint16_t)index;
@end
