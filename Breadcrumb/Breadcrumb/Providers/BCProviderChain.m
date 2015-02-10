//
//  BCProviderChain.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCProviderChain.h"
#import "BCTransaction.h"
#import "BCMutableTransaction.h"
#import "NSData+ConversionUtilties.h"
#import "BreadcrumbCore.h"

// Chain Error Constants
static NSString *const kBCChainProvider_ErrorDomain =
    @"com.breadcrumb.chainProvider";

// Chain Response Constants
static NSString *const kBCChainProvider_ErrorMessage = @"message";
static NSString *const kBCChainProvider_ErrorCode = @"code";
static NSString *const kBCChainProvider_Addresses = @"addresses";
static NSString *const kBCChainProvider_Script = @"script_hex";
static NSString *const kBCChainProvider_Hash = @"transaction_hash";
static NSString *const kBCChainProvider_OutputIndex = @"output_index";
static NSString *const kBCChainProvider_Value = @"value";
static NSString *const kBCChainProvider_Spent = @"spent";
static NSString *const kBCChainProvider_Confirmations = @"confirmations";

// Chain API
// TODO: Get API Key From Plist?
static NSString *const kChainAPIKey = @"DEMO-4a5e1e4";

#define kChainBasePath @"https://api.chain.com/v2"
static NSString *const kChainUTXOsURL =
    kChainBasePath @"/bitcoin/addresses/%@/unspents?api-key-id=%@";

@implementation BCProviderChain

#pragma mark Balance Interface

#pragma mark UTXO Interface

- (void)UTXOforAmount:(NSNumber *)amount
         andAddresses:(NSArray *)addresses
         withCallback:(void (^)(NSArray *, NSError *))callback {
  [[self class] UTXOsForAddresses:addresses withCallback:callback];
}

// We Need A UTXO cache which is synced with the server/network
// Need to get optimized UTXOs for transaction amounts

#pragma mark Publish Interface
- (void)publishTransaction:(BCMutableTransaction *)transaction
            withCompletion:(void (^)(NSError *))completion {
  // Publish to the Bitcoin Network.
  NSLog(@"Publish Trasaction:\n'%@'", [[transaction toData] toHex]);
  completion(NULL);
}

#pragma mark Chain API interface

+ (void)UTXOsForAddresses:(NSArray *)addresses
             withCallback:(void (^)(NSArray *, NSError *))callback {
  NSString *requestString, *addressesSting;
  NSURLRequest *request;
  __block void (^sCallback)(NSArray *, NSError *);
  NSParameterAssert(callback);
  NSParameterAssert([addresses isKindOfClass:[NSArray class]] &&
                    addresses.count > 0);
  if (![addresses isKindOfClass:[NSArray class]] || addresses.count == 0 ||
      !callback)
    return;

  // Create Address list
  addressesSting = [self addressListForAddresses:addresses];
  if (![addressesSting isKindOfClass:[NSString class]]) {
    // Failed to construct address string.
    return;
  }

  // Create Request String
  requestString =
      [NSString stringWithFormat:kChainUTXOsURL, addressesSting, kChainAPIKey];
  if (![requestString isKindOfClass:[NSString class]]) {
    // Failed to create request string
    return;
  }

  sCallback = callback;
  // Make the call to chain
  request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
  if (![request isKindOfClass:[NSURLRequest class]]) {
    // Failed to create request.
    return;
  }

  [NSURLConnection
      sendAsynchronousRequest:request
                        queue:[NSOperationQueue mainQueue]
            completionHandler:
                [[self class]
                    connectionProcessingWithResult:^(NSHTTPURLResponse *
                                                         response,
                                                     id data, NSError *error) {
                        if ([error isKindOfClass:[NSError class]]) {
                          sCallback(NULL, error);
                        } else if ([data isKindOfClass:[NSArray class]]) {
                          [[self class] processUTXOsResponse:data
                                                withCallback:sCallback];
                        } else {
                          // Unexpected response
                          sCallback(NULL, NULL);
                        }

                    }]];
}

#pragma mark Processing

+ (void)processUTXOsResponse:(NSArray *)response
                withCallback:(void (^)(NSArray *, NSError *))callback {
  NSMutableArray *utxos;
  id _transaction;
  NSParameterAssert([response isKindOfClass:[NSArray class]]);
  NSParameterAssert(callback);
  if (![response isKindOfClass:[NSArray class]] || !callback) return;

  // Convert transactions to native object
  utxos = [[NSMutableArray alloc] init];
  for (NSDictionary *transaction in response) {
    _transaction = [BCTransaction transactionFromChainTransaction:transaction];
    if ([_transaction isKindOfClass:[BCTransaction class]])
      [utxos addObject:_transaction];
  }

  callback([NSArray arrayWithArray:utxos], NULL);
}

#pragma mark Utilities

