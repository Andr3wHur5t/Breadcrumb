//
//  BCHashTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/18/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//

#import "Breadcrumb.h"
#import <XCTest/XCTest.h>

@interface BCHashTests : XCTestCase

@end

@implementation BCHashTests

#pragma mark Encryption

- (void)testAES256 {
  NSData *d, *bd, *k, *enc, *dec;

  for (NSUInteger i = 0; i < 14; ++i) {
    d = [NSData pseudoRandomDataWithLength:45];
    bd = [NSData pseudoRandomDataWithLength:45];
    k = [NSData pseudoRandomDataWithLength:32];

    // Valid Check
    enc = [d AES256Encrypt:k];
    XCTAssert([enc isKindOfClass:[NSData class]], @"Failed");
    dec = [enc AES256Decrypt:k];
    XCTAssert([dec isKindOfClass:[NSData class]], @"Failed");
    XCTAssert([dec isEqualToData:d], @"Failed");
    dec = NULL;
  }
}

- (void)testAES256ETM {
  NSData *d, *bd, *k, *enc, *dec;

  for (NSUInteger i = 0; i < 14; ++i) {
    d = [NSData pseudoRandomDataWithLength:45];
    bd = [NSData pseudoRandomDataWithLength:45];
    k = [NSData pseudoRandomDataWithLength:32];

    // Valid Check
    enc = [d AES256ETMEncrypt:k];
    XCTAssert([enc isKindOfClass:[NSData class]], @"Failed");
    dec = [enc AES256ETMDecrypt:k];
    XCTAssert([dec isKindOfClass:[NSData class]], @"Failed");
    XCTAssert([dec isEqualToData:d], @"Failed");
    dec = NULL;

    // Invalid Check
    dec = [k AES256ETMDecrypt:k];  // Mis match size
    XCTAssert(![dec isKindOfClass:[NSData class]], @"Failed");

    dec = [bd AES256ETMDecrypt:k];  // Same Size dif data
    XCTAssert(![dec isKindOfClass:[NSData class]], @"Failed");
  }
}
#pragma mark Digest

- (void)testRMD160 {
  for (NSUInteger i = 0; i < 20; ++i)
    XCTAssert([self RMD160:@"Rosetta Code"
                    outHex:@"b3be159860842cebaa7174c8fff0aa9e50a5199f"],
              @"Failed!");

  XCTAssert(
      [self RMD160:@"" outHex:@"9c1185a5c5e9fc54612808977ee8f548b2258d31"],
      @"Failed!");
  XCTAssert(
      [self RMD160:@"abc" outHex:@"8eb208f7e05d987a9b044a8e98c6b087f15a0bfc"],
      @"Failed!");
  XCTAssert([self RMD160:@"message digest"
                  outHex:@"5d0689ef49d2fae572b881b123a85ffa21595f36"],
            @"Failed!");
  XCTAssert([self RMD160:@"secure hash algorithm"
                  outHex:@"20397528223b6a5f4cbc2808aba0464e645544f9"],
            @"Failed!");
  XCTAssert([self RMD160:@"RIPEMD160 is considered to be safe"
                  outHex:@"a7d78608c7af8a8e728778e81576870734122b66"],
            @"Failed!");
  XCTAssert(
      [self RMD160:@"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
            outHex:@"12a053384a9c0c88e405a06c27dcf49ada62eb2b"],
      @"Failed!");
  XCTAssert(
      [self
          RMD160:
              @"For this sample, this 63-byte string will be used as input data"
          outHex:@"de90dbfee14b63fb5abf27c2ad4a82aaa5f27a11"],
      @"Failed!");
  XCTAssert([self RMD160:@"This is exactly 64 bytes long, not counting the "
                  @"terminating byte"
                  outHex:@"eda31d51d3a623b81e19eb02e24ff65d27d67b37"],
            @"Failed!");

  XCTAssert(
      [self RMD160:[[self class] repeatedSubstring:@"a" withRepeatCount:1000000]
            outHex:@"52783243c1697bdbe16d37f97f68f08325dc1528"],
      @"Failed!");
}

