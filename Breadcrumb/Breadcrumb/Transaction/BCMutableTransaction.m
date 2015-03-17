//
//  BCMutableTransaction.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/9/15.
//  Copyright (c) 2015 Breadcrumb.
//
//  Distributed under the MIT software license, see the accompanying
//  file LICENSE or http://www.opensource.org/licenses/mit-license.php.
//
//

#import "BCMutableTransaction.h"
#import "BreadcrumbCore.h"

#define BC_BITCOIN_VERSION 1
static NSString *const kTransactionBuildingErrorDomain =
    @"com.breadcrumb.transactionBuilder";

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

  // TODO: Calculate Fee, And Outputs

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

  [buffer appendUInt32:1];  // Hash Type Code

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
                                     forAmount:(uint64_t)amount
                                            to:(BCAddress *)address
                                       feePerK:(uint64_t)feePerK
                                 changeAddress:(BCAddress *)changeAddress
                                     withError:(NSError **)error {
  uint64_t changeAmount = 0, feeAmount = 0, utxoSumAmount = 0,
           transactionSize = 0;
  BCTransactionOutput *targetOutput, *changeOutput;
  BCTransactionInput *utxoInput;
  BCMutableTransaction *newTransaction;

  // Validate addresses
  if (![address isKindOfClass:[BCAddress class]] ||
      ![changeAddress isKindOfClass:[BCAddress class]]) {
    if (error) *error = [self invalidAddressesError];
    return NULL;
  }

  // Validate UTXOs
  if (![utxos isKindOfClass:[NSArray class]]) {
    if (error) *error = [self invalidUTXOsError];
    return NULL;
  }
  for (NSUInteger i = 0; i < utxos.count; ++i) {
    BCTransaction *tx = [utxos objectAtIndex:i];
    if (![tx isKindOfClass:[BCTransaction class]]) {
      if (error) *error = [self invalidUTXOsError];
      return NULL;
    }
  }

  // Create Mutable Transaction
  newTransaction = [BCMutableTransaction mutableTransaction];

  // Set Inputs From UTXOs
  for (BCTransaction *utxo in utxos) {
    // Convert utxo into transactionInput
    utxoInput = [[BCTransactionInput alloc] initWithTransaction:utxo];

    // Add Transaction Input
    [newTransaction addInput:utxoInput];

    // Sum the UTXOs values
    utxoSumAmount += utxo.value;
  }

  // Set Target Outputs
  targetOutput =
      [BCTransactionOutput standardOutputForAmount:amount toAddress:address];
  if (![targetOutput isKindOfClass:[BCTransactionOutput class]]) {
    if (error) *error = [self failedToCreateOutputError];
    return NULL;
  }
  [newTransaction addOutput:targetOutput];

  // Calculate the fee Based off of the transaction size. Assume Change Output
  transactionSize = [newTransaction currentSize] + 39;
  feeAmount = (uint64_t)((CGFloat)transactionSize / 1000.0f) * feePerK;

  // Check For Funds
  if (utxoSumAmount < (amount + feeAmount)) {
    if (error) *error = [self insufficientUTXOFundsError];
    return NULL;
  }

  // Because transactions in bitcoin require you to spend an entire transaction
  // to keep the leftover we need a change address so that you only spend the
  // desired amount. Anything left over in the transaction is considered the
  // mining fee.
  changeAmount = utxoSumAmount - (amount + feeAmount);

  // Check if we are over the limit for standard transactions
  if (transactionSize >= 100000) {
    if (error) *error = [self nonStandardTransactionError];
    return NULL;
  }

  // Set Change Output
  changeOutput = [BCTransactionOutput standardOutputForAmount:changeAmount
                                                    toAddress:changeAddress];
  if (![changeOutput isKindOfClass:[BCTransactionOutput class]]) {
    if (error) *error = [self failedToCreateOutputError];
    return NULL;
  }
  [newTransaction addOutput:changeOutput];

  // Return the built transaction
  return newTransaction;
}

#pragma mark Errors

+ (NSError *)nonStandardTransactionError {
  return [NSError errorWithDomain:kTransactionBuildingErrorDomain
                             code:505
                         userInfo:@{
                           NSLocalizedDescriptionKey :
                               @"Non-standard transaction size is non standard."
                         }];
}

+ (NSError *)insufficientUTXOFundsError {
  return
      [NSError errorWithDomain:kTransactionBuildingErrorDomain
                          code:506
                      userInfo:@{
                        NSLocalizedDescriptionKey :
                            @"Insufficient funds in UTXOs to build transaction."
                      }];
}

+ (NSError *)invalidAddressesError {
  return [NSError errorWithDomain:kTransactionBuildingErrorDomain
                             code:507
                         userInfo:@{
                           NSLocalizedDescriptionKey :
                               @"Invalid destination addresses provided."
                         }];
}

+ (NSError *)invalidUTXOsError {
  return
      [NSError errorWithDomain:kTransactionBuildingErrorDomain
                          code:508
                      userInfo:@{
                        NSLocalizedDescriptionKey : @"Invalid UTXOs provided."
                      }];
}

+ (NSError *)failedToCreateOutputError {
  return
      [NSError errorWithDomain:kTransactionBuildingErrorDomain
                          code:509
                      userInfo:@{
                        NSLocalizedDescriptionKey : @"Failed to create output."
                      }];
}

@end
