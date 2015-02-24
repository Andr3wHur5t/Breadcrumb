//
//  AppDelegate.m
//  Breadcrumb Example
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "AppDelegate.h"
#import <Breadcrumb/Breadcrumb.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

// TODO: Clean up
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  //
  //  [self rawParseDemo];
  [self walletDemo];
  //
  //  NSData *dat =
  //      @"01000000030bf0de38c26195919179f42d475beb7a6b15258c38b57236afdd60a07eddd"
  //      @"2cc000000008e4b3045022100f46b6efb201ae9fb01cb24b7999cb8f014b6158ea9da9"
  //      @"6825a2eb33ad38bfd5a0220186d8bd7cc37b93b035925e57c79e7426668bb055222307"
  //      @"45d721c1fd9d1542b01000000410455588b112746c08ec166a6d9c4d2edb07201c7a0a"
  //      @"07a6201441d24f34748a01030055fd1b0ee3788b190ef13f8a4d39d1029058ba64288f"
  //      @"c95a6e706922c1ce8ffffffff5ad2913b948c883b007b1bca39322c42d60ef465b9dc3"
  //      @"9bc0a53ffe8fe3faafd000000008d4a304402207169195e25a44f9336da4e8f19371b7"
  //      @"cae19ded75c59b884fe91188e2889c748022072ea56e1c808e7d029d4676156ae3e7a4"
  //      @"ef80ca1266e77bc0aff9714e1b80d9301000000410455588b112746c08ec166a6d9c4d"
  //      @"2edb07201c7a0a07a6201441d24f34748a01030055fd1b0ee3788b190ef13f8a4d39d1"
  //      @"029058ba64288fc95a6e706922c1ce8ffffffffb84a66c46e24fe71f9d8ab29b06df93"
  //      @"2d77bec2cc0691799fae398a8dc9069bf010000008d4a3044022033d6c744c4df96545"
  //      @"82a588f8ae4fbfd7a2fc10f90d6b8c92641462dcbfdd556022022414ad7a749f9fb36d"
  //      @"7cb184f238d3f88657af3c21c8a9750a472dad62c47f101000000410455588b112746c"
  //      @"08ec166a6d9c4d2edb07201c7a0a07a6201441d24f34748a01030055fd1b0ee3788b19"
  //      @"0ef13f8a4d39d1029058ba64288fc95a6e706922c1ce8ffffffff02c80000000000000"
  //      @"01a76a91505b472a266d0bd89c13706a4132ccfb16f7c3b9fcb88ac08e904000000000"
  //      @"01a76a91500c629680b8d13ca7a4b7d196360186d05658da6db88ac00000000"
  //           .hexToData;
  //
  //  NSLog(@"Created Trans:%@", [[BCMutableTransaction alloc]
  //  initWithData:dat]);

  //  NSData *pass = [NSMutableData dataWithCapacity:32];
  //  BCKeySequence *kp = [[BCKeySequence alloc]
  //      initWithRootSeed:@"000102030405060708090a0b0c0d0e0f".hexToData
  //          andMemoryKey:pass];
  //
  //  NSLog(@"%@",[[[[kp.masterKeyPair childKeyPairAt:44 withMemoryKey:pass]
  //  childKeyPairAt:0 withMemoryKey:pass] childKeyPairAt:0 withMemoryKey:pass]
  //  childKeyPairAt:0 withMemoryKey:pass].address);

  //  [self testWalletKeyGenVector0];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

