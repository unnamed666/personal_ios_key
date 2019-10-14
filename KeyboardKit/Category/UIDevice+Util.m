//
//  UIDevice+Util.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/14.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIDevice+Util.h"
#import <sys/utsname.h>
#import <mach/mach.h>
#import "CMMacro.h"

@implementation UIDevice (Util)

+ (NSString*)deviceModelName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    //iPhone 系列
    if ([deviceModel isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceModel isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceModel isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (GSM)";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (GSM)";
    
    //iPod 系列
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceModel isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    //iPad 系列
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceModel isEqualToString:@"iPad4,4"]
        ||[deviceModel isEqualToString:@"iPad4,5"]
        ||[deviceModel isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceModel isEqualToString:@"iPad4,7"]
        ||[deviceModel isEqualToString:@"iPad4,8"]
        ||[deviceModel isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    if ([deviceModel isEqualToString:@"iPad5,1"]
        ||[deviceModel isEqualToString:@"iPad5,2"])      return @"iPad mini 4";
    
    if ([deviceModel isEqualToString:@"iPad6,3"]
        ||[deviceModel isEqualToString:@"iPad6,4"]
        ||[deviceModel isEqualToString:@"iPad6,7"]
        ||[deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro";
    
    if ([deviceModel isEqualToString:@"iPad7,1"])      return @"iPad Pro 2";
    
    return deviceModel;
}

+ (float)residentSizeOfMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return 0.0f;
    }
    return (taskInfo.resident_size / (1024.0 * 1024.0));
}

+ (float)usedSizeOfMemory {
    task_vm_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_VM_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO_PURGEABLE, (task_info_t)&taskInfo, &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return 0.0f;
    }
    return ((taskInfo.internal + taskInfo.compressed - taskInfo.purgeable_volatile_pmap) / (1024.0 * 1024.0));
}

- (BOOL)canVibration {
    NSString* deviceName = [UIDevice deviceModelName];
    if ([deviceName containsString:@"iPhone"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)hasHapticFeedback {
    if (!IOS10_OR_LATER) {
        return NO;
    }
    NSString* keyString = [NSString stringWithFormat:@"%@edb%@or%@vel", @"_fe", @"ackSupp", @"tLe"];
    NSNumber* ret = [[UIDevice currentDevice] valueForKey:keyString];
    if ([ret integerValue] != 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isIphone55S5C
{
    NSString* deviceName = [UIDevice deviceModelName];
    
    if ([deviceName isEqualToString:@"iPhone 5"] || [deviceName isEqualToString:@"iPhone 5C"] || [deviceName isEqualToString:@"iPhone 5S"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isIpad
{
    NSString* deviceName = [UIDevice deviceModelName];
    if ([deviceName containsString:@"iPad"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) isIpadPro
{
    NSString* deviceName = [UIDevice deviceModelName];
    if ([deviceName containsString:@"iPad Pro 2"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isHeight568 {
    if ([UIScreen mainScreen].bounds.size.width == 568 || [UIScreen mainScreen].bounds.size.height == 568) {
        return YES;
    }
    return NO;
} //含iPhone 5/5c/5s/SE, iPod Touch 5G/6G

+ (BOOL)isHeight480 {
    if ([UIScreen mainScreen].bounds.size.width == 480 || [UIScreen mainScreen].bounds.size.height == 480) {
        return YES;
    }
    return NO;
} //含iPhone 4/4s, iPod Touch 1~4G

+ (BOOL)isHeight667 {
    if ([UIScreen mainScreen].bounds.size.width == 667 || [UIScreen mainScreen].bounds.size.height == 667) {
        return YES;
    }
    return NO;
} //含iPhone 6/7/8

+ (BOOL)isHeight736 {
    if ([UIScreen mainScreen].bounds.size.width == 736 || [UIScreen mainScreen].bounds.size.height == 736) {
        return YES;
    }
    return NO;
} //含iPhone 6p/7p/8p

+ (BOOL)isHeight812 {
    if ([UIScreen mainScreen].bounds.size.width == 812 || [UIScreen mainScreen].bounds.size.height == 812) {
        return YES;
    }
    return NO;
} //含iPhone X/XS

+ (BOOL)isHeight896 {
    if ([UIScreen mainScreen].bounds.size.width == 896 || [UIScreen mainScreen].bounds.size.height == 896) {
        return YES;
    }
    return NO;
} //含iPhone XS MAX/XR

+ (BOOL)isHeight1024 {
    if ([UIScreen mainScreen].bounds.size.width == 1024 || [UIScreen mainScreen].bounds.size.height == 1024) {
        return YES;
    }
    return NO;
} //含iPad iPadAir

+ (BOOL)isHeight1366 {
    if ([UIScreen mainScreen].bounds.size.width == 1366 || [UIScreen mainScreen].bounds.size.height == 1366) {
        return YES;
    }
    return NO;
} //含iPad Pro 12.9 inch

+ (BOOL)isHeight1112 {
    if ([UIScreen mainScreen].bounds.size.width == 1112 || [UIScreen mainScreen].bounds.size.height == 1112) {
        return YES;
    }
    return NO;
} //含iPad Pro 10.5 inch

+ (NSInteger)systemMajorVersion {
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return version.majorVersion;
}

+ (NSInteger)systemMinorVersion {
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return version.minorVersion;
}

- (BOOL)isScreenPortrait {
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        return YES;
    }
    return NO;
}

+ (void)orientationToPortrait:(UIInterfaceOrientation)orientation
{
    SEL sel1 = NSSelectorFromString([NSString stringWithFormat:@"se%@ntation:", @"tOrie"]);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:sel1]];
    [invocation setSelector:sel1];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    //前两个参数已被target和selector占用
    [invocation invoke];
}

#pragma mark - Keyboard Width And Height
+ (CGFloat)getRealWidthByRatio:(CGFloat)ratio {
    return ceil(ratio * kScreenWidth);
}

+ (CGFloat)getRealHeightByRatio:(CGFloat)ratio {
    return ceil(ratio * kScreenHeight);
}

@end
