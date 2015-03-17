//
//  BCAddress.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "BCAddress.h"
#import "BCCoin.h"
#import "BreadcrumbCore.h"
#import "BCScript.h"

@interface BCAddress () {
  NSString *_stringRepresentation;
  NSData *_dataRepresentation;
}

@end

@implementation BCAddress

@synthesize typeCode = _typeCode;

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
    _typeCode = [_dataRepresentation UInt8AtOffset:0];

    _stringRepresentation = addressString;
  }
  return self;
}

- (instancetype)initWithScript:(BCScript *)script usingCoin:(BCCoin *)coin {
  NSMutableData *buffer;
  NSParameterAssert([script isKindOfClass:[BCScript class]]);
  if (![script isKindOfClass:[BCScript class]]) return NULL;

  self = [super init];
  if (!self) return NULL;

  // P2SH Type code
  _typeCode = coin.P2SHCode;
  buffer = [[NSMutableData alloc] init];
  if (![buffer isKindOfClass:[NSMutableData class]]) return NULL;

  [buffer appendUInt8:_typeCode];

  // Hash160
  [buffer appendData:[[[script toData] SHA256] RMD160]];

  _dataRepresentation = [NSData dataWithData:buffer];
  _stringRepresentation = [_dataRepresentation base58CheckEncoding];

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

- (NSData *)toDataWithoutType {
  return [_dataRepresentation
      subdataWithRange:NSMakeRange(1, _dataRepresentation.length - 1)];
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

- (BOOL)isEqualExcludingVersion:(BCAddress *)address {
  NSData *addr1, *addr2;
  addr1 = [self toData];
  addr1 = [addr1 subdataWithRange:NSMakeRange(1, addr1.length - 1)];

  addr2 = [address toData];
  addr2 = [addr2 subdataWithRange:NSMakeRange(1, addr2.length - 1)];

  return [addr1 isEqualToData:addr2];
}

#pragma mark Conversion

+ (BCAddress *)addressFromPublicKey:(NSData *)publicKey
                          usingCoin:(BCCoin *)coin {
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
  [mHash appendUInt8:[coin addressTypeForFlags:0]];
  [mHash appendData:hash];

  addressString = [mHash base58CheckEncoding];
  if (![addressString isKindOfClass:[NSString class]]) return NULL;

  return [addressString toBitcoinAddress];
}

+ (BCAddress *)addressFromScript:(BCScript *)script usingCoin:(BCCoin *)coin {
  return [[[self class] alloc] initWithScript:script usingCoin:(BCCoin *)coin];
}

@end

@implementation NSString (BCAddress)

- (BCAddress *)toBitcoinAddress {
  return [[BCAddress alloc] initWithAddressString:self];
}

@end
