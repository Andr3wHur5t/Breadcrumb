//
//  BCTransactionInput.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCTransactionInput.h"
#import "BreadcrumbCore.h"

@implementation BCTransactionInput

@synthesize previousOutputHash = _previousOutputHash;
@synthesize previousOutputIndex = _previousOutputIndex;
@synthesize sequence = _sequence;
@synthesize controllingAddress = _controllingAddress;

@synthesize scriptSig = _scriptSig;
@synthesize isSigned = _isSigned;

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  return [self initWithData:data atOffset:0 withLength:NULL];
}

- (instancetype)initWithData:(NSData *)data
                    atOffset:(NSUInteger)offset
                  withLength:(NSUInteger *)length {
  NSUInteger position, _length, scriptLength;
  uint32_t transactionIndex, sequence;
  NSData *scriptData, *transactionHash, *_data;
  BCScript *script;
  NSParameterAssert([data isKindOfClass:[NSData class]]);
  if (![data isKindOfClass:[NSData class]]) return NULL;

  // Get the data in the correct range
  _data = [data subdataWithRange:NSMakeRange(offset, data.length - offset)];
  if (![_data isKindOfClass:[NSData class]]) return NULL;

  // Parse Data
  position = 0;  // Get the transaction Hash
  transactionHash = [_data subdataWithRange:NSMakeRange(position, 32)];
  position += 32;

  // Get the transaction output index
  transactionIndex = [_data UInt32AtOffset:position];
  position += sizeof(uint32_t);

  // Get the scripts length
  scriptLength = [_data varIntAtOffset:position length:&_length];
  position += _length;

  // Get the scripts data
  scriptData = [_data subdataWithRange:NSMakeRange(position, scriptLength)];
  position += scriptLength;

  // Get the sequence value
  sequence = [_data UInt32AtOffset:position];
  position += sizeof(uint32_t);

  // Check the script data
  if (![scriptData isKindOfClass:[NSData class]]) return NULL;

  script = [BCScript scriptWithData:scriptData];
  if (![script isKindOfClass:[BCScript class]]) return NULL;

  // Update Length if available
  if (length) *length = position;

  return [self initWithHash:transactionHash
              previousIndex:transactionIndex
                     script:script
                    address:NULL
                andSequence:sequence];
}

- (instancetype)initWithTransaction:(BCTransaction *)transaction {
  NSParameterAssert([transaction isKindOfClass:[BCTransaction class]]);
  if (![transaction isKindOfClass:[BCTransaction class]]) return NULL;

  return [self initWithHash:transaction.hash
              previousIndex:transaction.outputIndex
                     script:transaction.script
                    address:[transaction.addresses objectAtIndex:0]
                andSequence:UINT32_MAX];
}

- (instancetype)initWithHash:(NSData *)hash
               previousIndex:(uint32_t)index
                      script:(BCScript *)script
                     address:(BCAddress *)address
                 andSequence:(uint32_t)sequence {
  NSParameterAssert([hash isKindOfClass:[NSData class]]);
  if (![hash isKindOfClass:[NSData class]]) return NULL;
  self = [self init];
  if (self) {
    _previousOutputHash = hash;
    _previousOutputIndex = index;
    _scriptSig = script;
    _sequence = sequence;
    _isSigned = FALSE;
    _controllingAddress = address;
  }
  return self;
}

#pragma mark Fee Calculation

- (NSUInteger)size {
  return [self toData].length;
}

#pragma mark Representations

- (NSString *)toString {
  return [NSString stringWithFormat:@"Output Hash: '%@'\nOutput Index: %@\nSig "
                                    @"Script: '%@'\nSigned: %@\nSequence: %x",
                                    self.previousOutputHash.toHex,
                                    @(self.previousOutputIndex), self.scriptSig,
                                    self.isSigned ? @"True" : @"False",
                                    self.sequence];
}

- (NSData *)toData {
  NSData *scriptData;
  NSMutableData *buffer;

  buffer = [[NSMutableData alloc] init];

  scriptData = [self.scriptSig toData];
  if (![scriptData isKindOfClass:[NSData class]]) return NULL;

  [buffer appendData:self.previousOutputHash];
  [buffer appendUInt32:self.previousOutputIndex];
  [buffer appendVarInt:scriptData.length];
  [buffer appendData:scriptData];
  [buffer appendUInt32:self.sequence];

  return [NSData dataWithData:buffer];
}

#pragma mark Debug

- (NSString *)description {
  return [self toString];
}

@end
