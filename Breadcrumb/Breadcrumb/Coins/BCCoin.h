//
//  BCCoin.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @brief This is my method of supporting different 'environments' such as
 TestNet3, MainNet, and other alt-currencies which are close enough to bitcoin
 that they still work with this wallet.

 @discussion This method allows us to have multiple wallets for different
 currencies in the same application simultaneously. ;)
 */
@interface BCCoin : NSObject

#pragma mark Coin Metadata
/*!
 @brief The id of the coin used in BIP 44.
 */
@property(assign, nonatomic, readonly) uint32_t coinId;

#pragma mark Address Info
/*!
 @brief Gets the correct address type code for the specified string.

 @param flags The flags indicating the address type information

 @return The type code that should be used for the address with the specified
 flag.
 */
- (uint8_t)addressTypeForFlags:(NSUInteger)flags;

#pragma mark Default Coins

+ (instancetype)MainNetBitcoin;

+ (instancetype)TestNet3Bitcoin;

@end

@interface BCMainNetBitcoin : BCCoin
@end
@interface BCTestNet3Bitcoin : BCCoin
@end
