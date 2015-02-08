//
//  BCScript+DefaultScripts.h
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCScript.h"
#import "BCAddress.h"

@interface BCScript (DefaultScripts)

+ (instancetype)standardTransactionScript:(BCAddress *)address;

@end
