//
//  CMSettingManager.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/15.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMKeyboardManager.h"
@class CMSpacingAndPunctuations;

#define kCMSettingManager [CMSettingManager sharedInstance]
@interface CMSettingManager : NSObject
AS_SINGLETON(CMSettingManager)

@property (nonatomic,readonly) float autoCorrectionThreshold;

@property (nonatomic,readonly) BOOL showPrediction; //显示 prediction 词使能
@property (nonatomic,readonly) BOOL  showCorrection;//显示 correction 词使能
@property (nonatomic, assign) BOOL autoCapitalization;//自动大写使能
@property (nonatomic,readonly) BOOL autoCorrectEnabled; //correction 使能
@property (nonatomic,readonly) BOOL useDoubleSpacePeriod; //空格双击使能
@property (nonatomic,readwrite) BOOL openKeyboardSound; //开启点击键盘声音
@property (nonatomic,readwrite) float volume;// 音量

@property (nonatomic,readonly) BOOL historyEnabled; //history使能位

@property (nonatomic, assign) BOOL slideInputEnable;//滑动输入

@property (nonatomic,readonly) BOOL isAllowFullAccess;

@property (nonatomic) NSArray * cloudSupportLan;

@property (nonatomic,readonly) NSArray *languages;
@property (nonatomic,assign) CMKeyboardLanguageType languageType;
@property (nonatomic,copy) NSArray *recentlyEmoji;
@property (nonatomic,copy) NSArray *recentlyGif;

@property (nonatomic,readonly)CMSpacingAndPunctuations* spacingAndPunctuations;

@property (nonatomic,copy) NSString *currentThemeName; //宿主和extension共享的主题

- (void)switchLanguage:(CMKeyboardLanguageType)language;

- (BOOL)shouldInsertSpacesAutomatically:(UIKeyboardType)keyboardType;

- (BOOL)isWordCodePoint:(int)code;
@end
