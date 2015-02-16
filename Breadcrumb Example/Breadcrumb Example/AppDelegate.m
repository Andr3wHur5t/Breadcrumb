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

  //  [self walletDemo];
//    [self rawParseDemo];
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
  BCMutableTransaction *tx;
  NSString *transactionHex;

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

  transactionHex =
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
  
  NSString *str = [transactionHex.hexToData base58Encoding];
  // Full Check
 
  
  // Base58 encoding
  NSAssert([[@"deadBeeF".hexToData base58Encoding] isEqualToString:@"6h8cQN"], @"Encodes base58");
  NSAssert([[[@"6h8cQN" base58ToData] toHex] isEqual:@"deadbeef"], @"Decodes base58");
   NSAssert([[[transactionHex.hexToData base58Encoding] base58ToData] isEqualToData:transactionHex.hexToData], @"Full Encoding Check");
  
  
  // Base58 Check Encoding
  NSAssert([[@"00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827".hexToData base58CheckEncoding] isEqualToString:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"Encodes base58 with checksum");
  NSAssert([[[@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T" base58checkToData] toHex] isEqual:@"00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"], @"Decodes base58 with checksum");
  NSAssert([[[transactionHex.hexToData base58CheckEncoding] base58ToData] isEqualToData:transactionHex.hexToData], @"Full Encoding Check");

  
  tx = [[BCMutableTransaction alloc] initWithData:transactionHex.hexToData];
  NSLog(@"Transaction Info:\n%@", tx);
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
  BCWallet *wallet = [[BCWallet alloc] initNewWithPassword:password];

  // You can retrieve the wallets protected info like is mnemonic phrase using
  // the password
  [wallet mnemonicPhraseWithPassword:password
                       usingCallback:^(NSString *mnemonic) {
                           // Show the user their mnemonic phrase.
                           [self showAlertWithTitle:@"Your Phrase"
                                         andMessage:mnemonic];
                       }];

  // Sending Bitcoin is as easy just specify the amount of satoshi,
  // the address to send to, and a completion. The wallet, and service provider
  // will handle the rest.
  address = [@"3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy" toBitcoinAddress];
  amount = [@200 toSatoshi];
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

@end
