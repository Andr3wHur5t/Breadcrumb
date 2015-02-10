//
//  BCMutableTransaction.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCMutableTransaction.h"
#import "BreadcrumbCore.h"
#import "NSData+ConversionUtilties.h"

#define BC_BITCOIN_VERSION 1

@implementation BCMutableTransaction

@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

#pragma mark Construction

- (instancetype) init {
  self = [super init];
  if ( self ) {
    self.lockTime = 0;
  }
  return self;
}

+ (instancetype)mutableTransaction {
  return [[[self class] alloc] init];
}

#pragma mark Configuration

- (NSMutableArray *)inputs {
  if (!_inputs) _inputs = [[NSMutableArray alloc] init];
  return _inputs;
}

- (NSMutableArray *)outputs {
  if (!_outputs) _outputs = [[NSMutableArray alloc] init];
  return _outputs;
}
#pragma mark mutation

- (void)addInput:(BCTransactionInput *)input {
  NSParameterAssert([input isKindOfClass:[BCTransactionInput class]]);
  if (![input isKindOfClass:[BCTransactionInput class]]) return;

  [self.inputs addObject:input];
}

- (void)addOutput:(BCTransactionOutput *)output {
  NSParameterAssert([output isKindOfClass:[BCTransactionOutput class]]);
  if (![output isKindOfClass:[BCTransactionOutput class]]) return;

  [self.outputs addObject:output];
}

#pragma mark Representations

- (NSString *)toString {
  if (![self inputsAreValid]) return @"Has invalid input.";
  if (![self outputsAreValid]) return @"Has invalid output.";

  return [NSString
      stringWithFormat:@"Inputs:\n%@\nOutputs:\n%@", self.inputs, self.outputs];
}

- (NSData *)toData {
  NSMutableData *buffer;
  if (![self inputsAreValid] || ![self outputsAreValid]) return NULL;

  buffer = [[NSMutableData alloc] init];

  [buffer
      appendUInt32:BC_BITCOIN_VERSION];  // Write the bitcoin protocol version

  [buffer appendVarInt:self.inputs.count];            // Input Count
  for (NSUInteger i = 0; i < self.inputs.count; ++i)  // Write all inputs
    [buffer appendData:[[self.inputs objectAtIndex:i] toData]];

  [buffer appendVarInt:self.outputs.count];            // Output Count
  for (NSUInteger i = 0; i < self.outputs.count; ++i)  // Write Outputs
    [buffer appendData:[[self.outputs objectAtIndex:i] toData]];

  [buffer appendUInt32:self.lockTime];  // Lock Time

  return buffer;
}

#pragma mark Checks

- (BOOL)inputsAreValid {
  // Check all inputs are the correct class
  for (NSUInteger i = 0; i < self.inputs.count; ++i)
    if (![[self.inputs objectAtIndex:i]
            isKindOfClass:[BCTransactionInput class]])
      return FALSE;
  return TRUE;
}

- (BOOL)outputsAreValid {
  // Check all ouptuts are the correct class
  for (NSUInteger i = 0; i < self.outputs.count; ++i)
    if (![[self.outputs objectAtIndex:i]
            isKindOfClass:[BCTransactionOutput class]])
      return FALSE;
  return TRUE;
}

#pragma mark Debug

- (NSString *)description {
  return [self toString];
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
+ (BCMutableTransaction *)buildTransactionWith:(NSArray *)utxos
                                     forAmount:(NSNumber *)amount
                                            to:(BCAddress *)address
                                       feePerK:(NSNumber *)feePerK
                             withChangeAddress:(BCAddress *)changeAddress {
  uint64_t targetAmount = 0, changeAmount = 0, feeAmount = 0, utxoSumAmount = 0;
  BCTransactionOutput *targetOutput, *changeOutput;
  BCTransactionInput *utxoInput;
  BCMutableTransaction *newTransaction;
  
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
  newTransaction = [BCMutableTransaction mutableTransaction];
  
  // Set Inputs From UTXOs
  for (BCTransaction *utxo in utxos) {
    // Convert utxo into transactionInput
    utxoInput = [[BCTransactionInput alloc] initWithTransaction:utxo];
    // Add Transaction Input
    [newTransaction addInput:utxoInput];
    
    utxoInput = [[BCTransactionInput alloc] initWithData:[utxoInput toData]];
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
  [newTransaction addOutput:targetOutput];
  
  // Set Change Output
  changeOutput = [BCTransactionOutput standardOutputForAmount:@(changeAmount)
                                                    toAddress:changeAddress];
  if (![changeOutput isKindOfClass:[BCTransactionOutput class]]) return NULL;
  [newTransaction addOutput:changeOutput];
  
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
