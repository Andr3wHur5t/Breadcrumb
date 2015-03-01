//
//  BCWallet.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//  Interface Notes:
//  The wallet will operate on its' own queue, I'm building under the assumption
//  that the user is operating in the main queue with UI. All _internal methods
//  will be synchronous, but normal interface methods should automatically add
//  it self to the wallet queue.
//
//  I will only use this type of interface when I consider high level
//  interaction is occurring. This way low level users can interface without
//  having to deal with ping pong dispatching.
//
//  Calls should be built for async interaction anyway because most calls
//  through the wallet have to deal with the network, and if not will have long
//  running lookup operations.

#import "BCWallet.h"
#import "_BCWallet.h"
#import "BCMnemonic.h"

@implementation BCWallet

@synthesize provider = _provider;

@synthesize protectedMnemonic = _protectedMnemonic;
@synthesize keys = _keys;
@synthesize addressManager = _addressManager;

#pragma mark Construction

- (instancetype)initNewWithPassword:(NSData *)password andCoin:(BCCoin *)coin {
  return [self initNewWithPassword:password
                              coin:coin
                          provider:[[BCProviderChain alloc] init]
                      sequenceType:BCKeySequenceType_BIP44
                       andCallback:NULL];
}

- (instancetype)initNewWithPassword:(NSData *)password
                               coin:(BCCoin *)coin
                        andCallback:(void (^)(NSError *))callback {
  return [self initNewWithPassword:password
                              coin:coin
                          provider:[[BCProviderChain alloc] init]
                      sequenceType:BCKeySequenceType_BIP44
                       andCallback:callback];
}

- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                               password:(NSData *)password
                                   coin:(BCCoin *)coin
                            andCallback:(void (^)(NSError *))callback {
  return [self initUsingMnemonicPhrase:phrase
                                  coin:coin
                              provider:[[BCProviderChain alloc] init]
                          sequenceType:BCKeySequenceType_BIP44
                              password:password
                           andCallback:callback];
}

- (instancetype)initNewWithPassword:(NSData *)password
                        andProvider:(BCAProvider *)provider {
  return [self initNewWithPassword:password
                              coin:[BCCoin MainNetBitcoin]
                          provider:provider
                      sequenceType:BCKeySequenceType_BIP44
                       andCallback:NULL];
}

- (instancetype)initNewWithPassword:(NSData *)password
                               coin:(BCCoin *)coin
                           provider:(BCAProvider *)provider
                       sequenceType:(BCKeySequenceType)sequenceType
                        andCallback:(void (^)(NSError *))callback {
  @autoreleasepool {
    NSString *mnemonicPhrase;
    mnemonicPhrase = [BCMnemonic newMnemonic];
    if (![mnemonicPhrase isKindOfClass:[NSString class]]) return NULL;

    return [self initUsingMnemonicPhrase:mnemonicPhrase
                                    coin:coin
                                provider:provider
                            sequenceType:BCKeySequenceType_BIP44
                                password:password
                             andCallback:callback];
  }
}

- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                               provider:(BCAProvider *)provider
                               password:(NSData *)password
                            andCallback:(void (^)(NSError *))callback {
  return [self initUsingMnemonicPhrase:phrase
                                  coin:[BCCoin MainNetBitcoin]
                              provider:provider
                          sequenceType:BCKeySequenceType_BIP44
                              password:password
                           andCallback:callback];
}

- (instancetype)initUsingMnemonicPhrase:(NSString *)phrase
                                   coin:(BCCoin *)coin
                               provider:(BCAProvider *)provider
                           sequenceType:(BCKeySequenceType)sequenceType
                               password:(NSData *)password
                            andCallback:(void (^)(NSError *))callback {
  @autoreleasepool {
    __block NSData *sPassword;
    __block NSString *sPhrase;
    __block void (^sCallback)(NSError *);
    __block void (^sCom)(NSError *);
    NSParameterAssert([phrase isKindOfClass:[NSString class]]);
    if (![phrase isKindOfClass:[NSString class]]) return NULL;

    self = [super init];
    if (!self) {
      callback([[self class] walletGenerationErrorWithCode:1]);
      return NULL;
    }

    // Sanitize the phrase
    sPhrase = [BCMnemonic sanitizePhrase:phrase];
    if (![sPhrase isKindOfClass:[NSString class]]) {
      callback([[self class] walletGenerationErrorWithCode:2]);
      return NULL;
    }

    sPassword = password;
    _provider = provider;

    sCom = callback;
    sCallback = ^(NSError *error) {
        __block NSError *sError = error;
        if (sCom) dispatch_async(dispatch_get_main_queue(), ^{ sCom(sError); });
    };
    // We will be doing some long running operations, run them on a background
    // queue
    dispatch_async(self.queue, ^() {
        NSData *privateKey, *memoryKey;

        // Generate the memory key using the inputted password
        memoryKey = [[self class] _keyFromPassword:password];
        if (![memoryKey isKindOfClass:[NSData class]]) {
          sCallback([[self class] walletGenerationErrorWithCode:3]);
          return;
        }

        // Secure our phrase data
        [self _setMnemonic:sPhrase withMemoryKey:memoryKey];

        // Generate the private key from the phrase
        privateKey = [BCMnemonic keyFromPhrase:sPhrase withPassphrase:NULL];
        sPhrase = NULL;
        if (![privateKey isKindOfClass:[NSData class]]) {
          sCallback([[self class] walletGenerationErrorWithCode:4]);
          memoryKey = NULL;
          return;
        }

        // Create our key sequence, secure our private key with our memory key.
        _keys = [[BCKeySequence alloc] initWithRootSeed:privateKey
                                           andMemoryKey:memoryKey];
        privateKey = NULL;
        if (![_keys isKindOfClass:[BCKeySequence class]]) {
          sCallback([[self class] walletGenerationErrorWithCode:5]);
          memoryKey = NULL;
          return;
        }

        // Address manager needed to manage key paths, and addresses.
        _addressManager =
            [[BCAddressManager alloc] initWithKeySequence:self.keys
                                                 coinType:coin
                                            preferredPath:sequenceType
                                             andMemoryKey:memoryKey];
        memoryKey = NULL;
        if (![_addressManager isKindOfClass:[BCAddressManager class]]) {
          sCallback([[self class] walletGenerationErrorWithCode:6]);
          return;
        }

        sCallback(NULL);
    });

    // First Item to execute post construction is sync.
    [self synchronize:NULL];

    // We will return self before configuration, this means we need to dispatch
    // all operations on the wallets queue to ensure they happen in sync.
    return self;
  }
}

