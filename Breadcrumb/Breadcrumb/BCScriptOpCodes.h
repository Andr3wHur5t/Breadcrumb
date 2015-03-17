//
//  BCScriptOpCodes.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//
// Refer to https://en.bitcoin.it/wiki/Script

// Bitcoin Script Op Codes

#ifdef __BCScriptOpCodes__
#else
#define __BCScriptOpCodes__

#import <Foundation/Foundation.h>

typedef int8_t BCScriptOpCode;
typedef int32_t BCScriptSigHashCode;

static const BCScriptSigHashCode SIGHASH_ALL = (BCScriptSigHashCode)0x00000001;
static const BCScriptSigHashCode SIGHASH_NONE = (BCScriptSigHashCode)0x00000002;
static const BCScriptSigHashCode SIGHASH_SINGLE = (BCScriptSigHashCode)0x00000003;
static const BCScriptSigHashCode SIGHASH_ANYONECANPAY = (BCScriptSigHashCode)0x00000080;

static const BCScriptOpCode OP_FALSE = (BCScriptOpCode)0x00;
static const BCScriptOpCode OP_TRUE = (BCScriptOpCode)0x51;

static const BCScriptOpCode OP_0 = (BCScriptOpCode)0x00;
static const BCScriptOpCode OP_1 = (BCScriptOpCode)0x51;
static const BCScriptOpCode OP_2 = (BCScriptOpCode)0x52;
static const BCScriptOpCode OP_3 = (BCScriptOpCode)0x53;
static const BCScriptOpCode OP_4 = (BCScriptOpCode)0x54;
static const BCScriptOpCode OP_5 = (BCScriptOpCode)0x55;
static const BCScriptOpCode OP_6 = (BCScriptOpCode)0x56;
static const BCScriptOpCode OP_7 = (BCScriptOpCode)0x57;
static const BCScriptOpCode OP_8 = (BCScriptOpCode)0x58;
static const BCScriptOpCode OP_9 = (BCScriptOpCode)0x59;
static const BCScriptOpCode OP_10 = (BCScriptOpCode)0x5a;
static const BCScriptOpCode OP_11 = (BCScriptOpCode)0x5b;
static const BCScriptOpCode OP_12 = (BCScriptOpCode)0x5c;
static const BCScriptOpCode OP_13 = (BCScriptOpCode)0x5d;
static const BCScriptOpCode OP_14 = (BCScriptOpCode)0x5e;
static const BCScriptOpCode OP_15 = (BCScriptOpCode)0x5f;
static const BCScriptOpCode OP_16 = (BCScriptOpCode)0x60;

static const BCScriptOpCode OP_PUSHDATA1 = (BCScriptOpCode)0x4c;
static const BCScriptOpCode OP_PUSHDATA2 = (BCScriptOpCode)0x4d;
static const BCScriptOpCode OP_PUSHDATA4 = (BCScriptOpCode)0x4e;

// Control Flow
static const BCScriptOpCode OP_NOP = (BCScriptOpCode)0x61;
static const BCScriptOpCode OP_IF = (BCScriptOpCode)0x63;
static const BCScriptOpCode OP_NOTIF = (BCScriptOpCode)0x64;
static const BCScriptOpCode OP_ELSE = (BCScriptOpCode)0x67;
static const BCScriptOpCode OP_ENDIF = (BCScriptOpCode)0x68;
static const BCScriptOpCode OP_VERIFY = (BCScriptOpCode)0x69;
static const BCScriptOpCode OP_RETURN = (BCScriptOpCode)0x6a;

// Stack
static const BCScriptOpCode OP_TOALTSTACK = (BCScriptOpCode)0x6b;
static const BCScriptOpCode OP_FROMALTSTACK = (BCScriptOpCode)0x6c;
static const BCScriptOpCode OP_IFDUP = (BCScriptOpCode)0x73;
static const BCScriptOpCode OP_DEPTH = (BCScriptOpCode)0x74;
static const BCScriptOpCode OP_DROP = (BCScriptOpCode)0x75;
static const BCScriptOpCode OP_DUP = (BCScriptOpCode)0x76;
static const BCScriptOpCode OP_NIP = (BCScriptOpCode)0x77;
static const BCScriptOpCode OP_OVER = (BCScriptOpCode)0x78;
static const BCScriptOpCode OP_PICK = (BCScriptOpCode)0x79;
static const BCScriptOpCode OP_ROLL = (BCScriptOpCode)0x7a;
static const BCScriptOpCode OP_ROT = (BCScriptOpCode)0x7b;
static const BCScriptOpCode OP_SWAP = (BCScriptOpCode)0x7c;
static const BCScriptOpCode OP_TUCK = (BCScriptOpCode)0x7d;
static const BCScriptOpCode OP_2DROP = (BCScriptOpCode)0x6d;
static const BCScriptOpCode OP_2DUP = (BCScriptOpCode)0x6e;
static const BCScriptOpCode OP_3DUP = (BCScriptOpCode)0x6f;
static const BCScriptOpCode OP_2OVER = (BCScriptOpCode)0x70;
static const BCScriptOpCode OP_2ROT = (BCScriptOpCode)0x71;
static const BCScriptOpCode OP_2SWAP = (BCScriptOpCode)0x72;

