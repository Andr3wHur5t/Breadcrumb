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

@synthesize scriptSig = _scriptSig;
@synthesize isSigned = _isSigned;

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  NSUInteger position, length, scriptLength;
  uint32_t transactionIndex, sequence;
  NSData *scriptData, *transactionHash;
  BCScript *script;
  NSParameterAssert([data isKindOfClass:[NSData class]]);
  if (![data isKindOfClass:[NSData class]]) return NULL;

  // Parse Data
  position = 0;
  transactionHash = [data subdataWithRange:NSMakeRange(position, 32)];
  position += 32;
  transactionIndex = [data UInt32AtOffset:position];
  position += sizeof(uint32_t);
  scriptLength = [data varIntAtOffset:position length:&length];
  position += length;
  scriptData = [data subdataWithRange:NSMakeRange(position, scriptLength)];
  position += scriptLength;
  sequence = [data UInt32AtOffset:position];
  if (![scriptData isKindOfClass:[NSData class]]) return NULL;

  script = [BCScript scriptWithData:scriptData];
  if (![script isKindOfClass:[BCScript class]]) return NULL;

  // TODO: Specify Sig script
  return [self initWithHash:transactionHash
              previousIndex:transactionIndex
                     script:script
                andSequence:sequence];
}

- (instancetype)initWithTransaction:(BCTransaction *)transaction {
  NSParameterAssert([transaction isKindOfClass:[BCTransaction class]]);
  if (![transaction isKindOfClass:[BCTransaction class]]) return NULL;

  return [self initWithHash:transaction.hash
              previousIndex:transaction.outputIndex
                  andScript:transaction.script];
}

- (instancetype)initWithHash:(NSData *)hash
               previousIndex:(uint32_t)index
                   andScript:(BCScript *)script {
  return [self initWithHash:hash
              previousIndex:index
                     script:script
                andSequence:UINT32_MAX];
}

- (instancetype)initWithHash:(NSData *)hash
               previousIndex:(uint32_t)index
                      script:(BCScript *)script
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
  }
  return self;
}

#pragma mark Representations

- (NSString *)toString {
  return [NSString stringWithFormat:@"Output Hash: '%@'\nOutput Index: %@\nSig "
                                    @"Script: '%@'\nSigned: %@\nSequence: %x",
                                    self.previousOutputHash,
                                    @(self.previousOutputIndex), self.scriptSig,
                                    self.isSigned ? @"True" : @"False",
                                    self.sequence];
}

- (NSData *)toData {
  NSData *scriptData;
  NSMutableData *buffer;

  buffer = [[NSMutableData alloc] init];

  // TODO: Change to Sig Script
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
