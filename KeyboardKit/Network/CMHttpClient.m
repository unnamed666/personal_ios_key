//
//  CMHttpClient.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMHttpClient.h"

@implementation CMHttpClient

+ (instancetype)sharedClient {
    static CMHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CMHttpClient alloc] initWithBaseURL:[NSURL URLWithString:@""] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 创建NSMutableSet对象
        NSMutableSet *newSet = [NSMutableSet set];
        // 添加我们需要的类型
        newSet.set = _sharedClient.responseSerializer.acceptableContentTypes;
        [newSet addObject:@"text/html"];
        [newSet addObject:@"application/octet-stream"];
        [newSet addObject:@"text/plain"];
        
        // 重写给 acceptableContentTypes赋值
        _sharedClient.responseSerializer.acceptableContentTypes = newSet;
    });
    
    return _sharedClient;
}

@end
