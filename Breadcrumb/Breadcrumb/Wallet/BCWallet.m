//
//  BCWallet.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCWallet.h"
#import "_BCWallet.h"
#import "BCMnemonic.h"


@implementation BCWallet

@synthesize balance = _balance;
@synthesize provider = _provider;

@synthesize mnemonicCypherText = _mnemonicCypherText;
@synthesize seedCypherText = _seedCypherText;

@synthesize keySequence = _keySequence;
@synthesize masterPublicKey = _masterPublicKey;

#pragma mark Construction

- (instancetype)initNewWithPassword:(NSData *)password {
  @autoreleasepool {
    NSString *mnemonicPhrase;
    mnemonicPhrase = [BCMnemonic newMnemonic];
    if (![mnemonicPhrase isKindOfClass:[NSString class]]) return NULL;

    return [self initUsingMnemonicPhrase:mnemonicPhrase andPassword:password];
  }
}

- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                            andPassword:(NSData *)password {
  @autoreleasepool {
    NSData *seedData;
    NSParameterAssert([phrase isKindOfClass:[NSString class]]);
    if (![phrase isKindOfClass:[NSString class]]) return NULL;

    self = [super init];
    if (self) {
      phrase = [BCMnemonic sanitizePhrase:phrase];
      if (![phrase isKindOfClass:[NSString class]]) return NULL;

      // Get the seed extract the seed data.
      seedData = [[BRBIP39Mnemonic sharedInstance] deriveKeyFromPhrase:phrase
                                                        withPassphrase:nil];
      if (![seedData isKindOfClass:[NSData class]]) return NULL;

      // Set the seed Async
      [self _setSeed:seedData withPassword:password withCallback:^{}];

      // Set the public master key with the sequence utilities
      _masterPublicKey = [self.keySequence masterPublicKeyFromSeed:seedData];
      seedData = NULL;

      // Set Phrase Async
      [self _setMnemonic:phrase withPassword:password withCallback:^{}];
    }
    return self;
  }
}

+ (void)initUsingPrivateInfo:(NSDictionary *)privInfo
                  publicInfo:(NSDictionary *)pubInfo
                    password:(NSData *)password
              withCompletion:(void (^)(id))completion {
  @autoreleasepool {
    // TODO: Process info and restore
    return;
  }
}

#pragma mark Mnemonic

- (void)_setMnemonic:(NSString *)mnemonic
        withPassword:(NSData *)password
        withCallback:(void (^)())callback {
  @autoreleasepool {
    __block NSString *sMnemonic = mnemonic;
    __block NSData *sPassword = password;
    __block void (^sCallback)() = callback;
    // Dispatch async becaue scrypt from the password takes about 5 sec which is
    // too long to run on the main thread.
    dispatch_async(self.queue, ^{
        [self _setMnemonic:sMnemonic withPassword:sPassword];
        sMnemonic = NULL;
        sPassword = NULL;
        if (sCallback) sCallback();
    });
  }
}

- (void)_setMnemonic:(NSString *)mnemonic withPassword:(NSData *)password {
  @autoreleasepool {
    NSData *clearText, *cypherText, *key;

    clearText = [mnemonic dataUsingEncoding:NSUTF8StringEncoding
                       allowLossyConversion:FALSE];
    if (![clearText isKindOfClass:[NSData class]]) return;

    key = [[self class] _keyFromPassword:password];
    if (![key isKindOfClass:[NSData class]]) return;

    // Encrypt the cleartext with the password
    cypherText = [clearText AES256Encrypt:key];
    if (![cypherText isKindOfClass:[NSData class]]) return;

    // Set the cypher text data to the Ivar
    _mnemonicCypherText = cypherText;
  }
}

- (void)mnemonicPhraseWithPassword:(NSData *)password
                     usingCallback:(void (^)(NSString *))callback {
  @autoreleasepool {
    __block NSData *sPassword = password;
    __block void (^sCallback)(NSString *) = callback;
    // Dispatch async becaue scrypt from the password takes about 5 sec which is
    // too long to run on the main thread.
    dispatch_async(self.queue, ^{
        __block NSString *phrase = [self _mnemonicWithPassword:sPassword];
        sPassword = NULL;
        dispatch_async(dispatch_get_main_queue(), ^{
            sCallback(phrase);
            phrase = NULL;
        });
    });
  }
}

