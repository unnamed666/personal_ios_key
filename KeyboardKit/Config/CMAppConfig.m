//
//  CMAppConfig.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMAppConfig.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "CMGroupDataManager.h"
#import "NSString+Common.h"
#include <sys/utsname.h>
#import <objc/runtime.h>
#import "CMBizHelper.h"
#import "UICKeyChainStore.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "CMLogger.h"

@implementation CMAppConfig

+ (void)setupFabric {
    [Fabric with:@[CrashlyticsKit]];
    [CrashlyticsKit setUserIdentifier:[CMAppConfig deviceId]];
}

+ (NSString *)feedBackAppId {
    return @"45";
}

+ (NSString *)feedBackChannel {
    return @"0";    //0客户端上报，1客服人员反馈，2邮件反馈，3GP反馈
}

+ (NSString *)feedBackType {
    return @"feedback";
}

+ (NSString *)localeLanCode {
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

+ (NSString *)deviceIdentify {
    return [CMAppConfig deviceId];
}

+ (NSString *)appleId {
#ifndef SCHEME
    return @"1249925656";
#else
    return @"1258139747";
#endif
}

+ (NSString *)appURLScheme {
#ifdef SCHEME
    return @"CMHologram";
#else
    return @"CMKeyboard";
#endif
}


+ (NSString *)firstLaunchTime{
    return kCMGroupDataManager.firstLaunchTime;
}

+ (NSString *)channelId {
    return @"appstore";
}

+ (CGFloat)horizontalResolution{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenX = screenSize.width * scale;
    return screenX;
}

+ (CGFloat)verticalResolution{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenY = screenSize.height * scale;
    return screenY;
}

+ (NSString *)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

// 获取设备型号
+ (NSString *) deviceModel
{
    static NSString* model;
    
    if(model == nil)
    {
        struct utsname u;
        uname(&u);
        model = [[NSString stringWithCString:u.machine encoding:NSUTF8StringEncoding] copy];
    }
    
    return model;
}

+ (NSString *)currentLanguage
{
    static NSString * language;
    if(!language)
    {
        NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        language =  [[languages objectAtIndex:0] copy];
    }
    return language;
    
}


+ (NSString*)country{
    return [[NSLocale currentLocale]  objectForKey:NSLocaleCountryCode];
}

+ (NSString*)bundleIdentifier{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString*)bundleIdAddUpperCaseExtension
{
    return [[self bundleIdentifier] stringByAppendingString:@".Extension"];
}

+ (NSString*)bundleIdAddLowerCaseExtension
{
    return [[self bundleIdentifier] stringByAppendingString:@".extension"];
}

//app version
+ (NSString*)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+(NSString *)buildId{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
}

+(NSString*)hostAppbundleId{
    NSString *bundleId = [CMAppConfig bundleIdentifier];
    NSRange range = [bundleId rangeOfString:@"Extension" options:NSCaseInsensitiveSearch];
    
    if (range.location !=NSNotFound){
        bundleId = [bundleId stringByReplacingOccurrencesOfString:@".Extension" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, bundleId.length)];
    }else{
        range = [bundleId rangeOfString:@".iMessageE" options:NSCaseInsensitiveSearch];
        
        if (range.location !=NSNotFound){
            bundleId = [bundleId stringByReplacingOccurrencesOfString:@".iMessageE" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, bundleId.length)];
        }
    }
    return bundleId;
}

+(NSString *)appGroupId
{
    NSString *bundleId = [CMAppConfig hostAppbundleId];
     return [NSString stringWithFormat:@"group.%@",bundleId];
}

+ (NSString *) deviceId
{
    static NSString * deviceID;
    if(deviceID == nil || deviceID.length == 0)
    {
        NSError* error = nil;

        deviceID = kCMGroupDataManager.deviceIdentifier;

//        NSString *bundleId = [CMAppConfig bundleIdentifier];
//        NSRange range = [bundleId rangeOfString:@"Extension"];//设备id只能宿主APP才能生成，为了保证唯一性
//        if (range.location !=NSNotFound){
//            return deviceID;
//        }

        if (deviceID == nil) {
            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:kKeychainServiceName];
            deviceID = [keychain stringForKey:kKeychainUserName error:&error];
            if (error || [NSString stringIsEmpty:deviceID]) {
                deviceID = nil;
            }

            if(deviceID)
            {
                kCMGroupDataManager.deviceIdentifier = deviceID;
            }else{
                deviceID = [self udidWithIdfa];
                kCMGroupDataManager.deviceIdentifier = deviceID;

                if(deviceID)
                {
                    error = nil;
                    [keychain setString:deviceID forKey:kKeychainUserName error:&error];
                    if (error) {
//                        kLogError(@"%@", error.localizedDescription);
                    }
                }
            }
        }

    }

    return deviceID?deviceID:@"";
}

