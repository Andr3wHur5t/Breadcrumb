//
//  BCKeySequence.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCKeySequence.h"
#import "NSData+Hash.h"

#define BIP44_PURPOSE 0x8000002C
#define BIP32_PRIME 0x80000000
#define BIP32_SEED_KEY "Bitcoin seed"

@implementation BCKeySequence

@synthesize rootSeed = _rootSeed;
@synthesize masterKeyPair = _masterKeyPair;

#pragma mark Construction

- (instancetype)initWithRootSeed:(NSData *)rootSeed
                    andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([rootSeed isKindOfClass:[NSData class]]);
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);
    if (![rootSeed isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]])
      return NULL;
    self = [super init];
    if (self) {
      _rootSeed = [rootSeed protectedWithKey:memoryKey];
      if (![_rootSeed isKindOfClass:[BCProtectedData class]]) {
        rootSeed = NULL;
        memoryKey = NULL;
        return NULL;
      }

      _masterKeyPair =
          [[self class] masterKeyFromSeed:rootSeed andMemoryKey:memoryKey];
      rootSeed = NULL;
      memoryKey = NULL;

      if (![_masterKeyPair isKindOfClass:[BCKeyPair class]]) return NULL;
    }
    return self;
  }
}

- (BCKeyPair *)keyPairForCoin:(uint32_t)coin
                      account:(uint32_t)accountId
                     external:(BOOL)external
                        index:(uint32_t)index
                withMemoryKey:(NSData *)memoryKey {
  // m / purpose' / coin_type' / account' / change / address_index
  BCKeyPair *keyPair;

  // Purpose
  keyPair =
      [self.masterKeyPair childKeyPairAt:BIP44_PURPOSE withMemoryKey:memoryKey];

  // Coin Type
  keyPair = [keyPair childKeyPairAt:coin withMemoryKey:memoryKey];

  // Account Id (Hardened)
  keyPair =
      [keyPair childKeyPairAt:BIP32_PRIME + accountId withMemoryKey:memoryKey];

  // change
  keyPair = [keyPair childKeyPairAt:external ? 0 : 1 withMemoryKey:memoryKey];

  // Index
  keyPair = [keyPair childKeyPairAt:index withMemoryKey:memoryKey];

  return keyPair;
}

- (BCKeyPair *)keyPair32ForAccount:(uint32_t)accountId
                          external:(BOOL)external
                             index:(uint32_t)index
                     withMemoryKey:(NSData *)memoryKey {
  // m / acc' / change / address_index
  BCKeyPair *keyPair;

  // Account
  keyPair = [self.masterKeyPair childKeyPairAt:BIP32_PRIME + accountId
                                 withMemoryKey:memoryKey];

  // change
  keyPair = [keyPair childKeyPairAt:external ? 0 : 1 withMemoryKey:memoryKey];

  // Index
  keyPair = [keyPair childKeyPairAt:index withMemoryKey:memoryKey];

  return keyPair;
}

#pragma mark Utilties

+ (BCKeyPair *)masterKeyFromSeed:(NSData *)rootSeed
                    andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    // The generation process of the master private key is slitly diffrent from
    // generation of other child keys
    NSData *rootHMAC, *rootSecret, *rootChainCode;

    // HMAC the seed with the seeds key.
    rootHMAC = [rootSeed SHA512HmacWithKey:[self seedKeyData]];

    // The Root Secret is the left half of SHA512 (32 bytes)
    rootSecret = [rootHMAC subdataWithRange:NSMakeRange(0, 32)];

    // Thr Root Chain Code is the right side of SHA512 (32 bytes)
    rootChainCode = [rootHMAC subdataWithRange:NSMakeRange(32, 32)];

    return [[BCKeyPair alloc] initWithPrivateKey:rootSecret
                                       chainCode:rootChainCode
                                    andMemoryKey:memoryKey];
  }
}

+ (NSData *)seedKeyData {
  static dispatch_once_t onceToken;
  static NSData *keyData;
  dispatch_once(&onceToken, ^{
      keyData =
          [NSData dataWithBytes:BIP32_SEED_KEY length:strlen(BIP32_SEED_KEY)];
  });
  return keyData;
}
@end
