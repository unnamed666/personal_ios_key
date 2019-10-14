//
//  CMAppConfig.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// 调试云预测
//#define CLOUD_MOC

#define kDeviceUniqueIdentifierSetting          @"udid"

#define kKeychainUserName                       @"cheetahKeyboard"
#define kKeychainServiceName                    @"com.cmcm.cheetahKeyboard"

@interface CMAppConfig : NSObject
// 功能
+ (void)setupFabric;

+ (NSString *)appleId; //跳转市场用

+ (NSString*)firstLaunchTime;

// 当前target的URLScheme
+ (NSString *)appURLScheme;

// 渠道id，目前仅为appstore
+ (NSString *)channelId;

//设备唯一id
+ (NSString *)deviceId;

//build id
+ (NSString*)buildId;

//app version
+ (NSString*)appVersion;

//包名
+ (NSString*)bundleIdentifier;

//Extension名
+ (NSString*)bundleIdAddUpperCaseExtension;

// 兼容extension和Extension大小写
+ (NSString*)bundleIdAddLowerCaseExtension;

+ (NSString*)appGroupId;

//宿主 app 包名
+ (NSString*)hostAppbundleId;

//国家
+ (NSString*)country;

//当前语言
+ (NSString *)currentLanguage;

// 获取设备型号
+ (NSString *) deviceModel;

// 系统版本
+ (NSString *)systemVersion;

//竖向分辨率
+(CGFloat)verticalResolution;

//横向分辨率
+(CGFloat)horizontalResolution;

//获取手机上所有的app
+ (NSArray *)getAllAppsFromDevice;

//获取手机总内存(单位：M)
+ (long)getPhysicalMemory;

//获取idfa, 使用上面的deviceId方法
//+ (NSString *) idfa;

//获取产品名称
+ (NSString *)cloudProductName;


#pragma mark - 接口url
+ (NSString *)fetchThemeListUrl;

// infoc上报接口
+ (NSString *)infocHostUrl;

+ (NSString *)fetchDiyBgSourcesUrl;

+ (NSString *)fetchDiySoundSourcesUrl;

+ (NSString *)fetchDiyFontSourcesUrl;

// infoc apikey
+ (NSString *)infocApiKey;

//mcc
+ (NSString*)mobileCountryCode;

//icc
+ (NSString*)isoCountryCode;

//mnc
+ (NSString*)mobileNetworkCode;

// 获取系统语言
+ (NSString *)preferredLanguage;

//feedBack相关
+ (NSString *)feedBackAppId;
+ (NSString *)feedBackChannel;
+ (NSString *)feedBackType;

//获取手机系统当前的语言
+ (NSString *)localeLanCode;
//
+ (NSString *)deviceIdentify;
// > 1.14.2 版本才开启的内购
+ (NSString *)inappVersion;

//内购的密码
+ (NSString*)inappPassword;

//内购的验证服务器
+ (NSString*)inappUrl;

@end
