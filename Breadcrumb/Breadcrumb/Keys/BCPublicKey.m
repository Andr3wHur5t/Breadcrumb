//
//  BCPublicKey.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCPublicKey.h"
#import "BCKeySequence.h"
#import "BCsecp256k1.h"
#import "BreadcrumbCore.h"

@implementation BCPublicKey

@synthesize data = _data;

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  NSParameterAssert([data isKindOfClass:[NSData class]]);
  if (![data isKindOfClass:[NSData class]]) return NULL;

  self = [super init];
  if (!self) return NULL;
  _data = data;

  return self;
}

#pragma mark Info

- (BCAddress *)addressForCoin:(BCCoin *)coin {
  return [BCAddress addressFromPublicKey:_data usingCoin:coin];
}

#pragma mark Comparison
- (BOOL)isEqualToData:(NSData *)data {
  return [self.data isEqualToData:data];
}

@end

@implementation BCDerivablePublicKey

@synthesize chainCode = _chainCode;

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  NSAssert(false, @"Not implemented, use - "
           @"(instancetype)initWithData:andChainCode: instead.");
  return NULL;
}

- (instancetype)initWithData:(NSData *)data andChainCode:(NSData *)chainCode {
  NSParameterAssert([chainCode isKindOfClass:[NSData class]]);
  self = [super initWithData:data];
  if (!self) return NULL;
  _chainCode = chainCode;
  return self;
}

#pragma mark Derivation

// The function CKDpub((Kpar, cpar), i) → (Ki, ci) computes a child extended
// public key from the parent extended public key. It is only defined for
// non-hardened child keys.
- (BCPublicKey *)childKeyAtIndex:(uint32_t)index {
  // TODO: EC get the child code from the current public key.
  // TODO: add tests in HD.
  NSMutableData *dataToDerive;
  NSData *childChain, *opData;

  // Check For Hardened key
  if (index >= BIP32_PRIME) return NULL;

  // Setup the data to derive
  dataToDerive = [[NSMutableData alloc] init];
  if (![dataToDerive isKindOfClass:[NSMutableData class]]) return NULL;

  // dataToDerive = serP(Kpar) || ser32(i);
  [dataToDerive appendData:self.data];
  [dataToDerive appendUInt32:CFSwapInt32(index)];

  // HMAC-SHA512(key = chainCode, data = dataToDerive);
  opData = [dataToDerive SHA512HmacWithKey:self.chainCode];
  if (![opData isKindOfClass:[NSData class]] || opData.length != 64)
    return NULL;

  // parse256()
  childChain = [opData subdataWithRange:NSMakeRange(32, 32)];
  opData = [opData subdataWithRange:NSMakeRange(0, 32)];

  // childPublic = point(opData) + self.data.
  opData = [[BCsecp256k1 sharedInstance] publicKey:self.data add:opData];

  // In case parse256(IL) ≥ n or Ki is the point at infinity
  if (false)
    // key invalid, and one should proceed with the next value for i.
    return [self childKeyAtIndex:index + 1];

  //  return opData;
  return [[BCPublicKey alloc] initWithData:opData];
}

@end
