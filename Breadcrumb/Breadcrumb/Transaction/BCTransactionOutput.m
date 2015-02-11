//
//  BCTransactionOutput.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCTransactionOutput.h"
#import "BCScript+DefaultScripts.h"
#import "BreadcrumbCore.h"

@implementation BCTransactionOutput

@synthesize script = _script;
@synthesize value = _value;
#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  return [self initWithData:data atOffset:0 withLength:NULL];
}

- (instancetype)initWithData:(NSData *)data
                    atOffset:(NSUInteger)offset
                  withLength:(NSUInteger *)length {
  int64_t value;
  NSUInteger scriptLength, valueLength, position = 0;
  NSData *scriptData, *_data;
  BCScript *script;
  NSParameterAssert([data isKindOfClass:[NSData class]]);
  if (![data isKindOfClass:[NSData class]]) return NULL;

  // Get data from offset
  _data = [data subdataWithRange:NSMakeRange(offset, data.length - offset)];
  if (![_data isKindOfClass:[NSData class]]) return NULL;

  // Get the value of the output
  value = [_data UInt64AtOffset:0];
  position += sizeof(uint64_t);

  // Get the scripts length
  scriptLength = [_data varIntAtOffset:position length:&valueLength];
  position += valueLength;

  // Get the scripts data
  scriptData = [_data subdataWithRange:NSMakeRange(position, scriptLength)];
  position += scriptLength;
  if (![scriptData isKindOfClass:[NSData class]]) return NULL;

  script = [BCScript scriptWithData:scriptData];
  if (![script isKindOfClass:[BCScript class]]) return NULL;
  
  if (length) *length = position;

  return [self initWithScript:script andValue:@(value)];
}

- (instancetype)initWithScript:(BCScript *)script andValue:(NSNumber *)value {
  NSParameterAssert([script isKindOfClass:[BCScript class]]);
  NSParameterAssert([value isKindOfClass:[NSNumber class]]);
  if (![script isKindOfClass:[BCScript class]] ||
      ![value isKindOfClass:[NSNumber class]])
    return NULL;

  self = [self init];
  if (self) {
    _script = script;
    _value = value;
  }
  return self;
}

+ (instancetype)outputWithData:(NSData *)data {
  return [[[self class] alloc] initWithData:data];
}

+ (instancetype)outputWithScript:(BCScript *)script andValue:(NSNumber *)value {
  return [[[self class] alloc] initWithScript:script andValue:value];
}

+ (instancetype)standardOutputForAmount:(NSNumber *)amount
                              toAddress:(BCAddress *)address {
  BCScript *transactionScript;
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  NSParameterAssert([amount isKindOfClass:[NSNumber class]]);
  if (![address isKindOfClass:[BCAddress class]] ||
      ![amount isKindOfClass:[NSNumber class]])
    return NULL;

  transactionScript = [BCScript standardTransactionScript:address];
  if (![transactionScript isKindOfClass:[BCScript class]]) return NULL;

  return [self outputWithScript:transactionScript andValue:amount];
}

#pragma mark Fee Calculation

- (NSUInteger)size {
  return [self toData].length;
}

#pragma mark Representations

- (NSString *)toString {
  return [NSString
      stringWithFormat:@"Value: %@\nScript: '%@'", self.value, self.script];
}

- (NSData *)toData {
  uint64_t value, scriptSize;
  NSData *scriptData;
  NSMutableData *buffer = [[NSMutableData alloc] init];

  // Get the script data
  scriptData = [self.script toData];
  if (![scriptData isKindOfClass:[NSData class]]) return NULL;

  // Get the scripts length
  scriptSize = scriptData.length;

  // Get our transaction value.
  value = [self.value unsignedIntegerValue];

  // Append the buffer
  [buffer appendUInt64:value];
  [buffer appendVarInt:scriptSize];
  [buffer appendData:scriptData];

  // Make an immutable copy
  return [NSData dataWithData:buffer];
}

#pragma mark Debug

- (NSString *)description {
  return [self toString];
}

@end
