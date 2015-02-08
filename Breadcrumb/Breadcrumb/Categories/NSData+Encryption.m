//
//  NSData+Encryption.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "NSData+Encryption.h"
#import "ccMemory.h"
#import "NSData+Hash.h"
#import "NSMutableData+Bitcoin.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonCryptor.h>

// bitwise left rotation, this will typically be compiled into a single
// instruction
#define rotl(a, b) (((a) << (b)) | ((a) >> (32 - (b))))

// salsa20/8 stream cypher: http://cr.yp.to/snuffle.html
static void salsa20_8(uint32_t b[16]) {
  uint32_t x00 = b[0], x01 = b[1], x02 = b[2], x03 = b[3], x04 = b[4],
           x05 = b[5], x06 = b[6], x07 = b[7], x08 = b[8], x09 = b[9],
           x10 = b[10], x11 = b[11], x12 = b[12], x13 = b[13], x14 = b[14],
           x15 = b[15];

  for (int i = 0; i < 8; i += 2) {
    // operate on columns
    x04 ^= rotl(x00 + x12, 7), x08 ^= rotl(x04 + x00, 9),
        x12 ^= rotl(x08 + x04, 13), x00 ^= rotl(x12 + x08, 18);
    x09 ^= rotl(x05 + x01, 7), x13 ^= rotl(x09 + x05, 9),
        x01 ^= rotl(x13 + x09, 13), x05 ^= rotl(x01 + x13, 18);
    x14 ^= rotl(x10 + x06, 7), x02 ^= rotl(x14 + x10, 9),
        x06 ^= rotl(x02 + x14, 13), x10 ^= rotl(x06 + x02, 18);
    x03 ^= rotl(x15 + x11, 7), x07 ^= rotl(x03 + x15, 9),
        x11 ^= rotl(x07 + x03, 13), x15 ^= rotl(x11 + x07, 18);

    // operate on rows
    x01 ^= rotl(x00 + x03, 7), x02 ^= rotl(x01 + x00, 9),
        x03 ^= rotl(x02 + x01, 13), x00 ^= rotl(x03 + x02, 18);
    x06 ^= rotl(x05 + x04, 7), x07 ^= rotl(x06 + x05, 9),
        x04 ^= rotl(x07 + x06, 13), x05 ^= rotl(x04 + x07, 18);
    x11 ^= rotl(x10 + x09, 7), x08 ^= rotl(x11 + x10, 9),
        x09 ^= rotl(x08 + x11, 13), x10 ^= rotl(x09 + x08, 18);
    x12 ^= rotl(x15 + x14, 7), x13 ^= rotl(x12 + x15, 9),
        x14 ^= rotl(x13 + x12, 13), x15 ^= rotl(x14 + x13, 18);
  }

  b[0] += x00, b[1] += x01, b[2] += x02, b[3] += x03, b[4] += x04, b[5] += x05,
      b[6] += x06, b[7] += x07;
  b[8] += x08, b[9] += x09, b[10] += x10, b[11] += x11, b[12] += x12,
      b[13] += x13, b[14] += x14, b[15] += x15;
}

static void blockmix_salsa8(uint64_t *dest, const uint64_t *src, uint64_t *b,
                            uint32_t r) {
  CC_XMEMCPY(b, &src[(2 * r - 1) * 8], 64);

  for (uint32_t i = 0; i < 2 * r; i += 2) {
    for (uint32_t j = 0; j < 8; j++) b[j] ^= src[i * 8 + j];
    salsa20_8((uint32_t *)b);
    CC_XMEMCPY(&dest[i * 4], b, 64);
    for (uint32_t j = 0; j < 8; j++) b[j] ^= src[i * 8 + 8 + j];
    salsa20_8((uint32_t *)b);
    CC_XMEMCPY(&dest[i * 4 + r * 8], b, 64);
  }
}

