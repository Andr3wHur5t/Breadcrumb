//
//  BCWallet+TransactionSigning.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
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
                                   withKey:(NSData *)key
                                  andError:(NSError **)error {
  @autoreleasepool {  // Ensure immediate deallocation of sensitive data.
    NSMutableArray *signedInputs, *emptyScriptInputs;
    NSArray *originalInputs;
    BCTransactionInput *updatedInput;
    NSMutableData *currentSignature;
    NSData *currentHash, *signedHash;
    BCMutableScript *unlockScript;
    BCKeyPair *currentKeyPair;
    BCAddress *currentAddress;

    originalInputs = [transaction.inputs copy];

    // We need empty versions of the input for each transaction for when we sign.
    // https://github.com/minium/Bitcoin-Spec/blob/master/Images/SIGHASH_ALL.pdf
    emptyScriptInputs = [[NSMutableArray alloc] init];
    BCTransactionInput *newEmpty, *org;
    for (NSUInteger i = 0; i < originalInputs.count; ++i) {
      org = [originalInputs objectAtIndex:i];
      
      // Create the empty transaction
      newEmpty = [[BCTransactionInput alloc]
           initWithHash:org.previousOutputHash
          previousIndex:org.previousOutputIndex
                 script:[BCScript scriptWithData:NULL]
                address:org.controllingAddress
            andSequence:org.sequence];

      [emptyScriptInputs setObject:newEmpty atIndexedSubscript:i];
    }

    // For Multi-signiture check if the Input For the Pub Key Or Pub Key Hash
    // Need to detect tx type P2PKSH/P2SH , P2PK, and MULTI-SIG
    // Detect In Address Manager?
    
    // Sign Transaction Inputs
    signedInputs = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < originalInputs.count; ++i) {
      // Set all inputs to empty
      [transaction.inputs setArray:emptyScriptInputs];
      
      // Set the current index to its original script
      [transaction.inputs setObject:[originalInputs objectAtIndex:i] atIndexedSubscript:i];
      
      // Get The Hash of the current transaction
      currentHash = [[transaction toData] SHA256_2];
      if (![currentHash isKindOfClass:[NSData class]]) {
        if (error) *error = [[self class] internalSigningError:601];
        return NULL;
      }

      currentAddress =
          ((BCTransactionInput *)[transaction.inputs objectAtIndex:i])
              .controllingAddress;
      if (![currentAddress isKindOfClass:[BCAddress class]]) {
        if (error) *error = [[self class] internalSigningError:602];
        return NULL;
      }

      // TODO: Switch From Address to script
      // TODO: Alow for multiple keys to sign the input via array
      // Get the current key from the address manager
      currentKeyPair = [self.addressManager keyPairForAddress:currentAddress
                                               usingMemoryKey:key];
      if (![currentKeyPair.publicKey isKindOfClass:[BCPublicKey class]]) {
        if (error) *error = [[self class] internalSigningError:603];
        return NULL;
      }

      // Sign the transaction
      signedHash = [currentKeyPair signHash:currentHash withMemoryKey:key];

      // Sign the hash with the key that owns the input
      currentSignature = [[NSMutableData alloc] initWithData:signedHash];
      if (![currentSignature isKindOfClass:[NSData class]]) {
        if (error) *error = [[self class] internalSigningError:604];
        return NULL;
      }

      // Append it with the SIG_HASH all code which specifies the method we used
      // to sign
      [currentSignature appendUInt8:SIGHASH_ALL];

      // Create the unlock script (Also known as sig script)
      unlockScript = [BCMutableScript script];
      if (![unlockScript isKindOfClass:[BCScript class]]) {
        if (error) *error = [[self class] internalSigningError:605];
        return NULL;
      }

      // Append the signature
      [unlockScript writeBytes:currentSignature];

      // Append the Public Key of the owning Key Pair
      [unlockScript writeBytes:currentKeyPair.publicKey.data];

      // Create an updated input transaction
      updatedInput = [transaction.inputs objectAtIndex:i];
      if (![updatedInput isKindOfClass:[BCTransactionInput class]]) {
        if (error) *error = [[self class] internalSigningError:606];
        return NULL;
      }

      // Create A clone of the transaction input, but set the script signature
      // to the script we just created.
      updatedInput = [[BCTransactionInput alloc]
           initWithHash:updatedInput.previousOutputHash
          previousIndex:updatedInput.previousOutputIndex
                 script:unlockScript
                address:updatedInput.controllingAddress
            andSequence:updatedInput.sequence];
      if (![updatedInput isKindOfClass:[BCTransactionInput class]]) {
        if (error) *error = [[self class] internalSigningError:607];
        return NULL;
      }

      // Add the signed input to the signed inputs array
      [signedInputs setObject:updatedInput atIndexedSubscript:i];
    }

    // Replace all transaction inputs with the signed inputs
    [transaction.inputs setArray:signedInputs];
    return transaction;
  }
}

+ (NSError *)internalSigningError:(NSInteger)code {
  return [NSError
      errorWithDomain:@"com.breadcrumb.transactionSigning"
                 code:code
             userInfo:@{
               NSLocalizedDescriptionKey : [NSString
                   stringWithFormat:@"Transaction signing error. (Code: %@)",
                                    @(code)]
             }];
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
