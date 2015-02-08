//
//  BCScript+DefaultScripts.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCScript+DefaultScripts.h"

@implementation BCScript (DefaultScripts)

+ (instancetype)standardTransactionScript:(BCAddress *)address {
  BCMutableScript *script;
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  if (![address isKindOfClass:[BCAddress class]]) return NULL;

  script = [BCMutableScript script];
  [script writeOpCode:OP_DUP];
  [script writeOpCode:OP_HASH160];
  [script writeBytes:[address toData]];
  [script writeOpCode:OP_EQUALVERIFY];
  [script writeOpCode:OP_CHECKSIG];

  return script;
}

@end
