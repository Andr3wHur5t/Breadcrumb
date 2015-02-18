//
//  BCKeySequence.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCKeyPair.h"
#import "BCProtectedData.h"

/*!
 @brief  This keeps track of the wallets seed, and master public, and private
 key pairs.
 */
@interface BCKeySequence : NSObject
#pragma mark Construction
/*!
 @brief Constructs the key sequence using the provided seed, and memory key.

 @param rootSeed   The root seed to derive child keys from.
 @param memoryKey The memory key used to secure root seed, and its children.
 */
- (instancetype)initWithRootSeed:(NSData *)rootSeed
                    andMemoryKey:(NSData *)memoryKey;

#pragma mark Keys
/*!
 @brief The root seed of the wallet.
 */
@property(strong, nonatomic, readonly) BCProtectedData *rootSeed;

/*!
 @brief The master key pair derived from the seed.

 @discussion This is the key sequence used to derive child keys.
 */
@property(strong, nonatomic, readonly) BCKeyPair *masterKeyPair;

#pragma mark Child Retrieval

- (BCKeyPair *)keyPair44ForCoin:(uint32_t)coin
                        account:(uint32_t)accountId
                       external:(BOOL)external
                          index:(uint32_t)index
                  withMemoryKey:(NSData *)memoryKey;

- (BCKeyPair *)keyPair32ForAccount:(uint32_t)accountId
                          external:(BOOL)external
                             index:(uint32_t)index
                     withMemoryKey:(NSData *)memoryKey;

#pragma mark Utilities
/*!
 @brief Extracts the components from the given path.

 @param path The path to extract the components from.
 */
+ (NSArray *)componentsFromPath:(NSString *)path;

@end
