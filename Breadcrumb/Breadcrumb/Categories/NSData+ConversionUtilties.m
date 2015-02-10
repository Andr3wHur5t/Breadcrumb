//
//  NSData+ConversionUtilties.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "NSData+ConversionUtilties.h"

@implementation NSData (ConversionUtilties)

- (NSString *)toHex {
  NSUInteger dataLength = [self length];
  NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*2];
  const unsigned char *dataBytes = [self bytes];
  for (NSInteger idx = 0; idx < dataLength; ++idx) {
    [string appendFormat:@"%02x", dataBytes[idx]];
  }
  return string;
}

@end
