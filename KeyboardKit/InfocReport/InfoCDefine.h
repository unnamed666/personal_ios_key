//
//  InfoCDefine.h
//  InfoC
//
//  Created by wei_wei on 16/4/11.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#ifndef InfoCDefine_h
#define InfoCDefine_h

#if DEBUG
#define kHost       @"http://118.89.55.235/c/"
#else
#define kHost       @"https://helpcheetahkeyboard1.ksmobile.com/c/"
#endif

// 初始时间加密key
#define kInitTime   0
#define kInitKey    @"IXRiRkJrQCRCUDdpdnZOZw=="

// 配置文件名称 和 产品号
#define kFMTFileName    @"kfmt.dat"
#define kProductNo      183

// 最大缓存条数
//#if INNER_TEST
//#   define kMaxInfoCCacheCount 0
//#else
#   define kMaxInfoCCacheCount 29
//#endif

// 上报失败后的尝试次数
#define kRetryTimes     2
// 连续上报失败多少条后暂停上传
#define kMaxFailTimes   5
// 过多失败后休息时间 s
#define kRestTimeAfterTooMuchFail 30

typedef NS_ENUM(NSUInteger, ReportTactic) {
    ReportTacticSingle,
    ReportTacticMerge,
};

#endif /* InfoCDefine_h */
