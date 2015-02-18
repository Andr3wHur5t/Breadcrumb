//
//  BCKeySequenceTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/17/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "Breadcrumb.h"
#import <XCTest/XCTest.h>

@interface BCKeySequenceTests : XCTestCase

@end

@implementation BCKeySequenceTests

#pragma mark BIP 32 Test Vectors
// Refrence to Vectors https://en.bitcoin.it/wiki/BIP_0032_TestVectors

- (void)testHDVector1 {
  NSData *rootSeed, *pass;
  BCKeyPair *h0, *externalChain, *exh2, *exh2_2, *exh2_2_1e9;
  pass = [[NSMutableData alloc] initWithLength:32];
  rootSeed = @"000102030405060708090a0b0c0d0e0f".hexToData;

  BCKeySequence *kp =
      [[BCKeySequence alloc] initWithRootSeed:rootSeed andMemoryKey:pass];

  // Check that we set the root seed
  XCTAssert([[kp.rootSeed dataUsingMemoryKey:pass] isEqual:rootSeed],
            @"Failed.");

  // Check That the master chain code is correct
  XCTAssert(
      [kp.masterKeyPair.chainCode
          isEqualToData:@"873dff81c02f525623fd1fe5167eac3a55a049de3d314bb4"
                        @"2ee227ffed37d508".hexToData],
      @"Failed.");

  // Check that the private key is correct.
  XCTAssert(
      [[kp.masterKeyPair privateKeyUsingMemoryKey:pass]
          isEqualToData:@"e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a"
                        @"1494b917c8436b35".hexToData],
      @"Failed.");

  // Check That the master public key is correct
  // If this fails this means that pub key dirivaition failed. :(
  XCTAssert(
      [kp.masterKeyPair.publicKey
          isEqualToData:@"0339a36013301597daef41fbe593a02cc513d0b55527ec2d"
                        @"f1050e2e8ff49c85c2".hexToData],
      @"Failed.");

  // Check Address
  XCTAssert([kp.masterKeyPair.address
                isEqualExcludingVersion:
                    [@"15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma" toBitcoinAddress]],
            @"Failed");

  // Extract the hardened h0 keypair used in bip32 wallets
  h0 = [kp.masterKeyPair childKeyPairAt:0x80000000 withMemoryKey:pass];

  // Validate the h0 private key is valid
  XCTAssert(
      [[h0 privateKeyUsingMemoryKey:pass]
          isEqualToData:@"edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b"
                        @"0715a2d911a0afea".hexToData],
      @"Failed");

  // Validate the h0 chain code is correct
  XCTAssert(
      [h0.chainCode isEqualToData:@"47fdacbd0f1097043b78c63c20c34ef4ed9a111d980"
                                  @"047ad16282c7ae6236141".hexToData],
      @"Failed");

  // Validate the h0 public key is correct
  XCTAssert(
      [h0.publicKey isEqualToData:@"035a784662a4a20a65bf6aab9ae98a6c068a81c52e4"
                                  @"b032c0fb5400c706cfccc56".hexToData],
      @"Failed");

  // Check Address
  XCTAssert(
      [h0.address isEqualExcludingVersion:
                      [@"19Q2WoS5hSS6T8GjhK8KZLMgmWaq4neXrh" toBitcoinAddress]],
      @"Failed");

  // Check a nonhardened key
  externalChain = [h0 childKeyPairAt:1 withMemoryKey:pass];

  // Check Private Key
  XCTAssert(
      [[externalChain privateKeyUsingMemoryKey:pass]
          isEqualToData:@"3c6cb8d0f6a264c91ea8b5030fadaa8e538b020f0a387421"
                        @"a12de9319dc93368".hexToData],
      @"Failed");

  // Check Chain Code
  XCTAssert(
      [externalChain.chainCode isEqualToData:@"2a7857631386ba23dacac34180d"
                                             @"d1983734e444fdbf774041578e"
                                             @"9b6adb37c19".hexToData],
      @"Failed");

  // Check Public Key
  XCTAssert(
      [externalChain.publicKey isEqualToData:@"03501e454bf00751f24b1b489aa"
                                             @"925215d66af2234e3891c3b21a"
                                             @"52bedb3cd711c".hexToData],
      @"Failed");

  // Check Address
  XCTAssert([externalChain.address
                isEqualExcludingVersion:
                    [@"1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj" toBitcoinAddress]],
            @"Failed");

  // m/0'/1/2'
  exh2 = [externalChain childKeyPairAt:0x80000000 | 2 withMemoryKey:pass];

  // Check Private Key
  XCTAssert(
      [[exh2 privateKeyUsingMemoryKey:pass]
          isEqualToData:@"cbce0d719ecf7431d88e6a89fa1483e02e35092af60c042b"
                        @"1df2ff59fa424dca".hexToData],
      @"Failed");

  // Check Chain Code
  XCTAssert(
      [exh2.chainCode isEqualToData:@"04466b9cc8e161e966409ca52986c584f07e9dc81"
                                    @"f735db683c3ff6ec7b1503f".hexToData],
      @"Failed");

  // Check Public Key
  XCTAssert(
      [exh2.publicKey isEqualToData:@"0357bfe1e341d01c69fe5654309956cbea516822f"
                                    @"ba8a601743a012a7896ee8dc2".hexToData],
      @"Failed");

  // Check Address
  XCTAssert([exh2.address
                isEqualExcludingVersion:
                    [@"1NjxqbA9aZWnh17q1UW3rB4EPu79wDXj7x" toBitcoinAddress]],
            @"Failed");

  // m/0'/1/2'/2
  exh2_2 = [exh2 childKeyPairAt:2 withMemoryKey:pass];

  // Check Private Key
  XCTAssert(
      [[exh2_2 privateKeyUsingMemoryKey:pass]
          isEqualToData:@"0f479245fb19a38a1954c5c7c0ebab2f9bdfd96a17563ef2"
                        @"8a6a4b1a2a764ef4".hexToData],
      @"Failed");

  // Check Chain Code
  XCTAssert(
      [exh2_2.chainCode isEqualToData:@"cfb71883f01676f587d023cc53a35bc7f88f724"
                                      @"b1f8c2892ac1275ac822a3edd".hexToData],
      @"Failed");

  // Check Public Key
  XCTAssert(
      [exh2_2.publicKey
          isEqualToData:@"02e8445082a72f29b75ca48748a914df60622a609cacfce8"
                        @"ed0e35804560741d29".hexToData],
      @"Failed");

  // Check Address
  XCTAssert([exh2_2.address
                isEqualExcludingVersion:
                    [@"1LjmJcdPnDHhNTUgrWyhLGnRDKxQjoxAgt" toBitcoinAddress]],
            @"Failed");

  // m/0'/1/2'/2/1000000000
  exh2_2_1e9 = [exh2_2 childKeyPairAt:1000000000 withMemoryKey:pass];

  // Check Private Key
  XCTAssert(
      [[exh2_2_1e9 privateKeyUsingMemoryKey:pass]
          isEqualToData:@"471b76e389e528d6de6d816857e012c5455051cad6660850"
                        @"e58372a6c3e6e7c8".hexToData],
      @"Failed");

  // Check Chain Code
  XCTAssert(
      [exh2_2_1e9.chainCode isEqualToData:@"c783e67b921d2beb8f6b389cc646d7"
                                          @"263b4145701dadd2161548a8b078e"
                                          @"65e9e".hexToData],
      @"Failed");

  // Check Public Key
  XCTAssert(
      [exh2_2_1e9.publicKey isEqualToData:@"022a471424da5e657499d1ff51cb43"
                                          @"c47481a03b1e77f951fe64cec9f5a"
                                          @"48f7011".hexToData],
      @"Failed");

  // Check Address
  XCTAssert([exh2_2_1e9.address
                isEqualExcludingVersion:
                    [@"1LZiqrop2HGR4qrH1ULZPyBpU6AUP49Uam" toBitcoinAddress]],
            @"Failed");
}

