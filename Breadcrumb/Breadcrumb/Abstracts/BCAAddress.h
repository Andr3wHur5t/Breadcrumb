//
//  BCAAddress.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/5/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCAAddress : NSObject

#pragma mark Construction
/*!
 @brief Constructs a address object with the bitcoin address string.

 @param addressString The address string to construct the object with.
 */
- (instancetype)initWithAddressString:(NSString *)addressString;

#pragma mark Info
/*!
 @brief Gets the string representation of the address.
 */
@property(weak, nonatomic, readonly) NSString *stringRepresentation;

@end
