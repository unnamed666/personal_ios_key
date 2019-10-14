//
//  CMBizHelper.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/23.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import "CMBizHelper.h"
#import "CMAppConfig.h"
#import "CMGroupDataManager.h"
#import "UIDevice+Util.h"
#import <CoreText/CoreText.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMLogger.h"
#import "CMOReachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NSString+Common.h"

@implementation CMBizHelper

+ (CGFloat)distanceBetweenRect:(CGRect)rect point:(CGPoint)point {
    if (CGRectContainsPoint(rect, point)) {
        return 0;
    }
    
    CGPoint closest = rect.origin;
    
    if (rect.origin.x + rect.size.width < point.x) {
        closest.x += rect.size.width;
    }
    else if (point.x > rect.origin.x) {
        closest.x = point.x;
    }
    
    if (rect.origin.y + rect.size.height < point.y) {
        closest.y += rect.size.height;
    }
    else if (point.y > rect.origin.y) {
        closest.y = point.y;
    }
    
    double a = pow((closest.y - point.y), 2);
    double b = pow((closest.x - point.x), 2);
    CGFloat result = sqrt(a+b);
    return result;
}

+ (CGFloat)distanceBetweenPoint:(CGPoint)point1 point:(CGPoint)point2 {
    double a = pow((point1.y - point2.y), 2);
    double b = pow((point1.x - point2.x), 2);
    CGFloat result = sqrt(a+b);
    return result;
}

+ (CGAffineTransform)createAffineTransform:(CGRect)fromRect toRect:(CGRect)toRect {
    CGFloat sx = toRect.size.width/fromRect.size.width;
    CGFloat sy = toRect.size.height/fromRect.size.height;
    
    CGAffineTransform scale = CGAffineTransformMakeScale(sx, sy);
    
    CGFloat heightDiff = fromRect.size.height - toRect.size.height;
    CGFloat widthDiff = fromRect.size.width - toRect.size.width;
    
    CGFloat dx = toRect.origin.x - widthDiff / 2 - fromRect.origin.x;
    CGFloat dy = toRect.origin.y - heightDiff / 2 - fromRect.origin.y;
    
    CGAffineTransform trans = CGAffineTransformMakeTranslation(dx, dy);
    return CGAffineTransformConcat(scale, trans);
}

+ (BOOL) checkIsAddCheetahKeyboard
{
    NSArray *keyboards = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleKeyboards"];
    // NSDictionary* theDiction = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    // Check for your keyboard
    //NSString* strTemp = [CMAppConfig bundleIdAddUpperCaseExtension];
    NSUInteger index1 = [keyboards indexOfObject:[CMAppConfig bundleIdAddUpperCaseExtension]];
    NSUInteger index2 = [keyboards indexOfObject:[CMAppConfig bundleIdAddLowerCaseExtension]];

    if (index1 != NSNotFound || index2 != NSNotFound)
    {
        kLogInfo(@"Found Keyboard");
        return true;
    }
    else
    {
        kLogInfo(@"Not Found");
        return false;
    }
}

+ (NSString*) fullAccessUrlFromUpperCase {
    
    NSString* str1 = @"A";
    NSString* str2 = @"pp-Pr";
    NSString* str3 = @"efs";
    NSString* str4 = @":r";
    NSString* str5 = @"oot=G";
    NSString* str6 = @"eneral&p";
    NSString* str7 = @"ath=Keyboard/KEYBOARDS/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",str1,str2,str3,str4,str5,str6,str7];
    
    urlString = [urlString stringByAppendingString:[CMAppConfig bundleIdAddUpperCaseExtension]];
    
    return urlString;
}

+ (NSString*) fullAccessUrlFromLowerCase {
    
    NSString* str1 = @"A";
    NSString* str2 = @"pp-Pr";
    NSString* str3 = @"efs";
    NSString* str4 = @":r";
    NSString* str5 = @"oot=G";
    NSString* str6 = @"eneral&p";
    NSString* str7 = @"ath=Keyboard/KEYBOARDS/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",str1,str2,str3,str4,str5,str6,str7];
    
    urlString = [urlString stringByAppendingString:[CMAppConfig bundleIdAddLowerCaseExtension]];
    
    return urlString;
}

