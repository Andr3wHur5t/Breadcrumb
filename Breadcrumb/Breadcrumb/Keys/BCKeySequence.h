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
/*!
 @brief Gets the internal key pair at the specified path.

 @discussion This responds the same as
 - (BCKeyPair *)internalKeyPairWithComponents:(NSArray *)components;

 @param path The path of the key pair in the hd wallet. Example: 44/0/0/1
 */
- (BCKeyPair *)internalKeyPairAtPath:(NSString *)path;

/*!
 @brief Gets the external key pair at the specified path.

 @discussion This responds the same as
 - (BCKeyPair *)internalKeyPairWithComponents:(NSArray *)components;

 @param path The path of the key pair in the hd wallet. Example: 44/0/0/1
 */
- (BCKeyPair *)externalKeyPairAtPath:(NSString *)path;

/*!
 @brief Gets the key pair at the specified component path.

 @discussion Gets the internal key pair to be used for change addresses.

 @param components An array of components. Example: @[@44,@0,@0,@1]
 */
- (BCKeyPair *)internalKeyPairWithComponents:(NSArray *)components;

/*!
 @brief Gets the key pair at the specified component path.

 @discussion Gets an external key pair to be used for receiving.

 @param components An array of components. Example: @[@44,@0,@0,@1]
 */
- (BCKeyPair *)externalKeyPairWithComponents:(NSArray *)components;

#pragma mark Utilities
/*!
 @brief Extracts the components from the given path.

 @param path The path to extract the components from.
 */
+ (NSArray *)componentsFromPath:(NSString *)path;

@end
