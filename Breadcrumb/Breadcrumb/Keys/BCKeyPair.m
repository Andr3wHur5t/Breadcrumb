//
//  BCKeyPair.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "BCKeyPair.h"
#import "BCKeySequence.h"
#import "BCProtectedData.h"
#import "NSString+Base58.h"
#import "NSData+Hash.h"
#import "BCsecp256k1.h"
#import "BreadcrumbCore.h"
#import "tommath.h"

#define WIF_BTC_MAINNET 0x80
#define WIF_BTC_TESTNET 0xef
#define WIF_HAS_COMPRESSED_PUB 0x01

@interface BCKeyPair ()
/*!
 @brief The protected private key.
 */
@property(strong, nonatomic, readonly) BCProtectedData *privateKey;

@end

@implementation BCKeyPair

@synthesize publicKey = _publicKey;
@synthesize privateKey = _privateKey;

#pragma mark Construction

- (instancetype)initWithPrivateKey:(NSData *)privateKey
                     compressedPub:(BOOL)compressed
                      andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSData *pubData;
    NSParameterAssert([privateKey isKindOfClass:[NSData class]]);
    if (![privateKey isKindOfClass:[NSData class]]) {
      privateKey = NULL;
      memoryKey = NULL;
      return NULL;
    }
    self = [super init];
    if (self) {
      _isCompressed = compressed;

      pubData = [[BCsecp256k1 sharedInstance] publicKeyFromKey:privateKey
                                                    compressed:_isCompressed];
      if (![pubData isKindOfClass:[NSData class]]) {
        privateKey = NULL;
        memoryKey = NULL;
        return NULL;
      }

      _publicKey = [[BCPublicKey alloc] initWithData:pubData];
      _privateKey = [privateKey protectedWithKey:memoryKey];
      privateKey = NULL;
      memoryKey = NULL;
    }
    return self;
  }
}

- (instancetype)initWithPrivateKey:(NSData *)privateKey
                         chainCode:(NSData *)chainCode
                      andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([privateKey isKindOfClass:[NSData class]]);
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;

    self = [self initWithPrivateKey:privateKey
                      compressedPub:true  // ASSUMING TRUE, FIX!
                       andMemoryKey:memoryKey];
    memoryKey = NULL;
    if (!self) {
      privateKey = NULL;
      return NULL;
    }

    _chainCode = chainCode;
    // Update Public Key
    _publicKey = [[BCDerivablePublicKey alloc]
        initWithData:[[BCsecp256k1 sharedInstance]
                         publicKeyFromKey:privateKey
                               compressed:_isCompressed]
        andChainCode:_chainCode];

    privateKey = NULL;
    return self;
  }
}

- (instancetype)initWithWIF:(NSString *)wifString
               andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    BOOL isCompressed;
    NSData *privateKey;
    NSMutableData *decodedWif;
    NSParameterAssert([wifString isKindOfClass:[NSString class]]);
    if (![wifString isKindOfClass:[NSString class]]) {
      memoryKey = NULL;
      wifString = NULL;
      return NULL;
    }

    // Convert the wif string to a private key.
    decodedWif = [NSMutableData secureDataWithData:wifString.base58checkToData];
    wifString = NULL;
    if (![decodedWif isKindOfClass:[NSData class]]) {
      decodedWif = NULL;
      memoryKey = NULL;
      return NULL;
    }

    // Check If it is a compressed Key
    isCompressed = [decodedWif UInt8AtOffset:decodedWif.length - 1] ==
                   WIF_HAS_COMPRESSED_PUB;

    // We Need to Drop the last byte because they added a compressed code.
    if (isCompressed) decodedWif.length = decodedWif.length - 1;

    // Get Private Key From left over
    privateKey = [NSMutableData
        secureDataWithData:[decodedWif
                               subdataWithRange:NSMakeRange(
                                                    1, decodedWif.length - 1)]];
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;
    return [self initWithPrivateKey:privateKey
                      compressedPub:isCompressed
                       andMemoryKey:memoryKey];
  }
}

#pragma mark Public Info

- (BCPublicKey *)publicKey {
  NSParameterAssert([_publicKey isKindOfClass:[BCPublicKey class]]);
  return _publicKey;
}

#pragma mark Private Info

- (NSData *)privateKeyUsingMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([self.privateKey isKindOfClass:[BCProtectedData class]]);
    return [self.privateKey dataUsingMemoryKey:memoryKey];
  }
}

#pragma mark Child Retrieval

#pragma mark Signing Operations

- (NSData *)signHash:(NSData *)hash withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSData *signedData, *rawPrivateKey;
    NSParameterAssert([hash isKindOfClass:[NSData class]] ||
                      [memoryKey isKindOfClass:[NSData class]]);
    if (![hash isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]] ||
        ![_privateKey isKindOfClass:[BCProtectedData class]])
      return NULL;

    // Get the private key to sign with
    rawPrivateKey = [self.privateKey dataUsingMemoryKey:memoryKey];
    memoryKey = NULL;
    if (![rawPrivateKey isKindOfClass:[NSData class]]) return NULL;

    // Sign the data with the private key.
    signedData = [[BCsecp256k1 sharedInstance] signatureForHash:hash
                                                 withPrivateKey:rawPrivateKey];
    rawPrivateKey = NULL;

    return [signedData isKindOfClass:[NSData class]] ? signedData : NULL;
  }
}

