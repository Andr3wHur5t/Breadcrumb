//
//  BCWalletGenerationTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/18/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "Breadcrumb.h"
#import "_BCWallet.h"
#import <XCTest/XCTest.h>

@interface BCWalletGenerationTests : XCTestCase

@end

@implementation BCWalletGenerationTests

#pragma mark Internal Tests

- (void)testWalletCreationVector0 {
  BCWallet *wallet;
  NSData *password;
  password = [NSMutableData dataWithLength:32];

  // Random Construction Test
  wallet = [[BCWallet alloc] initNewWithPassword:password
                                         andCoin:[BCCoin MainNetBitcoin]];
  XCTAssert([wallet isKindOfClass:[BCWallet class]], @"Failed to construct");
}

#pragma mark BIP Defined Vectors

// This is a memonic test Not a wallet Generation Test

// correct horse battery staple
// Private Key: C4BBCB1FBEC99D65BF59D85C8CB62EE2DB963F0FE106F483D9AFA73BD4E39A8A
// Address: 1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T

#pragma mark BitcoinJ BIP 32 Vectors (TESTNET)

// Seed as words: mouse palace human birth waste brother pair fragile million
// west aspect express
// Seed as hex:
// 4b51919e2f2be7909d5d5260e0f9a929799d93b4ab687657d1d5bcfde97be80fa2e36d6fa3fc594943e82aa5a238723be6c931fba5dd4d7395d0a8c9a46b4272
// M/0H
// DeterministicKey{pub=039bc63c02a83c5347e5e0a45aa1ece696bb66b3408e4048f1379fa6514169f65e,
// chainCode=a9b92f438ba117eb470c423ba6965fadaf6d97607b481e4128660b6ba403ebc4,
// path=M/0H}
// M/0H/0
// DeterministicKey{pub=03bfe172fa9be00ae96c19ca7345316fc1a2b1768bc009370a507b154550ba7040,
// chainCode=90690e08539f021d9a6e196cd25d404e3b5423f48435881d0e45823317648faa,
// path=M/0H/0}
// M/0H/0/0
// DeterministicKey{pub=02fb9b3bf3374d0e1b9573156b3c0a778b2f0979482e0fd7fa07e8af42dd55eb7c,
// chainCode=156940426ae5cfc90eea3dd6c94a0b3255d99fbb7ad69435f1581011db8020b0,
// path=M/0H/0/0} mvihzZu32GdpYrhVHi8CYXF2yUDaKG2ivu

// NT this is not a proper test yet
- (void)NTtestWalletKeyGenVector0 {
  // Test compatibility with BitcoinJ
  NSData *password;
  BCWallet *wallet;

  password = [[NSMutableData alloc] initWithLength:32];
  wallet = [[BCWallet alloc]
      initUsingMnemonicPhrase:@"slab ski horn medal document cat minute "
      @"uniform worth coyote sight dragon"
                     password:password
                         coin:[BCCoin TestNet3Bitcoin]
                  andCallback:NULL];

  NSAssert(wallet, @"Failed");
  [wallet
      keySequenceWithPassword:password
                usingCallback:^(BCKeySequence *sequence, NSData *memoryKey) {
                    BCKeyPair *m_0h, *m_0h_0, *m_0h_0_0;
                    // Verify the root seed matches
                    NSAssert([[sequence.rootSeed dataUsingMemoryKey:memoryKey]
                                 isEqualToData:@"77e572c9238590d687ca29cd3c6a6b"
                                               @"f9f973a26eafadf49e24880d1c62f"
                                               @"3ec03ac7867aa2b1a0102c5bc11cc"
                                               @"dc40eea2580ab41a818fea2166b60"
                                               @"816a96c98b1".hexToData],
                             @"Failed");

                    // Verify HD
                    // M/0'
                    m_0h = [sequence.masterKeyPair childKeyPairAt:0x80000000
                                                    withMemoryKey:memoryKey];

                    // Chain Code
                    NSAssert([m_0h.chainCode
                                 isEqualToData:@"e92d1221934bfe476a6311a1c4efca"
                                               @"755fcf27170dbdde60e2efb52a82a"
                                               @"1bf91".hexToData],
                             @"Failed");

                    // Pub Key
                    NSAssert([m_0h.publicKey
                                 isEqualToData:@"031c243bb8b8c1a3f31f4a68ed550e"
                                               @"80862bb314387b0c06872a95142f2"
                                               @"55e65d6".hexToData],
                             @"Failed");

                    // M/0'/0
                    m_0h_0 = [m_0h childKeyPairAt:0 withMemoryKey:memoryKey];

                    // Chain Code
                    NSAssert([m_0h_0.chainCode
                                 isEqualToData:@"0ff81906965fa4957fd97958839a70"
                                               @"33dc6ddcb46ef100e0ceb3f6841d8"
                                               @"86e0a".hexToData],
                             @"Failed");

                    // Pub Key
                    NSAssert([m_0h_0.publicKey
                                 isEqualToData:@"02cefa13934831168b8d6e12e1c1e3"
                                               @"41240d3e0c9be18a8557758c98a17"
                                               @"f7d9f97".hexToData],
                             @"Failed");

                    // M/0'/0/0
                    m_0h_0_0 =
                        [m_0h_0 childKeyPairAt:0 withMemoryKey:memoryKey];

                    // Chain Code
                    NSAssert([m_0h_0_0.chainCode
                                 isEqualToData:@"f0219686103125a3993ec60d73238a"
                                               @"03fbd36ec89fe539514fedbda0766"
                                               @"c0bd5".hexToData],
                             @"Failed");

                    // Pub Key
                    NSAssert([m_0h_0_0.publicKey
                                 isEqualToData:@"033319568f40dca5ee98bfada06bd1"
                                               @"c239d62946646b854f49b055c973f"
                                               @"9e5c265".hexToData],
                             @"Failed");
                }];
}
@end
