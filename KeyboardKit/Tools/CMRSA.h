//
//  CMRSA.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMRSA : NSObject

+ (NSData *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

@end
