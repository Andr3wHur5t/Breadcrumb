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

@end
