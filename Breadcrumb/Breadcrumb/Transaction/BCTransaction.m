//
//  BCTransaction.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/7/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCTransaction.h"
#import "BCScript+DefaultScripts.h"
#import "BreadcrumbCore.h"

@implementation BCTransaction

@synthesize addresses = _addresses;
@synthesize script = _script;
@synthesize hash = _hash;
@synthesize outputIndex = _outputIndex;

@synthesize value = _value;
@synthesize spent = _spent;
@synthesize confirmations = _confirmations;

@synthesize isSigned = _isSigned;

#pragma mark Construction

- (instancetype)initWithAddresses:(NSArray *)addresses
                           script:(BCScript *)script
                             hash:(NSData *)hash
                      outputIndex:(uint32_t)outputIndex
                            value:(NSNumber *)value
                            spent:(NSNumber *)spent
                    confirmations:(NSNumber *)confirmations
                        andSigned:(BOOL)isSigned {
  self = [super init];
  if (self) {
    // Validate addresses
    if (![addresses isKindOfClass:[NSArray class]]) return NULL;
    for (NSUInteger i = 0; i < addresses.count; ++i)
      if (![[addresses objectAtIndex:i] isKindOfClass:[BCAddress class]])
        return NULL;
    _addresses = addresses;

    if (![script isKindOfClass:[BCScript class]]) return NULL;
    _script = script;
    if (![hash isKindOfClass:[NSData class]]) return NULL;
    _hash = hash;

    _outputIndex = outputIndex;

    if (![value isKindOfClass:[NSNumber class]]) return NULL;
    _value = value;
    if (![spent isKindOfClass:[NSNumber class]]) return NULL;
    _spent = spent;

    // Optional value, can be NULL
    _confirmations =
        [confirmations isKindOfClass:[NSNumber class]] ? confirmations : NULL;
    _isSigned = isSigned;
  }
  return self;
}

#pragma mark Debug

- (NSString *)description {
  NSString *addresses;
  for (BCAddress *address in self.addresses)
    if ([addresses isKindOfClass:[NSString class]]) {
      addresses =
          [NSString stringWithFormat:@"%@, %@", addresses, [address toString]];
    } else {
      addresses = [address toString];
    }

  return [NSString stringWithFormat:@"Address(es): %@\nValue: %@\nSpent: %@\n"
                                    @"Confirmations: %@\nHash: %@\nOutput "
                                    @"Index:%@\nScript: '%@'\nisSigned: %@\n",
                                    addresses, self.value, self.spent,
                                    self.confirmations, self.hash.toHex,
                                    @(self.outputIndex), self.script,
                                    self.isSigned ? @"true" : @"false"];
}

@end