- (void)testSHA1 {
  XCTAssert([self SHA1:@"" outHex:@"da39a3ee5e6b4b0d3255bfef95601890afd80709"],
            @"Failed!");
  XCTAssert(
      [self SHA1:@"abc" outHex:@"a9993e364706816aba3e25717850c26c9cd0d89d"],
      @"Failed!");
  XCTAssert([self SHA1:@"message digest"
                outHex:@"c12252ceda8be8994d5fa0290a47231c1d16aae3"],
            @"Failed!");
  XCTAssert([self SHA1:@"secure hash algorithm"
                outHex:@"d4d6d2f0ebe317513bbd8d967d89bac5819c2f60"],
            @"Failed!");
  XCTAssert([self SHA1:@"SHA1 is considered to be safe"
                outHex:@"f2b6650569ad3a8720348dd6ea6c497dee3a842a"],
            @"Failed!");
  XCTAssert(
      [self SHA1:@"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
          outHex:@"84983e441c3bd26ebaae4aa1f95129e5e54670f1"],
      @"Failed!");
  XCTAssert([self SHA1:@"This is exactly 64 bytes long, not counting the "
                  @"terminating byte"
                outHex:@"fb679f23e7d1ce053313e66e127ab1b444397057"],
            @"Failed!");
  XCTAssert(
      [self SHA1:[[self class] repeatedSubstring:@"a" withRepeatCount:1000000]
          outHex:@"34aa973cd4c4daa4f61eeb2bdbad27316534016f"],
      @"Failed!");
}

- (void)testSHA256 {
  XCTAssert([self SHA256:@""
                  outHex:@"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495"
                  @"991b7852b855"],
            @"Failed!");
  XCTAssert([self SHA256:@"abc"
                  outHex:@"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410"
                  @"ff61f20015ad"],
            @"Failed!");
  XCTAssert([self SHA256:@"message digest"
                  outHex:@"f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1"
                  @"413d393cb650"],
            @"Failed!");
  XCTAssert([self SHA256:@"secure hash algorithm"
                  outHex:@"f30ceb2bb2829e79e4ca9753d35a8ecc00262d164cc077080295"
                  @"381cbd643f0d"],
            @"Failed!");
  XCTAssert([self SHA256:@"SHA256 is considered to be safe"
                  outHex:@"6819d915c73f4d1e77e4e1b52d1fa0f9cf9beaead3939f15874b"
                  @"d988e2a23630"],
            @"Failed!");
  XCTAssert(
      [self SHA256:@"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
            outHex:@"248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419"
            @"db06c1"],
      @"Failed!");
  XCTAssert(
      [self
          SHA256:
              @"For this sample, this 63-byte string will be used as input data"
          outHex:@"f08a78cbbaee082b052ae0708f32fa1e50c5c421aa772ba5dbb406a2ea6b"
          @"e342"],
      @"Failed!");
  XCTAssert([self SHA256:@"This is exactly 64 bytes long, not counting the "
                  @"terminating byte"
                  outHex:@"ab64eff7e88e2e46165e29f2bce41826bd4c7b3552f6b382a9e7"
                  @"d3af47c245f8"],
            @"Failed!");
  XCTAssert([self SHA256:@"As Bitcoin relies on 80 byte header hashes, we want "
                  @"to have an example for that."
                  outHex:@"7406e8de7d6e4fffc573daef05aefb8806e7790f55eab5576f31"
                  @"349743cca743"],
            @"Failed!");
  XCTAssert(
      [self SHA256:[[self class] repeatedSubstring:@"a" withRepeatCount:1000000]
            outHex:@"cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7"
            @"112cd0"],
      @"Failed!");
}

