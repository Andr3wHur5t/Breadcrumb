//
//  BCWallet.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
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
    __block NSData *sPassword;
    __block NSString *sPhrase;
    NSParameterAssert([phrase isKindOfClass:[NSString class]]);
    if (![phrase isKindOfClass:[NSString class]]) return NULL;

    self = [super init];
    if (!self) return NULL;

    // Sanitize the phrase
    sPhrase = [BCMnemonic sanitizePhrase:phrase];
    if (![sPhrase isKindOfClass:[NSString class]]) return NULL;

    // Set the password to something block safe
    sPassword = password;

    // We will be doing some long running operations, run them on a background
    // queue
    dispatch_async(self.queue, ^() {
        NSData *privateKey, *memoryKey;

        // Generate the memory key using the inputted password
        memoryKey = [[self class] _keyFromPassword:password];
        if (![memoryKey isKindOfClass:[NSData class]]) {
          NSLog(@"Failed to generate wallet memory key!");
          return;
        }

        // Secure our phrase data
        [self _setMnemonic:sPhrase withMemoryKey:memoryKey];

        // Generate the private key from the phrase
        privateKey = [BCMnemonic keyFromPhrase:sPhrase withPassphrase:NULL];
        sPhrase = NULL;
        if (![privateKey isKindOfClass:[NSData class]]) {
          NSLog(@"Failed to generate wallet private key!");
          memoryKey = NULL;
          return;
        }

        // Create our key sequence, secure our private key with our memory key.
        _keys = [[BCKeySequence alloc] initWithRootSeed:privateKey
                                           andMemoryKey:memoryKey];
        privateKey = NULL;
        if (![_keys isKindOfClass:[BCKeySequence class]]) {
          NSLog(@"Failed to generate wallet key sequence!");
          memoryKey = NULL;
          return;
        }

        // TODO: Configure with the inputted coin, and preferred path.
        _addressManager = [[BCAddressManager alloc]
            initWithKeySequence:self.keys
                       coinType:[BCCoin TestNet3Bitcoin]
                  preferredPath:BCKeySequenceType_BIP44
                   andMemoryKey:memoryKey];
        memoryKey = NULL;
        if (![_addressManager isKindOfClass:[BCAddressManager class]]) {
          NSLog(@"Failed to construct address manager!");
          return;
        }
    });

    // First Item to execute post construction is sync.
    [self synchronize];

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

- (void)synchronize {
  dispatch_async(self.queue,
                 ^{ [self.provider syncAddressManager:self.addressManager]; });
}

- (void)getBalance:(void (^)(uint64_t, NSError *))callback {
  dispatch_async(self.queue, ^{
      [self.provider getBalanceForAddressManager:self.addressManager
                                    withCallback:callback];
  });
}

- (BCAProvider *)provider {
  // Allow them to set the provider with by changing the returned class
  // TODO: Allow passing startup params
  if (!_provider) _provider = [[[[self class] defaultProvider] alloc] init];
  return _provider;
}

- (void)getCurrentAddress:(void (^)(BCAddress *))callback {
  __block void (^sCallback)(BCAddress *) = callback;
  dispatch_async(self.queue, ^{
      dispatch_async(dispatch_get_main_queue(),
                     ^{ sCallback(self.addressManager.firstUnusedExternal); });
  });
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

@end
