//
//  NSString+Base64.m
//  InfoC
//
//  Created by wei_wei on 16/4/7.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSData *)base64DecodeString
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    return data;
}

@end
