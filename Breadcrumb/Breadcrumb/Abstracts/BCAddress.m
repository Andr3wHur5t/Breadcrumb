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

@synthesize type = _type;

#pragma mark Construction

- (instancetype)initWithAddressString:(NSString *)addressString {
  if (addressString.length > 35 || addressString.length < 26)
    return NULL;  // These are size constraints provided by here:
                  // https://en.bitcoin.it/wiki/Address
  self = [super init];
  if (self) {
    // The address should by base58check encoded
    _dataRepresentation = addressString.base58checkToData;

    // If the data representation is null we should assume that the checksum
    // validation failed, and the address is invalid.
    if (![_dataRepresentation isKindOfClass:[NSData class]]) return NULL;

    // Get the version byte from the data
    _type = [_dataRepresentation UInt8AtOffset:0];

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

#pragma mark Conversion

+ (BCAddress *)addressFromPublicKey:(NSData *)publicKey {
  NSData *hash;
  NSMutableData *mHash;
  NSString *addressString;
  NSParameterAssert([publicKey isKindOfClass:[NSData class]]);
  if (![publicKey isKindOfClass:[NSData class]]) return NULL;

  // HASH160
  hash = [[publicKey SHA256] RMD160];
  if (![hash isKindOfClass:[NSData class]]) return NULL;

  mHash = [[NSMutableData alloc] init];

  // Because we don't currently support multi-sig use the old version byte
  [mHash appendUInt8:BCAddressType_Old];
  [mHash appendData:hash];

  addressString = [mHash base58CheckEncoding];
  if (![addressString isKindOfClass:[NSString class]]) return NULL;

  return [addressString toBitcoinAddress];
}

@end

@implementation NSString (BCAddress)

- (BCAddress *)toBitcoinAddress {
  return [[BCAddress alloc] initWithAddressString:self];
}

@end