+ (NSString*) fullAccessUrlFromExtension
{
    if (@available(iOS 11.0, *)){
       NSString*  urlString = [@"App-Prefs:" stringByAppendingString:[CMAppConfig hostAppbundleId]];
        return urlString;
    }else{
        NSString* str1 = @"A";
        NSString* str2 = @"pp-Pr";
        NSString* str3 = @"efs";
        NSString* str4 = @":r";
        NSString* str5 = @"oot=G";
        NSString* str6 = @"eneral&p";
        NSString* str7 = @"ath=Keyboard/KEYBOARDS/";
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",str1,str2,str3,str4,str5,str6,str7];
        
        urlString = [urlString stringByAppendingString:[CMAppConfig bundleIdentifier]];
        
        return urlString;
    }
}

+ (UIFont *)getFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Montserrat-Regular" size:fontSize];
}

+ (BOOL)checkIsCheetahKeyboard:(UITextField *)textField {
    BOOL result = NO;
    NSArray<UITextInputMode *> *array = [UITextInputMode activeInputModes];
    if (array && array.count > 0) {
        UITextInputMode* inputMode = [[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDisplayed = YES"]] lastObject];
        if (inputMode) {
            NSString* theString = (NSString*)[inputMode valueForKey:@"identifier"];
            if (![NSString stringIsEmpty:theString] && ([theString isEqualToString:[CMAppConfig bundleIdAddLowerCaseExtension]] || [theString isEqualToString:[CMAppConfig bundleIdAddUpperCaseExtension]])) {
                result = YES;
            }
        }
    }
    return result;
}


+ (UIColor *)itemSelectedColor
{
    return [UIColor colorWithRed:24.0/255.0 green:31.0/255.0 blue:55.0/255.0 alpha:1.0];
}

+ (BOOL)isiPhone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?  YES : NO;
}

/**
 *得到本机现在用的语言
 * en-CN 或en  英文  zh-Hans-CN或zh-Hans  简体中文   zh-Hant-CN或zh-Hant  繁体中文    ja-CN或ja  日本  ......
 */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (BOOL)shouldUseABTest
{
    return NO;
    
//    NSString* udid = [CMAppConfig deviceId];
//    NSArray* filterArray = @[@"1", @"3", @"5", @"7", @"9", @"b", @"d", @"f"];
//    NSString* lastChar = [udid substringFromIndex:udid.length-1];
//    if (![filterArray containsObject:lastChar])
//    {
//        return YES;
//    }
//    return NO;
}

+ (BOOL)shouldUseABTestAtInitPage
{
//    NSString* udid = [CMAppConfig deviceId];
//    NSArray* filterArray = @[@"1", @"3", @"5", @"7", @"9", @"b", @"d", @"f"];
//    NSString* lastChar = [udid substringFromIndex:udid.length-1];
//    if ((![filterArray containsObject:lastChar]) && IOS10_OR_LATER)
//    {
//        return YES;
//    }
//    else if (IOS11_OR_LATER)
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
    if (IOS11_OR_LATER)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (UIViewController*) currentVisibleViewController:(UIViewController*) rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self currentVisibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        
        return [self currentVisibleViewController:selectedViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self currentVisibleViewController:presentedViewController];
}

+ (void)registerFont:(NSString *)fontPath
{
    NSData *dynamicFontData = [NSData dataWithContentsOfFile:fontPath];
    if (!dynamicFontData)
    {
        return;
    }
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    if (! CTFontManagerRegisterGraphicsFont(font, &error))
    {
        //注册失败
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        kLogError(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(providerRef);
}

+ (CMVersionCompare) versionCompareOfVersion1:(NSString*) version1 andVersion2:(NSString*) version2
{
    NSComparisonResult compareResult = [version1 compare:version2 options:NSNumericSearch];
    if (compareResult == NSOrderedDescending)
    {
        return CMVersionCompareOneBigger;
    }
    else if (compareResult == NSOrderedSame)
    {
        return CMVersionCompareSame;
    }
    else
    {
        return CMVersionCompareTwoBigger;
    }
}

+ (BOOL)isFontRegistered:(NSString *)fontName
{
    UIFont* aFont = [UIFont fontWithName:fontName size:12.0];
    BOOL isDownloaded = (aFont && ([aFont.fontName caseInsensitiveCompare:fontName] == NSOrderedSame || [aFont.familyName caseInsensitiveCompare:fontName] == NSOrderedSame));
    return isDownloaded;
}

+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}

+ (NSInteger) getDateDifferent:(NSDate*) nowDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *cmps = [calendar components:type fromDate:nowDate toDate:[NSDate date] options:0];
    NSInteger secondDiff = [cmps hour]*3600+[cmps minute]*60+[cmps second];
    
    return  secondDiff;
}

+(NSString*) getDate
{
    NSDate  *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    return [NSString stringWithFormat:@"%.2ld%.2ld%.2ld",(long)[components year],(long)[components month],(long)[components day]];
}

+ (BOOL)hasNetWork
{
    
    return 1 != [CMBizHelper getNetType];
}

+ (BOOL)isWifiNetWork
{
    return 5 == [CMBizHelper getNetType];
}

+ (Byte)getNetType
{
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyGPRS          __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyEdge          __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyWCDMA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyHSDPA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyHSUPA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMA1x        __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORev0  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORevA  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORevB  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyeHRPD         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    //    CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyLTE           __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
    
    //    1.无网络
    //    2.2G
    //    3.3G
    //    4.4G
    //    5.wifi
    Byte net = 0;   //表示没有判断到
    kNavNetWorkStatus  networkReachabilityStatus =[CMOReachability status];
    
    if (networkReachabilityStatus == kNavNetWorkWIFI) {
        net = 5;
    } else if (networkReachabilityStatus == kNavNetWorkNotReachable) {
        net = 1;
    } else if (networkReachabilityStatus == kNavNetWorkWWAN) {
        NSString *netType = [CMBizHelper currentRadioAccessTechnology];
        if ([netType isEqualToString:CTRadioAccessTechnologyGPRS] ||
            [netType isEqualToString:CTRadioAccessTechnologyEdge]) {
            net = 2;
        }
        else if ([netType isEqualToString:CTRadioAccessTechnologyWCDMA] ||
                 [netType isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                 [netType isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                 [netType isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                 [netType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                 [netType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                 [netType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                 [netType isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            net = 3;
        } else if ([netType isEqualToString:CTRadioAccessTechnologyLTE]) {
            net = 4;
        }
    }
    return net;
}

+ (NSString *)currentRadioAccessTechnology
{
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    return telephonyInfo.currentRadioAccessTechnology;
}

// 根据机型来取屏幕宽高，解决未适配app取不到正确宽高的问题
+ (CGFloat)adapterScreenWidth {
//    NSString* deviceModelName = [UIDevice deviceModelName];
//    if ([deviceModelName containsString:@"iPhone 4"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 320.0f : 480.0f;
//    }
//    else if ([deviceModelName containsString:@"iPhone 5"] || [deviceModelName containsString:@"iPhone SE"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 320.0f : 568.0f;
//    }
//    else if (([deviceModelName containsString:@"iPhone 6"] || [deviceModelName containsString:@"iPhone 7"]) && ![deviceModelName containsString:@"Plus"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 375.0f : 667.0f;
//    }
//    else if (([deviceModelName containsString:@"iPhone 6"] || [deviceModelName containsString:@"iPhone 7"]) && [deviceModelName containsString:@"Plus"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 414.0f : 736.0f;
//    }
//    else if ([deviceModelName isEqualToString:@"iPod Touch 5G"] || [deviceModelName isEqualToString:@"iPod Touch 6G"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 320.0f : 568.0f;
//    }
//    else if ([deviceModelName isEqualToString:@"iPod Touch 1G"]
//             || [deviceModelName isEqualToString:@"iPod Touch 2G"]
//             || [deviceModelName isEqualToString:@"iPod Touch 3G"]
//             || [deviceModelName isEqualToString:@"iPod Touch 4G"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 320.0f : 480.0f;
//    }
//    else if ([deviceModelName containsString:@"iPad Pro"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 1024.0f : 1366.0;
//    }
//    else if ([deviceModelName containsString:@"iPad"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 768.0f : 1024.0f;
//    }
//    else {
        return [UIScreen mainScreen].bounds.size.width;
//    }
}

+ (CGFloat)adapterScreenHeight {
//    NSString* deviceModelName = [UIDevice deviceModelName];
//    if ([deviceModelName containsString:@"iPhone 4"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 480.0f : 320.0f;
//    }
//    else if ([deviceModelName containsString:@"iPhone 5"] || [deviceModelName containsString:@"iPhone SE"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 568.0f : 320.0f;
//    }
//    else if (([deviceModelName containsString:@"iPhone 6"] || [deviceModelName containsString:@"iPhone 7"]) && ![deviceModelName containsString:@"Plus"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 667.0f : 375.0f;
//    }
//    else if (([deviceModelName containsString:@"iPhone 6"] || [deviceModelName containsString:@"iPhone 7"]) && [deviceModelName containsString:@"Plus"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 736.0f : 414.0f;
//    }
//    else if ([deviceModelName isEqualToString:@"iPod Touch 5G"] || [deviceModelName isEqualToString:@"iPod Touch 6G"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 568.0f : 320.0f;
//    }
//    else if ([deviceModelName isEqualToString:@"iPod Touch 1G"]
//             || [deviceModelName isEqualToString:@"iPod Touch 2G"]
//             || [deviceModelName isEqualToString:@"iPod Touch 3G"]
//             || [deviceModelName isEqualToString:@"iPod Touch 4G"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 480.0f : 320.0f;
//    }
//    else if ([deviceModelName containsString:@"iPad Pro"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 1366.0f : 1024.0f;
//    }
//    else if ([deviceModelName containsString:@"iPad"]) {
//        return [UIDevice currentDevice].isScreenPortrait ? 1024.0f : 768.0f;
//    }
//    else {
        return [UIScreen mainScreen].bounds.size.height;
//    }
}
+ (void)sendGifPath:(NSString*)gifPath{
    NSData *data=[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:gifPath]];
    [CMBizHelper sendGifData:data];
}

+ (void)sendGifData:(NSData*)data{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys: data,(NSString *)kUTTypeGIF,     nil];
    pasteboard.items = [NSArray arrayWithObject:item];
}

+(CGFloat)getRatioPoint:(CGFloat)value{
    
    CGFloat radio = 1.0f;
    if ([UIDevice currentDevice].isScreenPortrait) {
        //竖屏
        if ([UIDevice isIpad]) {
            //ipad
            radio = 1.0;
            radio = [self adapterScreenWidth]*0.75/375.0f;
        }else{
            radio = [self adapterScreenWidth]/375.0f;
        }
        
    }else{
        //横屏
        if ([UIDevice isIpad]) {
            //ipad
//            radio = 1.0;
            radio = [self adapterScreenWidth]/667.0f;

        }else{
            radio = [self adapterScreenWidth]/667.0f;
        }
    }
    
    return ceil(value * radio);
}

+(CGFloat)getKeyboardRatioPoint:(CGFloat)value{
    CGFloat ratio = [UIDevice currentDevice].isScreenPortrait ? ([UIDevice isIpad] ? 0.2463f : 0.333f) : ([UIDevice isIpad] ? 0.442f : 0.44f);
    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight568]) {
            ratio = 0.3762;
        }
        else if ([UIDevice isHeight667]) {
            ratio = 0.3234;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.2383;
        }
        else if ([UIDevice isHeight1024]) {
            ratio = 0.2547;
        }
        else if ([UIDevice isHeight736]) {
            ratio = 0.3070;
        }
        else if ([UIDevice isHeight812]) {
            ratio = 0.2645;
        }
    }
    else {
        if ([UIDevice isHeight568]) {
            ratio = 0.514f;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.407f;
        }
        
    }
    
    return ceil(ratio * value/0.3234);

}

+ (BOOL)CGImageWriteToFile:(CGImageRef)imageRef path:(NSURL *)path {
    CFURLRef url = (__bridge CFURLRef)path;
//    float compression = 0.2; //设置压缩比
//    float sizeScale = 0.5; //缩放比
//    int orientation = 4; // 设置朝向bottom, left.
//    CFStringRef myKeys[2];
//    CFTypeRef   myValues[2];
//    CFDictionaryRef myOptions = NULL;
//    myKeys[0] = kCGImagePropertyOrientation;
//    myValues[0] = CFNumberCreate(NULL, kCFNumberIntType, &orientation);
//
//    NSInteger frameScale = (NSInteger)CGImageGetWidth(imageRef) * sizeScale;
//    myKeys[0] = kCGImageDestinationLossyCompressionQuality;
//    myValues[0] = CFNumberCreate(NULL, kCFNumberFloatType, &compression);
//    myKeys[1] = kCGImageDestinationImageMaxPixelSize;
//    myValues[1] = CFNumberCreate(NULL, kCFNumberIntType, &frameScale);
//    myOptions = CFDictionaryCreate( NULL, (const void **)myKeys, (const void **)myValues, 2,
//                                   &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary* myOptions = @{(__bridge id)kCGImageDestinationLossyCompressionQuality:@(0.8),
                               (__bridge id)kCGImageDestinationImageMaxPixelSize:@(200)
                               };

    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    if (!destination) {
        kLogError(@"Failed to create CGImageDestination for %@", path);
        return NO;
    }
    CGImageDestinationAddImage(destination, imageRef, (__bridge CFDictionaryRef)myOptions);
    if (!CGImageDestinationFinalize(destination)) {
        kLogError(@"Failed to write image to %@", path);
        CFRelease(destination);
        return NO;
    }
    CFRelease(destination);
    return YES;
}

@end
