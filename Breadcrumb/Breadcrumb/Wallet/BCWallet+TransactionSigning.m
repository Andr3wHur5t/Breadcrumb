//
//  BCWallet+TransactionSigning.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//
// Because it is hard to find good documentation on this I'm going to put
// this here for future reference.
//
// How To Sign A Transaction:
// 1) Build an unsigned transaction
//  - Inputs scripts should look similar to
// 'OP_DUP OP_HASH160 010966776006953d5567439e5e39f86a0d273bee OP_EQUALVERIFY
// OP_CHECKSIG'
// 2) For Each Input In the transaction build a hash
// 3) Sign The Hash with the Key which "owns" the transaction
// 4) Append the signature with SIG_HASHALL code
// 5) Append the signature that you just appended with SIG_HASH all with the
// public key of the key which "owns" the transaction.
// 6) Create A script which pushes the signature you just Appended.
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
    NSMutableData *currentSignature;
    NSData *currentHash, *signedHash;
    BCMutableScript *unlockScript;
    BCKeyPair *currentKeyPair;
    BCAddress *currentAddress;

    for (NSUInteger i = 0; i < transaction.inputs.count; ++i) {
      // Get The Hash of the current transaction
      currentHash = [[transaction toData] SHA256_2];
      if (![currentHash isKindOfClass:[NSData class]]) return NULL;

      currentAddress =
          ((BCTransactionInput *)[transaction.inputs objectAtIndex:i])
              .controllingAddress;
      if (![currentAddress isKindOfClass:[BCAddress class]]) return NULL;

      // Get the current key from the address manager
      currentKeyPair = [self.addressManager keyPairForAddress:currentAddress
                                               usingMemoryKey:key];
      if (![currentKeyPair.publicKey isKindOfClass:[BCPublicKey class]])
        return NULL;

      // Sign the transaction
      signedHash = [currentKeyPair signHash:currentHash withMemoryKey:key];

      // Sign the hash with the key that owns the input
      currentSignature = [[NSMutableData alloc] initWithData:signedHash];
      if (![currentSignature isKindOfClass:[NSData class]]) return NULL;

      // Append it with the SIG_HASH all code which specifies the method we used
      // to sign
      [currentSignature appendUInt8:SIGHASH_ALL];

      // Create the unlock script (Also known as sig script)
      unlockScript = [BCMutableScript script];
      if (![unlockScript isKindOfClass:[BCScript class]]) return NULL;

      // Append the signature
      [unlockScript writeBytes:currentSignature];

      // Append the Public Key of the owning Key Pair
      [unlockScript writeBytes:currentKeyPair.publicKey.data];

      // Create an updated input transaction
      updatedInput = [transaction.inputs objectAtIndex:i];
      if (![updatedInput isKindOfClass:[BCTransactionInput class]]) return NULL;

      // Create A clone of the transaction input, but set the script signature
      // to the script we just created.
      updatedInput = [[BCTransactionInput alloc]
           initWithHash:updatedInput.previousOutputHash
          previousIndex:updatedInput.previousOutputIndex
                 script:unlockScript
                address:updatedInput.controllingAddress
            andSequence:updatedInput.sequence];
      if (![updatedInput isKindOfClass:[BCTransactionInput class]]) return NULL;

      // Set The transaction Input to the transaction
      [transaction.inputs setObject:updatedInput atIndexedSubscript:i];
    }

    return transaction;
  }
}

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
  // TODO: Generate a nonce and put it in the key chain
  return @"0X0X0X0XEFFF".hexToData;
}
@end
