# Breadcrumb

**Breadcrumb**

[![Build Status](https://travis-ci.org/Andr3wHur5t/Breadcrumb.svg)](https://travis-ci.org/Andr3wHur5t/Breadcrumb)

Takes away the complexity that you normally encounter when working with other **Bitcoin**, or **Blockchain** libraries. 

With minimalistic interfaces you can quickly get started working with Bitcoin, and the Blockchain.

Explore the capabilities of the block chain by publishing, and building custom transactions, and scripts.

Making a wallet is so easy you can start sending, and receiving Bitcoin in less than 15 lines of code.

## How to get started

Include `Breadcrumb.framework`, `CommonCrypto.framework`, and `CoreData.framework` into your Xcode project.

Add `#import <Breadcrumb/Breadcrumb.h>` to one of your applications' source files.

Make a wallet, and start sending Bitcoin.

```Objective-C
  NSData *password = [@"password" dataUsingEncoding:NSUTF8StringEncoding];
  BCWallet *wallet = [[BCWallet alloc] initNewWithPassword:password];

  [wallet mnemonicPhraseWithPassword:password
                       usingCallback:^(NSString *mnemonic) { 
  	NSLog(@"Brainwallet Phrase: %@",mnemonic);
  }];
  
  BCAddress *address = [@"3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy" toBitcoinAddress];
  NSNumber *amount = @20000; // Satoshi
  [wallet send:amount to:address usingPassword:password withCallback:
  ^(NSError *error) { 
       if ( [error isKindOfClass:[NSError class]] )
       		NSLog(@"Transaction Failed: '%@'",error.localizedDescription); 
  }];
                  
```



## License
Breadcrumb is under **MIT license**, and uses source from **Breadwallet** (also under MIT) 


The MIT License (MIT)

Copyright (c) 2015 Andrew Hurst

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
