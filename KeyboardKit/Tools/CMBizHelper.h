//
//  CMBizHelper.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/23.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CMVersionCompare)
{
    CMVersionCompareOneBigger = -1L,
    CMVersionCompareSame,
    CMVersionCompareTwoBigger
};

@interface CMBizHelper : NSObject

+ (CGFloat)distanceBetweenRect:(CGRect)rect point:(CGPoint)point;

+ (CGFloat)distanceBetweenPoint:(CGPoint)point1 point:(CGPoint)point2;

+ (CGAffineTransform)createAffineTransform:(CGRect)fromRect toRect:(CGRect)toRect;

+ (BOOL) checkIsAddCheetahKeyboard;

+ (BOOL) checkIsCheetahKeyboard:(UITextField *)textField;

//+ (NSString *)readDataByContainer;
//+ (void)saveTextByContainer;

//+ (NSString *)readDataByKeyboard;
//+ (void)saveTextByKeyboard;

// 兼容extension和Extension大小写
+ (NSString*) fullAccessUrlFromUpperCase;

+ (NSString*) fullAccessUrlFromLowerCase;

+ (NSString*) fullAccessUrlFromExtension;

+ (UIFont*) getFontWithSize: (CGFloat) fontSize;

+ (UIColor*) itemSelectedColor;

+ (BOOL)isiPhone;

//获取当前日期 20170603
+(NSString*) getDate;

+ (BOOL)hasNetWork;

+ (BOOL)isWifiNetWork;

//    1.无网络
//    2.2G
//    3.3G
//    4.4G
//    5.wifi
+ (Byte)getNetType;

+ (NSString*)getPreferredLanguage;
+ (BOOL)shouldUseABTest;
+ (BOOL)shouldUseABTestAtInitPage;

// 根据机型来取屏幕宽高，解决未适配app取不到正确宽高的问题
+ (CGFloat)adapterScreenWidth;

+ (CGFloat)adapterScreenHeight;

// 动态加载字体
+ (void)registerFont:(NSString *)fontPath;
+ (UIViewController*) currentVisibleViewController:(UIViewController*) rootViewController;

+ (BOOL)isFontRegistered:(NSString *)fontName;

+ (CMVersionCompare) versionCompareOfVersion1:(NSString*) version1 andVersion2:(NSString*) version2;


+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController;
+ (NSInteger) getDateDifferent:(NSDate*) nowDate;

+(CGFloat)getRatioPoint:(CGFloat)value;

+ (void)sendGifPath:(NSString*)gifPath;
+ (void)sendGifData:(NSData*)data;

+(CGFloat)getKeyboardRatioPoint:(CGFloat)value;


+ (BOOL)CGImageWriteToFile:(CGImageRef)imageRef path:(NSURL *)path;

@end