- (void)rawParseDemo {
  //  BCMutableTransaction *tx;
  //  NSString *transactionHex;

  //  transactionHex =
  //      @"0100000001cf6b23baf0ebb8a09559f761144ab4407b5dce75a9484ed07a6da41f7f021"
  //      @"8e9010000008a4730440220372be617d9d276340846265ddc7ba9dabbe78e97fac9709"
  //      @"1f7e2cb19ec2929ae02203be15a0a3929b2353ebb81f5d67b20ab3b1e427f124855a23"
  //      @"09649858eaa4b340141040cfa3dfb357bdff37c8748c7771e173453da5d7caa32972ab"
  //      @"2f5c888fff5bbaeb5fc812b473bf808206930fade81ef4e373e60039886b51022ce689"
  //      @"02d96ef70ffffffff0240420f00000000001976a914a5319d469e1ddd9558bd558a50e"
  //      @"95f74b3da58c988ac78c4f81e010000001976a91461b469ada61f37c620010912a9d5d"
  //      @"56646015f1688ac00000000";
  //
  //  transactionHex =
  //  @"010000000297515bb7f32f28446bfe7b34b232b1e9ad1221f1d4ab4624726412764b126611000000006b483045022100fa43ae8f04367447d9682e6a7c2f747ee234d5e57e9414a3ed4039458bd0e8e702200e7f0d7dad54df586145f45ae0fe66bd2ba2018fc4c515853cc2574a65c1508f01210387212e3733d75ddcce9121c2af5df1f06e71f63fb736df4dc02dc56e9f3c4f02ffffffffbe6ee63b7c778f1c31c4710dbffa599b9ec8a9c0fd0e65f7f08d1077ef2f07e4000000006a47304402205e96ffae4e9d4df893391cff431e271aec931ef2255e758619aa8bd1e15c151b0220324a3626c2b8d39a1fec8a9a8dfd3db3513380458edf94c6a06f33da43e5575a01210387212e3733d75ddcce9121c2af5df1f06e71f63fb736df4dc02dc56e9f3c4f02ffffffff0150c30000000000001976a9143696e32f2e5ee974ce59b16a11387dcf05435d6a88ac00000000";

  //  30440220382abd07bc22b92f289b21745bb8c93734eadaf86cc0ff310658b73ac522a69b022043cd23001e4b78dfe3c9df10ab61e10e47abeb88b86c4bc8f0d2a2db95f405d501000000043531554b88ed1404d6d421a115aa72b1a429505a3b0ce248ebaba63e83df9bf444ef7a73b12798d5f47a40d66eb3c09d63b952783f7718f9d81258ed39a3bc43

  // 4930460221009e0339f72c793a89e664a8a932df073962a3f84eda0bd9e02084a6a9567f75aa022100bd9cbaca2e5ec195751efdfac164b76250b1e21302e51ca86dd7ebd7020cdc0601410450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6
  //
  //  transactionHex =
  //      @"0100000002be6ee63b7c778f1c31c4710dbffa599b9ec8a9c0fd0e65f7f08d1077ef2f0"
  //      @"7e4000000006a473044022028758879bba44439ab8ad5be025ff9d8acc38206f626d1c"
  //      @"a4a1dbf0af343265302205bb7db56d5426bd11810ed06bf50ae2a018bc7cc8639d6dfc"
  //      @"5e7fdc9f052c13f01210387212e3733d75ddcce9121c2af5df1f06e71f63fb736df4dc"
  //      @"02dc56e9f3c4f02ffffffff97515bb7f32f28446bfe7b34b232b1e9ad1221f1d4ab462"
  //      @"4726412764b126611000000006a47304402200c3dd4af3a7e273aab864d797d18b1b05"
  //      @"a5f1980a19fd27e8a5de8d3c3ec8cdf02203718499f163104d162d67d1a095bbc9c443"
  //      @"db9d8ca03207a461aefe4e16f394301210387212e3733d75ddcce9121c2af5df1f06e7"
  //      @"1f63fb736df4dc02dc56e9f3c4f02ffffffff0228230000000000001976a914dc8ae9c"
  //      @"bf82a840cb562793cc1928bd485cc531888ac50c30000000000001976a9143696e32f2"
  //      @"e5ee974ce59b16a11387dcf05435d6a88ac00000000";
  //
  //  NSString *str = [transactionHex.hexToData base58Encoding];

  //  tx = [[BCMutableTransaction alloc] initWithData:transactionHex.hexToData];
  //  NSLog(@"Transaction Info:\n%@", tx);
}