// Splice
static const BCScriptOpCode OP_SIZE = (BCScriptOpCode)0x82;

// Bitwise Logic
static const BCScriptOpCode OP_EQUAL = (BCScriptOpCode)0x87;
static const BCScriptOpCode OP_EQUALVERIFY = (BCScriptOpCode)0x88;

// Arithmetic
static const BCScriptOpCode OP_1ADD = (BCScriptOpCode)0x8b;
static const BCScriptOpCode OP_1SUB = (BCScriptOpCode)0x8c;
static const BCScriptOpCode OP_NEGATE = (BCScriptOpCode)0x8f;
static const BCScriptOpCode OP_ABS = (BCScriptOpCode)0x90;
static const BCScriptOpCode OP_NOT = (BCScriptOpCode)0x91;
static const BCScriptOpCode OP_0NOTEQUAL = (BCScriptOpCode)0x92;
static const BCScriptOpCode OP_ADD = (BCScriptOpCode)0x93;
static const BCScriptOpCode OP_SUB = (BCScriptOpCode)0x94;
static const BCScriptOpCode OP_BOOLAND = (BCScriptOpCode)0x9a;
static const BCScriptOpCode OP_BOOLOR = (BCScriptOpCode)0x9b;
static const BCScriptOpCode OP_NUMEQUAL = (BCScriptOpCode)0x9c;
static const BCScriptOpCode OP_NUMEQUALVERIFY = (BCScriptOpCode)0x9d;
static const BCScriptOpCode OP_NUMNOTEQUAL = (BCScriptOpCode)0x9e;
static const BCScriptOpCode OP_LESSTHAN = (BCScriptOpCode)0x9f;
static const BCScriptOpCode OP_GREATERTHAN = (BCScriptOpCode)0xa0;
static const BCScriptOpCode OP_LESSTHANOREQUAL = (BCScriptOpCode)0xa1;
static const BCScriptOpCode OP_GREATERTHANOREQUA = (BCScriptOpCode)0xa2;
static const BCScriptOpCode OP_MIN = (BCScriptOpCode)0xa3;
static const BCScriptOpCode OP_MAX = (BCScriptOpCode)0xa4;
static const BCScriptOpCode OP_WITHIN = (BCScriptOpCode)0xa5;

// Crypto
static const BCScriptOpCode OP_RIPEMD160 = (BCScriptOpCode)0xa6;
static const BCScriptOpCode OP_SHA1 = (BCScriptOpCode)0xa7;
static const BCScriptOpCode OP_SHA256 = (BCScriptOpCode)0xa8;
static const BCScriptOpCode OP_HASH160 = (BCScriptOpCode)0xa9;
static const BCScriptOpCode OP_CODESEPARATOR = (BCScriptOpCode)0xab;
static const BCScriptOpCode OP_CHECKSIG = (BCScriptOpCode)0xac;
static const BCScriptOpCode OP_CHECKSIGVERIFY = (BCScriptOpCode)0xad;
static const BCScriptOpCode OP_CHECKMULTISIG = (BCScriptOpCode)0xae;
static const BCScriptOpCode OP_CHECKMULTISIGVERIFY = (BCScriptOpCode)0xaf;

// Pseudo-Words
static const BCScriptOpCode OP_PUBKEYHASH = (BCScriptOpCode)0xfd;
static const BCScriptOpCode OP_PUBKEY = (BCScriptOpCode)0xfe;
static const BCScriptOpCode OP_INVALIDOPCODE = (BCScriptOpCode)0xff;

// Reserved words
static const BCScriptOpCode OP_RESERVED = (BCScriptOpCode)0x50;
static const BCScriptOpCode OP_VER = (BCScriptOpCode)0x62;
static const BCScriptOpCode OP_VERIF = (BCScriptOpCode)0x65;
static const BCScriptOpCode OP_VERNOTIF = (BCScriptOpCode)0x66;
static const BCScriptOpCode OP_RESERVED1 = (BCScriptOpCode)0x89;
static const BCScriptOpCode OP_RESERVED2 = (BCScriptOpCode)0x8a;