- (void)testHDVector2 {
  NSData *rootSeed, *pass;
  BCKeyPair *m_0, *m_0_2147483647H, *m_0_2147483647H_1,
      *m_0_2147483647H_1_2147483646, *m_0_2147483647H_1_2147483646_2;
  pass = [[NSMutableData alloc] initWithLength:32];
  rootSeed = @"fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a2"
             @"9f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b48454"
             @"2".hexToData;

  BCKeySequence *kp =
      [[BCKeySequence alloc] initWithRootSeed:rootSeed andMemoryKey:pass];

  // Check that we set the root seed
  XCTAssert([[kp.rootSeed dataUsingMemoryKey:pass] isEqual:rootSeed],
            @"Failed.");

  // Check That the master chain code is correct
  XCTAssert([kp.masterKeyPair.chainCode
                isEqualToData:@"60499f801b896d83179a4374aeb7822aaeaceaa0db1f85e"
                              @"e3e904c4defbd9689".hexToData],
            @"Failed.");

  // Check that the private key is correct.
  XCTAssert([[kp.masterKeyPair privateKeyUsingMemoryKey:pass]
                isEqualToData:@"4b03d6fc340455b363f51020ad3ecca4f0850280cf436c7"
                              @"0c727923f6db46c3e".hexToData],
            @"Failed.");

  // Check That the master public key is correct
  // If this fails this means that pub key dirivaition failed. :(
  XCTAssert([kp.masterKeyPair.publicKey
                isEqualToData:@"03cbcaa9c98c877a26977d00825c956a238e8dddfbd322c"
                              @"ce4f74b0b5bd6ace4a7".hexToData],
            @"Failed.");

  // Check Address
  XCTAssert([kp.masterKeyPair.address
                isEqualExcludingVersion:
                    [@"1JEoxevbLLG8cVqeoGKQiAwoWbNYSUyYjg" toBitcoinAddress]],
            @"Failed");

  // m/0
  m_0 = [kp.masterKeyPair childKeyPairAt:0 withMemoryKey:pass];

  // Check That the master chain code is correct
  XCTAssert(
      [m_0.chainCode isEqualToData:@"f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a"
                                   @"5c2cac40e7412f232f7c9c".hexToData],
      @"Failed.");

  // Check that the private key is correct.
  XCTAssert([[m_0 privateKeyUsingMemoryKey:pass]
                isEqualToData:@"abe74a98f6c7eabee0428f53798f0ab8aa1bd3787399904"
                              @"1703c742f15ac7e1e".hexToData],
            @"Failed.");

  // Check That the master public key is correct
  XCTAssert(
      [m_0.publicKey isEqualToData:@"02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d85"
                                   @"85886c9c826b6b22a98d12ea".hexToData],
      @"Failed.");

  // Check Address
  XCTAssert([m_0.address
                isEqualExcludingVersion:
                    [@"19EuDJdgfRkwCmRzbzVBHZWQG9QNWhftbZ" toBitcoinAddress]],
            @"Failed");

  // m/0/2147483647'
  m_0_2147483647H =
      [m_0 childKeyPairAt:0x80000000 | 2147483647 withMemoryKey:pass];

  // Check That the master chain code is correct
  XCTAssert([m_0_2147483647H.chainCode
                isEqualToData:@"be17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7"
                              @"b38547f585c9a37d9".hexToData],
            @"Failed.");

  // Check that the private key is correct.
  XCTAssert([[m_0_2147483647H privateKeyUsingMemoryKey:pass]
                isEqualToData:@"877c779ad9687164e9c2f4f0f4ff0340814392330693ce9"
                              @"5a58fe18fd52e6e93".hexToData],
            @"Failed.");

  // Check That the master public key is correct
  XCTAssert([m_0_2147483647H.publicKey
                isEqualToData:@"03c01e7425647bdefa82b12d9bad5e3e6865bee0502694b"
                              @"94ca58b666abc0a5c3b".hexToData],
            @"Failed.");

  // Check Address
  XCTAssert([m_0_2147483647H.address
                isEqualExcludingVersion:
                    [@"1Lke9bXGhn5VPrBuXgN12uGUphrttUErmk" toBitcoinAddress]],
            @"Failed");

  // m/0/2147483647'/1
  m_0_2147483647H_1 = [m_0_2147483647H childKeyPairAt:1 withMemoryKey:pass];

  // Check That the master chain code is correct
  XCTAssert([m_0_2147483647H_1.chainCode
                isEqualToData:@"f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c3"
                              @"36c927eb246fb38cb".hexToData],
            @"Failed.");

  // Check that the private key is correct.
  XCTAssert([[m_0_2147483647H_1 privateKeyUsingMemoryKey:pass]
                isEqualToData:@"704addf544a06e5ee4bea37098463c23613da32020d6045"
                              @"06da8c0518e1da4b7".hexToData],
            @"Failed.");

  // Check That the master public key is correct
  XCTAssert([m_0_2147483647H_1.publicKey
                isEqualToData:@"03a7d1d856deb74c508e05031f9895dab54626251b3806e"
                              @"16b4bd12e781a7df5b9".hexToData],
            @"Failed.");

  // Check Address
  XCTAssert([m_0_2147483647H_1.address
                isEqualExcludingVersion:
                    [@"1BxrAr2pHpeBheusmd6fHDP2tSLAUa3qsW" toBitcoinAddress]],
            @"Failed");

  // m/0/2147483647'/1/2147483646'
  m_0_2147483647H_1_2147483646 =
      [m_0_2147483647H_1 childKeyPairAt:0x80000000 | 2147483646
                          withMemoryKey:pass];

  // Check That the master chain code is correct
  XCTAssert([m_0_2147483647H_1_2147483646.chainCode
                isEqualToData:@"637807030d55d01f9a0cb3a7839515d796bd07706386a6e"
                              @"ddf06cc29a65a0e29".hexToData],
            @"Failed.");

  // Check that the private key is correct.
  XCTAssert([[m_0_2147483647H_1_2147483646 privateKeyUsingMemoryKey:pass]
                isEqualToData:@"f1c7c871a54a804afe328b4c83a1c33b8e5ff48f5087273"
                              @"f04efa83b247d6a2d".hexToData],
            @"Failed.");

  // Check That the master public key is correct
  XCTAssert([m_0_2147483647H_1_2147483646.publicKey
                isEqualToData:@"02d2b36900396c9282fa14628566582f206a5dd0bcc8d5e"
                              @"892611806cafb0301f0".hexToData],
            @"Failed.");

  // Check Address
  XCTAssert([m_0_2147483647H_1_2147483646.address
                isEqualExcludingVersion:
                    [@"15XVotxCAV7sRx1PSCkQNsGw3W9jT9A94R" toBitcoinAddress]],
            @"Failed");
  
  // m/0/2147483647'/1/2147483646'/2
  
  m_0_2147483647H_1_2147483646_2 =
  [m_0_2147483647H_1_2147483646 childKeyPairAt:2
                      withMemoryKey:pass];
  
  // Check That the master chain code is correct
  XCTAssert([m_0_2147483647H_1_2147483646_2.chainCode
             isEqualToData:@"9452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed271".hexToData],
            @"Failed.");
  
  // Check that the private key is correct.
  XCTAssert([[m_0_2147483647H_1_2147483646_2 privateKeyUsingMemoryKey:pass]
             isEqualToData:@"bb7d39bdb83ecf58f2fd82b6d918341cbef428661ef01ab97c28a4842125ac23".hexToData],
            @"Failed.");
  
  // Check That the master public key is correct
  XCTAssert([m_0_2147483647H_1_2147483646_2.publicKey
             isEqualToData:@"024d902e1a2fc7a8755ab5b694c575fce742c48d9ff192e63df5193e4c7afe1f9c".hexToData],
            @"Failed.");
  
  // Check Address
  XCTAssert([m_0_2147483647H_1_2147483646_2.address
             isEqualExcludingVersion:
             [@"14UKfRV9ZPUp6ZC9PLhqbRtxdihW9em3xt" toBitcoinAddress]],
            @"Failed");
}

@end
