//
//  BCScript+DefaultScripts.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import "BCScript+DefaultScripts.h"

@implementation BCScript (DefaultScripts)

+ (instancetype)standardTransactionScript:(BCAddress *)address {
  BCMutableScript *script;
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  if (![address isKindOfClass:[BCAddress class]]) return NULL;

  script = [BCMutableScript script];
  if (![script isKindOfClass:[BCMutableScript class]]) return NULL;

  // Write the script
  [script writeOpCode:OP_DUP];
  [script writeOpCode:OP_HASH160];

  // The type is redundant, drop it here.
  [script writeBytes:[address toDataWithoutType]];

  [script writeOpCode:OP_EQUALVERIFY];
  [script writeOpCode:OP_CHECKSIG];

  // Return the script, Note we don't need to convert to an immutable instance
  // because mutable methods are technically available on BCScript but
  // inaccessible unless you manually call it via -()performSelector:(SEL);
  return [script isKindOfClass:[BCScript class]]
             ? [BCScript scriptWithData:[script toData]]
             : NULL;
}

@end
