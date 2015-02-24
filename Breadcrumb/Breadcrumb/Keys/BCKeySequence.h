//
//  BCKeySequence.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
// Explanation:
// m = Master key that is derived from the root/seed
// # = is the index of the key
// #' = the index of the hardened key aka 0x80000000 | #
// The / is equivalent to derived from
//
// Example 1)
// Sequence: m/0'/0/0/0'
// Meaning: [[[master childAt: 0x80000000 | 0]
//                    childAt: 0]
//                    childAt: 0]
//                    childAt: 0x80000000 | 0];
//
// 0x80000000 is the hardened index.

#import "BCKeyPair.h"
#import "BCProtectedData.h"

// All Keys derived past this index are considered to be hardened.
#define BIP32_PRIME 0x80000000

// Valid Chars for path
static NSString *const kBCKeySequenceValidChars = @"m/'h1234567890";
static NSString *const kBCKeySequenceMasterChar = @"m";
static NSString *const kBCKeySequenceDelimiterChar = @"/";
static NSString *const kBCKeySequenceNumericalChars = @"1234567890";
static NSString *const kBCKeySequenceHardenedFlagChars = @"'h";

/*!
 @brief Defines how a key hierarchy is structured.
 */
typedef enum
    : NSUInteger {
        /*!
         @brief The BIP32 standard. Example: m/0'/0/0

         @discussion you should try to migrate away from this, and use a newer
         standard.

         Description: m/account'/isExternal/index
         */
        BCKeySequenceType_BIP32 = 0,
        /*!
         @brief The BIP44 path standard. Example: m/44'/0'/0'/0/0

         @discussion This is an extension of BIP32 with better definition on how
         paths should work, you should use this instead of BIP32.

         Description: m/44'/coin'/account'/isExternal/index
         */
        BCKeySequenceType_BIP44 = 1,
      } BCKeySequenceType;

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
 @brief Gets the key pair with the array of indexes.

 @param components The array of indexes to get the key pair for.
 @param memoryKey  The memory key to use in protecting the key pairs private
 key.
 */
- (BCKeyPair *)keyPairForComponents:(NSArray *)components
                       andMemoryKey:(NSData *)memoryKey;

/*!
 @brief Gets the key pair at the specified bip32 path

 @param path      The bip32 path to get the key pair for.
 @param memoryKey The memory key to protect the key pairs private key.
 */
- (BCKeyPair *)keyPairForPath:(NSString *)path andMemoryKey:(NSData *)memoryKey;

#pragma mark Utilities
/*!
 @brief Extracts the components from inputted key path, as defined in BIP 32.

 @param The array of components needed to derive the specified key from a master
 key pair.
 */
+ (NSArray *)componentsFromPath:(NSString *)path;

@end
