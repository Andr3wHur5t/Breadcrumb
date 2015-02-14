//
//  BCWallet+TransactionSigning.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
// Because it is hard to find good documentation on this I'm going to put
// this here for future refrence.
//
// How To Sign A Transaction:
// 1) Build an unsigned transaction
//  - Inputs scripts should look similar to
// 'OP_DUP OP_HASH160 010966776006953d5567439e5e39f86a0d273bee OP_EQUALVERIFY
// OP_CHECKSIG'
// 2) For Each Input In the transaction build a hash
// 3) Sign The Hash with the Key which "owns" the transaction
// 4) Append the signiture with SIG_HASHALL code
// 5) Append the signiture that you just appended with SIG_HASH all with the
// public key of the key which "owns" the transaction.
// 6) Create A script which pushes the signiture you just Appended.
// 7) Replace the script of the first most input that is unsigned with the newly
// generated script.
// 8) Do this again for each input...

#import "BCWallet+TransactionSigning.h"
#import "_BCWallet.h"
#import "NSData+Hash.h"

@implementation BCWallet (_TransactionSigning)

- (BCMutableTransaction *)_signTransaction:(BCMutableTransaction *)transaction
                                   withKey:(NSData *)key {
  @autoreleasepool {  // Ensure immediate deallocation of sensitive data.
    BCTransactionInput *updatedInput;
    NSMutableData *currentSigniture;
    NSData *currentHash, *signedHash;
    BCMutableScript *unlockScript;
    BCKeyPair *currentKeyPair;

    // This is a complex process, This should be well commented for
    // explanation...
    for (NSUInteger i = 0; i < transaction.inputs.count; ++i) {
      // Get The Hash of the current transaction
      currentHash = [[transaction toData] SHA256_2];
      if (![currentHash isKindOfClass:[NSData class]]) return NULL;

      // TODO: Find key
      currentKeyPair = self.keys;
      if (![currentKeyPair.publicKey isKindOfClass:[NSData class]]) return NULL;
      
      // Sign the transaction
      signedHash = [currentKeyPair signHash:currentHash withMemoryKey:key];
      
      // Sign the hash with the key that owns the input
      currentSigniture = [[NSMutableData alloc] initWithData:signedHash];
      if (![currentSigniture isKindOfClass:[NSData class]]) return NULL;


      // Append it with the SIG_HASH all code which specifies the method we used
      // to sign
      [currentSigniture appendUInt32:SIGHASH_ALL];
      

      // Create the unlock script (Also known as sig script)
      unlockScript = [BCMutableScript script];
      if (![unlockScript isKindOfClass:[BCScript class]]) return NULL;

      // Append the signiture
      [unlockScript writeBytes:currentSigniture];

      // Append the Public Key of the owning Key Pair
      [unlockScript writeBytes:currentKeyPair.publicKey];

      // Create an updated input transaction
      updatedInput = [transaction.inputs objectAtIndex:i];
      if (![updatedInput isKindOfClass:[BCTransactionInput class]]) return NULL;

      // Create A clone of the transaction input, but set the script signiture
      // to the script we just created.
      updatedInput = [[BCTransactionInput alloc]
           initWithHash:updatedInput.previousOutputHash
          previousIndex:updatedInput.previousOutputIndex
                 script:unlockScript
            andSequence:updatedInput.sequence];
      if (![updatedInput isKindOfClass:[BCTransactionInput class]]) return NULL;

      // Set The transaction Input to the transaction
      [transaction.inputs setObject:updatedInput atIndexedSubscript:i];
    }

    return transaction;  // transaction;
  }
}

#pragma mark Old
// sign any inputs in the given transaction that can be signed using private
// keys from the wallet
//- (BOOL)signTransaction:(BRTransaction *)transaction withPrompt:(NSString
//*)authprompt
//{
//  @autoreleasepool { // @autoreleasepool ensures sensitive data will be
//  dealocated immediately
//    int64_t amount = [self amountSentByTransaction:transaction] - [self
//    amountReceivedFromTransaction:transaction];
//    NSData *seed = self.seed(authprompt, (amount > 0) ? amount : 0);
//    NSMutableArray *pkeys = [NSMutableArray array];
//    NSMutableOrderedSet *externalIndexes = [NSMutableOrderedSet orderedSet],
//    *internalIndexes = [NSMutableOrderedSet orderedSet];
//
//    if (! seed) return YES; // user canceled authentication
//
//    for (NSString *addr in transaction.inputAddresses) {
//      [internalIndexes addObject:@([self.internalAddresses
//      indexOfObject:addr])];
//      [externalIndexes addObject:@([self.externalAddresses
//      indexOfObject:addr])];
//    }
//
//    [internalIndexes removeObject:@(NSNotFound)];
//    [externalIndexes removeObject:@(NSNotFound)];
//    [pkeys addObjectsFromArray:[self.sequence privateKeys:[externalIndexes
//    array] internal:NO fromSeed:seed]];
//    [pkeys addObjectsFromArray:[self.sequence privateKeys:[internalIndexes
//    array] internal:YES fromSeed:seed]];
//
//    [transaction signWithPrivateKeys:pkeys];
//
//    return [transaction isSigned];
//  }
//}

@end

@implementation BCWallet (_SecurityUtilities)

+ (NSData *)_keyFromPassword:(NSData *)password {
  @autoreleasepool {
    NSData *keyData;
    keyData = [NSData scryptPassword:password
                           usingSalt:[self _saltData]
                    withOutputLength:32];

    return keyData;
  }
}

+ (NSData *)_saltData {
  // TODO: Get salt on a per device basis
  return @"0X0X0X0XEFFF".hexToData;
}
@end
