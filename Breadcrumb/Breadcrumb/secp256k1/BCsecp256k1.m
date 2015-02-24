//
//  BCsecp256k1.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/11/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCsecp256k1.h"
#import "secp256k1.h"
#import "BreadcrumbCore.h"

@implementation BCsecp256k1
#pragma mark Construction

- (instancetype)init {
  NSAssert(false, @"MUST use shared instance of BCsecp256k1.");
  return NULL;
}

- (instancetype)_init {
  self = [super init];
  if (self) {
    // Need to alloc for secp256k1
    secp256k1_start(SECP256K1_START_SIGN);
    secp256k1_start(SECP256K1_START_VERIFY);
  }
  return self;
}

- (void)dealloc {
  secp256k1_stop();
}

#pragma mark Operations

- (NSData *)publicKeyFromKey:(NSData *)privateKey compressed:(BOOL)compressed {
  @autoreleasepool {
    unsigned char pubKey[65];
    int pubKeyLength;
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;
    if (![privateKey bytes] || privateKey.length != 32) return NULL;

    if (secp256k1_ec_pubkey_create(pubKey, &pubKeyLength, [privateKey bytes],
                                   compressed) == 0) {
      NSLog(@"Failed to create public key!");  // TODO: Report as errors
      return NULL;
    } else {
      return [[NSData alloc] initWithBytes:pubKey length:pubKeyLength];
    }
  }
}

- (NSData *)signatureForHash:(NSData *)hash withPrivateKey:(NSData *)key {
  @autoreleasepool {
    unsigned char signature[72];
    int sigLength = 72;
    NSData *signiture;
    if (![key isKindOfClass:[NSData class]]) {
      key = NULL;
      return NULL;
    }

    if (secp256k1_ec_seckey_verify([key bytes]) == 0) {
      NSLog(@"Key Not Valid");  // TODO: Report as errors
      key = NULL;
      return NULL;
    }

    if (secp256k1_ecdsa_sign(
            [hash bytes], signature, &sigLength, [key bytes], secp256k1_nonce_function_rfc6979,
            NULL) == 0) {
      NSLog(@"Failed to sign!");  // TODO: Report as errors
      key = NULL;
      return NULL;
    } else {
      key = NULL;
      signiture = [[NSData alloc] initWithBytes:signature length:sigLength];

      return [signiture isKindOfClass:[NSData class]] ? signiture : NULL;
    }
  }
}

- (BOOL)signature:(NSData *)signature
             originHash:(NSData *)hash
    isValidForPublicKey:(NSData *)publicKey {
  @autoreleasepool {
    int status;
    // TODO: Validate Inputs

    status = secp256k1_ecdsa_verify([hash bytes], [signature bytes],
                                    (int)signature.length, [publicKey bytes],
                                    (int)publicKey.length);
    switch (status) {
      case 1:
        return TRUE;
        break;
      case 0:
        //        NSLog(@"Incorrect Sig");  // TODO: Report as errors
        return FALSE;
        break;
      case -1:
        //        NSLog(@"Invalid Sig");  // TODO: Report as errors
        return FALSE;
        break;
      case -2:
        //        NSLog(@"Invalid pub key");  // TODO: Report as errors
        return FALSE;
        break;

      default:
        return FALSE;
        break;
    }
  }
}

#pragma mark Shared access

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static BCsecp256k1 *instance;
  dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] _init]; });
  return instance;
}

#pragma mark Utilties
+ (NSData *)pseudoRandomDataWithLength:(NSUInteger)length {
  @autoreleasepool {
    NSMutableData *entropy;

    entropy = [NSMutableData secureDataWithLength:length];
    SecRandomCopyBytes(kSecRandomDefault, entropy.length, entropy.mutableBytes);

    return entropy;
  }
}

+ (mp_int)curveOrder {
  // TODO: Move to ECDSA helper
  static dispatch_once_t onceToken;
  static mp_int curveOrder;
  dispatch_once(&onceToken, ^{
      mp_init(&curveOrder);
      // sepc256k1 curve order as defined https://en.bitcoin.it/wiki/Secp256k1
      mp_read_radix(
          &curveOrder,
          "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
          16);
  });
  return curveOrder;
}

@end
