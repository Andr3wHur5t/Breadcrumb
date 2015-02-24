//
//  BCAddressTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/17/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "Breadcrumb.h"
#import <XCTest/XCTest.h>

@interface BCAddressTests : XCTestCase

@end

@implementation BCAddressTests
#pragma mark Test Address Parsing

- (void)testAddresses {
  // Valid
  XCTAssert([[BCAddress addressWithString:@"1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i"]
                isKindOfClass:[BCAddress class]],
            @"Failed");

  // Valid
  XCTAssert([[BCAddress addressWithString:@"1Q1pE5vPGEEMqRcVRMbtBK842Y6Pzo6nK9"]
                isKindOfClass:[BCAddress class]],
            @"Failed");

  // Invalid
  XCTAssert(
      ![[BCAddress addressWithString:@"1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62X"]
          isKindOfClass:[BCAddress class]],
      @"Failed");

  // Invalid
  XCTAssert(
      ![[BCAddress addressWithString:@"1ANNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i"]
          isKindOfClass:[BCAddress class]],
      @"Failed");

  // Invalid
  XCTAssert(
      ![[BCAddress addressWithString:@"1A Na15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i"]
          isKindOfClass:[BCAddress class]],
      @"Failed");
}

#pragma mark Address From Public Key

- (void)testAddressFromPublicKeyVector0 {
  // Test Address Generation From Pub Key
  XCTAssert(
      [[BCAddress addressFromPublicKey:@"03f5dfdb9768d46bff4c93952ed7cd9e7"
                                       @"2c944afb00de14335be0e73baf20516b"
                                       @"a".hexToData usingCoin:[BCCoin TestNet3Bitcoin]]
          isEqualExcludingVersion:
              [@"mw2LAcLNSWETLQXEQ7xs237RtkPUDrQTXR" toBitcoinAddress]],
      @"Failed");
}

#pragma mark Address Equality

- (void)testAddressEqualitySameNetwork {
  // Same Value
  XCTAssert(
      [[@"mw2LAcLNSWETLQXEQ7xs237RtkPUDrQTXR" toBitcoinAddress]
          isEqual:[@"mw2LAcLNSWETLQXEQ7xs237RtkPUDrQTXR" toBitcoinAddress]],
      @"Failed");

  // From Diff Network
  XCTAssert(
      ![[@"mw2LAcLNSWETLQXEQ7xs237RtkPUDrQTXR" toBitcoinAddress]
          isEqual:[@"1GWNsZFPdUoCZJ3cgYzVC7u72knmJBhHiQ" toBitcoinAddress]],
      @"Failed");
}

- (void)testAddressEqualityDifNetwork {
  // Same but from diff network
  XCTAssert([[@"mw2LAcLNSWETLQXEQ7xs237RtkPUDrQTXR" toBitcoinAddress]
                isEqualExcludingVersion:
                    [@"1GWNsZFPdUoCZJ3cgYzVC7u72knmJBhHiQ" toBitcoinAddress]],
            @"Failed");
}
@end
