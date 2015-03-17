//
//  BCAMMasterKey.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/22/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
#import "BCAMMasterKey.h"
#import "BCProtectedData.h"
#import "BCsecp256k1.h"

// Set this to change our edge address search distance
#define GAP_DISTANCE 20

@implementation BCAMMasterKey

@synthesize key = _key;
@synthesize coin = _coin;
@synthesize addresses = _addresses;
@synthesize lastUsedIndex = _lastUsedIndex;

#pragma mark Construction

- (instancetype)initWithKeyPair:(BCKeyPair *)key andCoin:(BCCoin *)coin {
  @autoreleasepool {
    NSParameterAssert([key isKindOfClass:[BCKeyPair class]]);
    if (![key isKindOfClass:[BCKeyPair class]]) return NULL;
    self = [super init];
    if (!self) return NULL;

    _key = key;
    _coin = coin;

    return self;
  }
}

#pragma mark Index Management

- (void)setLastUsedIndex:(uint16_t)lastUsedIndex {
  [self expandAddressToIndex:lastUsedIndex + GAP_DISTANCE];
  _lastUsedIndex = lastUsedIndex;
}

- (void)expandAddressToIndex:(uint16_t)index {
  uint16_t count, initial;
  if (self.addresses.count > index) return;

  initial = (uint16_t)self.addresses.count;
  count = index - initial;
  for (uint16_t i = 0; i < count; ++i) [self addressAtIndex:initial + i];
}

#pragma mark Address Management

- (NSMutableArray *)addresses {
  if (!_addresses) _addresses = [[NSMutableArray alloc] init];
  return _addresses;
}

- (void)cacheAddress:(BCAddress *)address atIndex:(uint16_t)index {
  if (![address isKindOfClass:[BCAddress class]]) return;

  // Fill Empty spaces with NULL. Will be caught by address at index.
  for (uint16_t i = (uint16_t)self.addresses.count; i < index; ++i)
    [self.addresses setObject:[NSNull null] atIndexedSubscript:i];
  [self.addresses setObject:address atIndexedSubscript:index];
}

- (BCAddress *)firstUnusedAddress {
  return [self addressAtIndex:self.lastUsedIndex + 1];
}

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
  if (![child isKindOfClass:[BCPublicKey class]]) return NULL;

  // Get its address
  address = [child addressForCoin:_coin];
  [self cacheAddress:address atIndex:index];
  return [address isKindOfClass:[BCAddress class]] ? address : NULL;
}

- (uint16_t)indexOfAddress:(BCAddress *)address {
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  if (![address isKindOfClass:[BCAddress class]]) return UINT16_MAX;

  // Note: Last used index is disconected from the count of cached addresses
  // Note: This searches known addresses in self.lastUsedIndex and will try some
  // edge addresses as well.
  for (uint16_t i = 0; i < self.lastUsedIndex + GAP_DISTANCE; ++i)
    if ([address isEqualExcludingVersion:[self addressAtIndex:i]]) return i;

  // We failed
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
