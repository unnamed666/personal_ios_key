//
//  FmtManager.h
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

/*
 格式文件读取
 验证数据格式是否正确，以及确定数据连接顺序
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LengthType) {
    LengthTypeBit = -2,
    LengthTypeString,
    LengthTypeBinaray
};

@interface FmtManager : NSObject

+ (instancetype)shareManager;

- (NSArray*)fmtForReportNo:(NSInteger)reportNo;

@end
