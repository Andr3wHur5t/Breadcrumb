//
//  BCsecp256k1.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/11/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCsecp256k1.h"
#import "secp256k1.h"

@implementation BCsecp256k1
#pragma mark Construction

- (instancetype)init {
  NSAssert(false, @"MUST use shared instance of BCsecp256k1.");
  return NULL;
}

- (instancetype)_init {
  self = [super init];
  if (self) {
    // Need to alloc for secp256
    secp256k1_start(SECP256K1_START_SIGN);
    secp256k1_start(SECP256K1_START_VERIFY);
  }
  return self;
}

- (void)dealloc {
  secp256k1_stop();
}

#pragma mark Operations

- (NSData *)publicKeyFromKey:(NSData *)privateKey {
  @autoreleasepool {
    unsigned char pubKey[65];
    int pubKeyLength;
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;

    if (secp256k1_ec_pubkey_create(pubKey, &pubKeyLength, [privateKey bytes],
                                   0) == 0) {
      NSLog(@"Failed to create public key!");
      return NULL;
    } else {
      return [[NSData alloc] initWithBytes:pubKey length:pubKeyLength];
    }
  }
}

- (NSData *)signitureForHash:(NSData *)hash withPrivateKey:(NSData *)key {
  @autoreleasepool {
    unsigned char signiture[75];
    int sigLength = 75;

    if (secp256k1_ec_seckey_verify([key bytes]) == 0) {
      NSLog(@"Key Not Valid");
      return NULL;
    }

    if (secp256k1_ecdsa_sign([hash bytes], signiture, &sigLength, [key bytes],
                             NULL, NULL) == 0) {
      NSLog(@"Failed to sign!");
      return NULL;
    } else {
      return [[NSData alloc] initWithBytes:signiture length:sigLength];
    }
  }
}

- (BOOL)signiture:(NSData *)signiture
              orginHash:(NSData *)hash
    isValidForPublicKey:(NSData *)publicKey {
  @autoreleasepool {
    int status;
    // TODO: Validate Inputs

    status = secp256k1_ecdsa_verify([hash bytes], [signiture bytes],
                                    (int)signiture.length, [publicKey bytes],
                                    (int)publicKey.length);
    switch (status) {
      case 1:
        return TRUE;
        break;
      case 0:
        NSLog(@"Incorrect Sig");
        return FALSE;
        break;
      case -1:
        NSLog(@"Invalid Sig");
        return FALSE;
        break;
      case -2:
        NSLog(@"Invalid pub key");
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
@end
