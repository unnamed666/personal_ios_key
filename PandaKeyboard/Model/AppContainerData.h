//
//  AppContainerData.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/8/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContainerData : NSObject

+ (NSDate *)appFirstInstallTime;
+ (void)setAppFirstInstallTime:(NSDate *)appFirstInstallTime;

+ (NSDate *)appStartTimeForReport;
+ (void)setAppStartTimeForReport:(NSDate *)appStartTimeForReport;

+ (BOOL)isShowedRateUsView;
+ (void)setIsShowedRateUsView:(BOOL)isShowedRateUsView;

+ (BOOL)isShowedFullAccess;
+ (void)setIsShowedFullAccess:(BOOL)isShowedFullAccess;
@end