- (void)testSHA512 {
  XCTAssert(
      [self
          SHA512:@""
          outHex:@"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36c"
          @"e9ce"
          @"47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"],
      @"Failed!");
  XCTAssert([self SHA512:@"abc"
                  outHex:@"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9e"
                  @"eee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d442"
                  @"3643ce80e2a9ac94fa54ca49f"],
            @"Failed!");
  XCTAssert([self SHA512:@"message digest"
                  outHex:@"107dbf389d9e9f71a3a95f6c055b9251bc5268c2be16d6c13492"
                  @"ea45b0199f3309e16455ab1e96118e8a905d5597b72038ddb37"
                  @"2a89826046de66687bb420e7c"],
            @"Failed!");
  XCTAssert([self SHA512:@"secure hash algorithm"
                  outHex:@"7746d91f3de30c68cec0dd693120a7e8b04d8073cb699bdce1a3"
                  @"f64127bca7a3d5db502e814bb63c063a7a5043b2df87c611333"
                  @"95f4ad1edca7fcf4b30c3236e"],
            @"Failed!");
  XCTAssert([self SHA512:@"SHA512 is considered to be safe"
                  outHex:@"099e6468d889e1c79092a89ae925a9499b5408e01b66cb5b0a3b"
                  @"d0dfa51a99646b4a3901caab1318189f74cd8cf2e941829012f"
                  @"2449df52067d3dd5b978456c2"],
            @"Failed!");
  XCTAssert(
      [self SHA512:@"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
            outHex:@"204a8fc6dda82f0a0ced7beb8e08a41657c16ef468b228a8279be331a7"
            @"03c33596fd15c13b1b07f9aa1d3bea57789ca031ad85c7a71dd70354e"
            @"c631238ca3445"],
      @"Failed!");
  XCTAssert(
      [self
          SHA512:
              @"For this sample, this 63-byte string will be used as input data"
          outHex:@"b3de4afbc516d2478fe9b518d063bda6c8dd65fc38402dd81d1eb7364e72"
          @"fb6e6663cf6d2771c8f5a6da09601712fb3d2a36c6ffea3e28b0818b05b"
          @"0a8660766"],
      @"Failed!");
  XCTAssert([self SHA512:@"This is exactly 64 bytes long, not counting the "
                  @"terminating byte"
                  outHex:@"70aefeaa0e7ac4f8fe17532d7185a289bee3b428d950c14fa8b7"
                  @"13ca09814a387d245870e007a80ad97c369d193e41701aa07f3"
                  @"221d15f0e65a1ff970cedf030"],
            @"Failed!");
  XCTAssert(
      [self SHA512:@"abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhi"
            @"jklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
            outHex:@"8e959b75dae313da8cf4f72814fc143f8f7779c6eb9f7fa17299aeadb6"
            @"889018501d289e4900f7e4331b99dec4b5433ac7d329eeb6dd26545e9"
            @"6e55b874be909"],
      @"Failed!");
  XCTAssert(
      [self SHA512:[[self class] repeatedSubstring:@"a" withRepeatCount:1000000]
            outHex:@"e718483d0ce769644e2e42c7bc15b4638e1f98b13b2044285632a803af"
            @"a973ebde0ff244877ea60a4cb0432ce577c31beb009c5c2c49aa2e4ea"
            @"db217ad8cc09b"],
      @"Failed!");
}

//- (void)testHMACSHA512 {
// test cases 1, 2, 3, 4, 6 and 7 of RFC 4231