static const BCScriptOpCode OP_NOP1 = (BCScriptOpCode)0xb0;
static const BCScriptOpCode OP_NOP2 = (BCScriptOpCode)0xb1;
static const BCScriptOpCode OP_NOP3 = (BCScriptOpCode)0xb2;
static const BCScriptOpCode OP_NOP4 = (BCScriptOpCode)0xb3;
static const BCScriptOpCode OP_NOP5 = (BCScriptOpCode)0xb4;
static const BCScriptOpCode OP_NOP6 = (BCScriptOpCode)0xb5;
static const BCScriptOpCode OP_NOP7 = (BCScriptOpCode)0xb6;
static const BCScriptOpCode OP_NOP8 = (BCScriptOpCode)0xb7;
static const BCScriptOpCode OP_NOP9 = (BCScriptOpCode)0xb8;
static const BCScriptOpCode OP_NOP10 = (BCScriptOpCode)0xb9;

static NSString __attribute__((unused)) *stingFromSigHashCode(BCScriptSigHashCode sigHashCode) {
  switch (sigHashCode) {
    case SIGHASH_ALL:
      return @"SIGHASH_ALL";
      break;
    case SIGHASH_NONE:
      return @"SIGHASH_NONE";
      break;
    case SIGHASH_SINGLE:
      return @"SIGHASH_SINGLE";
      break;
    case SIGHASH_ANYONECANPAY:
      return @"SIGHASH_ANYONECANPAY";
      break;
    default:
      return NULL;
      break;
  }
}

