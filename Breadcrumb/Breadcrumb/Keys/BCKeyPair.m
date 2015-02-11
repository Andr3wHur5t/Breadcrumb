//
//  BCKeyPair.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCKeyPair.h"
#import "BCProtectedData.h"
#import "NSString+Base58.h"
#import "BreadcrumbCore.h"

@interface BCKeyPair ()
/*!
 @brief The protected private key.
 */
@property(strong, nonatomic, readonly) BCProtectedData *privateKey;
@end

@implementation BCKeyPair

@synthesize address = _address;
@synthesize publicKey = _publicKey;
@synthesize privateKey = _privateKey;

#pragma mark Construction

- (instancetype)initWithPrivate:(NSData *)privateKey
                         public:(NSData *)publicKey
                   andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([privateKey isKindOfClass:[NSData class]]);
    NSParameterAssert([publicKey isKindOfClass:[NSData class]]);
    if (![privateKey isKindOfClass:[NSData class]] ||
        ![publicKey isKindOfClass:[NSData class]])
      return NULL;

    _publicKey = publicKey;
    _privateKey = [privateKey protectedWithKey:memoryKey];
    // TODO: Get address from public key.
    //    _address = [[NSString addressWithScriptPubKey:publicKey]
    //    toBitcoinAddress];
    //    if (![_address isKindOfClass:[NSString class]]) return NULL;
  }
  return self;
}

#pragma mark Old Sequence Interface

- (BRBIP32Sequence *)sequenceHelper {
  if (!_sequenceHelper) _sequenceHelper = [[BRBIP32Sequence alloc] init];
  return _sequenceHelper;
}

#pragma mark Public Info

- (BCAddress *)address {
  return _address;
}

- (NSData *)publicKey {
  NSParameterAssert([_publicKey isKindOfClass:[NSData class]]);
  return _publicKey;
}

#pragma mark Private Info

- (NSData *)privateKeyUsingMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([self.privateKey isKindOfClass:[BCProtectedData class]]);
    return [self.privateKey dataUsingMemoryKey:memoryKey];
  }
}

#pragma mark Child Retrevial

#pragma mark Siging Operations

- (NSData *)sign:(NSData *)data withMemoryKey:(NSData *)memoryKey {
  // TODO: Implment https://github.com/bitcoin/secp256k1 for signing, and
  // signiture verification.
  // ECDSA Sign
  return data;
}

#pragma mark Deriviation Operations

- ()
@end
