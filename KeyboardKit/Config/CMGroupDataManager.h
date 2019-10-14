//
//  CMGroupDataManager.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/7.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMGlobalEnum.h"

//@class CMTheme;

#define kCMGroupDataManager [CMGroupDataManager shareInstance]
static const float IS_SHOWED_RATE_VIEW = -1;

extern NSString* const kFirstLaunchTime;
extern NSString* const kIS_SHOW_KEYBOARD_FIRST;
extern NSString* const kPREF_AUTO_CORRECTION;
extern NSString* const kCloudAppVersion;
extern NSString* const kCloudFetchTimestampKey;

// 按键振动
extern NSString* const kTapVibrationKey;

@interface CMGroupDataManager : NSObject
@property (nonatomic,strong) NSURL *containerURL;

@property (nonatomic,readonly) NSURL *Documents;
@property (nonatomic,readonly) NSURL *Library;
@property (nonatomic,readonly) NSURL *ThemePath; //存放解压Theme路径
@property (nonatomic,readonly) NSURL *Caches;
@property (nonatomic,readonly) NSURL *tmp;
@property (nonatomic,readonly) NSURL *EmoGifPath;//Gif图片
@property (nonatomic,readonly) NSURL *ThemeSoundPath; //主题音效资源
@property (nonatomic,readonly) NSURL *ThemeFontPath; //主题字体资源
@property (nonatomic,readonly) NSURL *diyResourcePath;//Diy主题下载的资源

@property (nonatomic,copy) NSString *currentThemeName; //宿主和extension共享的主题

@property (nonatomic,strong) NSUserDefaults *shared;

@property (nonatomic,readonly) NSString *firstLaunchTime;

@property (nonatomic) NSString * deviceIdentifier;

@property (nonatomic,assign) BOOL showPrediction; //显示 prediction 词使能
@property (nonatomic,assign) BOOL  showCorrection;//显示 correction 词使能
@property (nonatomic,assign) BOOL autoCapitalization;//自动大写使能
@property (nonatomic,assign) BOOL autoCorrectEnabled; //correction 使能
@property (nonatomic,assign) BOOL useDoubleSpacePeriod; //空格双击使能
@property (nonatomic,assign) BOOL openKeyboardSound; //开启键盘声音

@property (nonatomic,assign) BOOL vibrationEnable; //点击按键振动

@property (nonatomic,assign) float volume;// 音量

// 云控相关，目前Container App与extension共用一套云控数据
@property (nonatomic, copy) NSString *cloudConfigVer; // 本地保存的最新返回的云控版本
@property (nonatomic, copy) NSString *cloudAppVer; // 本地保存的最新返回的云控版本，对应的App版本
@property (nonatomic, copy) NSString *cloudAppLang; // 本地保存的最新返回的云控版本，对应的语言环境
@property (nonatomic, copy) NSDictionary* cloudConfigDic;
@property (nonatomic, strong)NSDate* lastCloudFetchDate;


@property (nonatomic,assign) BOOL historySuggestions;//是否是用 history

// 滑动输入
@property (nonatomic, assign, getter=isSlideInputEnable)BOOL slideInputEnable;

#ifdef DEBUG
@property (nonatomic, assign, getter=isTensorFlowABTestEnable)BOOL tensorFlowABTestEnable;
@property (nonatomic, copy) NSString * mccTestString;
#endif

@property (nonatomic,weak) NSArray * languageArray;
@property (nonatomic,assign) CMKeyboardLanguageType languageType;//当前选择的语言
@property (nonatomic,copy) NSArray *recentlyEmoji;
@property (nonatomic,copy) NSArray *recentlyGif;

@property (nonatomic,assign) NSTimeInterval othersKeyboardTimestamp; //上一次上报第三方键盘信息的时间戳

@property (nonatomic,readonly) NSString *resourcePath;
+(instancetype) shareInstance;
- (void)stop;

#pragma mark - Add By Niecongcong
@property (nonatomic,assign) BOOL isShowedFullAccess;
@property (nonatomic,assign) BOOL isShowedKeyboardFirstTime;
@property (nonatomic,assign) NSString* isOpenFullAccessByContainer;
@property (nonatomic,assign) NSString* isOpenFullAccessByKeyboard;
@property (nonatomic,assign) NSInteger keyboardHideTimes;
@property (nonatomic,assign) NSInteger keyboardThemeChangeTimes;
@property (nonatomic, assign) BOOL isShowingCloudPredictTip;
@property (nonatomic, assign) BOOL isShowNewMarkOnSettingIconByCustomTheme;
@property (nonatomic, assign) BOOL isShowRedRoundMarkOnCustomThemeButton;
//- (void)setSettingItemObject:(id)value forKey:(NSString *)defaultName;
#ifdef DEBUG
- (NSArray *)configMccLanguage;
#endif

@property (nonatomic, assign) BOOL hasPurchasedIAP;
@property (nonatomic, assign) NSData* purchasedIAPReceipt;
@property (nonatomic, assign) NSDate* lastVerifyRIAPPDate;


@end
