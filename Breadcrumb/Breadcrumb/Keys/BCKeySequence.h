//
//  BCKeySequence.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/10/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCKeyPair.h"

@interface BCKeySequence : BCKeyPair
/*!
 @brief Gets the key pair at the specified path.

 @param path The path of the key pair in the hd wallet. Example: 44/0/0/1
 */
- (BCKeyPair *)keyPairAtPath:(NSString *)path;

/*!
 @brief Gets the keypair at the specified component path.

 @param components An array of components. Example: @[@44,@0,@0,@1].
 */
- (BCKeyPair *)keyPairWithComponents:(NSArray *)components;

@end