- (NSString *)_mnemonicWithPassword:(NSData *)password {
  @autoreleasepool {
    NSData *clearData, *key;
    NSString *clearText;
    if (![_mnemonicCypherText isKindOfClass:[NSData class]] ||
        ![password isKindOfClass:[NSData class]])
      return NULL;

    key = [[self class] _keyFromPassword:password];
    if (![key isKindOfClass:[NSData class]]) return NULL;

    clearData = [_mnemonicCypherText AES256Decrypt:key];
    key = NULL;
    if (![clearData isKindOfClass:[NSData class]]) return NULL;

    clearText =
        [[NSString alloc] initWithData:clearData encoding:NSUTF8StringEncoding];
    clearData = NULL;

    return [clearText isKindOfClass:[NSString class]] ? clearText : NULL;
  }
}

#pragma mark Seed

- (void)_setSeed:(NSData *)seed
    withPassword:(NSData *)password
    withCallback:(void (^)())callback {
  @autoreleasepool {
    __block NSData *sPassword = password, *sSeed = seed;
    __block void (^sCallback)() = callback;
    // Dispatch async becaue scrypt from the password takes about 5 sec which is
    // too long to run on the main thread.
    dispatch_async(self.queue, ^{
        [self _setSeed:sSeed withPassword:sPassword];
        sPassword = NULL;
        sSeed = NULL;
        sCallback();
    });
  }
}

- (void)_setSeed:(NSData *)seed withPassword:(NSData *)password {
  @autoreleasepool {
    NSData *key, *cypherText;

    key = [[self class] _keyFromPassword:password];
    if (![key isKindOfClass:[NSData class]]) return;

    cypherText = [seed AES256Encrypt:key];
    key = NULL;
    if (![cypherText isKindOfClass:[NSData class]]) return;

    _seedCypherText = cypherText;
    cypherText = NULL;
  }
}

- (NSData *)_seedWithPassword:(NSData *)password {
  @autoreleasepool {
    NSData *clearText, *key;

    key = [[self class] _keyFromPassword:password];
    if (![key isKindOfClass:[NSData class]]) return NULL;

    clearText = [_seedCypherText AES256Decrypt:key];
    key = NULL;
    if (![clearText isKindOfClass:[NSData class]]) return NULL;

    return clearText;
  }
}

- (void)seedWithPassword:(NSData *)password
             andCallback:(void (^)(NSData *))callback {
  @autoreleasepool {
    __block void (^sCallback)(NSData *) = callback;
    __block NSData *sPassword = password;
    // Dispatch async becaue scrypt from the password takes about 5 sec which is
    // too long to run on the main thread.
    dispatch_async(self.queue, ^{
        // TODO: Dispatch on Main so the user dosn't need to thing about queues
        sCallback([self _seedWithPassword:sPassword]);
        sPassword = NULL;
    });
  }
}

#pragma mark Keys

- (BRBIP32Sequence *)keySequence {
  if (!_keySequence) _keySequence = [BRBIP32Sequence new];
  return _keySequence;
}

#pragma mark Wallet Info

- (BCAProvider *)provider {
  // Use Chain as the default provider.
  if (!_provider) _provider = [[[[self class] defaultProvider] alloc] init];
  return _provider;
}

- (NSNumber *)balance {
  return _balance;
}

- (BCAddress *)currentAddress {
  // Need to get address from UTXO. Or Get current Index
  return [@"1K4nPxBMy6sv7jssTvDLJWk1ADHBZEoUVb" toBitcoinAddress];
}

#pragma mark Queue

- (dispatch_queue_t)queue {
  if (!__queue) __queue = dispatch_queue_create(kBCWalletQueueLabel, NULL);
  return __queue;
}

#pragma mark Defaults

+ (Class)defaultProvider {
  return [BCProviderChain class];
}

#pragma mark Utilities

+ (NSDictionary *)privateInfoWithEncryptedSeed:(NSData *)seed
                             encryptedMnemonic:(NSData *)mnemonic {
  @autoreleasepool {
    NSParameterAssert([seed isKindOfClass:[NSData class]]);
    NSParameterAssert([mnemonic isKindOfClass:[NSData class]]);
    if (![seed isKindOfClass:[NSData class]] ||
        ![mnemonic isKindOfClass:[NSData class]])
      return NULL;
    return @{kBCRestoration_Seed : seed, kBCRestoration_Mnemonic : mnemonic};
  }
}
@end
