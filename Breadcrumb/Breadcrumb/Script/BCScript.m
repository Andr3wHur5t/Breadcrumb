//
//  BCScript.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import "BCScript.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "BreadcrumbCore.h"
#import "BCPublicKey.h"

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
  [self.buffer appendUInt8:(uint8_t)opCode];
}

- (void)writeBytes:(NSData *)data {
  NSParameterAssert([data isKindOfClass:[NSData class]] && data.length != 0);
  if (data.length == 0 || ![data isKindOfClass:[NSData class]]) return;

  // Check which mode to write the data, and write the opCode/length.
  if (data.length < OP_PUSHDATA1) {
    [self.buffer appendUInt8:(uint8_t)data.length];
  } else if (data.length < UINT8_MAX) {
    [self writeOpCode:OP_PUSHDATA1];
    [self.buffer appendUInt8:(uint8_t)data.length];
  } else if (data.length < UINT16_MAX) {
    [self writeOpCode:OP_PUSHDATA2];
    [self.buffer appendUInt16:(uint8_t)data.length];
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

- (BCAddress *)P2SHAddressForCoin:(BCCoin *)coin {
  return [BCAddress addressFromScript:self usingCoin:coin];
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

  // Jump pass the bytes we just processed
  *i += lengthToRead;

  // Return the hex of the values
  return processedValue;
}

- (NSArray *)elements {
  return [_buffer scriptElements];
}

- (NSString *)descriptionInMode:(BOOL)printLong {
  id object;
  NSMutableString *str = [[NSMutableString alloc] init];
  NSArray *elements = [self elements];

  for (NSUInteger i = 0; i < elements.count; ++i) {
    object = [elements objectAtIndex:i];
    if ([object isKindOfClass:[NSNumber class]]) {
      [str appendString:stringFromScriptOpCode((BCScriptOpCode)[object intValue])];

    } else if ([object isKindOfClass:[NSData class]]) {
      if (printLong)
        [str appendFormat:@"('%@' [%lu bytes])", ((NSData *)object).toHex,
                          ((NSData *)object).length];
      else
        [str appendFormat:@"'%@'", ((NSData *)object).toHex];
    }
    if (i + 1 < elements.count) [str appendString:printLong ? @" \n" : @" "];
  }

  return str;
}

- (BCScriptType)type {
  BCScriptOpCode firstCode, secondCode, secondToLastCode, lastCode;
  firstCode = (BCScriptOpCode)[_buffer UInt8AtOffset:0];
  secondCode = (BCScriptOpCode)[_buffer UInt8AtOffset:1];
  secondToLastCode = (BCScriptOpCode)[_buffer UInt8AtOffset:_buffer.length - 2];
  lastCode = (BCScriptOpCode)[_buffer UInt8AtOffset:_buffer.length - 1];
  // Calculate type

  if (firstCode == OP_RETURN) {
    // Check For Non Standard
    // Check Push Data Length
    // OP_RETURN <message>
    return BCScriptType_OPReturn;
  }

  if (firstCode == OP_HASH160 && lastCode == OP_EQUAL) {
    // Check Push Data Length
    // OP_HASH160 <20 bytes of script hash> OP_EQUAL
    return BCScriptType_P2SH;
  }

  if (firstCode == OP_DUP && secondCode == OP_HASH160 &&
      secondToLastCode == OP_EQUALVERIFY && lastCode == OP_CHECKSIG) {
    // OP_DUP OP_HASH160 <20 bytes of public key hash> OP_EQUALVERIFY
    // OP_CHECKSIG
    return BCScriptType_P2PKH;
  }

  // Check For Push Data
  if (lastCode == OP_CHECKSIG) {
    // <33 or 65 bytes of public key> OP_CHECKSIG
    return BCScriptType_P2PK;
  }

  if (numFromOP_(firstCode) != UINT16_MAX &&
      numFromOP_(secondToLastCode) != UINT16_MAX &&
      lastCode == OP_CHECKMULTISIG) {
    // OP_<m> [n <public key>s] OP_<n> OP_CHECKMULTISIG
    return BCScriptType_MofN;
  }

  return BCScriptType_NonStandard;
}

#pragma mark Debug

- (NSString *)description {
  return [NSString stringWithFormat:@"('%@', \"%@\")",
                                    [[self class] stringFromType:self.type],
                                    [self descriptionInMode:false]];
}

+ (NSString *)stringFromType:(BCScriptType)type {
  switch (type) {
    case BCScriptType_P2SH:
      return @"P2SH";
      break;
    case BCScriptType_P2PK:
      return @"P2PK";
      break;
    case BCScriptType_P2PKH:
      return @"P2PKH";
      break;
    case BCScriptType_OPReturn:
      return @"OP_Return";
      break;
    case BCScriptType_MofN:
      return @"M-of-N";
      break;
    default:
    case BCScriptType_NonStandard:
      return @"Non Standard";
      break;
  }
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
