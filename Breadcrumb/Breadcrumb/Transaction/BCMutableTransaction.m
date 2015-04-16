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

// I use these biases to score transaction inputs, this way we can optimize
// usage
#define kInputBiasWithAmount(__v__) \
  (uint32_t)((CGFloat)kInputStandardBias * __v__)
static const uint32_t kInputStandardBias = UINT32_MAX / 20;

// We really want to use the target utxos if possible
static const uint32_t kInputBelongsToTargetAddressBias =
    kInputBiasWithAmount(10);

// We want to reduce the usage of diffrent addresses in transactions
static const uint32_t kInputUsageBias = kInputBiasWithAmount(1);

// We want to prioritize high value coins to reduce number of inputs.
static const uint32_t kInputValueBias = kInputBiasWithAmount(14);

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

#pragma mark Metadata

- (uint64_t)value {
  uint64_t sum = 0;
  for (BCTransactionInput *input in self.inputs) {
    sum += input.value;
  }
  return sum;
}

- (uint64_t)outputAmount {
  uint64_t sum = 0;
  for (BCTransactionOutput *output in self.outputs) {
    sum += output.value;
  }
  return sum;
}

- (uint64_t)fee {
  return self.value - self.outputAmount;
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

#pragma mark UTXO Selection

+ (NSArray *)inputsFromUTXOs:(NSArray *)utxos
               andScoreBlock:(uint64_t (^)(BCTransaction *tx,
                                           bool isCommited))scoreBlock {
  NSMutableArray *scoredInputs, *prioritizedInputs;
  NSArray *sortedInputs;
  NSParameterAssert([scoreBlock isKindOfClass:NSClassFromString(@"NSBlock")]);
  NSParameterAssert([utxos isKindOfClass:[NSArray class]]);

  // Let the score block get stats
  for (BCTransaction *tx in utxos) scoreBlock(tx, false);

  // Score each input
  scoredInputs = [[NSMutableArray alloc] init];
  for (BCTransaction *tx in utxos)
    [scoredInputs addObject:@{
      @"score" : @(scoreBlock(tx, true)),
      @"tx" : tx
    }];

  // Sort inputs by score
  sortedInputs = [scoredInputs
      sortedArrayWithOptions:NSSortConcurrent
             usingComparator:^NSComparisonResult(id obj1, id obj2) {
               uint64_t score1 = (uint64_t)[
                            [obj1 objectForKey:@"score"] unsignedLongLongValue],
                        score2 = (uint64_t)[
                            [obj2 objectForKey:@"score"] unsignedLongLongValue];
               if (score1 == score2)
                 return NSOrderedSame;
               else if (score1 > score2)
                 return NSOrderedAscending;
               else
                 return NSOrderedDescending;
             }];

  // Return juts the tx in order
  prioritizedInputs = [[NSMutableArray alloc] init];
  for (NSDictionary *dict in sortedInputs)
    [prioritizedInputs addObject:[dict objectForKey:@"tx"]];

  return prioritizedInputs;
}

+ (uint64_t (^)(BCTransaction *tx, BOOL isCommitted))scoreBlockForTargetAddress:
        (BCAddress *)targetAddress {
  __block BCAddress *sTargetAddress;
  __block NSMutableDictionary *sAddressUsage;
  __block uint64_t maxValue = 0;

  sAddressUsage = [[NSMutableDictionary alloc] init];
  sTargetAddress = targetAddress;
  return ^uint64_t(BCTransaction *tx, BOOL committed) {
    uint64_t score = 0;
    NSNumber *usageCount;

    // Our score is not committed, collect data
    if (!committed) {
      // Get the most valuable transaction
      maxValue = MAX(maxValue, tx.value);

      // Get address usage data
      for (BCAddress *address in tx.addresses) {
        usageCount = [sAddressUsage objectForKey:address.toString];
        if ([usageCount isKindOfClass:[NSNumber class]])
          usageCount = @([usageCount integerValue] + 1);
        else
          usageCount = @1;

        [sAddressUsage setObject:usageCount forKeyedSubscript:address.toString];
      }
      return 0;
    }

    // Prefer UTXOs received from output addresses to mitigate double spending
    // and requesting a refund
    if ([tx.addresses containsObject:targetAddress])
      score += kInputBelongsToTargetAddressBias;

    // avoid combining addresses in a single transaction to reduce information
    // leakage
    uint64_t reuseScore = 0;
    for (BCAddress *address in tx.addresses) {
      reuseScore +=
          [[sAddressUsage objectForKey:address.toString] unsignedIntegerValue];
    }

    NSUInteger rSum = 0;
    for (NSString *key in sAddressUsage.allKeys) {
      rSum += [[sAddressUsage objectForKey:key] unsignedIntegerValue];
    }

    score += (uint64_t)MIN(kInputUsageBias,
                           ((CGFloat)kInputUsageBias *
                            ((CGFloat)reuseScore /
                             ((CGFloat)rSum / (CGFloat)sAddressUsage.count))));

    // Prefer high value coins
    score +=
        (uint32_t)(kInputValueBias * ((CGFloat)tx.value / (CGFloat)maxValue));

    return score;
  };
}

#pragma mark Output Selection

+ (NSArray *)outputsForInputAmount:(uint64_t)inputAmount
                targetOutputAmount:(uint64_t)targetOutputAmount
                          feeBlock:
                              (uint64_t (^)(NSUInteger outputByteSize))feeBlock
               changeDustTolerance:(uint64_t)changeDustTolerance
                     targetAddress:(BCAddress *)targetAddress
                     changeAddress:(BCAddress *)changeAddress
                           andCoin:(BCCoin *)coin {
  BCTransactionOutput *target, *change;
  NSMutableArray *outputs;
  uint64_t changeAmount;

  NSParameterAssert([coin isKindOfClass:[BCCoin class]]);
  NSParameterAssert([targetAddress isKindOfClass:[BCAddress class]]);
  NSParameterAssert([targetAddress isKindOfClass:[BCAddress class]]);
  outputs = [[NSMutableArray alloc] init];

  // Create the target output
  target = [BCTransactionOutput standardOutputForAmount:targetOutputAmount
                                              toAddress:targetAddress
                                                forCoin:coin];
  [outputs addObject:target];

  // Check if we are below our change output dust tolerance, if so then ignore
  // the
  changeAmount =
      (inputAmount - feeBlock([target toData].length * 2)) - targetOutputAmount;
  if (changeAmount >= changeDustTolerance) {
    change = [BCTransactionOutput standardOutputForAmount:changeAmount
                                                toAddress:changeAddress
                                                  forCoin:coin];
    [outputs addObject:change];
  }
  return outputs;
}

#pragma mark Transaction Building

+ (NSComparisonResult (^)(id obj1, id obj2))randomSortComparator {
  return ^NSComparisonResult(id obj1, id obj2) {
    switch (
        (uint16_t)([NSData pseudoRandomDataWithLength:sizeof(uint32_t)].bytes) %
        3) {
      case 1:
        return NSOrderedDescending;
        break;
      case 2:
        return NSOrderedAscending;
        break;
      default:
        return NSOrderedSame;
        break;
    }
  };
}

+ (uint64_t (^)(NSUInteger, NSUInteger))defaultFeeBlock:(uint64_t)feePerKb {
  __block uint64_t sFeePerKb = feePerKb;
  return ^uint64_t(NSUInteger inputByteLength, NSUInteger outputByteLength) {
    // 10 is the other header information byte size
    return (uint64_t)(
        ((CGFloat)(inputByteLength + outputByteLength + 10) / 1000.0f) *
        (CGFloat)sFeePerKb);
  };
}

+ (BCMutableTransaction *)buildTransactionWithInputs:(NSArray *)inputs
                                          andOutputs:(NSArray *)outputs {
  NSArray *randomOrderOutputs, *randomOrderInputs;
  BCMutableTransaction *transaction;
  NSParameterAssert([inputs isKindOfClass:[NSArray class]]);
  NSParameterAssert([outputs isKindOfClass:[NSArray class]]);
  for (id obj in inputs)
    NSParameterAssert([obj isKindOfClass:[BCTransactionInput class]]);
  for (id obj in outputs)
    NSParameterAssert([obj isKindOfClass:[BCTransactionOutput class]]);

  transaction = [[[self class] alloc] init];

  // Randomly swap order of outputs so the change address isn't publicly known,
  // and inputs so its harder to guess what wallet you are using.
  randomOrderOutputs =
      [outputs sortedArrayUsingComparator:[self randomSortComparator]];
  randomOrderInputs =
      [inputs sortedArrayUsingComparator:[self randomSortComparator]];

  // Set the inputs and outputs to the transaction.
  [transaction.inputs setArray:randomOrderInputs];
  [transaction.outputs setArray:randomOrderOutputs];

  return transaction;
}

+ (BCMutableTransaction *)buildTransactionWith:(NSArray *)utxos
                                     forAmount:(uint64_t)amount
                                            to:(BCAddress *)address
                                       feePerK:(uint64_t)feePerK
                                 changeAddress:(BCAddress *)changeAddress
                                     withError:(NSError **)error
                                       andCoin:(BCCoin *)coin {
  return [self buildTransactionWith:utxos
                          forAmount:amount
                                 to:address
                      dustTolerance:kBCDefaultDustThreshold
                       feeCalcBlock:[self defaultFeeBlock:feePerK]
                      changeAddress:changeAddress
                          withError:error
                            andCoin:coin];
}

+ (BCMutableTransaction *)
    buildTransactionWith:(NSArray *)utxos
               forAmount:(uint64_t)amount
                      to:(BCAddress *)address
           dustTolerance:(uint64_t)dustTolerance
            feeCalcBlock:(uint64_t (^)(NSUInteger inputByteLength,
                                       NSUInteger outputByteLength))feeBlock
           changeAddress:(BCAddress *)changeAddress
               withError:(NSError **)error
                 andCoin:(BCCoin *)coin {
  uint64_t feeAmount = 0, utxoSumAmount = 0;
  NSUInteger numberOfOutputs = 2;  // This is an estimated value
  NSArray *scoredInputs, *outputsToUse;
  NSMutableArray *inputsToUse;
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
  for (BCTransaction *obj in utxos) {
    if (![obj isKindOfClass:[BCTransaction class]]) {
      if (error) *error = [self invalidUTXOsError];
      return NULL;
    }
  }

  // Sort our inputs,
  // This sorts our inputs to optimize for value, address reuse, and  and target
  // address usage. Based on a set of defined biases.
  scoredInputs =
      [self inputsFromUTXOs:utxos
              andScoreBlock:[self scoreBlockForTargetAddress:address]];

  // Choose our inputs
  inputsToUse = [[NSMutableArray alloc] init];
  BCTransactionInput *utxo;
  NSUInteger previousInputByteLength = 0;
  for (BCTransaction *input in scoredInputs) {
    // Convert Input to UTXO class
    utxo = [[BCTransactionInput alloc] initWithTransaction:input];
    if (![utxo isKindOfClass:[BCTransactionInput class]]) continue;

    // Add the Input
    [inputsToUse addObject:utxo];

    // Keep count of our input sum value
    utxoSumAmount += input.value;

    // recalculate our fee
    previousInputByteLength += [utxo toData].length;
    feeAmount = feeBlock(previousInputByteLength, numberOfOutputs * 34);

    // if we have enough to pay for the amount & the fee stop adding inputs
    if (utxoSumAmount >= amount + feeAmount) break;  // Stop Adding Inputs
  }

  // Check For Funds
  if (utxoSumAmount < (amount + feeAmount)) {
    if (error)
      *error = [self insufficientUTXOFundsError:utxoSumAmount - feeAmount];
    return NULL;
  }

  // Create Outputs
  outputsToUse =
      [self outputsForInputAmount:utxoSumAmount
               targetOutputAmount:amount
                         feeBlock:^uint64_t(NSUInteger outputByteSize) {
                           return feeBlock(previousInputByteLength,
                                           outputByteSize);
                         }
              changeDustTolerance:dustTolerance
                    targetAddress:address
                    changeAddress:changeAddress
                          andCoin:coin];
  if (![outputsToUse isKindOfClass:[NSArray class]]) {
    if (error) *error = [self failedToCreateOutputError];
    return NULL;
  }

  // Create the transaction
  newTransaction =
      [self buildTransactionWithInputs:inputsToUse andOutputs:outputsToUse];

  // Check if we are over the limit for standard transactions
  if ([newTransaction toData].length >= 100000) {
    if (error) *error = [self nonStandardTransactionError];
    return NULL;
  }

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

+ (NSError *)insufficientUTXOFundsError:(uint64_t)canSpend {
  return [NSError
      errorWithDomain:kTransactionBuildingErrorDomain
                 code:506
             userInfo:@{
               @"canSpend" : @(canSpend),
               NSLocalizedDescriptionKey : [NSString
                   stringWithFormat:@"Insufficient funds in UTXOs to build "
                                    @"transaction. you can spend %@ and still "
                                    @"pay for fees.",
                                    [BCAmount prettyPrint:canSpend]]
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
