//
//  BCKeyPairTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/18/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "Breadcrumb.h"
#import <XCTest/XCTest.h>

// Secret is same thing as private key, I took these from BitcoinD Tests (NOTE:
// WIF)
NSString *const kStrSecret1 =
    @"5HxWvvfubhXpYYpS3tJkw6fq9jE9j18THftkZjHHfmFiWtmAbrj";
NSString *const strSecret2 =
    @"5KC4ejrDjv152FGwP386VD1i2NYc5KkfSMyv1nGy1VGDxGHqVY3";
NSString *const strSecret1C =
    @"Kwr371tjA9u2rFSMZjTNun2PXXP3WPZu2afRHTcta6KxEUdm1vEw";
NSString *const strSecret2C =
    @"L3Hq7a8FEQwJkW1M2GNKDW28546Vp5miewcCzSqUD9kCAXrJdS3g";

NSString *const addr1 = @"1QFqqMUD55ZV3PJEJZtaKCsQmjLT6JkjvJ";
NSString *const addr2 = @"1F5y5E5FMc5YzdJtB9hLaUe43GDxEKXENJ";
NSString *const addr1C = @"1NoJrossxPBKfCHuJXT4HadJrXRE9Fxiqs";
NSString *const addr2C = @"1CRj2HyM1CXWzHAXLQtiGLyggNT9WQqsDs";

NSString *const strAddressBad = @"1HV9Lc3sNHZxwj4Zk6fB38tEmBryq2cBiF";

@interface BCKeyPairTests : XCTestCase

@end

@implementation BCKeyPairTests

- (void)testWifConversionVector1 {
  // WIF is tested sufecnetly in testKeySigningVector1, I was just using this
  // for development
  BCKeyPair *kp;
  NSData *memKey = [NSMutableData dataWithLength:32];
  kp = [[BCKeyPair alloc]
       initWithWIF:@"5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
      andMemoryKey:memKey];

  XCTAssert([kp isKindOfClass:[BCKeyPair class]]);

  XCTAssert([[kp privateKeyUsingMemoryKey:memKey]
      isEqualToData:
          @"0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA1D"
              .hexToData]);
}

- (void)testKeySigningVector1 {
  NSString *strMsg;
  NSData *memKey, *hashedMessage;
  NSData *sign1, *sign2, *sign1C, *sign2C;
  BCKeyPair *keyPair1, *keyPair2, *keyPair1C, *keyPair2C;

  memKey = [NSMutableData dataWithLength:32];
  keyPair1 = [[BCKeyPair alloc] initWithWIF:kStrSecret1 andMemoryKey:memKey];
  XCTAssert([keyPair1 isKindOfClass:[BCKeyPair class]], @"Failed");
  
  // Check If Compressed
  XCTAssert(!keyPair1.isCompressed, @"Failed");

  // Check Address
  XCTAssert([keyPair1.address isEqual:[addr1 toBitcoinAddress]], @"Failed");

  // Verify pub Key

  keyPair2 = [[BCKeyPair alloc] initWithWIF:strSecret2 andMemoryKey:memKey];
    XCTAssert([keyPair2 isKindOfClass:[BCKeyPair class]], @"Failed");

  XCTAssert(!keyPair2.isCompressed, @"Failed");

  // Check Address
  XCTAssert([keyPair2.address isEqual:[addr2 toBitcoinAddress]], @"Failed");

  // Verify pub Key

  keyPair1C = [[BCKeyPair alloc] initWithWIF:strSecret1C andMemoryKey:memKey];
      XCTAssert([keyPair1C isKindOfClass:[BCKeyPair class]], @"Failed");

  // Check If Compressed
  XCTAssert(keyPair1C.isCompressed, @"Failed");

  // Check Address
  XCTAssert([keyPair1C.address isEqual:[addr1C toBitcoinAddress]], @"Failed");

  // Verify pub Key

  keyPair2C = [[BCKeyPair alloc] initWithWIF:strSecret2C andMemoryKey:memKey];
        XCTAssert([keyPair2C isKindOfClass:[BCKeyPair class]], @"Failed");

  // Check If Compressed
  XCTAssert(keyPair2C.isCompressed, @"Failed");

  // Check Address
  XCTAssert([keyPair2C.address isEqual:[addr2C toBitcoinAddress]], @"Failed");

  // Verify pub Key
  for (int n = 0; n < 24; ++n) {
    strMsg = [NSString stringWithFormat:@"Very secret message %i: 11", n];
    hashedMessage = [[strMsg dataUsingEncoding:NSASCIIStringEncoding] SHA256];

    // Sign And Verify Message With Each Key
    sign1 = [keyPair1 signHash:hashedMessage withMemoryKey:memKey];
    XCTAssert([sign1 isKindOfClass:[NSData class]], @"Failed");

    sign2 = [keyPair2 signHash:hashedMessage withMemoryKey:memKey];
    XCTAssert([sign2 isKindOfClass:[NSData class]], @"Failed");

    sign1C = [keyPair1C signHash:hashedMessage withMemoryKey:memKey];
    XCTAssert([sign1C isKindOfClass:[NSData class]], @"Failed");

    sign2C = [keyPair2C signHash:hashedMessage withMemoryKey:memKey];
    XCTAssert([sign2C isKindOfClass:[NSData class]], @"Failed");

    // Key Pair 1 Negitive
    XCTAssert([keyPair1 didSign:sign1 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert(![keyPair1 didSign:sign2 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert([keyPair1 didSign:sign1C withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert(![keyPair1 didSign:sign2C withOriginalHash:hashedMessage],
              @"Failed");

    // Key Pair 2 Negitive
    XCTAssert(![keyPair2 didSign:sign1 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert([keyPair2 didSign:sign2 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert(![keyPair2 didSign:sign1C withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert([keyPair2 didSign:sign2C withOriginalHash:hashedMessage],
              @"Failed");

    // Key Pair 1C Negitive
    XCTAssert([keyPair1C didSign:sign1 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert(![keyPair1C didSign:sign2 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert([keyPair1C didSign:sign1C withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert(![keyPair1C didSign:sign2C withOriginalHash:hashedMessage],
              @"Failed");

    // Key Pair 2C Negitive
    XCTAssert(![keyPair2C didSign:sign1 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert([keyPair2C didSign:sign2 withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert(![keyPair2C didSign:sign1C withOriginalHash:hashedMessage],
              @"Failed");
    XCTAssert([keyPair2C didSign:sign2C withOriginalHash:hashedMessage],
              @"Failed");
  }
  
  // NOTE: No determinisitc sign tests, it may be a good idea to add them...
}

@end
