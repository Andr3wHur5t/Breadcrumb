//
//  BRBIP39Mnemonic.m
//  BreadWallet
//
//  Created by Aaron Voisine on 3/21/14.
//  Copyright (c) 2014 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRBIP39Mnemonic.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "NSMutableData+Bitcoin.h"
#import "ccMemory.h"
#import <CommonCrypto/CommonKeyDerivation.h>



// BIP39 is method for generating a deterministic wallet seed from a mnemonic
// phrase
// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki

@implementation BRBIP39Mnemonic

+ (NSBundle *)bundle {
  return [NSBundle bundleWithIdentifier:@"BC.Breadcrumb"];
}

+ (instancetype)sharedInstance {
  static id singleton = nil;
  static dispatch_once_t onceToken = 0;

  dispatch_once(&onceToken, ^{ singleton = [self new]; });

  return singleton;
}

- (NSString *)encodePhrase:(NSData *)data {
  if ((data.length % 4) != 0)
    return nil;  // data length must be a multiple of 32 bits

  NSArray *words = [NSArray
      arrayWithContentsOfFile:[[[self class] bundle] pathForResource:WORDS
                                                              ofType:@"plist"]];

  uint32_t n = (uint32_t)words.count, x;
  NSMutableArray *a = CFBridgingRelease(CFArrayCreateMutable(
      SecureAllocator(), data.length * 3 / 4, &kCFTypeArrayCallBacks));

  if (![data isKindOfClass:[NSData class]]) return NULL;
  NSMutableData *d = [NSMutableData secureDataWithData:data];

  [d appendData:data.SHA256];  // append SHA256 checksum

  NSParameterAssert(n != 0);  // Failed To Load File
  for (NSUInteger i = 0; i < data.length * 3 / 4; i++) {
    x = CFSwapInt32BigToHost(
        *(const uint32_t *)((const uint8_t *)d.bytes + i * 11 / 8));
    [a addObject:words[(x >> (sizeof(x) * 8 - (11 + ((i * 11) % 8)))) % n]];
  }

  CC_XZEROMEM(&x, sizeof(x));
  return CFBridgingRelease(CFStringCreateByCombiningStrings(
      SecureAllocator(), (CFArrayRef)a, CFSTR(" ")));
}

- (NSData *)decodePhrase:(NSString *)phrase {
  NSArray *words = [NSArray
      arrayWithContentsOfFile:[[[self class] bundle] pathForResource:WORDS
                                                              ofType:@"plist"]];
  NSArray *a = CFBridgingRelease(CFStringCreateArrayBySeparatingStrings(
      SecureAllocator(), (CFStringRef)[self normalizePhrase : phrase],
      CFSTR(" ")));
  NSMutableData *d =
      [NSMutableData secureDataWithCapacity:(a.count * 11 + 7) / 8];
  uint32_t n = (uint32_t)words.count, x, y;
  uint8_t b;

  if ((a.count % 3) != 0 || a.count > 24) {
    NSLog(@"phrase has wrong number of words");
    return nil;
  }

  for (NSUInteger i = 0; i < (a.count * 11 + 7) / 8; i++) {
    x = (uint32_t)[words indexOfObject : a[i * 8 / 11]];
    y = (i * 8 / 11 + 1 < a.count)
            ? (uint32_t)[words indexOfObject : a[i * 8 / 11 + 1]]
            : 0;

    if (x == (uint32_t)NSNotFound || y == (uint32_t)NSNotFound) {
      NSLog(@"phrase contained unknown word: %@",
            a[i * 8 / 11 + (x == (uint32_t)NSNotFound ? 0 : 1)]);
      return nil;
    }

    b = ((x * n + y) >> ((i * 8 / 11 + 2) * 11 - (i + 1) * 8)) & 0xff;
    [d appendBytes:&b length:1];
  }

  b = *((const uint8_t *)d.bytes + a.count * 4 / 3) >> (8 - a.count / 3);
  d.length = a.count * 4 / 3;

  if (b != (*(const uint8_t *)d.SHA256.bytes >> (8 - a.count / 3))) {
    NSLog(@"incorrect phrase, bad checksum");
    return nil;
  }

  CC_XZEROMEM(&x, sizeof(x));
  CC_XZEROMEM(&y, sizeof(y));
  CC_XZEROMEM(&b, sizeof(b));
  return d;
}

- (BOOL)phraseIsValid:(NSString *)phrase {
  return ([self decodePhrase:phrase] == nil) ? NO : YES;
}

- (NSString *)normalizePhrase:(NSString *)phrase {
  NSMutableString *s = CFBridgingRelease(
      CFStringCreateMutableCopy(SecureAllocator(), 0, (CFStringRef)phrase));

  [s replaceOccurrencesOfString:@"."
                      withString:@" "
                         options:0
                           range:NSMakeRange(0, s.length)];
  [s replaceOccurrencesOfString:@","
                      withString:@" "
                         options:0
                           range:NSMakeRange(0, s.length)];
  [s replaceOccurrencesOfString:@"\n"
                      withString:@" "
                         options:0
                           range:NSMakeRange(0, s.length)];
  CFStringTrimWhitespace((CFMutableStringRef)s);
  CFStringLowercase((CFMutableStringRef)s, CFLocaleGetSystem());

  while ([s rangeOfString:@"  "].location != NSNotFound) {
    [s replaceOccurrencesOfString:@"  "
                        withString:@" "
                           options:0
                             range:NSMakeRange(0, s.length)];
  }

  return s;
}

- (NSData *)deriveKeyFromPhrase:(NSString *)phrase
                 withPassphrase:(NSString *)passphrase {
  NSMutableData *key =
      [NSMutableData secureDataWithLength:CC_SHA512_DIGEST_LENGTH];
  NSData *password, *salt;
  CFMutableStringRef pw = CFStringCreateMutableCopy(
      SecureAllocator(), (CFIndex)phrase.length, (CFStringRef)phrase);
  CFMutableStringRef s = CFStringCreateMutableCopy(
      SecureAllocator(), 8 + (CFIndex)passphrase.length, CFSTR("mnemonic"));

  if (passphrase) CFStringAppend(s, (CFStringRef)passphrase);
  CFStringNormalize(pw, kCFStringNormalizationFormKD);
  CFStringNormalize(s, kCFStringNormalizationFormKD);
  password = CFBridgingRelease(CFStringCreateExternalRepresentation(
      SecureAllocator(), pw, kCFStringEncodingUTF8, 0));
  salt = CFBridgingRelease(CFStringCreateExternalRepresentation(
      SecureAllocator(), s, kCFStringEncodingUTF8, 0));
  CFRelease(pw);
  CFRelease(s);

  CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes,
                       salt.length, kCCPRFHmacAlgSHA512, 2048, key.mutableBytes,
                       key.length);
  return key;
}

@end
