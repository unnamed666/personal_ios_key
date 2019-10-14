//
//  UIDevice+Util.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/14.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Util)

+ (NSString*)deviceModelName;

+ (BOOL)hasHapticFeedback;

+ (float)residentSizeOfMemory;

+ (float)usedSizeOfMemory;

+ (BOOL) isIphone55S5C;
+ (BOOL) isIpad;
+ (BOOL) isIpadPro;

+ (BOOL)isHeight568; //含iPhone 5/5c/5s/SE, iPod Touch 5G/6G

+ (BOOL)isHeight480; //含iPhone 4/4s, iPod Touch 1~4G

+ (BOOL)isHeight667; //含iPhone 6/7/8

+ (BOOL)isHeight736; //含iPhone 6p/7p/8p

+ (BOOL)isHeight812;//含iPhone X XS

+ (BOOL)isHeight896; //含iphone XSMAX XR

+ (BOOL)isHeight1024; //含iPad

+ (BOOL)isHeight1366; //含iPad Pro
+ (BOOL)isHeight1112;

- (BOOL)canVibration;

- (BOOL)isScreenPortrait;

// 获取系统版本号
#define IOS8_OR_LATER ([UIDevice systemMajorVersion] >= 8)
#define IOS9_OR_LATER ([UIDevice systemMajorVersion] >= 9)
#define IOS9_1_OR_LATER    ([UIDevice systemMajorVersion] > 9) || (([UIDevice systemMajorVersion] == 9) && [UIDevice systemMinorVersion] >= 1)
#define IOS10_OR_LATER ([UIDevice systemMajorVersion] >= 10)
#define IOS10_2_OR_LATER    ([UIDevice systemMajorVersion] > 10) || (([UIDevice systemMajorVersion] == 10) && [UIDevice systemMinorVersion] >= 2)
#define IOS11_OR_LATER ([UIDevice systemMajorVersion] >= 11)
#define IOS11_1_OR_LATER    ([UIDevice systemMajorVersion] > 11) || (([UIDevice systemMajorVersion] == 11) && [UIDevice systemMinorVersion] >= 1)


+ (NSInteger)systemMajorVersion;
+ (NSInteger)systemMinorVersion;

+ (void)orientationToPortrait:(UIInterfaceOrientation)orientation;

@end
