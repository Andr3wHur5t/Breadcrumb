//
//  BCWalletGenerationTests.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/18/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "Breadcrumb.h"
#import "_BCWallet.h"
#import <XCTest/XCTest.h>

@interface BCWalletGenerationTests : XCTestCase

@end

@implementation BCWalletGenerationTests

#pragma mark BIP Defined Vectors

// correct horse battery staple
// Private Key: C4BBCB1FBEC99D65BF59D85C8CB62EE2DB963F0FE106F483D9AFA73BD4E39A8A
// Address: 1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T

#pragma mark BitcoinJ BIP 32 Vectors (TESTNET)

// Seed as words: mouse palace human birth waste brother pair fragile million
// west aspect express
// Seed as hex:
// 4b51919e2f2be7909d5d5260e0f9a929799d93b4ab687657d1d5bcfde97be80fa2e36d6fa3fc594943e82aa5a238723be6c931fba5dd4d7395d0a8c9a46b4272
// M/0H
// DeterministicKey{pub=039bc63c02a83c5347e5e0a45aa1ece696bb66b3408e4048f1379fa6514169f65e,
// chainCode=a9b92f438ba117eb470c423ba6965fadaf6d97607b481e4128660b6ba403ebc4,
// path=M/0H}
// M/0H/0
// DeterministicKey{pub=03bfe172fa9be00ae96c19ca7345316fc1a2b1768bc009370a507b154550ba7040,
// chainCode=90690e08539f021d9a6e196cd25d404e3b5423f48435881d0e45823317648faa,
// path=M/0H/0}
// M/0H/0/0
// DeterministicKey{pub=02fb9b3bf3374d0e1b9573156b3c0a778b2f0979482e0fd7fa07e8af42dd55eb7c,
// chainCode=156940426ae5cfc90eea3dd6c94a0b3255d99fbb7ad69435f1581011db8020b0,
// path=M/0H/0/0} mvihzZu32GdpYrhVHi8CYXF2yUDaKG2ivu


@end
