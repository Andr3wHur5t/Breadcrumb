//
//  BCAAddress.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCAAddress.h"
#import "BreadcrumbCore.h"

@implementation BCAAddress

#pragma mark Construction

- (instancetype)initWithAddressString:(NSString *)addressString {
  NSAssert(FALSE, @"Called method on abstract class.");
  return NULL;
}

#pragma mark Info

- (NSString *)stringRepresentation {
  NSAssert(FALSE, @"Called method on abstract class.");
  return NULL;
}

#pragma mark Debugging

- (NSString *)debugDescription {
  return [self description];
}

- (NSString *)description {
  return self.stringRepresentation;
}

#pragma mark Comparison

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[self class]]) return FALSE;
  return [self.stringRepresentation
      isEqualToString:((BCAAddress *)object).stringRepresentation];
}

@end
