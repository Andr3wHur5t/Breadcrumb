//
//  BCKeySequence.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCKeySequence.h"
#import "NSData+Hash.h"

@implementation BCKeySequence

@synthesize rootSeed = _rootSeed;
@synthesize masterKeyPair = _masterKeyPair;

#pragma mark Construction

- (instancetype)initWithRootSeed:(NSData *)rootSeed
                    andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    BCProtectedData *protectedSeed;
    NSData *masterPrivate, *masterChainCode, *seedHash;
    NSParameterAssert([rootSeed isKindOfClass:[NSData class]]);
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);
    if (![rootSeed isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]])
      return NULL;

    // Secure the root seed
    protectedSeed = [rootSeed protectedWithKey:memoryKey];
    if (![protectedSeed isKindOfClass:[BCProtectedData class]]) {
      rootSeed = NULL;
      memoryKey = NULL;
      return NULL;
    }

    // Get The hash of the seed
    seedHash = [rootSeed SHA512];
    rootSeed = NULL;
    if (![seedHash isKindOfClass:[NSData class]]) {
      memoryKey = NULL;
      return NULL;
    }

    // Retrieve the master private key from the hash seed key.
    masterPrivate = [seedHash subdataWithRange:NSMakeRange(0, 32)];
    if (![masterPrivate isKindOfClass:[NSData class]]) {
      seedHash = NULL;
      memoryKey = NULL;
      return NULL;
    }

    // Retrieve the master chain key from the hash of seed key.
    masterChainCode = [seedHash subdataWithRange:NSMakeRange(32, 32)];
    seedHash = NULL;
    if (![masterChainCode isKindOfClass:[NSData class]]) {
      masterPrivate = NULL;
      memoryKey = NULL;
      return NULL;
    }

    self = [super init];
    if (self) {
      _masterKeyPair = [[BCKeyPair alloc] initWithPrivateKey:masterPrivate
                                                   chainCode:masterChainCode
                                                andMemoryKey:memoryKey];
    }
    return self;
  }
}
@end
