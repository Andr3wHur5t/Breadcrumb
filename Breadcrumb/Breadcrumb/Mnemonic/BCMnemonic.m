//
//  BCMnemonic.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCMnemonic.h"
#import "BreadcrumbCore.h"

#define SEED_ENTROPY_LENGTH (128 / 8)

@implementation BCMnemonic
#pragma mark Generation

+ (NSString *)newMnemonic {
  // Auto release pool ensures data is deallocated immediately
  @autoreleasepool {
    NSString *phrase;
    NSMutableData *entropy;

    entropy = [NSMutableData secureDataWithLength:SEED_ENTROPY_LENGTH];
    SecRandomCopyBytes(kSecRandomDefault, entropy.length, entropy.mutableBytes);
    if (![entropy isKindOfClass:[NSData class]]) {
      NSAssert(FALSE, @"Failed to generate entropy.");
      return NULL;
    }

    phrase = [self mnemonicFromEntropy:entropy];
    return [phrase isKindOfClass:[NSString class]] ? phrase : NULL;
  }
}

+ (NSString *)mnemonicFromEntropy:(NSData *)data {
  // Auto release pool ensures data is deallocated immediately
  @autoreleasepool {
    NSParameterAssert([data isKindOfClass:[NSData class]]);
    if (![data isKindOfClass:[NSData class]]) return NULL;
    return [[BRBIP39Mnemonic sharedInstance] encodePhrase:data];
  }
}

#pragma mark Processing

+ (NSString *)sanitizePhrase:(NSString *)phrase {
  // Auto release pool ensures data is deallocated immediately
  @autoreleasepool {
    NSString *sanitizedPhrase;
    NSParameterAssert([phrase isKindOfClass:[NSString class]]);
    if (![phrase isKindOfClass:[NSString class]]) return NULL;

    BRBIP39Mnemonic *m = [BRBIP39Mnemonic sharedInstance];
    if (![m isKindOfClass:[BRBIP39Mnemonic class]]) return NULL;

    sanitizedPhrase = [m encodePhrase:[m decodePhrase:phrase]];
    return [sanitizedPhrase isKindOfClass:[NSString class]] ? sanitizedPhrase
                                                            : NULL;
  }
}

+ (NSData *)decodePhrase:(NSString *)phrase {
  // Auto release pool ensures data is deallocated immediately
  @autoreleasepool {
    NSData *decodedValue;
    NSParameterAssert([phrase isKindOfClass:[NSString class]]);
    if ([phrase isKindOfClass:[NSString class]]) return NULL;

    decodedValue = [[BRBIP39Mnemonic sharedInstance] decodePhrase:phrase];
    return [decodedValue isKindOfClass:[NSData class]] ? decodedValue : NULL;
  }
}

+ (NSString *)encodeData:(NSData *)phraseData {
  // Auto release pool ensures data is deallocated immediately
  @autoreleasepool {
    NSString *encodedValue;
    NSParameterAssert([phraseData isKindOfClass:[NSData class]]);
    if ([phraseData isKindOfClass:[NSString class]]) return NULL;

    encodedValue = [[BRBIP39Mnemonic sharedInstance] encodePhrase:phraseData];
    return [encodedValue isKindOfClass:[NSString class]] ? encodedValue : NULL;
  }
}

#pragma mark Conversion

+ (NSData *)keyFromPhrase:(NSString *)phrase
           withPassphrase:(NSString *)passphrase {
  @autoreleasepool {
    return [[BRBIP39Mnemonic sharedInstance] deriveKeyFromPhrase:phrase
                                                  withPassphrase:passphrase];
  }
}

@end
