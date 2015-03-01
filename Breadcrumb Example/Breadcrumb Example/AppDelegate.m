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

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  // This demos raw transaction parsing.
  //  [self rawParse];

  // This demos end to end wallet functionality.
  [self walletDemo];
  [self testPubKeyDiriviation];

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

- (void)rawParse {
  // This parses the transaction hex, and prints its' contents.
  NSString *transactionHex =
      @"0100000002be6ee63b7c778f1c31c4710dbffa599b9ec8a9c0fd0e65f7f08d1077ef2f0"
      @"7e4000000006a473044022028758879bba44439ab8ad5be025ff9d8acc38206f626d1c"
      @"a4a1dbf0af343265302205bb7db56d5426bd11810ed06bf50ae2a018bc7cc8639d6dfc"
      @"5e7fdc9f052c13f01210387212e3733d75ddcce9121c2af5df1f06e71f63fb736df4dc"
      @"02dc56e9f3c4f02ffffffff97515bb7f32f28446bfe7b34b232b1e9ad1221f1d4ab462"
      @"4726412764b126611000000006a47304402200c3dd4af3a7e273aab864d797d18b1b05"
      @"a5f1980a19fd27e8a5de8d3c3ec8cdf02203718499f163104d162d67d1a095bbc9c443"
      @"db9d8ca03207a461aefe4e16f394301210387212e3733d75ddcce9121c2af5df1f06e7"
      @"1f63fb736df4dc02dc56e9f3c4f02ffffffff0228230000000000001976a914dc8ae9c"
      @"bf82a840cb562793cc1928bd485cc531888ac50c30000000000001976a9143696e32f2"
      @"e5ee974ce59b16a11387dcf05435d6a88ac00000000";

  BCMutableTransaction *tx =
      [[BCMutableTransaction alloc] initWithData:transactionHex.hexToData];
  NSLog(@"Transaction Info:\n%@", tx);
}

- (void)walletDemo {
  NSData *password;
  // This is an example of our high level interface

  // The password is an NSData object so that you can easily use touch
  // authentication, and other authentication sources.
  password = [@"password" dataUsingEncoding:NSUTF8StringEncoding];

  // When you instantiate a wallet it requires a password to decrypt private
  // restoration data, or encrypt new private data such as the wallets' seed
  // phrase.
  NSString *phrase = @"palace canal coast awake mother captain mountain bronze "
      @"cabbage unfair patrol robot";

  BCWallet *wallet = [[BCWallet alloc]
      initUsingMnemonicPhrase:phrase
                         coin:[BCCoin TestNet3Bitcoin]
                     provider:[[BCProviderChain alloc] init]
                 sequenceType:BCKeySequenceType_BIP44
                     password:password
                  andCallback:^(NSError *error) {
                      if (![error isKindOfClass:[NSError class]])
                        NSLog(@"Generated wallet");
                      else
                        NSLog(@"Failed to generate wallet because '%@'",
                              error.localizedDescription);
                  }];

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
      NSLog(@"\nAddress: '%@'", currentAddress);
  }];

  // Get balance
  [wallet getBalance:^(uint64_t balance, NSError *error) {
      NSLog(@"balance: %@", [BCAmount prettyPrint:balance]);
  }];

  // Sending Bitcoin is as easy just specify the amount of satoshi,
  // the address to send to, and a completion. The wallet, and service provider
  // will handle the rest.
  BCAddress *address = [@"mjD8pSfS6A6SzyVkyPHruvHuTwNM79HHrb" toBitcoinAddress];

  // BCAmount converts to and from satoshi.
  uint64_t amount = [BCAmount Bits:1.345666];
  [wallet send:amount
                 to:address
      usingPassword:password
       withCallback:^(NSData *transactionHash, NSError *error) {
           if ([error isKindOfClass:[NSError class]])
             [self showAlertWithTitle:@"Woops"
                           andMessage:error.localizedDescription];
           else {
             [self
                 showAlertWithTitle:
                     [NSString stringWithFormat:@"Sent %@ to",
                                                [BCAmount prettyPrint:amount]]
                         andMessage:[NSString stringWithFormat:@"%@", address]];
             NSLog(@"See the transaction at "
                   @"'https://test.helloblock.io/transactions/%@'",
                   [transactionHash toHex]);
           }
       }];
  NSLog(@"\nSending %@ to: %@", [BCAmount prettyPrint:amount], address);
}

- (void)testPubKeyDiriviation {
  BCWallet *wallet;
  NSData *password = [NSData pseudoRandomDataWithLength:32];
  NSString *phrase = @"palace canal coast awake mother captain mountain bronze "
      @"cabbage unfair patrol robot";

  wallet =
      [[BCWallet alloc] initUsingMnemonicPhrase:phrase
                                           coin:[BCCoin TestNet3Bitcoin]
                                       provider:[[BCProviderChain alloc] init]
                                   sequenceType:BCKeySequenceType_BIP44
                                       password:password
                                    andCallback:^(NSError *e){

                                    }];
  [wallet
      keySequenceWithPassword:password
                usingCallback:^(BCKeySequence *sequence, NSData *memoryKey) {
                    BCDerivablePublicKey *root1;
                    BCKeyPair *kp1;

                    root1 =
                        (BCDerivablePublicKey *)
                            [sequence keyPairForComponents:@[ @0, @0 ]
                                              andMemoryKey:memoryKey].publicKey;
                    kp1 = [sequence keyPairForComponents:@[ @(0), @0 ]
                                            andMemoryKey:memoryKey];

                    NSAssert([[root1 childKeyAtIndex:0].data
                                 isEqualToData:[kp1 childKeyPairAt:0
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");
                    NSAssert([[root1 childKeyAtIndex:1].data
                                 isEqualToData:[kp1 childKeyPairAt:1
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");
                    NSAssert([[root1 childKeyAtIndex:2].data
                                 isEqualToData:[kp1 childKeyPairAt:2
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");

                    NSAssert([[root1 childKeyAtIndex:3].data
                                 isEqualToData:[kp1 childKeyPairAt:3
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");

                    root1 =
                        (BCDerivablePublicKey *)[sequence
                            keyPairForComponents:@[ @(BIP32_PRIME | 0), @0 ]
                                    andMemoryKey:memoryKey].publicKey;
                    kp1 = [sequence
                        keyPairForComponents:@[ @(BIP32_PRIME | 0), @0 ]
                                andMemoryKey:memoryKey];

                    NSAssert([[root1 childKeyAtIndex:0].data
                                 isEqualToData:[kp1 childKeyPairAt:0
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");
                    NSAssert([[root1 childKeyAtIndex:1].data
                                 isEqualToData:[kp1 childKeyPairAt:1
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");
                    NSAssert([[root1 childKeyAtIndex:2].data
                                 isEqualToData:[kp1 childKeyPairAt:2
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");

                    NSAssert([[root1 childKeyAtIndex:3].data
                                 isEqualToData:[kp1 childKeyPairAt:3
                                                     withMemoryKey:memoryKey]
                                                   .publicKey.data],
                             @"Failed");

                }];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
  [[[UIAlertView alloc] initWithTitle:title
                              message:message
                             delegate:NULL
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

@end
