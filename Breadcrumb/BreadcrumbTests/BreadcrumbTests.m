//
//  BreadcrumbTests.m
//  BreadcrumbTests
//
//  Created by Andrew Hurst on 2/4/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Breadcrumb.h"
#import <XCTest/XCTest.h>

@interface BreadcrumbTests : XCTestCase

@end

@implementation BreadcrumbTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each
  // test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each
  // test method in the class.
  [super tearDown];
}

#pragma mark RIPMD 160

- (void)testRMD160 {
  for (NSUInteger i = 0; i < 20; ++i)
    XCTAssert([self RMD160:@"Rosetta Code"
                    outHex:@"b3be159860842cebaa7174c8fff0aa9e50a5199f"],
              @"Failed!");
}

- (BOOL)RMD160:(NSString *)input outHex:(NSString *)outputHex {
  NSLog(@"%@", [[input dataUsingEncoding:NSASCIIStringEncoding] RMD160]);
  return [[[input dataUsingEncoding:NSASCIIStringEncoding] RMD160]
      isEqualToData:[outputHex hexToData]];
}

#pragma mark Base58

- (void)testBase58 {
  // Base58 encoding (Note Failure to encode...)
  XCTAssert([[@"deadBeeF".hexToData base58Encoding] isEqualToString:@"6h8cQN"],
            @"Encodes base58");
  XCTAssert([[[@"6h8cQN" base58ToData] toHex] isEqual:@"deadbeef"],
            @"Decodes base58");
  XCTAssert([[[[[self class] transactionOneHex]
                    .hexToData base58Encoding] base58ToData]
                isEqualToData:[[self class] transactionOneHex].hexToData],
            @"Full Encoding Check");
}

- (void)testBase58Check {
  // Base58 Check Encoding
  XCTAssert([[@"00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"
                    .hexToData base58CheckEncoding]
                isEqualToString:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"],
            @"Encodes base58 with checksum");
  XCTAssert([[[@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T" base58checkToData] toHex]
                isEqual:@"00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"],
            @"Decodes base58 with checksum");
  XCTAssert([[[[[self class] transactionOneHex]
                    .hexToData base58CheckEncoding] base58checkToData]
                isEqualToData:[[self class] transactionOneHex].hexToData],
            @"Full Encoding Check");
}

#pragma mark Data

+ (NSString *)transactionOneHex {
  return
      @"0100000002be6ee63b7c778f1c31c4710dbffa599b9ec8a9c0fd0e65f7f08d1077ef2f0"
      @"7e4000000006a473044022028758879bba44439ab8ad5be025ff9d8acc38206f626d1c"
      @"a4a1dbf0af343265302205bb7db56d5426bd11810ed06bf50ae2a018bc7cc8639d6dfc"
      @"5e7fdc9f052c13f01210387212e3733d75ddcce9121c2af5df1f06e71f63fb736df4dc"
      @"02dc56e9f3c4f02ffffffff97515bb7f32f28446bfe7b34b232b1e9ad1221f1d4ab462"
      @"4726412764b126611000000006a47304402200c3dd4af3a7e273aab864d797d18b1b05"
      @"a5f1980a19fd27e8a5de8d3c3ec8cdf02203718499f163104d162d67d1a095bbc9c443"
      @"db9d8ca03207a461aefe4e16f394301210387212e3733d75ddcce9121c2af5df1f06e7"
      @"1f63fb736df4dc02dc56e9f3c4f02ffffffff0228230000000000001976a914dc8ae9c"
      @"bf82a840cb562793cc1928bd485cc531888ac50c30000000000001976a9143696e32f2"
      @"e5ee974ce59b16a11387dcf05435d6a88ac00000000";
  ;
}

@end
