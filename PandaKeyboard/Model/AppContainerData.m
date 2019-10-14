//
//  AppContainerData.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/8/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "AppContainerData.h"

static NSString * kAPP_START_TIMES = @"AppStartTimes";
static NSString * kAPP_START_TIMES_FOR_REPORT = @"AppStartTimesForReport";
static NSString * kIS_SHOWED_RATE_US_VIEW = @"isShowedRateUsView";
static NSString * kIS_SHOWED_FULL_ACCESS = @"isShowedKeyForContainerFullAccess";

@implementation AppContainerData

+ (NSDate *)appFirstInstallTime
{
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    if (theDefault)
    {
        return [theDefault objectForKey:kAPP_START_TIMES];
    }
    
    return nil;
}

+ (void)setAppFirstInstallTime:(NSDate *)appFirstInstallTime
{
    if (!appFirstInstallTime)
    {
        return;
    }
    
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    if (theDefault)
    {
        [theDefault setObject:appFirstInstallTime forKey:kAPP_START_TIMES];
        [theDefault synchronize];
    }
}

+ (NSDate *)appStartTimeForReport
{
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    if (theDefault)
    {
        return [theDefault objectForKey:kAPP_START_TIMES_FOR_REPORT];
    }
    
    return nil;
}

+ (void)setAppStartTimeForReport:(NSDate *)appStartTimeForReport
{
    if (!appStartTimeForReport)
    {
        return;
    }
    
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    if (theDefault)
    {
        [theDefault setObject:appStartTimeForReport forKey:kAPP_START_TIMES_FOR_REPORT];
        [theDefault synchronize];
    }
}

+ (BOOL)isShowedRateUsView
{
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    return [theDefault boolForKey:kIS_SHOWED_RATE_US_VIEW];
}

+ (void)setIsShowedRateUsView:(BOOL)isShowedRateUsView
{
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    if (!theDefault)
    {
        return;
    }
    [theDefault setBool:isShowedRateUsView forKey:kIS_SHOWED_RATE_US_VIEW];
}

+ (BOOL)isShowedFullAccess
{
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    return [theDefault boolForKey:kIS_SHOWED_FULL_ACCESS];
}

+ (void)setIsShowedFullAccess:(BOOL)isShowedFullAccess
{
    NSUserDefaults * theDefault = [NSUserDefaults standardUserDefaults];
    if (!theDefault)
    {
        return;
    }
    [theDefault setBool:isShowedFullAccess forKey:kIS_SHOWED_FULL_ACCESS];
}

@end
