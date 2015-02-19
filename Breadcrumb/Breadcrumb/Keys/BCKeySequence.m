//
//  BCKeySequence.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCKeySequence.h"
#import "NSData+Hash.h"

// Keys using this as there purpose value are assumed to conform to BIP 44
#define BIP44_PURPOSE 0x8000002C

// This is an odd value, if i plan on supporting other coins dose this need to
// be
// changed?
#define BIP32_SEED_KEY "Bitcoin seed"

@implementation BCKeySequence

@synthesize rootSeed = _rootSeed;
@synthesize masterKeyPair = _masterKeyPair;

#pragma mark Construction

- (instancetype)initWithRootSeed:(NSData *)rootSeed
                    andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    // Validate Inputs
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

#pragma mark Child Retrieval

- (BCKeyPair *)keyPairForComponents:(NSArray *)components
                       andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    BCKeyPair *currentkeyPair;
    NSParameterAssert([components isKindOfClass:[NSArray class]]);
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);
    if (![components isKindOfClass:[NSArray class]] ||
        ![memoryKey isKindOfClass:[NSData class]]) {
      memoryKey = NULL;
      return NULL;
    }
    // Ensure all objects are numbers
    for (id object in components) {
      if (![object isKindOfClass:[NSNumber class]]) {
        memoryKey = NULL;
        return NULL;
      }
    }

    // Set first key pair to root.
    currentkeyPair = self.masterKeyPair;

    // Get key pair by enumerating indexes of components
    for (NSNumber *componentIndex in components) {
      // Validate Last Key Pair
      if (![currentkeyPair isKindOfClass:[BCKeyPair class]]) {
        memoryKey = NULL;
        return NULL;
      }

      // Get its child key pair.
      currentkeyPair =
          [currentkeyPair childKeyPairAt:(uint32_t)[componentIndex intValue]
                           withMemoryKey:memoryKey];
    }

    memoryKey = NULL;
    return [currentkeyPair isKindOfClass:[BCKeyPair class]] ? currentkeyPair
                                                            : NULL;
  }
}

- (BCKeyPair *)keyPair44ForCoin:(uint32_t)coin
                        account:(uint32_t)accountId
                       external:(BOOL)external
                          index:(uint32_t)index
                  withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSArray *components;
    BCKeyPair *keyPair;

    components = [[self class] bip44ComponentsForCoin:coin
                                              account:accountId
                                             external:external
                                                index:index];
    if (![components isKindOfClass:[NSArray class]]) {
      memoryKey = NULL;
      return NULL;
    }

    keyPair = [self keyPairForComponents:components andMemoryKey:memoryKey];
    memoryKey = NULL;
    return keyPair;
  }
}

- (BCKeyPair *)keyPair32ForAccount:(uint32_t)accountId
                          external:(BOOL)external
                             index:(uint32_t)index
                     withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSArray *components;
    BCKeyPair *keyPair;

    components = [[self class] bip32StdComponentsForAccount:accountId
                                                   external:external
                                                      index:index];
    if (![components isKindOfClass:[NSArray class]]) {
      memoryKey = NULL;
      return NULL;
    }

    keyPair = [self keyPairForComponents:components andMemoryKey:memoryKey];
    memoryKey = NULL;
    return keyPair;
  }
}

- (BCKeyPair *)keyPairForPath:(NSString *)path andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSArray *components;
    BCKeyPair *keyPair;
    
    components = [[self class] componentsFromPath:path];
    if (![components isKindOfClass:[NSArray class]]) {
      memoryKey = NULL;
      return NULL;
    }
    
    keyPair = [self keyPairForComponents:components andMemoryKey:memoryKey];
    memoryKey = NULL;
    return keyPair;
  }
}
#pragma mark Master Utilities

+ (BCKeyPair *)masterKeyFromSeed:(NSData *)rootSeed
                    andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    // The generation process of the master private key is slightly different
    // from
    // generation of other child keys
    NSData *rootHMAC, *rootSecret, *rootChainCode;
    NSParameterAssert([rootSeed isKindOfClass:[NSData class]]);
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);
    if (![rootSeed isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]])
      return NULL;

    // HMAC the seed with the seeds key.
    rootHMAC = [rootSeed SHA512HmacWithKey:[self seedKeyData]];
    if (![rootHMAC isKindOfClass:[NSData class]]) return NULL;

    // The Root Secret is the left half of SHA512 (32 bytes)
    rootSecret = [rootHMAC subdataWithRange:NSMakeRange(0, 32)];
    if (![rootSecret isKindOfClass:[NSData class]]) return NULL;

    // The Root Chain Code is the right side of SHA512 (32 bytes)
    rootChainCode = [rootHMAC subdataWithRange:NSMakeRange(32, 32)];
    if (![rootChainCode isKindOfClass:[NSData class]]) return NULL;

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

