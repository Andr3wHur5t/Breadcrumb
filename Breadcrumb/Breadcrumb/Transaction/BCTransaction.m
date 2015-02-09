//
//  BCTransaction.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/7/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCTransaction.h"
#import "BCScript+DefaultScripts.h"
#import "BreadcrumbCore.h"

#import "BCTransactionOutput.h"
#import "BCTransactionInput.h"

@implementation BCTransaction

@synthesize addresses = _addresses;
@synthesize script = _script;
@synthesize hash = _hash;
@synthesize outputIndex = _outputIndex;

@synthesize value = _value;
@synthesize spent = _spent;
@synthesize confirmations = _confirmations;

@synthesize isSigned = _isSigned;

#pragma mark Construction

- (instancetype)initWithAddresses:(NSArray *)addresses
                           script:(BCScript *)script
                             hash:(NSString *)hash
                      outputIndex:(uint32_t)outputIndex
                            value:(NSNumber *)value
                            spent:(NSNumber *)spent
                    confirmations:(NSNumber *)confirmations
                        andSigned:(BOOL)isSigned {
  self = [super init];
  if (self) {
    // Validate addresses
    if (![addresses isKindOfClass:[NSArray class]]) return NULL;
    for (NSUInteger i = 0; i < addresses.count; ++i)
      if (![[addresses objectAtIndex:i] isKindOfClass:[BCAddress class]])
        return NULL;
    _addresses = addresses;

    if (![script isKindOfClass:[BCScript class]]) return NULL;
    _script = script;
    if (![hash isKindOfClass:[NSString class]]) return NULL;
    _hash = hash;

    _outputIndex = outputIndex;

    if (![value isKindOfClass:[NSNumber class]]) return NULL;
    _value = value;
    if (![spent isKindOfClass:[NSNumber class]]) return NULL;
    _spent = spent;

    // Optional value, can be NULL
    _confirmations =
        [confirmations isKindOfClass:[NSNumber class]] ? confirmations : NULL;
    _isSigned = isSigned;
  }
  return self;
}

#pragma mark Debug

- (NSString *)description {
  NSString *addresses;
  for (BCAddress *address in self.addresses)
    if ([addresses isKindOfClass:[NSString class]]) {
      addresses =
          [NSString stringWithFormat:@"%@, %@", addresses, [address toString]];
    } else {
      addresses = [address toString];
    }

  return [NSString stringWithFormat:@"Address(es): %@\nValue: %@\nSpent: %@\n"
                                    @"Confirmations: %@\nHash: %@\nOutput "
                                    @"Index:%@\nScript: '%@'\nisSigned: %@\n",
                                    addresses, self.value, self.spent,
                                    self.confirmations, self.hash,
                                    @(self.outputIndex), self.script,
                                    self.isSigned ? @"true" : @"false"];
}

#pragma mark Transaction Building

// TODO: make sure transaction is less than TX_MAX_SIZE
// TODO: use up all UTXOs for all used addresses to avoid leaving funds in
// addresses whose public key is revealed
// TODO: avoid combining addresses in a single transaction when possible to
// reduce information leakage
// TODO: use any UTXOs received from output addresses to mitigate an
// attacker double spending and requesting a refund
// TODO: randomly swap order of outputs so the change address isn't publicly
// known
+ (instancetype)buildTransactionWith:(NSArray *)utxos
                           forAmount:(NSNumber *)amount
                                  to:(BCAddress *)address
                             feePerK:(NSNumber *)feePerK
                   withChangeAddress:(BCAddress *)changeAddress {
  uint64_t targetAmount = 0, changeAmount = 0, feeAmount = 0, utxoSumAmount = 0;
  BCTransactionOutput *targetOutput, *changeOutput;
  BCTransactionInput *utxoInput;
  BCTransaction *newTransaction;
  // Validate addresses
  if (![address isKindOfClass:[BCAddress class]] ||
      ![changeAddress isKindOfClass:[BCAddress class]])
    return NULL;

  // Validate UTXOs
  if (![utxos isKindOfClass:[NSArray class]]) return NULL;
  for (NSUInteger i = 0; i < utxos.count; ++i) {
    BCTransaction *tx = [utxos objectAtIndex:i];
    if (![tx isKindOfClass:[BCTransaction class]]) return NULL;
    if (tx.isSigned) return NULL;
  }

  // Set our target amount as a usable value
  targetAmount = [amount unsignedIntegerValue];

  // Validate target amount within params

  // Create Mutable Transaction
  newTransaction = [[BCTransaction alloc] init];

  // Set Inputs From UTXOs
  for (BCTransaction *utxo in utxos) {
    // Convert utxo into transactionInput
    utxoInput = [[BCTransactionInput alloc] initWithTransaction:utxo];
    // Add Transaction Input

    // Sum the UTXOs values
    utxoSumAmount += [utxo.value unsignedIntegerValue];
  }

  // Calculate the fee Based off of the transaction size.
  feeAmount = 1;

  if (utxoSumAmount < (targetAmount + feeAmount)) {
    // not enough Funds Error
    return NULL;
  }

  // Because transactions in bitcoin require you to spend an entire transaction
  // to keep the leftover we need a change address so that you only spend the
  // desired amount. Anything left over in the transaction is considered the
  // mining fee.
  changeAmount = utxoSumAmount - (targetAmount + feeAmount);

  // Set Target Outputs
  targetOutput = [BCTransactionOutput standardOutputForAmount:@(targetAmount)
                                                    toAddress:address];
  if (![targetOutput isKindOfClass:[BCTransactionOutput class]]) return NULL;

  // Set Change Output
  changeOutput = [BCTransactionOutput standardOutputForAmount:@(changeAmount)
                                                    toAddress:changeAddress];
  if (![changeOutput isKindOfClass:[BCTransactionOutput class]]) return NULL;

  // Return the built transaction
  return newTransaction;
}

#pragma mark Old

//  // What is happening here
//
//  // Process UTXO scripts?
//  for (NSData *o in utxos) {
//    // What is happening here
//    BRTransaction *tx = self.allTx[[o hashAtOffset:0]];
//
//    // What is N? We are grabbing something in the beginning, or the end?
//    uint32_t n = [o UInt32AtOffset:CC_SHA256_DIGEST_LENGTH];
//
//    // Why are we doing it this way
//    if (!tx) continue;
//    [transaction addInputHash:tx.txHash index:n script:tx.outputScripts[n]];
//    balance += [tx.outputAmounts[n] unsignedLongLongValue];
//
//    // Calculate the Fee
//    if (hasFee) feeAmount = [self feeForTxSize:transaction.size + 34];
//    // assume we will add a change output (34 bytes)
//
//    // Stop if we are sending out more than we have, or we are sending the min
//    // amount, why are we breaking the loop here?
//    if (balance == amount + feeAmount ||
//        balance >= amount + feeAmount + TX_MIN_OUTPUT_AMOUNT)
//      break;
//  }
//
//  if (balance < amount + feeAmount) {  // insufficient funds
//    NSLog(@"Insufficient funds. %llu is less than transaction amount:%llu",
//          balance, amount + feeAmount);
//    return nil;
//  }
//
//   TODO: randomly swap order of outputs so the change address isn't publicly
//   known
//  if (balance - (amount + feeAmount) >= TX_MIN_OUTPUT_AMOUNT) {
//    [transaction addOutputAddress:self.changeAddress
//                           amount:balance - (amount + feeAmount)];
//  }
//
//  //  return transaction;
//  return NULL;
//}

@end
