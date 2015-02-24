//
//  BCAProvider.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/6/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCMutableTransaction.h"
#import "BCTransaction.h"
#import "BCAddressManager.h"
#import "BCAmount.h"

@interface BCAProvider : NSObject

/*!
 @brief Gets the optimized UTXOs for the given addresses optimized for the given
 amount.

 @discussion This method is used to get inputs for transactions.

 @param amount      The amount the UTXOs should be optimized for.
 @param addresses   The addresses to get the UTXOs for.
 @param callback    The callback to call once the operation completes
 */
- (void)UTXOforAmount:(uint64_t)amount
         andAddresses:(BCAddressManager *)addresses
         withCallback:(void (^)(NSArray *, NSError *))callback;

/*!
 @brief Publishes the transaction through the providers network.

 @discussion This allows a provider to route the transaction through their
 service if desired. This is useful if you are issuing requests to multiple
 clients, and wish to reduplicate transactions on the server. Also if the
 transaction is not built, and signed on the client.

 @param transaction The transaction to publish.
 @param completion  The completion to call once the transaction has been
 published, or the operation failed.
 */
- (void)publishTransaction:(BCMutableTransaction *)transaction
                   forCoin:(BCCoin *)coin
            withCompletion:(void (^)(NSData *, NSError *))completion;

- (void)syncAddressManager:(BCAddressManager *)addressManager
              withCallback:(void (^)(NSError *))callback;

- (void)getBalanceForAddressManager:(BCAddressManager *)addressManager
                       withCallback:(void (^)(uint64_t, NSError *))callback;

@end
