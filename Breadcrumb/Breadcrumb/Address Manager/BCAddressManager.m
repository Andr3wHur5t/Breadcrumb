//
//  BCAddressManager.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/19/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "BCAddressManager.h"
#import "_BCWallet.h"

@implementation BCAddressManager

@synthesize keySequence = _keySequence;
@synthesize coin = _coin;
@synthesize preferredSequenceType = _preferredSequenceType;

#pragma mark Construction

- (instancetype)initWithKeySequence:(BCKeySequence *)keys
                           coinType:(BCCoin *)coinType
                      preferredPath:(BCKeySequenceType)preferred
                       andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([keys isKindOfClass:[BCKeySequence class]]);
    self = [self init];
    if (!self) return NULL;
    _keySequence = keys;
    _coin = coinType;
    _preferredSequenceType = preferred;

    // Configure Keys
    [self setMasters:memoryKey];
    memoryKey = NULL;
    return self;
  }
}

#pragma mark Configuration

- (void)setMasters:(NSData *)memoryKey {
  @autoreleasepool {
    BCKeyPair *currentKey;
    // Set Bip 44 masters FORCE ACCOUNT 0
    currentKey = [self.keySequence
        keyPairForComponents:
            @[ @(0x8000002C), @(self.coin.coinId), @(BIP32_PRIME | 0), @(1) ]
                andMemoryKey:memoryKey];
    _bip44Internal =
        [[BCAMMasterKey alloc] initWithKeyPair:currentKey andCoin:self.coin];

    currentKey = [self.keySequence
        keyPairForComponents:
            @[ @(0x8000002C), @(self.coin.coinId), @(BIP32_PRIME | 0), @(0) ]
                andMemoryKey:memoryKey];
    _bip44External =
        [[BCAMMasterKey alloc] initWithKeyPair:currentKey andCoin:self.coin];

    // Set bip 32 masters
    currentKey =
        [self.keySequence keyPairForComponents:@[ @(BIP32_PRIME | 0), @(1) ]
                                  andMemoryKey:memoryKey];
    _bip32Internal =
        [[BCAMMasterKey alloc] initWithKeyPair:currentKey andCoin:self.coin];

    currentKey =
        [self.keySequence keyPairForComponents:@[ @(BIP32_PRIME | 0), @(0) ]
                                  andMemoryKey:memoryKey];
    _bip32External =
        [[BCAMMasterKey alloc] initWithKeyPair:currentKey andCoin:self.coin];

    memoryKey = NULL;
  }
}

#pragma mark Address Data

- (BCAddress *)firstUnusedExternal {
  switch (self.preferredSequenceType) {
    case BCKeySequenceType_BIP32:
      return self.bip32External.firstUnusedAddress;
      break;
    default:
      return self.bip44External.firstUnusedAddress;
      break;
  }
}

- (BCAddress *)firstUnusedInternal {
  switch (self.preferredSequenceType) {
    case BCKeySequenceType_BIP32:
      return self.bip32Internal.firstUnusedAddress;
      break;
    default:
      return self.bip44Internal.firstUnusedAddress;
      break;
  }
}

#pragma mark Lookup

- (BCKeyPair *)keyPairForAddress:(BCAddress *)address
                  usingMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    BCKeyPair *key;
    // Check all masters for key.
    key =
        [self.bip32Internal keyPairForAddress:address withMemoryKey:memoryKey];
    if ([key isKindOfClass:[BCKeyPair class]]) {
      memoryKey = NULL;
      return key;
    }

    key =
        [self.bip32External keyPairForAddress:address withMemoryKey:memoryKey];
    if ([key isKindOfClass:[BCKeyPair class]]) {
      memoryKey = NULL;
      return key;
    }

    key =
        [self.bip44Internal keyPairForAddress:address withMemoryKey:memoryKey];
    if ([key isKindOfClass:[BCKeyPair class]]) {
      memoryKey = NULL;
      return key;
    }

    key =
        [self.bip44External keyPairForAddress:address withMemoryKey:memoryKey];
    memoryKey = NULL;
    if ([key isKindOfClass:[BCKeyPair class]]) return key;

    return NULL;
  }
}

- (NSArray *)keyPairsForScript:(BCScript *)script
                usingMemoryKey:(NSData *)memoryKey {
  NSMutableData *data = [[NSMutableData alloc] init];
  BCAddress *address;
  NSMutableArray *addresses;

  addresses = [[NSMutableArray alloc] init];
  switch (script.type) {
    case BCScriptType_P2PKH:
      // Fake an address
      [data appendUInt8:0x01];
      [data appendData:[script.elements objectAtIndex:2]];
      if (data.length < 20) return NULL;

      address = [data.base58CheckEncoding toBitcoinAddress];
      return @[ [self keyPairForAddress:address usingMemoryKey:memoryKey] ];
      break;
    case BCScriptType_P2SH:
      // Fake an address
      [data appendUInt8:0x01];
      [data appendData:[script.elements objectAtIndex:1]];
      if (data.length < 20) return NULL;

      address = [data.base58CheckEncoding toBitcoinAddress];
      return @[ [self keyPairForAddress:address usingMemoryKey:memoryKey] ];
      break;
    case BCScriptType_P2PK:
      // Check the pub key is valid
      [data appendData:[script.elements objectAtIndex:0]];
      if (data.length < 35) return NULL;
      // Get its address
      address =
          [[[BCPublicKey alloc] initWithData:data] addressForCoin:self.coin];
      return @[ [self keyPairForAddress:address usingMemoryKey:memoryKey] ];
      break;
    case BCScriptType_MofN:
      // TODO: This
      return NULL;
      break;
    default:
      return NULL;
      break;
  }

  return @[];
}

@end
