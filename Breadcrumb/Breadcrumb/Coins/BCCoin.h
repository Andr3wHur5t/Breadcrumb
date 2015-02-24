//
//  BCCoin.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/20/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BCAddress;

// @brief This defines a set of known address types. OLD MIGRATE.
// typedef enum : uint8_t {
//                 BCAddressType_Old = 0x00,
//                 BCAddressType_New = 0x05
//               } BCAddressType;

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


/*!
 @brief Checks if the inputted address is valid for the coin.
 
 @param address The address to check.
 */
- (BOOL)typeIsValidForCoin:(BCAddress *)address;

#pragma mark Default Coins

/*!
 @brief This coin is configured for main net.
 */
+ (instancetype)MainNetBitcoin;

/*!
 @brief This coin is configured for testnet3.
 */
+ (instancetype)TestNet3Bitcoin;

@end

@interface BCMainNetBitcoin : BCCoin
@end

@interface BCTestNet3Bitcoin : BCCoin
@end
