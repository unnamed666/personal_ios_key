//
//  BodyGenerator.h
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

/*
 business字段 验证处理
 */

#import <Foundation/Foundation.h>

@interface BodyGenerator : NSObject

+ (instancetype)shareGenerator;

- (BOOL)checkQuery:(NSInteger)businessIndex params:(NSDictionary*)params;

- (NSString*)getQueryString:(NSInteger)businessIndex params:(NSDictionary*)params withHeader:(NSDictionary*)publicInfo;

- (NSData*)buildSection:(short)index withQuerys:(NSDictionary*)querys;

@end
