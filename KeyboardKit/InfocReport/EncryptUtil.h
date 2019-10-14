//
//  EncryptUtil.h
//  InfoC
//
//  Created by wei_wei on 16/4/7.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Encrypt)

- (NSString*)AES128EncryptWithKey:(NSData*)key andIV:(NSData*)iv;

@end

@interface NSData(Encrypt)

- (NSData*)AES128EncryptWithKey:(NSData*)key andIV:(NSData*)iv;

@end