static NSString __attribute__((unused)) *stringFromScriptOpCode(BCScriptOpCode opCode) {
  // This is a big switch statement...
  switch (opCode) {
    case OP_FALSE:
      return @"(OP_FALSE|OP_0)";
      break;
    case OP_TRUE:
      return @"(OP_TRUE|OP_1)";
      break;
    case OP_2:
      return @"OP_2";
      break;
    case OP_3:
      return @"OP_3";
      break;
    case OP_4:
      return @"OP_4";
      break;
    case OP_5:
      return @"OP_5";
      break;
    case OP_6:
      return @"OP_6";
      break;
    case OP_7:
      return @"OP_7";
      break;
    case OP_8:
      return @"OP_8";
      break;
    case OP_9:
      return @"OP_9";
      break;
    case OP_10:
      return @"OP_10";
      break;
    case OP_11:
      return @"OP_11";
      break;
    case OP_12:
      return @"OP_12";
      break;
    case OP_13:
      return @"OP_13";
      break;
    case OP_14:
      return @"OP_14";
      break;
    case OP_15:
      return @"OP_15";
      break;
    case OP_16:
      return @"OP_16";
      break;

    case OP_PUSHDATA1:
      return @"OP_PUSHDATA1";
      break;
    case OP_PUSHDATA2:
      return @"OP_PUSHDATA2";
      break;
    case OP_PUSHDATA4:
      return @"OP_PUSHDATA4";
      break;

    case OP_NOP:
      return @"OP_NOP";
      break;
    case OP_IF:
      return @"OP_IF";
      break;
    case OP_NOTIF:
      return @"OP_NOTIF";
      break;
    case OP_ELSE:
      return @"OP_ELSE";
      break;
    case OP_VERIFY:
      return @"OP_VERIFY";
      break;
    case OP_RETURN:
      return @"OP_RETURN";
      break;

    case OP_TOALTSTACK:
      return @"OP_TOALTSTACK";
      break;
    case OP_FROMALTSTACK:
      return @"OP_FROMALTSTACK";
      break;
    case OP_IFDUP:
      return @"OP_IFDUP";
      break;
    case OP_DEPTH:
      return @"OP_DEPTH";
      break;
    case OP_DROP:
      return @"OP_DROP";
      break;
    case OP_DUP:
      return @"OP_DUP";
      break;
    case OP_NIP:
      return @"OP_NIP";
      break;
    case OP_OVER:
      return @"OP_OVER";
      break;
    case OP_PICK:
      return @"OP_PICK";
      break;
    case OP_ROLL:
      return @"OP_ROLL";
      break;
    case OP_ROT:
      return @"OP_ROT";
      break;
    case OP_SWAP:
      return @"OP_SWAP";
      break;
    case OP_TUCK:
      return @"OP_TUCK";
      break;
    case OP_2DROP:
      return @"OP_2DROP";
      break;
    case OP_2DUP:
      return @"OP_2DROP";
      break;
    case OP_3DUP:
      return @"OP_3DUP";
      break;
    case OP_2OVER:
      return @"OP_2OVER";
      break;
    case OP_2ROT:
      return @"OP_2ROT";
      break;
    case OP_2SWAP:
      return @"OP_2SWAP";
      break;

    case OP_SIZE:
      return @"OP_SIZE";
      break;

    case OP_EQUAL:
      return @"OP_EQUAL";
      break;
    case OP_EQUALVERIFY:
      return @"OP_EQUALVERIFY";
      break;

    case OP_1ADD:
      return @"OP_1ADD";
      break;
    case OP_1SUB:
      return @"OP_1SUB";
      break;
    case OP_NEGATE:
      return @"OP_NEGATE";
      break;
    case OP_ABS:
      return @"OP_ABS";
      break;
    case OP_NOT:
      return @"OP_NOT";
      break;
    case OP_0NOTEQUAL:
      return @"OP_0NOTEQUAL";
      break;
    case OP_ADD:
      return @"OP_ADD";
      break;
    case OP_SUB:
      return @"OP_SUB";
      break;
    case OP_BOOLAND:
      return @"OP_BOOLAND";
      break;
    case OP_BOOLOR:
      return @"OP_BOOLOR";
      break;
    case OP_NUMEQUAL:
      return @"OP_NUMEQUAL";
      break;
    case OP_NUMNOTEQUAL:
      return @"OP_NUMNOTEQUAL";
      break;
    case OP_LESSTHAN:
      return @"OP_LESSTHAN";
      break;
    case OP_GREATERTHAN:
      return @"OP_GREATERTHAN";
      break;
    case OP_LESSTHANOREQUAL:
      return @"OP_LESSTHANOREQUAL";
      break;
    case OP_GREATERTHANOREQUA:
      return @"OP_GREATERTHANOREQUA";
      break;
    case OP_MIN:
      return @"OP_MIN";
      break;
    case OP_MAX:
      return @"OP_MAX";
      break;
    case OP_WITHIN:
      return @"OP_WITHIN";
      break;

    case OP_SHA1:
      return @"OP_SHA1";
      break;
    case OP_SHA256:
      return @"OP_SHA256";
      break;
    case OP_HASH160:
      return @"OP_HASH160";
      break;
    case OP_CODESEPARATOR:
      return @"OP_CODESEPARATOR";
      break;
    case OP_CHECKSIG:
      return @"OP_CHECKSIG";
      break;
    case OP_CHECKSIGVERIFY:
      return @"OP_CHECKSIGVERIFY";
      break;
    case OP_CHECKMULTISIG:
      return @"OP_CHECKMULTISIG";
      break;
    case OP_CHECKMULTISIGVERIFY:
      return @"OP_CHECKMULTISIGVERIFY";
      break;

    case OP_PUBKEYHASH:
      return @"OP_PUBKEYHASH";
      break;
    case OP_PUBKEY:
      return @"OP_PUBKEY";
      break;
    case OP_INVALIDOPCODE:
      return @"OP_INVALIDOPCODE";
      break;

    case OP_RESERVED:
      return @"OP_RESERVED";
      break;
    case OP_VER:
      return @"OP_VER";
      break;
    case OP_VERIF:
      return @"OP_VERIF";
      break;
    case OP_VERNOTIF:
      return @"OP_VERNOTIF";
      break;
    case OP_RESERVED1:
      return @"OP_RESERVED1";
      break;
    case OP_RESERVED2:
      return @"OP_RESERVED2";
      break;

    case OP_NOP1:
      return @"OP_NOP1";
      break;
    case OP_NOP2:
      return @"OP_NOP1";
      break;
    case OP_NOP3:
      return @"OP_NOP1";
      break;
    case OP_NOP4:
      return @"OP_NOP1";
      break;
    case OP_NOP5:
      return @"OP_NOP1";
      break;
    case OP_NOP6:
      return @"OP_NOP1";
      break;
    case OP_NOP7:
      return @"OP_NOP1";
      break;
    case OP_NOP8:
      return @"OP_NOP1";
      break;
    case OP_NOP9:
      return @"OP_NOP1";
      break;
    case OP_NOP10:
      return @"OP_NOP10";
      break;

    default:
      return NULL;
      break;
  }
}

static BCScriptOpCode __attribute__((unused)) OP_(uint16_t value) {
  if (value == 0) return OP_0;
  if (value >= 1 && value <= 16) return (BCScriptOpCode)(OP_1 + (value - 1));
  return OP_NOP1;
}


static uint16_t  __attribute__((unused)) numFromOP_(BCScriptOpCode value) {
  if ( value == OP_0) return 0;
  if (value >= OP_1 && value <= OP_16) return (uint8_t)(value - OP_1) + 1;
  return UINT16_MAX;
}

#endif  //__BCScriptOpCodes__