+ (void (^)(NSURLResponse *, NSData *, NSError *))
    connectionProcessingWithResult:(void (^)(NSHTTPURLResponse *, id,
                                             NSError *))completion {
  __block void (^sCompletion)(NSHTTPURLResponse *, id, NSError *) = completion;
  return ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
      id _data;
      NSError *parseError;
      if (((NSHTTPURLResponse *)response).statusCode == 404) {
        // not Found Error
        sCompletion((NSHTTPURLResponse *)response, NULL, NULL);

      } else if (((NSHTTPURLResponse *)response).statusCode == 400) {
        sCompletion((NSHTTPURLResponse *)response, NULL,
                    [self processChainError:data]);

      } else if (((NSHTTPURLResponse *)response).statusCode == 500) {
        sCompletion((NSHTTPURLResponse *)response, NULL,
                    [self processChainError:data]);

      } else if ([connectionError isKindOfClass:[NSError class]]) {
        sCompletion((NSHTTPURLResponse *)response, NULL, connectionError);

      } else if ([data isKindOfClass:[NSData class]]) {
        // Is JSON?
        if ([((NSHTTPURLResponse *)response).MIMEType.lowercaseString
                isEqualToString:@"application/json".lowercaseString]) {
          // Parse Response
          _data = [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:&parseError];
          if ([parseError isKindOfClass:[NSError class]]) {
            sCompletion((NSHTTPURLResponse *)response, NULL, parseError);
            return;
          }

          // Pass Response
          sCompletion((NSHTTPURLResponse *)response, _data, NULL);
        } else {
          // Unexpected response
          sCompletion((NSHTTPURLResponse *)response, NULL, NULL);
        }

      } else {
        // Unexpected response
        sCompletion((NSHTTPURLResponse *)response, NULL, NULL);
      }
  };
}

+ (NSString *)addressListForAddresses:(NSArray *)addresses {
  NSString *addressesSting;
  NSParameterAssert([addresses isKindOfClass:[NSArray class]] &&
                    addresses.count != 0);
  if (![addresses isKindOfClass:[NSArray class]] || addresses.count == 0)
    return NULL;

  // Composite the addresses
  for (NSString *address in addresses)
    if ([address.toBitcoinAddress isKindOfClass:[BCAddress class]]) {
      if ([addressesSting isKindOfClass:[NSString class]])
        addressesSting =
            [NSString stringWithFormat:@"%@,%@", addressesSting, address];
      else
        addressesSting = address;
    }

  return [addressesSting isKindOfClass:[NSString class]] ? addressesSting
                                                         : NULL;
}

#pragma mark Errors

+ (NSError *)processChainError:(NSData *)responseBody {
  NSString *message, *code, *composite;
  NSError *parseError;
  NSDictionary *body;
  // Should we throw an unexpected error error, or is that to much?
  if (![responseBody isKindOfClass:[NSData class]]) return NULL;

  body = [NSJSONSerialization JSONObjectWithData:responseBody
                                         options:0
                                           error:&parseError];
  // Return Null if failed to parse so that the dev can more easily debug.
  if ([parseError isKindOfClass:[NSError class]]) return NULL;
  if (![body isKindOfClass:[NSDictionary class]]) return NULL;

  // Extract the message and code to put in the error object.
  message = [body objectForKey:kBCChainProvider_ErrorMessage];
  if (![message isKindOfClass:[NSString class]]) return NULL;

  code = [body objectForKey:kBCChainProvider_ErrorCode];
  if (![code isKindOfClass:[NSString class]]) return NULL;

  composite = [NSString stringWithFormat:@"%@(Chain Code:%@)", message, code];
  if (![composite isKindOfClass:[NSString class]]) return NULL;

  return [NSError errorWithDomain:kBCChainProvider_ErrorDomain
                             code:0
                         userInfo:@{NSLocalizedDescriptionKey : composite}];
}

@end

@implementation BCTransaction (BCProviderChain)

+ (BCTransaction *)transactionFromChainTransaction:
                       (NSDictionary *)chainTransaction {
  NSArray *rawAddresses;
  NSMutableArray *addresses;
  BCScript *script;
  NSString *scriptHex, *transactionHash;
  NSNumber *value, *spent, *confirmations, *isSigned, *outputIndex;

  rawAddresses = [chainTransaction objectForKey:kBCChainProvider_Addresses];
  if (![rawAddresses isKindOfClass:[NSArray class]]) return NULL;

  // Validate Addresses
  addresses = [[NSMutableArray alloc] init];
  BCAddress *currentAddress;
  for (NSString *address in rawAddresses) {
    currentAddress = address.toBitcoinAddress;
    if ([currentAddress isKindOfClass:[BCAddress class]])
      [addresses addObject:currentAddress];
    else
      return NULL;
  }

  // Get values and type check
  scriptHex = [chainTransaction objectForKey:kBCChainProvider_Script];
  if (![scriptHex isKindOfClass:[NSString class]]) return NULL;

  script = [[BCScript alloc] initWithData:scriptHex.hexToData];
  if (![script isKindOfClass:[BCScript class]]) return NULL;

  transactionHash = [chainTransaction objectForKey:kBCChainProvider_Hash];
  if (![transactionHash isKindOfClass:[NSString class]]) return NULL;

  outputIndex = [chainTransaction objectForKey:kBCChainProvider_OutputIndex];
  if (![outputIndex isKindOfClass:[NSNumber class]]) return NULL;

  value = [chainTransaction objectForKey:kBCChainProvider_Value];
  if (![value isKindOfClass:[NSNumber class]]) return NULL;

  spent = [chainTransaction objectForKey:kBCChainProvider_Spent];
  if (![spent isKindOfClass:[NSNumber class]]) return NULL;

  confirmations =
      [chainTransaction objectForKey:kBCChainProvider_Confirmations];
  if (![confirmations isKindOfClass:[NSNumber class]]) return NULL;

  // Create Transaction
  return [[BCTransaction alloc]
      initWithAddresses:[NSArray arrayWithArray:addresses]
                 script:script
                   hash:transactionHash.hexToData
            outputIndex:[outputIndex unsignedIntValue]
                  value:value
                  spent:spent
          confirmations:confirmations
              andSigned:[isSigned boolValue]];
}

@end
