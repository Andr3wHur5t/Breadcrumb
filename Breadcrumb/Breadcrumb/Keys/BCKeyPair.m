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
#import "NSData+Hash.h"
#import "BCsecp256k1.h"
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

- (instancetype)initWithPrivateKey:(NSData *)privateKey
                      andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([privateKey isKindOfClass:[NSData class]]);
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;

    _publicKey = [[BCsecp256k1 sharedInstance] publicKeyFromKey:privateKey];
    _privateKey = [privateKey protectedWithKey:memoryKey];
    // TODO: Get address from public key.
    //    _address = [[NSString addressWithScriptPubKey:publicKey]
    //    toBitcoinAddress];
    //    if (![_address isKindOfClass:[NSString class]]) return NULL;
  }
  return self;
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

#pragma mark Child Retrieval

#pragma mark Signing Operations

- (NSData *)signHash:(NSData *)hash withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSData *signedData, *rawPrivateKey;
    NSParameterAssert([hash isKindOfClass:[NSData class]] ||
                      [memoryKey isKindOfClass:[NSData class]]);
    if (![hash isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]] ||
        ![_privateKey isKindOfClass:[BCProtectedData class]])
      return NULL;

    // Get the private key to sign with
    rawPrivateKey = [self.privateKey dataUsingMemoryKey:memoryKey];
    memoryKey = NULL;
    if (![rawPrivateKey isKindOfClass:[NSData class]]) return NULL;

    // Sign the data with the private key.
    signedData = [[BCsecp256k1 sharedInstance] signitureForHash:hash
                                                 withPrivateKey:rawPrivateKey];
    rawPrivateKey = NULL;

    return [signedData isKindOfClass:[NSData class]] ? signedData : NULL;
  }
}

- (BOOL)didSign:(NSData *)signedData withOriginal:(NSData *)original {
  NSData *hash;
  NSParameterAssert([signedData isKindOfClass:[NSData class]]);
  NSParameterAssert([original isKindOfClass:[NSData class]]);
  if (![_publicKey isKindOfClass:[NSData class]] ||
      ![signedData isKindOfClass:[NSData class]] ||
      ![original isKindOfClass:[NSData class]])
    return FALSE;

  hash = [original SHA256_2];
  if (![hash isKindOfClass:[NSData class]]) return FALSE;

  return [[BCsecp256k1 sharedInstance] signiture:signedData
                                       orginHash:[original SHA256_2]
                             isValidForPublicKey:_publicKey];
}

#pragma mark Derivation Operations

@end
