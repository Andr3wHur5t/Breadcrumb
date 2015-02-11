//
//  BCScript.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCScript.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"

@interface BCScript ()

/*!
 @brief The buffer the script will be written into.
 */
@property(strong, nonatomic, readonly) NSMutableData *buffer;

#pragma mark Mutation

- (void)writeOpCode:(BCScriptOpCode)opCode;

- (void)writeBytes:(NSData *)data;

@end

@implementation BCScript

@synthesize buffer = _buffer;

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  self = [self init];
  if (self) [self.buffer setData:data];
  return self;
}

+ (instancetype)scriptWithData:(NSData *)data {
  return [[[self class] alloc] initWithData:data];
}

+ (instancetype)script {
  return [[[self class] alloc] init];
}

#pragma mark Internal

- (NSMutableData *)buffer {
  if (!_buffer) _buffer = [[NSMutableData alloc] init];
  return _buffer;
}

#pragma mark Mutation

- (void)writeOpCode:(BCScriptOpCode)opCode {
  [self.buffer appendUInt8:opCode];
}

- (void)writeBytes:(NSData *)data {
  NSParameterAssert([data isKindOfClass:[NSData class]] && data.length != 0);
  if (data.length == 0 || ![data isKindOfClass:[NSData class]]) return;

  // Check which mode to write the data, and write the opCode/length.
  if (data.length < OP_PUSHDATA1) {
    [self.buffer appendUInt8:data.length];
  } else if (data.length < UINT8_MAX) {
    [self writeOpCode:OP_PUSHDATA1];
    [self.buffer appendUInt8:data.length];
  } else if (data.length < UINT16_MAX) {
    [self writeOpCode:OP_PUSHDATA2];
    [self.buffer appendUInt16:data.length];
  } else {
    [self writeOpCode:OP_PUSHDATA4];
    [self.buffer appendUInt32:(uint32_t)data.length];
  }

  // Append the data after the opcode, and size.
  [self.buffer appendData:data];
}

#pragma mark Representation

- (NSData *)toData {
  // write our current bytes into an immutable object, and return it
  return [NSData dataWithBytes:self.buffer.bytes length:self.buffer.length];
}

- (NSString *)toString {
  BOOL lastWasOpCode;
  NSString *script, *nextSegment;
  const char *bytes;

  script = @"";
  lastWasOpCode = TRUE;
  bytes = [self.buffer bytes];

  // Process the bytes to get the human readable string
  for (NSUInteger i = 0; i < [self.buffer length]; i++) {
    // Attempt to get an op code from the current byte, append with a string for
    // readability
    nextSegment = [stringFromScriptOpCode(bytes[i])
        stringByAppendingString:i + 1 < [self.buffer length] ? @" " : @""];

    if (![nextSegment isKindOfClass:[NSString class]]) {
      // Failed to get an op code, attempt to look for pushed data. pass an
      // index
      // so we can jump to an index if we find data.
      nextSegment = [self processPushedData:bytes atIndex:&i];

      // Update char status so we can do spacing properly
      lastWasOpCode = FALSE;
    } else {
      if (!lastWasOpCode)
        nextSegment = [@" " stringByAppendingString:nextSegment];
      // Update char status so we can do spacing properly
      lastWasOpCode = TRUE;
    }

    // My safety hamlet
    if ([nextSegment isKindOfClass:[NSString class]])
      script = [script stringByAppendingString:nextSegment];
  }
  return script;
}

- (NSString *)processPushedData:(const char *)bytes atIndex:(NSUInteger *)i {
  NSString *processedValue;
  NSUInteger lengthToRead;

  // Look For Push Data Opcodes and extract the length needed to read.
  if (bytes[*i] < OP_PUSHDATA1)
    lengthToRead = [self.buffer UInt8AtOffset:*i];
  else if (bytes[*i] == OP_PUSHDATA2)
    lengthToRead = [self.buffer UInt16AtOffset:*i + 1];
  else if (bytes[*i] == OP_PUSHDATA4)
    lengthToRead = [self.buffer UInt32AtOffset:*i + 1];
  else
    return NULL;

  // Processes the pushed bytes into hex.
  processedValue = @"";
  for (NSUInteger q = 0; q < lengthToRead; ++q) {
    processedValue = [processedValue
        stringByAppendingString:[NSString stringWithFormat:@"%02hhx",
                                                           bytes[*i + 1 + q]]];
  }

  // Jump pass the bytes we just proccessed
  *i += lengthToRead;

  // Retun the hex of the values
  return processedValue;
}

#pragma mark Debug

- (NSString *)debugDescription {
  return [self toString];
}

- (NSString *)description {
  return [self toString];
}

@end

@implementation BCMutableScript

#pragma mark Mutation

- (void)writeOpCode:(BCScriptOpCode)opCode {
  [super writeOpCode:opCode];
}

- (void)writeBytes:(NSData *)data {
  [super writeBytes:data];
}

@end