- (BOOL)didSign:(NSData *)signedData withOriginalHash:(NSData *)hash {
  NSParameterAssert([signedData isKindOfClass:[NSData class]]);
  NSParameterAssert([hash isKindOfClass:[NSData class]]);
  if (![_publicKey isKindOfClass:[BCPublicKey class]] ||
      ![signedData isKindOfClass:[NSData class]] ||
      ![hash isKindOfClass:[NSData class]])
    return FALSE;
  return [[BCsecp256k1 sharedInstance] signature:signedData
                                      originHash:hash
                             isValidForPublicKey:_publicKey.data];
}

#pragma mark Derivation Operations

- (instancetype)childKeyPairAt:(uint32_t)index
                 withMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSData *privateKey, *hmacData, *segment, *childPrivate, *childChainCode;
    NSMutableData *data;
    NSParameterAssert([memoryKey isKindOfClass:[NSData class]]);
    if (![self.chainCode isKindOfClass:[NSData class]] ||
        ![memoryKey isKindOfClass:[NSData class]])
      return NULL;

    // Get Private Key
    privateKey = [self privateKeyUsingMemoryKey:memoryKey];
    if (![privateKey isKindOfClass:[NSData class]]) return NULL;

    data = [[NSMutableData alloc] init];
    // The index defines if the key is hardened or not.
    if (index >= BIP32_PRIME) {
      // Build Hardened
      // Disallows master pub -> child pub
      [data appendUInt8:0x00];
      [data appendData:privateKey];
    } else {
      // Build Normal
      // Allows master pub -> child pub
      // REQ: POINT(q)
      [data appendData:self.publicKey.data];
    }

    // Append The index for Both
    [data appendUInt32:OSSwapHostToBigInt32(index)];

    // Sha512 HMAC using our chain code.
    hmacData = [data SHA512HmacWithKey:self.chainCode];
    data = NULL;
    if (![hmacData isKindOfClass:[NSData class]] || hmacData.length != 64) {
      privateKey = NULL;
      return NULL;
    }

    // Split the hmac into its parts
    // This is the parse256 operation
    segment = [hmacData subdataWithRange:NSMakeRange(0, 32)];
    if (![segment isKindOfClass:[NSData class]]) {
      privateKey = NULL;
      hmacData = NULL;
      return NULL;
    }

    // Calculate the private key from the segment.
    childPrivate =
        [[self class] childPrivateFromParent:privateKey andLeftSegment:segment];
    privateKey = NULL;

    // Get the chain code from the other side
    childChainCode = [hmacData subdataWithRange:NSMakeRange(32, 32)];
    if (![childChainCode isKindOfClass:[NSData class]]) {
      hmacData = NULL;
      return NULL;
    }

    // Create the key pair object, it will create the public key automatically.
    return [[[self class] alloc] initWithPrivateKey:childPrivate
                                          chainCode:childChainCode
                                       andMemoryKey:memoryKey];
  }
}

// Trying to make the code simpler, more organized, and more readable
+ (NSData *)childPrivateFromParent:(NSData *)parent
                    andLeftSegment:(NSData *)leftSegment {
  mp_int nParentKey, nLeftSegment, nResult, nCurveOrder;
  unsigned char bytes[512];
  NSUInteger length;
  NSData *data;

  // Init Values
  mp_init(&nParentKey);
  mp_init(&nResult);
  mp_init(&nLeftSegment);
  nCurveOrder = [BCsecp256k1 curveOrder];

  // Convert our data into big numbers
  mp_read_unsigned_bin(&nParentKey, parent.bytes, (int)parent.length);
  mp_read_unsigned_bin(&nLeftSegment, leftSegment.bytes,
                       (int)leftSegment.length);

  // ki = IL + kpar (mod n)
  // In This case parse is converting the left segment to big endian, then
  // adding to the parent key.
  // Which is then goes through % of the curve order of sepc256k1 (statically
  // defined bellow).
  // NOTE: this is also the point() operation defined in BIP32
  mp_addmod(&nLeftSegment, &nParentKey, &nCurveOrder, &nResult);
  mp_to_unsigned_bin_n(&nResult, bytes, &length);

  data = [NSData dataWithBytes:bytes length:length];
  return [data isKindOfClass:[NSData class]] ? data : NULL;
}

#pragma mark Utilities

+ (NSString *)serializeSequence:(NSArray *)sequence {
  NSMutableString *result;
  NSNumberFormatter *formatter;
  BOOL isHardened;
  NSParameterAssert([sequence isKindOfClass:[NSArray class]]);
  if (![sequence isKindOfClass:[NSArray class]]) return NULL;

  // Ensure all objects are numbers
  for (id object in sequence)
    if (![object isKindOfClass:[NSNumber class]]) return NULL;

  // Get key pair by enumerating indexes of components
  formatter = [[NSNumberFormatter alloc] init];
  result = [[NSMutableString alloc] initWithString:kBCKeySequenceMasterChar];
  for (NSNumber *componentIndex in sequence) {
    [result appendString:kBCKeySequenceDelimiterChar];

    isHardened = (uint32_t)[componentIndex intValue] >= BIP32_PRIME;

    // Append the value
    [result
        appendString:[formatter
                         stringFromNumber:isHardened
                                              ? @([componentIndex unsignedIntValue] -
                                                  BIP32_PRIME)
                                              : componentIndex]];

    // Append the hardened flag if needed
    if (isHardened)
      [result
          appendString:[kBCKeySequenceHardenedFlagChars substringToIndex:1]];
  }

  return [NSString stringWithString:result];
}

+ (BOOL)typeCodeStatesCompressed:(char)typeCode {
  return typeCode == 'K' || typeCode == 'L' || typeCode == 'c' ||
         typeCode == '9';
}

@end