//  XCTAssert([self SHA512:@"0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"
//          HMAC:@"4869205468657265"
//        outHex:@"87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17c"
//        @"dedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a1"
//             @"26854"],
//            @"Failed!");
//
//  XCTAssert([self SHA512:@"4a656665"
//          HMAC:@"7768617420646f2079612077616e7420666f72206e6f7468696e673f"
//        outHex:@"164b7a7bfcf819e2e395fbe73b56e0a387bd64222e831fd610270cd7ea2505"
//               @"549758bf75c05a994a6d034f65f8f0e6fdcaeab1a34d4a6b4b636e070a38b"
//             @"ce737"],
//            @"Failed!");
//
//  XCTAssert([self SHA512:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//          HMAC:@"dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
//               @"dddddddddddddddddddddddddddddddddddddd"
//        outHex:@"fa73b0089d56a284efb0f0756c890be9b1b5dbdd8ee81a3655f83e33b2279d"
//               @"39bf3e848279a722c806b485a47e67c807b946a337bee8942674278859e13"
//             @"292fb"],
//            @"Failed!");
//
//  XCTAssert([self
//  SHA512:@"0102030405060708090a0b0c0d0e0f10111213141516171819"
//          HMAC:@"cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd"
//               @"cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd"
//        outHex:@"b0ba465637458c6990e5a8c5f61d4af7e576d97ff94b872de76f8050361ee3"
//               @"dba91ca5c11aa25eb4d679275cc5788063a5f19741120c4f2de2adebeb10a"
//             @"298dd"],
//            @"Failed!");
//
//  XCTAssert([self
//  SHA512:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaa"
//          HMAC:@"54657374205573696e67204c6172676572205468616e20426c6f636b2d5369"
//               @"7a65204b6579202d2048617368204b6579204669727374"
//        outHex:@"80b24263c7c1a3ebb71493c1dd7be8b49b46d1f41b4aeec1121b013783f8f3"
//               @"526b56d037e05f2598bd0fd2215d6a1e5295e64f73f63f0aec8b915a985d7"
//             @"86598"],
//            @"Failed!");
//
//  XCTAssert([self
//  SHA512:@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
//               @"aaaaaaaaaaaaaaaaa"
//          HMAC:@"5468697320697320612074657374207573696e672061206c61726765722074"
//               @"68616e20626c6f636b2d73697a65206b657920616e642061206c617267657"
//               @"2207468616e20626c6f636b2d73697a6520646174612e20546865206b6579"
//               @"206e6565647320746f20626520686173686564206265666f7265206265696"
//               @"e6720757365642062792074686520484d414320616c676f726974686d2e"
//        outHex:@"e37b6a775dc87dbaa4dfa9f96e5e3ffddebd71f8867289865df5a32d20cdc9"
//               @"44b6022cac3c4982b10d5eeb55c3e4de15134676fb6de0446065c97440fa8"
//             @"c6a58"],
//            @"Failed!");
//}

- (BOOL)SHA1:(NSString *)data outHex:(NSString *)hex {
  return [[[data dataUsingEncoding:NSASCIIStringEncoding] SHA1]
      isEqualToData:[hex hexToData]];
}

- (BOOL)SHA256:(NSString *)data outHex:(NSString *)hex {
  return [[[data dataUsingEncoding:NSASCIIStringEncoding] SHA256]
      isEqualToData:[hex hexToData]];
}

- (BOOL)SHA512:(NSString *)data outHex:(NSString *)hex {
  return [[[data dataUsingEncoding:NSASCIIStringEncoding] SHA512]
      isEqualToData:[hex hexToData]];
}

- (BOOL)RMD160:(NSString *)input outHex:(NSString *)outputHex {
  return [[[input dataUsingEncoding:NSASCIIStringEncoding] RMD160]
      isEqualToData:[outputHex hexToData]];
}

- (BOOL)SHA512:(NSString *)data HMAC:(NSString *)hmac outHex:(NSString *)hex {
  return [[[data dataUsingEncoding:NSASCIIStringEncoding]
      SHA512HmacWithKey:[hmac dataUsingEncoding:NSASCIIStringEncoding]]
      isEqualToData:[hex hexToData]];
}

#pragma mark Utilities

+ (NSString *)repeatedSubstring:(NSString *)sub
                withRepeatCount:(NSUInteger)count {
  NSMutableString *str;
  NSParameterAssert([sub isKindOfClass:[NSString class]]);

  str = [[NSMutableString alloc] init];
  for (NSUInteger i = 0; i < count; ++i) [str appendString:sub];

  return str;
}

@end
