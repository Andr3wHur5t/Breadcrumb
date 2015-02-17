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
                         chainCode:(NSData *)chainCode
                      andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([privateKey isKindOfClass:[NSData class]]);
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;

    _publicKey = [[BCsecp256k1 sharedInstance] publicKeyFromKey:privateKey];
    _privateKey = [privateKey protectedWithKey:memoryKey];
    privateKey = NULL;
    memoryKey = NULL;

    _chainCode = chainCode;

    _address = [BCAddress addressFromPublicKey:_publicKey];
    if (![_address isKindOfClass:[BCAddress class]]) return NULL;
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
    signedData = [[BCsecp256k1 sharedInstance] signatureForHash:hash
                                                 withPrivateKey:rawPrivateKey];
    rawPrivateKey = NULL;

    return [signedData isKindOfClass:[NSData class]] ? signedData : NULL;
  }
}

- (BOOL)didSign:(NSData *)signedData withOriginalHash:(NSData *)hash {
  NSParameterAssert([signedData isKindOfClass:[NSData class]]);
  NSParameterAssert([hash isKindOfClass:[NSData class]]);
  if (![_publicKey isKindOfClass:[NSData class]] ||
      ![signedData isKindOfClass:[NSData class]] ||
      ![hash isKindOfClass:[NSData class]])
    return FALSE;
  return [[BCsecp256k1 sharedInstance] signature:signedData
                                      originHash:hash
                             isValidForPublicKey:_publicKey];
}

#pragma mark Derivation Operations

- (instancetype)childKeyPairAt:(uint32_t)index
                 withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSMutableData *data;
    NSData *privateKey, *hmacData, *childPrivate, *childChainCode;
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);
    if (![self.chainCode isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]])
      return NULL;

    // Get Private Key
    privateKey = [self privateKeyUsingMemoryKey:memoryKey];
    memoryKey = NULL;
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;

    data = [[NSMutableData alloc] init];
    // The index defines if the key is hardened or not.
    if (index >= 0x80000000) {
      // Build Hardened
      // Disallows master pub -> child pub
      [data appendUInt8:0x00];
      [data appendData:privateKey];
    } else {
      // Build Normal
      // Allows master pub -> child pub
      [data appendData:self.publicKey];
    }
    privateKey = NULL;

    // Append The index for Both
    [data appendUInt32:OSSwapHostToBigInt32(index)];
    
    // secp256k1 Curve order
//    @"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".hexToData;

    // Sha512 HMAC using our chain code.
    hmacData = [data SHA512HmacWithKey:self.chainCode];
    data = NULL;
    if (![hmacData isKindOfClass:[NSData class]] || hmacData.length != 64) {
      return NULL;
    }

    // Split the hmac into its parts
    childPrivate = [hmacData subdataWithRange:NSMakeRange(0, 32)];
    if (![childPrivate isKindOfClass:[NSData class]]) {
      hmacData = NULL;
      return NULL;
    }

    childChainCode = [hmacData subdataWithRange:NSMakeRange(32, 32)];
    if (![childChainCode isKindOfClass:[NSData class]]) {
      hmacData = NULL;
      return NULL;
    }

    // Create the key pair object, it will create the public key automaticly.
    return [[[self class] alloc] initWithPrivateKey:childPrivate
                                          chainCode:childChainCode
                                       andMemoryKey:memoryKey];
  }
}

@end