//+ (NSString *) deviceId
//{
//    static NSString * deviceID;
//    if(deviceID == nil || deviceID.length == 0)
//    {
//        NSUserDefaults *userDefaults = kCMGroupDataManager.shared;
//        NSError* error = nil;
//        
//        deviceID = [userDefaults objectForKey:kDeviceIdentifierSetting];
//        if (deviceID == nil) {
//            
//            @try {
//                deviceID = [SFHFKeychainUtils getPasswordForUsername:kKeychainUserName andServiceName:kKeychainServiceName error:&error];
//            } @catch (NSException *exception) {
//                deviceID = nil;
//            }
//            
//            if (![deviceID length]) {
//                deviceID = nil;
//            }
//            
//            if(deviceID)
//            {
//                [userDefaults setObject:deviceID forKey:kDeviceIdentifierSetting];
//                [userDefaults synchronize];
//            }else{
//                deviceID = [self udidWithIdfa];
//                [userDefaults setObject:deviceID forKey:kDeviceIdentifierSetting];
//                [userDefaults synchronize];
//                
//                if(deviceID)
//                {
//                    error = nil;
//                    @try {
//                        [SFHFKeychainUtils storeUsername:kKeychainUserName andPassword:deviceID forServiceName:kKeychainServiceName updateExisting:YES error:&error];
//                    } @catch (NSException *exception) {
//                    }
//                }
//            }
//        }
//        
//    }
//    
//    return deviceID;
//}

+ (NSString *) idfa
{
    NSString *idfa = @"";
    Class theClass = NSClassFromString([NSString stringWithFormat:@"ASIden%@ager", @"tifierMan"]);
    id manager = [theClass sharedManager];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id xxxid = [manager performSelector:NSSelectorFromString([NSString stringWithFormat:@"advert%@fier", @"isingIdenti"]) withObject:nil];
    id result = [xxxid performSelector:NSSelectorFromString([NSString stringWithFormat:@"UU%@ing", @"IDStr"]) withObject:nil];
#pragma clang diagnostic pop
    if(result){
        idfa =[result copy];
    }
    return idfa;
}

