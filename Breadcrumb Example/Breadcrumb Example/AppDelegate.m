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

  [self walletDemo];
  [self rawParseDemo];
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

  transactionHex =
      @"0100000001cf6b23baf0ebb8a09559f761144ab4407b5dce75a9484ed07a6da41f7f021"
      @"8e9010000008a4730440220372be617d9d276340846265ddc7ba9dabbe78e97fac9709"
      @"1f7e2cb19ec2929ae02203be15a0a3929b2353ebb81f5d67b20ab3b1e427f124855a23"
      @"09649858eaa4b340141040cfa3dfb357bdff37c8748c7771e173453da5d7caa32972ab"
      @"2f5c888fff5bbaeb5fc812b473bf808206930fade81ef4e373e60039886b51022ce689"
      @"02d96ef70ffffffff0240420f00000000001976a914a5319d469e1ddd9558bd558a50e"
      @"95f74b3da58c988ac78c4f81e010000001976a91461b469ada61f37c620010912a9d5d"
      @"56646015f1688ac00000000";

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