#pragma mark Mnemonic

- (void)_setMnemonic:(NSString *)mnemonic withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSData *clearText;

    // Convert String into data
    clearText = [NSMutableData
        secureDataWithData:[mnemonic dataUsingEncoding:NSUTF8StringEncoding
                                  allowLossyConversion:FALSE]];
    if (![clearText isKindOfClass:[NSData class]]) return;

    // Protect the data with the inputted key.
    _protectedMnemonic = [clearText protectedWithKey:memoryKey];

    memoryKey = NULL;
    clearText = NULL;
  }
}

- (void)mnemonicPhraseWithPassword:(NSData *)password
                     usingCallback:(void (^)(NSString *))callback {
  @autoreleasepool {
    __block NSData *sPassword = password;
    __block void (^sCallback)(NSString *) = callback;
    // Dispatch async because scrypt from the password takes about 5 sec which
    // is too long to run on the main thread.
    dispatch_async(self.queue, ^{
        __block NSString *phrase;
        NSData *memoryKey;

        // Derive the memory key from the password
        memoryKey = [[self class] _keyFromPassword:sPassword];
        sPassword = NULL;

        // Get the phrase
        phrase = [self _mnemonicWithMemoryKey:memoryKey];

        // Dispatch on main so they don't need to think about what queue they
        // are on.
        dispatch_async(dispatch_get_main_queue(), ^{
            sCallback(phrase);
            phrase = NULL;
        });
    });
  }
}

- (NSString *)_mnemonicWithMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSData *clearData;
    NSString *clearText;
    // Validate
    if (![_protectedMnemonic isKindOfClass:[BCProtectedData class]] ||
        ![memoryKey isKindOfClass:[NSData class]])
      return NULL;

    // Get the clear text data
    clearData = [_protectedMnemonic dataUsingMemoryKey:memoryKey];
    memoryKey = NULL;
    if (![clearData isKindOfClass:[NSData class]]) return NULL;

    // Convert the data into Text
    clearText =
        [[NSString alloc] initWithData:clearData encoding:NSUTF8StringEncoding];
    clearData = NULL;

    // Return the phrase
    return [clearText isKindOfClass:[NSString class]] ? clearText : NULL;
  }
}

#pragma mark Key Sequence

- (void)keySequenceWithPassword:(NSData *)password
                  usingCallback:(void (^)(BCKeySequence *, NSData *))callback {
  @autoreleasepool {
    __block NSData *sPassword = password;
    __block void (^sCallback)(BCKeySequence *, NSData *) = callback;
    // Dispatch async because scrypt from the password takes about 5 sec which
    // is too long to run on the main thread.
    dispatch_async(self.queue, ^{
        __block NSData *memoryKey;

        // Derive the memory key from the password
        memoryKey = [[self class] _keyFromPassword:sPassword];
        sPassword = NULL;

        // Dispatch on main so they don't need to think about what queue they
        // are on.
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
              sCallback(self.keys, memoryKey);
              memoryKey = NULL;
            }
        });
    });
  }
}

#pragma mark Wallet Info

- (void)synchronize:(void (^)(NSError *))callback {
  dispatch_async(self.queue, ^{
      [self.provider syncAddressManager:self.addressManager
                           withCallback:^(NSError *error) {
                               if (!callback) return;
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{ callback(error); });
                           }];
  });
}

- (void)getBalance:(void (^)(uint64_t, NSError *))callback {
  if (!callback) return;
  dispatch_async(self.queue, ^{
      [self.provider
          getBalanceForAddressManager:self.addressManager
                         withCallback:^(uint64_t balance, NSError *error) {
                             dispatch_async(dispatch_get_main_queue(),
                                            ^{ callback(balance, error); });
                         }];
  });
}

- (BCAProvider *)provider {
  if (!_provider) _provider = [[BCProviderChain alloc] init];
  return _provider;
}

- (void)getCurrentAddress:(void (^)(BCAddress *))callback {
  if (!callback) return;
  dispatch_async(self.queue, ^{
      dispatch_async(dispatch_get_main_queue(),
                     ^{ callback(self.addressManager.firstUnusedExternal); });
  });
}

- (BCCoin *)coin {
  if (![self.addressManager isKindOfClass:[BCAddressManager class]])
    return NULL;
  return self.addressManager.coin;
}

#pragma mark Queue

- (dispatch_queue_t)queue {
  if (!__queue) __queue = dispatch_queue_create(kBCWalletQueueLabel, NULL);
  return __queue;
}

#pragma mark errors

+ (NSError *)walletGenerationErrorWithCode:(NSUInteger)code {
  return [NSError
      errorWithDomain:@"com.breadcrumb.walletGeneration"
                 code:code
             userInfo:@{
               NSLocalizedDescriptionKey : [NSString
                   stringWithFormat:@"Wallet generation error. (Code: %@)",
                                    @(code)]
             }];
}

@end
