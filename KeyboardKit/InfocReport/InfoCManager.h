//
//  InfoCManager.h
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoCManager : NSObject

@property (nonatomic) BOOL networkReachable;

+ (instancetype)shareManager;

- (void)event:(NSInteger)eventID params:(NSDictionary*)params;
- (void)forceReport;
@end
