//
//  BCScriptOpCodes.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
// Refer to https://en.bitcoin.it/wiki/Script

// Bitcoin Script Op Codes

#ifdef __BCScriptOpCodes__
#else
#define __BCScriptOpCodes__

#import <Foundation/Foundation.h>

typedef int8_t BCScriptOpCode;

static const BCScriptOpCode OP_FALSE               = 0x00;
static const BCScriptOpCode OP_TRUE                = 0x51;

static const BCScriptOpCode OP_0                   = 0x00;
static const BCScriptOpCode OP_1                   = 0x51;
static const BCScriptOpCode OP_2                   = 0x52;
static const BCScriptOpCode OP_3                   = 0x53;
static const BCScriptOpCode OP_4                   = 0x54;
static const BCScriptOpCode OP_5                   = 0x55;
static const BCScriptOpCode OP_6                   = 0x56;
static const BCScriptOpCode OP_7                   = 0x57;
static const BCScriptOpCode OP_8                   = 0x58;
static const BCScriptOpCode OP_9                   = 0x59;
static const BCScriptOpCode OP_10                  = 0x5a;
static const BCScriptOpCode OP_11                  = 0x5b;
static const BCScriptOpCode OP_12                  = 0x5c;
static const BCScriptOpCode OP_13                  = 0x5d;
static const BCScriptOpCode OP_14                  = 0x5e;
static const BCScriptOpCode OP_15                  = 0x5f;
static const BCScriptOpCode OP_16                  = 0x60;

static const BCScriptOpCode OP_PUSHDATA1           = 0x4c;
static const BCScriptOpCode OP_PUSHDATA2           = 0x4d;
static const BCScriptOpCode OP_PUSHDATA4           = 0x4e;

// Control Flow
static const BCScriptOpCode OP_NOP                 = 0x61;
static const BCScriptOpCode OP_IF                  = 0x63;
static const BCScriptOpCode OP_NOTIF               = 0x64;
static const BCScriptOpCode OP_ELSE                = 0x67;
static const BCScriptOpCode OP_ENDIF               = 0x68;
static const BCScriptOpCode OP_VERIFY              = 0x69;
static const BCScriptOpCode OP_RETURN              = 0x6a;

// Stack
static const BCScriptOpCode OP_TOALTSTACK          = 0x6b;
static const BCScriptOpCode OP_FROMALTSTACK        = 0x6c;
static const BCScriptOpCode OP_IFDUP               = 0x73;
static const BCScriptOpCode OP_DEPTH               = 0x74;
static const BCScriptOpCode OP_DROP                = 0x75;
static const BCScriptOpCode OP_DUP                 = 0x76;
static const BCScriptOpCode OP_NIP                 = 0x77;
static const BCScriptOpCode OP_OVER                = 0x78;
static const BCScriptOpCode OP_PICK                = 0x79;
static const BCScriptOpCode OP_ROLL                = 0x7a;
static const BCScriptOpCode OP_ROT                 = 0x7b;
static const BCScriptOpCode OP_SWAP                = 0x7c;
static const BCScriptOpCode OP_TUCK                = 0x7d;
static const BCScriptOpCode OP_2DROP               = 0x6d;
static const BCScriptOpCode OP_2DUP                = 0x6e;
static const BCScriptOpCode OP_3DUP                = 0x6f;
static const BCScriptOpCode OP_2OVER               = 0x70;
static const BCScriptOpCode OP_2ROT                = 0x71;
static const BCScriptOpCode OP_2SWAP               = 0x72;

// Splice
static const BCScriptOpCode OP_SIZE                = 0x82;

// Bitwise Logic
static const BCScriptOpCode OP_EQUAL               = 0x87;
static const BCScriptOpCode OP_EQUALVERIFY         = 0x88;

// Arithmitic
static const BCScriptOpCode OP_1ADD                = 0x8b;
static const BCScriptOpCode OP_1SUB                = 0x8c;
static const BCScriptOpCode OP_NEGATE              = 0x8f;
static const BCScriptOpCode OP_ABS                 = 0x90;
static const BCScriptOpCode OP_NOT                 = 0x91;
static const BCScriptOpCode OP_0NOTEQUAL           = 0x92;
static const BCScriptOpCode OP_ADD                 = 0x93;
static const BCScriptOpCode OP_SUB                 = 0x94;
static const BCScriptOpCode OP_BOOLAND             = 0x9a;
static const BCScriptOpCode OP_BOOLOR              = 0x9b;
static const BCScriptOpCode OP_NUMEQUAL            = 0x9c;
static const BCScriptOpCode OP_NUMEQUALVERIFY      = 0x9d;
static const BCScriptOpCode OP_NUMNOTEQUAL         = 0x9e;
static const BCScriptOpCode OP_LESSTHAN            = 0x9f;
static const BCScriptOpCode OP_GREATERTHAN         = 0xa0;
static const BCScriptOpCode OP_LESSTHANOREQUAL     = 0xa1;
static const BCScriptOpCode OP_GREATERTHANOREQUA   = 0xa2;
static const BCScriptOpCode OP_MIN                 = 0xa3;
static const BCScriptOpCode OP_MAX                 = 0xa4;
static const BCScriptOpCode OP_WITHIN              = 0xa5;

// Crypto
static const BCScriptOpCode OP_RIPEMD160           = 0xa6;
static const BCScriptOpCode OP_SHA1                = 0xa7;
static const BCScriptOpCode OP_SHA256              = 0xa8;
static const BCScriptOpCode OP_HASH160             = 0xa9;
static const BCScriptOpCode OP_CODESEPARATOR       = 0xab;
static const BCScriptOpCode OP_CHECKSIG            = 0xac;
static const BCScriptOpCode OP_CHECKSIGVERIFY      = 0xad;
static const BCScriptOpCode OP_CHECKMULTISIG       = 0xae;
static const BCScriptOpCode OP_CHECKMULTISIGVERIFY = 0xaf;

// Psudo-words
static const BCScriptOpCode OP_PUBKEYHASH          = 0xfd;
static const BCScriptOpCode OP_PUBKEY              = 0xfe;
static const BCScriptOpCode OP_INVALIDOPCODE       = 0xff;

// Reserved words
static const BCScriptOpCode OP_RESERVED            = 0x50;
static const BCScriptOpCode OP_VER                 = 0x62;
static const BCScriptOpCode OP_VERIF               = 0x65;
static const BCScriptOpCode OP_VERNOTIF            = 0x66;
static const BCScriptOpCode OP_RESERVED1           = 0x89;
static const BCScriptOpCode OP_RESERVED2           = 0x8a;

static const BCScriptOpCode OP_NOP1                = 0xb0;
static const BCScriptOpCode OP_NOP2                = 0xb1;
static const BCScriptOpCode OP_NOP3                = 0xb2;
static const BCScriptOpCode OP_NOP4                = 0xb3;
static const BCScriptOpCode OP_NOP5                = 0xb4;
static const BCScriptOpCode OP_NOP6                = 0xb5;
static const BCScriptOpCode OP_NOP7                = 0xb6;
static const BCScriptOpCode OP_NOP8                = 0xb7;
static const BCScriptOpCode OP_NOP9                = 0xb8;
static const BCScriptOpCode OP_NOP10               = 0xb9;

static NSString *stringFromScriptOpCode(BCScriptOpCode opCode) {
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

#endif  //__BCScriptOpCodes__
