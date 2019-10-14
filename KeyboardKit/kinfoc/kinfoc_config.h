//
//  kinfoc_config.h
//  KEWL
//
//  Created by Jin Ye on 4/23/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KInfocConfig : NSObject

+ (NSString*) getPublicTableName;
+ (NSString*) getDefaultServerUrl;

/// 如果用户不允许上报，则只上报需要强制上报的数据。
+ (BOOL) didUserAllowedUploadInfo;

@end

#define MAX_PROBABILITY 10000