// scrypt key derivation: http://www.tarsnap.com/scrypt.html
static NSData *scrypt(NSData *password, NSData *salt, int64_t n, uint32_t r,
                      uint32_t p, NSUInteger length) {
  NSMutableData *d = [NSMutableData secureDataWithLength:length];
  uint8_t b[128 * r * p];
  uint64_t x[16 * r], y[16 * r], z[8], *v = CC_XMALLOC(128 * r * (int)n), m;

  CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes,
                       salt.length, kCCPRFHmacAlgSHA256, 1, b, sizeof(b));

  for (uint32_t i = 0; i < p; i++) {
    for (uint32_t j = 0; j < 32 * r; j++) {
      ((uint32_t *)x)[j] =
          CFSwapInt32LittleToHost(*(uint32_t *)&b[i * 128 * r + j * 4]);
    }

    for (uint64_t j = 0; j < n; j += 2) {
      CC_XMEMCPY(&v[j * (16 * r)], x, 128 * r);
      blockmix_salsa8(y, x, z, r);
      CC_XMEMCPY(&v[(j + 1) * (16 * r)], y, 128 * r);
      blockmix_salsa8(x, y, z, r);
    }

    for (uint64_t j = 0; j < n; j += 2) {
      m = CFSwapInt64LittleToHost(x[(2 * r - 1) * 8]) & (n - 1);
      for (uint32_t k = 0; k < 16 * r; k++) x[k] ^= v[m * (16 * r) + k];
      blockmix_salsa8(y, x, z, r);
      m = CFSwapInt64LittleToHost(y[(2 * r - 1) * 8]) & (n - 1);
      for (uint32_t k = 0; k < 16 * r; k++) y[k] ^= v[m * (16 * r) + k];
      blockmix_salsa8(x, y, z, r);
    }

    for (uint32_t j = 0; j < 32 * r; j++) {
      *(uint32_t *)&b[i * 128 * r + j * 4] =
          CFSwapInt32HostToLittle(((uint32_t *)x)[j]);
    }
  }

  CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, b, sizeof(b),
                       kCCPRFHmacAlgSHA256, 1, d.mutableBytes, d.length);

  CC_XZEROMEM(b, sizeof(b));
  CC_XZEROMEM(x, sizeof(x));
  CC_XZEROMEM(y, sizeof(y));
  CC_XZEROMEM(z, sizeof(z));
  CC_XZEROMEM(v, 128 * r * (int)n);
  CC_XFREE(v, 128 * r * (int)n);
  CC_XZEROMEM(&m, sizeof(m));
  return d;
}

@implementation NSData (Encryption)

- (NSData *)AES256Encrypt:(NSData *)key {
  @autoreleasepool {
    return [self AES256CryptOperation:kCCEncrypt withKey:key];
  }
}

- (NSData *)AES256Decrypt:(NSData *)key {
  @autoreleasepool {
    return [self AES256CryptOperation:kCCDecrypt withKey:key];
  }
}

- (NSData *)AES256CryptOperation:(CCOperation)operation withKey:(NSData *)key {
  @autoreleasepool {
    NSData *keyData =
        [NSData dataWithBytes:key.bytes length:kCCKeySizeAES256 + 1];

    NSUInteger dataLength = [self length];

    // See the doc: For block ciphers, the output size will always be less than
    // or
    // equal to the input size plus the size of one block.
    // That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytes = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
        operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyData.bytes,
        kCCKeySizeAES256, NULL /* initialization vector (optional) */,
        [self bytes], dataLength, /* input */
        buffer, bufferSize,       /* output */
        &numBytes);

    if (cryptStatus == kCCSuccess)
      return [NSData dataWithBytesNoCopy:buffer length:numBytes];

    free(buffer);
    return nil;
  }
}

#pragma mark Scrypt

+ (NSData *)scryptPassword:(NSData *)password
                 usingSalt:(NSData *)salt
          withOutputLength:(NSUInteger)length {
  @autoreleasepool {
    return [self scryptPassword:password
                      usingSalt:salt
                     workFactor:16448
                      blockSize:8
          parallelizationFactor:8
               withOutputLength:length];
  }
}

+ (NSData *)scryptPassword:(NSData *)password
                 usingSalt:(NSData *)salt
                workFactor:(uint64_t)n
                 blockSize:(uint32_t)r
     parallelizationFactor:(uint32_t)p
          withOutputLength:(NSUInteger)length {
  @autoreleasepool {
    NSParameterAssert(password);
    if (![password isKindOfClass:[NSData class]]) return NULL;
    return scrypt(password, salt, n, r, p, length);
  }
}

@end