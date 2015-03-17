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
#import "BCPublicKey.h"

@implementation BCScript (DefaultScripts)

+ (instancetype)standardTransactionScript:(BCAddress *)address {
  BCMutableScript *script;
  NSParameterAssert([address isKindOfClass:[BCAddress class]]);
  if (![address isKindOfClass:[BCAddress class]]) return NULL;

  script = [BCMutableScript script];
  if (![script isKindOfClass:[BCMutableScript class]]) return NULL;

  // Check if it is a P2SH address
  if (address.typeCode == 0x05) {
    [script writeOpCode:OP_HASH160];
    [script writeBytes:[address toDataWithoutType]];
    [script writeOpCode:OP_EQUAL];

  } else {
    // Write the script
    [script writeOpCode:OP_DUP];
    [script writeOpCode:OP_HASH160];

    // The type is redundant
    [script writeBytes:[address toDataWithoutType]];

    [script writeOpCode:OP_EQUALVERIFY];
    [script writeOpCode:OP_CHECKSIG];
  }
  // Return the script, Note we don't need to convert to an immutable instance
  // because mutable methods are technically available on BCScript but
  // inaccessible unless you manually call it via -()performSelector:(SEL);
  return [script isKindOfClass:[BCScript class]]
             ? [BCScript scriptWithData:[script toData]]
             : NULL;
}

+ (instancetype)multisigScriptWithPubkeys:(NSArray *)pubkeys
                     andMinumumSignitures:(uint8_t)minSignitures {
  BCMutableScript *script;
  BCScriptOpCode minSigs, totalSigs;
  NSParameterAssert([pubkeys isKindOfClass:[NSArray class]]);
  if (![pubkeys isKindOfClass:[NSArray class]]) return NULL;

  // Get Min sigs count
  minSigs = OP_(minSignitures);
  if (minSigs == OP_NOP1) return NULL;  // Out of range

  // Get Total Sigs Count
  totalSigs = OP_((uint16_t)pubkeys.count);
  if (totalSigs == OP_NOP1 || totalSigs == OP_0) return NULL;  // Out of range

  // Write Script
  script = [[BCMutableScript alloc] init];

  [script writeOpCode:minSigs];
  for (BCPublicKey *pubKey in pubkeys) [script writeBytes:pubKey.data];
  [script writeOpCode:totalSigs];
  [script writeOpCode:OP_CHECKMULTISIG];

  return [script isKindOfClass:[BCScript class]] ? script : NULL;
}

+ (instancetype)opReturnScriptWithData:(NSData *)data {
  BCMutableScript *script;
  NSParameterAssert([data isKindOfClass:[NSData class]] && data.length < 40);
  if (![data isKindOfClass:[NSData class]] || data.length > 40) return NULL;
  script = [[BCMutableScript alloc] init];

  [script writeOpCode:OP_RETURN];
  [script writeBytes:data];

  return [script isKindOfClass:[BCScript class]] ? script : NULL;
}

@end