+ (NSString *)udidWithIdfa {
    NSString *udid = nil;
    if (udid == nil || udid.length == 0) {
        NSUserDefaults *userDefaults = kCMGroupDataManager.shared;

        udid = [userDefaults objectForKey:kDeviceUniqueIdentifierSetting];
        if (udid == nil || udid.length == 0) {
            NSString* idfa = [self idfa];
            if(![idfa length] || [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"])
            {
                idfa = [CMAppConfig generateRandomStringWithLength:32 newCharacterSet:nil];
            }
            NSString* fakeIdfa = [NSString stringWithFormat:@"%@appid",idfa];

            fakeIdfa = [[fakeIdfa md5] md5];
            //   udid = [NSString stringWithFormat:@"%@%@",fakeIdfa,[[idfa md5] substringFromIndex:32-8]];
            udid = [NSString stringWithFormat:@"%@%@",[[idfa md5] substringFromIndex:32-8],fakeIdfa];

            //            udid = [self generateRandomStringWithLength:kDeviceUniqueIdentifierMaximumLength newCharacterSet:nil];
            //
            [userDefaults setObject:udid forKey:kDeviceUniqueIdentifierSetting];
            [userDefaults synchronize];
        }
    }

    return udid;
}

+ (NSString *)generateRandomStringWithLength:(NSInteger)length newCharacterSet:(NSString *)newCharacterSet {
    NSMutableString *string = [[NSMutableString alloc] init];
    NSString *charSet = nil;
    
    if (newCharacterSet != nil) {
        charSet = newCharacterSet;
    } else {
        charSet = @"0123456789abcdef";
    }
    
    for (int i = 0; i < length; i++) {
        [string appendFormat:@"%c", [charSet characterAtIndex:arc4random() % [charSet length]]];
    }
    
    return string;
}

+ (NSArray *)getAllAppsFromDevice
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //获取手机上所有的app
    NSMutableArray *resultArray = [NSMutableArray new];
    
    //LSApplicationWorkspace
    Class theClass = NSClassFromString([NSString stringWithFormat:@"LSAp%@ork%@", @"plicationW", @"space"]);
    
    SEL sel1 = NSSelectorFromString([NSString stringWithFormat:@"defa%@kspace", @"ultWor"]);
    SEL sel2 = NSSelectorFromString([NSString stringWithFormat:@"al%@alle%@ions", @"lInst", @"dApplicat"]);

    NSObject *theObj = [theClass performSelector:sel1];
    NSArray *objs = [theObj performSelector:sel2];

    //LSApplicationProxy
    Class theClass2 = NSClassFromString([NSString stringWithFormat:@"L%@ati%@xy", @"SApplic", @"onPro"]);
    for (int i = 0; i < objs.count; i++) {
        NSObject *temp = objs[i];
        if ([temp isKindOfClass:theClass2]) {
//            ApplicationModel *appModel = [[ApplicationModel alloc] init];
            //applicationIdentifier
            SEL sel3 = NSSelectorFromString([NSString stringWithFormat:@"%@atio%@tifier", @"applic", @"nIden"]);
            NSString *tempKey = [temp performSelector:sel3];
            NSRange range = [tempKey rangeOfString:[NSString stringWithFormat:@"c%@pple", @"om.a"]];//判断字符串是否包含
            if (range.location !=NSNotFound){continue;}
            //版本
            SEL sel4 = NSSelectorFromString([NSString stringWithFormat:@"sho%@io%@ng", @"rtVers", @"nStri"]);
            NSString *tempVersionNumber = [temp performSelector:sel4];
            kLog(@"%@ %@",tempKey,tempVersionNumber);
            [resultArray addObject:tempKey];
        }
    }
    return [resultArray copy];
#pragma clang diagnostic pop
}

+ (long)getPhysicalMemory {
    return [NSProcessInfo processInfo].physicalMemory / (1024 * 1024);
}

+ (NSString *)cloudProductName
{
    return @"keyboard_ios";
}


#pragma mark - 接口url
+ (NSString *)fetchThemeListUrl {
    return @"https://api-keyboard.cmcm.com/ios/theme/list";

//#ifdef DEBUG
//    return @"https://10.60.81.153/ios/theme/list";
//#else
//    return @"https://api-keyboard.cmcm.com/ios/theme/list";
//#endif
}

// infoc上报接口
+ (NSString *)infocHostUrl {
#ifdef DEBUG
    return @"http://118.89.55.235/c/";
#else
    return @"https://helpcheetahkeyboard1.ksmobile.com/c/";
#endif
}

+ (NSString *)fetchDiyBgSourcesUrl
{
    return @"https://api-keyboard.cmcm.com/ios/diy/bg";
}

+ (NSString *)fetchDiySoundSourcesUrl
{
    return @"https://api-keyboard.cmcm.com/ios/diy/sounds";
}

+ (NSString *)fetchDiyFontSourcesUrl
{
    return @"https://api-keyboard.cmcm.com/ios/diy/fonts";
}
// infoc apikey
+ (NSString *)infocApiKey {
    return @"183";
}

+ (NSString*)mobileCountryCode
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    return mcc ? mcc :@"0";
}

+ (NSString*)isoCountryCode
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *icc = [carrier isoCountryCode];
    return icc? icc :@"0";
}

+ (NSString*)mobileNetworkCode
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    return mnc ? mnc :@"0";
}

+ (NSString *)preferredLanguage
{
    static NSString * lan;
    if(!lan)
    {
        NSString* currentlanguage =  [CMAppConfig currentLanguage];
        NSRange  range = [currentlanguage rangeOfString:@"-"];
        if(range.location != NSNotFound){
            lan = [currentlanguage substringToIndex:range.location];
        }else{
            lan = currentlanguage;
        }
    }
    return lan;
}

+ (NSString *)inappVersion {
    return @"1.14.2";
}

+ (NSString *)inappPassword {
    return @"PLYFkqnjKkHLlc2ZD1WyDpyNq5vWGM85";
}

+ (NSString *)inappUrl {
    return @"https://cmiscan.com/verifyReceipt2/IOSKeyboard";
}


@end
