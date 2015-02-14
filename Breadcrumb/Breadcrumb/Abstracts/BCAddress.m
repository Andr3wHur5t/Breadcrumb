//
//  BCAddress.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCAddress.h"
#import "BreadcrumbCore.h"

@interface BCAddress () {
  NSString *_stringRepresentation;
  NSData *_dataRepresentation;
}

@end

@implementation BCAddress

#pragma mark Construction

- (instancetype)initWithAddressString:(NSString *)addressString {
  self = [super init];
  if (self) {
    // TODO: Add base 58 utility
    //    _dataRepresentation = addressString.base58ToData;
//    if (![_dataRepresentation isKindOfClass:[NSData class]]) return NULL;
    _stringRepresentation = addressString;
  }
  return self;
}

+ (instancetype)addressWithString:(NSString *)address {
  return [[[self class] alloc] initWithAddressString:address];
}

#pragma mark Info

- (NSString *)toString {
  return _stringRepresentation;
}

- (NSData *)toData {
  return _dataRepresentation;
}

#pragma mark Debugging

- (NSString *)debugDescription {
  return [self description];
}

- (NSString *)description {
  return [self toString];
}

#pragma mark Comparison

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[self class]]) return FALSE;
  return [[self toString] isEqualToString:[((BCAddress *)object)toString]];
}

@end

@implementation NSString (BCAddress)

- (BCAddress *)toBitcoinAddress {
  return [[BCAddress alloc] initWithAddressString:self];
}

@end
