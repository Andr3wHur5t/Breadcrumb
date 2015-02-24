//
//  BCAMMasterKey.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/22/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCAMMasterKey.h"
#import "BCProtectedData.h"
#import "BCsecp256k1.h"

// Set this to change our edge address search distance
#define GAP_DISTANCE 100

@interface BCAMMasterKey ()

/*!
 @brief !!!!!!! THIS IS TEMP !!!!!!!! REMOVE THIS !!!!!!!!

 @discussion I didnt have time to add a EC point system to do pub key
 diriviation im adding this as a temporary work around so I can demo this. It us
 my top priority to not store the memory key.
 */
@property(strong, nonatomic, readonly) BCProtectedData *proMemKey;
@property(strong, nonatomic, readonly) NSData *tempNonce;

@end

@implementation BCAMMasterKey

@synthesize key = _key;
@synthesize coin = _coin;
@synthesize addresses = _addresses;
@synthesize lastUsedIndex = _lastUsedIndex;

@synthesize tempNonce = _tempNonce;
@synthesize proMemKey = _proMemKey;

#pragma Construction

- (instancetype)initWithKeyPair:(BCKeyPair *)key
                         memKey:(NSData *)memKey
                        andCoin:(BCCoin *)coin {
  @autoreleasepool {
    NSParameterAssert([key isKindOfClass:[BCKeyPair class]]);
    if (![key isKindOfClass:[BCKeyPair class]]) return NULL;
    self = [super init];
    if (!self) return NULL;

    _key = key;
    _coin = coin;

    // !!!!!!! REMOVE ME !!!!!!!
    _tempNonce = [BCsecp256k1 pseudoRandomDataWithLength:32];
    _proMemKey = [memKey protectedWithKey:_tempNonce];

    return self;
  }
}

#pragma mark Index Management
- (void)setLastUsedIndex:(uint16_t)lastUsedIndex {
  [self expandAddressToIndex:lastUsedIndex];
  _lastUsedIndex = lastUsedIndex;
}

- (void)expandAddressToIndex:(uint16_t)index {
  uint16_t count, initial;
  if (self.addresses.count > index) return;
  
  initial = self.addresses.count;
  count = index - initial;
  for (uint16_t i = 0 ; i < count; ++i)
    [self addressAtIndex:initial + i];
}

#pragma mark Address Management

- (NSMutableArray *)addresses {
  if (!_addresses) _addresses = [[NSMutableArray alloc] init];
  return _addresses;
}

- (void)cacheAddress:(BCAddress *)address atIndex:(uint16_t)index {
  if (![address isKindOfClass:[BCAddress class]]) return;

  // Fill Empty spaces with NULL. Will be caught by address at index.
  for (uint16_t i = self.addresses.count; i < index; ++i)
    [self.addresses setObject:[NSNull null] atIndexedSubscript:i];
  [self.addresses setObject:address atIndexedSubscript:index];
}

- (BCAddress *)firstUnusedAddress {
  return [self addressAtIndex:self.lastUsedIndex + 1];
}

// !!!!!! TMP solution !!!!!!
- (BCAddress *)addressAtIndex:(uint16_t)index {
  @autoreleasepool {
    NSData *memKey;
    BCKeyPair *childKey;
    BCAddress *address;
    // Check Cache
    if (self.addresses.count > index) {
      address = [self.addresses objectAtIndex:index];

      // if we found return, else generate address.
      if ([address isKindOfClass:[BCAddress class]]) return address;
    }

    // Get secured mem key
    memKey = [self.proMemKey dataUsingMemoryKey:self.tempNonce];
    if (![memKey isKindOfClass:[NSData class]]) return NULL;
    if (memKey.length != 32) return NULL;

    childKey = [self.key childKeyPairAt:index withMemoryKey:memKey];
    memKey = NULL;
    if (![childKey isKindOfClass:[BCKeyPair class]])
      return NULL;

    // Get its address
    address = [childKey.publicKey addressForCoin:_coin];
    if (![address isKindOfClass:[BCAddress class]])
      return NULL;
    [self cacheAddress:address atIndex:index];
    return address;
  }
}

/*
 This is what we want to migtate to, pub parent -> pub child but it requires ec
point multipication which i have to understand better before implmentation.

- (BCAddress *)addressAtIndex:(uint16_t)index {
  BCPublicKey *child;
  BCAddress *address;
  // Check Cache
  if (self.addresses.count > index) {
    address = [self.addresses objectAtIndex:index];

    // if we found return, else generate address.
    if ([address isKindOfClass:[BCAddress class]]) return address;
  }

  // Check if we can derive the child from pub key.
  if (![self.key.publicKey isKindOfClass:[BCDerivablePublicKey class]])
    return NULL;

  // Get the child public key at the correct index.
  child = [(BCDerivablePublicKey *)self.key.publicKey childKeyAtIndex:index];
  if (![child isKindOfClass:[BCKeyPair class]]) return NULL;

  // Get its address
  address = [child addressForCoin:_coin];
  [self cacheAddress:address atIndex:index];
  return [address isKindOfClass:[BCAddress class]] ? address : NULL;
}
 */

- (uint16_t)indexOfAddress:(BCAddress *)address {
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  if (![address isKindOfClass:[BCAddress class]]) return UINT16_MAX;

  // Note: Last used index is disconected from the count of cached addresses
  // Note: This searches known addresses in self.lastUsedIndex and will try some
  // edge addresses as well.
  for (uint16_t i = 0; i < self.lastUsedIndex + GAP_DISTANCE; ++i)
    if ([address isEqualExcludingVersion:[self addressAtIndex:i]]) return i;

  // We failed to find it.
  return UINT16_MAX;
}

- (BCKeyPair *)keyPairForAddress:(BCAddress *)address
                   withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    uint16_t index;
    BCKeyPair *child;
    NSParameterAssert([address isKindOfClass:[BCAddress class]]);
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);

    index = [self indexOfAddress:address];
    if (index == UINT16_MAX) return NULL;  // We Failed :(

    child = [self.key childKeyPairAt:index withMemoryKey:memoryKey];
    return [child isKindOfClass:[BCKeyPair class]] ? child : NULL;
  }
}

@end
