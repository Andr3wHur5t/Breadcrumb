//
//  BCMutableTransaction.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCMutableTransaction.h"
#import "BreadcrumbCore.h"

#define BC_BITCOIN_VERSION 1

@implementation BCMutableTransaction

@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

#pragma mark Construction

- (instancetype)init {
  self = [super init];
  if (self) {
    self.lockTime = 0;
  }
  return self;
}

- (instancetype)initWithData:(NSData *)data {
  BCTransactionInput *input;
  BCTransactionOutput *output;
  uint64_t inputCount = 0, outputCount = 0;
  NSUInteger position = 0, length = 0;
  uint32_t version = 0;
  NSParameterAssert([data isKindOfClass:[NSData class]]);
  if (![data isKindOfClass:[NSData class]]) return NULL;

  self = [super init];
  if (!self) return NULL;

  version = [data UInt32AtOffset:position];  // Get the version
  position += sizeof(uint32_t);

  // Parse Based off of version
  switch (version) {
    default:  // version 1
      // Get Inputs
      inputCount = [data varIntAtOffset:position length:&length];
      position += length;
      for (NSUInteger i = 0; i < inputCount; ++i) {
        input = [[BCTransactionInput alloc] initWithData:data
                                                atOffset:position
                                              withLength:&length];
        if (![input isKindOfClass:[BCTransactionInput class]]) return NULL;

        [self addInput:input];
        position += length;
      }

      // Get Outputs
      outputCount = [data varIntAtOffset:position length:&length];
      position += length;
      for (NSUInteger i = 0; i < outputCount; ++i) {
        output = [[BCTransactionOutput alloc] initWithData:data
                                                  atOffset:position
                                                withLength:&length];
        if (![output isKindOfClass:[BCTransactionOutput class]]) return NULL;

        [self addOutput:output];
        position += length;
      }
      break;
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
  NSString *inputsString, *outputsString;
  if (![self inputsAreValid]) return @"Has invalid input.";
  if (![self outputsAreValid]) return @"Has invalid output.";

  inputsString = @"";
  for (BCTransactionInput *input in self.inputs)
    inputsString = [inputsString stringByAppendingFormat:@"%@\n\n", input];

  outputsString = @"";
  for (BCTransactionOutput *output in self.outputs)
    outputsString = [outputsString stringByAppendingFormat:@"%@\n\n", output];

  return [NSString stringWithFormat:@"Inputs: %@\n%@Outputs: %@\n%@",
                                    @(self.inputs.count), inputsString,
                                    @(self.outputs.count), outputsString];
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
  // Check all outputs are the correct class
  for (NSUInteger i = 0; i < self.outputs.count; ++i)
    if (![[self.outputs objectAtIndex:i]
            isKindOfClass:[BCTransactionOutput class]])
      return FALSE;
  return TRUE;
}

#pragma mark Fee Calculation

- (NSUInteger)currentSize {
  NSUInteger size = sizeof(BC_BITCOIN_VERSION) + sizeof(self.lockTime);
  if (![self inputsAreValid] || ![self outputsAreValid]) return 0;

  for (NSUInteger i = 0; i < self.outputs.count; ++i)
    size += [((BCTransactionOutput *)[self.outputs objectAtIndex:i])size];
  for (NSUInteger i = 0; i < self.inputs.count; ++i)
    size += [((BCTransactionInput *)[self.inputs objectAtIndex:i])size];

  return size;
}

#pragma mark Debug

- (NSString *)description {
  return [self toString];
}

#pragma mark Transaction Building

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
  uint64_t targetAmount = 0, changeAmount = 0, feeAmount = 0, utxoSumAmount = 0,
           transactionSize = 0;
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

    // Sum the UTXOs values
    utxoSumAmount += [utxo.value unsignedIntegerValue];
  }

  // Set Target Outputs
  targetOutput = [BCTransactionOutput standardOutputForAmount:@(targetAmount)
                                                    toAddress:address];
  if (![targetOutput isKindOfClass:[BCTransactionOutput class]]) return NULL;
  [newTransaction addOutput:targetOutput];

  // Calculate the fee Based off of the transaction size. Assume Change Output
  transactionSize = [newTransaction currentSize] + 39;
  feeAmount =
      ((CGFloat)transactionSize / 1000.0f) * [feePerK unsignedIntegerValue];
  feeAmount = MAX(feeAmount, 10000);

  // Check For Funds
  if (utxoSumAmount < (targetAmount + feeAmount)) {
    // not enough Funds Error
    return NULL;
  }

  // Because transactions in bitcoin require you to spend an entire transaction
  // to keep the leftover we need a change address so that you only spend the
  // desired amount. Anything left over in the transaction is considered the
  // mining fee.
  changeAmount = utxoSumAmount - (targetAmount + feeAmount);

  // Check if we are over the limit for standard transactions
  if (transactionSize >= 100000) {
    // Non Standard Transactions, Over size limit.
    return NULL;
  }

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