#pragma mark Utilities

+ (NSArray *)bip44ComponentsForCoin:(uint32_t)coin
                            account:(uint32_t)accountId
                           external:(BOOL)external
                              index:(uint32_t)index {
  // m/purpose(44)'/coin_type'/account'/change/address_index
  // m/0x8000002C/0x80000000/0x80000000/0/0
  return @[
    @(BIP44_PURPOSE),
    @(coin),
    @(BIP32_PRIME | accountId),
    @(external ? 0 : 1),
    @(index)
  ];
}

+ (NSArray *)bip32StdComponentsForAccount:(uint32_t)accountId
                                 external:(BOOL)external
                                    index:(uint32_t)index {
  // m/account'/change/address_index
  // m/0x80000000/0/0
  return @[ @(BIP32_PRIME | accountId), @(external ? 0 : 1), @(index) ];
}

+ (NSArray *)componentsFromPath:(NSString *)path {
  NSString *normalizedPath;
  NSArray *stringComponents;

  NSParameterAssert([path isKindOfClass:[NSString class]]);
  if (![path isKindOfClass:[NSString class]]) return NULL;

  // Normalize
  normalizedPath =
      [path.lowercaseString stringByReplacingOccurrencesOfString:@" "
                                                      withString:@""];

  // Check Chars
  if (![self string:normalizedPath onlyContainsChars:kBCKeySequenceValidChars])
    return NULL;

  // Separate into components
  stringComponents =
      [normalizedPath componentsSeparatedByString:kBCKeySequenceDelimiterChar];

  // Must have at least 1 item
  if (![stringComponents isKindOfClass:[NSArray class]] ||
      stringComponents.count < 1)
    return NULL;

  // Do We Start with master?
  if (![[stringComponents objectAtIndex:0]
          isEqualToString:kBCKeySequenceMasterChar])
    return NULL;

  return [self pathComponentsFromArray:stringComponents];
}

+ (NSArray *)pathComponentsFromArray:(NSArray *)components {
  NSMutableArray *outputComponents;
  NSNumberFormatter *numFormatter;
  NSNumber *currentValue;
  NSString *component, *valueString;
  BOOL isHardened;
  NSParameterAssert([components isKindOfClass:[NSArray class]]);
  if (![components isKindOfClass:[NSArray class]]) return NULL;

  numFormatter = [[NSNumberFormatter alloc] init];
  outputComponents = [[NSMutableArray alloc] init];
  for (NSUInteger i = 1; i < components.count; ++i) {
    // Get the current component
    component = [components objectAtIndex:i];

    // Check if hardened
    isHardened =
        [self string:[component substringWithRange:NSMakeRange(
                                                       component.length - 1, 1)]
            onlyContainsChars:kBCKeySequenceHardenedFlagChars];

    // Get the value string
    valueString =
        [component substringWithRange:NSMakeRange(0, component.length -
                                                         (isHardened ? 1 : 0))];

    // Must only contain base 10 numerical chars.
    if (![self string:valueString
            onlyContainsChars:kBCKeySequenceNumericalChars])
      return NULL;

    currentValue = [numFormatter numberFromString:valueString];
    if (![currentValue isKindOfClass:[NSNumber class]]) return NULL;

    if (isHardened) {
      // Mutate the index to be hardened.
      currentValue =
          @((uint32_t)BIP32_PRIME | (uint32_t)[currentValue intValue]);
      if (![currentValue isKindOfClass:[NSNumber class]]) return NULL;
    }

    // Add the item
    [outputComponents addObject:currentValue];

    // Reset
    currentValue = NULL;
    component = NULL;
    valueString = NULL;
  }

  return [NSArray arrayWithArray:outputComponents];
}

+ (BOOL)string:(NSString *)sequence onlyContainsChars:(NSString *)allowedChars {
  BOOL charIsInvalid = TRUE;
  unichar currentChar;
  // Validate that path only contains correct chars
  for (NSUInteger i = 0; i < sequence.length; ++i) {
    // Assume invalid until proven otherwise
    currentChar = [sequence characterAtIndex:i];
    charIsInvalid = TRUE;
    for (NSUInteger q = 0; q < allowedChars.length; ++q)
      if (currentChar == [allowedChars characterAtIndex:q])
        charIsInvalid = FALSE;

    // We have gone through all allowed chars, if we haven't bee proven valid
    // then the string has invalid chars.
    if (charIsInvalid) return FALSE;
  }
  return TRUE;
}

@end
