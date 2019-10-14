//
//  CMHttpClient.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface CMHttpClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