- (void)walletDemo {
  NSData *password;
  BCAddress *address;
  NSNumber *amount;
  // This is an example of our high level simple interface

  // The password is an NSData object so that you can easily use touch
  // authentication, and other authentication sources.
  password = [@"password" dataUsingEncoding:NSUTF8StringEncoding];

  // When you instantiate a wallet it requires a password to decrypt private
  // restoration data, or encrypt new private data such as the wallets' seed
  // phrase.
  NSString *phrase = @"palace canal coast awake mother captain mountain bronze "
      @"cabbage unfair patrol robot";
  BCWallet *wallet =
      [[BCWallet alloc] initUsingMnemonicPhrase:phrase andPassword:password];

  // You can retrieve the wallets protected info like is mnemonic phrase using
  // the password
  [wallet mnemonicPhraseWithPassword:password
                       usingCallback:^(NSString *mnemonic) {
                           // Show the user their mnemonic phrase.
                           [self showAlertWithTitle:@"Your Phrase"
                                         andMessage:mnemonic];
                           NSLog(@"Phrase '%@'", mnemonic);
                       }];

  // Get your current address
  [wallet getCurrentAddress:^(BCAddress *currentAddress) {
      [self showAlertWithTitle:@"Your Address"
                    andMessage:[currentAddress toString]];
      NSLog(@"Address: '%@'", currentAddress);
  }];

  // Get balance
  [wallet getBalance:^(uint64_t balance, NSError *error) {
      NSLog(@"balance: %@", @(balance));
  }];

  // Sending Bitcoin is as easy just specify the amount of satoshi,
  // the address to send to, and a completion. The wallet, and service provider
  // will handle the rest.
  address = [@"1fcgJ8z4kcEG4aPwGTjXZp3z6sDTUvoU8" toBitcoinAddress];
  // TODO: Change amount to uint64_t
  amount = [@(1e3) toSatoshi];
  [wallet send:amount
                 to:address
      usingPassword:password
       withCallback:^(NSError *error) {
           if ([error isKindOfClass:[NSError class]])
             [self showAlertWithTitle:@"Woops"
                           andMessage:error.localizedDescription];
           else
             [self showAlertWithTitle:@"Sent!" andMessage:@"You Sent Bitcoin!"];
       }];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
  [[[UIAlertView alloc] initWithTitle:title
                              message:message
                             delegate:NULL
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

#pragma mark Test Vectors (TODO: MOVE TO XCTESTS)

- (void)testWalletKeyGenVector0 {
  // Test compatibility with BitcoinJ
  NSData *password;
  BCWallet *wallet;

  password = [[NSMutableData alloc] initWithLength:32];
  wallet = [[BCWallet alloc]
      initUsingMnemonicPhrase:@"slab ski horn medal document cat minute "
      @"uniform worth coyote sight dragon"
                  andPassword:password];

  NSAssert(wallet, @"Failed");
  [wallet
      keySequenceWithPassword:password
                usingCallback:^(BCKeySequence *sequence, NSData *memoryKey) {
                    BCKeyPair *m_0h, *m_0h_0, *m_0h_0_0;
                    // Verify the root seed matches
                    NSAssert([[sequence.rootSeed dataUsingMemoryKey:memoryKey]
                                 isEqualToData:@"77e572c9238590d687ca29cd3c6a6b"
                                               @"f9f973a26eafadf49e24880d1c62f"
                                               @"3ec03ac7867aa2b1a0102c5bc11cc"
                                               @"dc40eea2580ab41a818fea2166b60"
                                               @"816a96c98b1".hexToData],
                             @"Failed");

                    // Verify HD
                    // M/0'
                    m_0h = [sequence.masterKeyPair childKeyPairAt:0x80000000
                                                    withMemoryKey:memoryKey];

                    // Chain Code
                    NSAssert([m_0h.chainCode
                                 isEqualToData:@"e92d1221934bfe476a6311a1c4efca"
                                               @"755fcf27170dbdde60e2efb52a82a"
                                               @"1bf91".hexToData],
                             @"Failed");

                    // Pub Key
                    NSAssert([m_0h.publicKey
                                 isEqualToData:@"031c243bb8b8c1a3f31f4a68ed550e"
                                               @"80862bb314387b0c06872a95142f2"
                                               @"55e65d6".hexToData],
                             @"Failed");

                    // M/0'/0
                    m_0h_0 = [m_0h childKeyPairAt:0 withMemoryKey:memoryKey];

                    // Chain Code
                    NSAssert([m_0h_0.chainCode
                                 isEqualToData:@"0ff81906965fa4957fd97958839a70"
                                               @"33dc6ddcb46ef100e0ceb3f6841d8"
                                               @"86e0a".hexToData],
                             @"Failed");

                    // Pub Key
                    NSAssert([m_0h_0.publicKey
                                 isEqualToData:@"02cefa13934831168b8d6e12e1c1e3"
                                               @"41240d3e0c9be18a8557758c98a17"
                                               @"f7d9f97".hexToData],
                             @"Failed");

                    // M/0'/0/0
                    m_0h_0_0 =
                        [m_0h_0 childKeyPairAt:0 withMemoryKey:memoryKey];

                    // Chain Code
                    NSAssert([m_0h_0_0.chainCode
                                 isEqualToData:@"f0219686103125a3993ec60d73238a"
                                               @"03fbd36ec89fe539514fedbda0766"
                                               @"c0bd5".hexToData],
                             @"Failed");

                    // Pub Key
                    NSAssert([m_0h_0_0.publicKey
                                 isEqualToData:@"033319568f40dca5ee98bfada06bd1"
                                               @"c239d62946646b854f49b055c973f"
                                               @"9e5c265".hexToData],
                             @"Failed");
                }];
}

@end
