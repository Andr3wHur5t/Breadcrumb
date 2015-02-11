//
//  BCProtectedData.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCProtectedData.h"
#import "NSData+Encryption.h"
#import "NSMutableData+Bitcoin.h"

@implementation BCProtectedData

@synthesize cypherText = _cypherText;

#pragma mark Construction

- (instancetype)initData:(NSData *)data withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([data isKindOfClass:[NSData class]]);
    NSParameterAssert([[self class] keyIsValidForAlgorithm:memoryKey]);
    if (![data isKindOfClass:[NSData class]] ||
        ![[self class] keyIsValidForAlgorithm:memoryKey])
      return NULL;

    // We want to use secure mutable data because it will zero it self out.
    _cypherText = [NSMutableData
        secureDataWithData:[[self class] encrypt:data withKey:memoryKey]];
  }
  return self;
}

+ (instancetype)protectedData:(NSData *)data withMemoryKey:(NSData *)memoryKey {
  return [[[self class] alloc] initData:data withMemoryKey:memoryKey];
}

#pragma mark Retrieval

- (NSData *)dataUsingMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([[self class] keyIsValidForAlgorithm:memoryKey]);
    if (![[self class] keyIsValidForAlgorithm:memoryKey]) return NULL;

    // Attempt to decrypt the entered data, return secure data so it will zero
    // it self out.
    return [NSMutableData secureDataWithData:[[self class] decrypt:_cypherText
                                                           withKey:memoryKey]];
  }
}

#pragma mark Algorithm Implementation

+ (NSData *)encrypt:(NSData *)data withKey:(NSData *)key {
  @autoreleasepool {
    NSData *cypherText = [data AES256Encrypt:key];
    return [cypherText isKindOfClass:[NSData class]] ? cypherText : NULL;
  }
}

+ (NSData *)decrypt:(NSData *)data withKey:(NSData *)key {
  @autoreleasepool {
    NSData *clearText = [data AES256Decrypt:key];
    return [clearText isKindOfClass:[NSData class]] ? clearText : NULL;
  }
}

+ (BOOL)keyIsValidForAlgorithm:(NSData *)key {
  @autoreleasepool {
    // AES Requires key to be in quantities of 32 bytes
    return [key isKindOfClass:[NSData class]] && key.length % 32 == 0;
  }
}

@end

@implementation NSData (BCProtectedData)

- (BCProtectedData *)protectedWithKey:(NSData *)key {
  @autoreleasepool {
    return [BCProtectedData protectedData:self withMemoryKey:key];
  }
}

@end
