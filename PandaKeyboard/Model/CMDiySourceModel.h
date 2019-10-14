//
//  CMDiyBackgroundModel.h
//  PandaKeyboard
//
//  Created by duwenyan on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 DIY主题素材相关资源信息（包括DIY背景、DIY音效、DIY字体）
 */
@interface CMDiySourceModel : NSObject

@property (nonatomic, copy) NSString *sourceId;
@property (nonatomic, copy) NSString *cover_url;
@property (nonatomic ,copy) NSString *download_url;

@property (nonatomic, assign) BOOL isFetching; //是否正在从网络上fetch

- (instancetype)initWithFetchedInfoDic:(NSDictionary *)infoDic;

+ (instancetype)modelWithFetchedInfoDic:(NSDictionary *)infoDic;

- (instancetype)initWithPlistInfoDic:(NSDictionary *)infoDic;

@end
