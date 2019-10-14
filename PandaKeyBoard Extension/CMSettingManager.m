//
//  CMSettingManager.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/15.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMSettingManager.h"
#import "CMSpacingAndPunctuations.h"
#import "CMGroupDataManager.h"
#import "Character.h"
#import "NSString+Common.h"

@interface CMSettingManager ()
@property (nonatomic, readwrite, strong)CMSpacingAndPunctuations* spacingAndPunctuations;

@end

@implementation CMSettingManager
DEF_SINGLETON(CMSettingManager)


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.spacingAndPunctuations = [[CMSpacingAndPunctuations alloc] init];
        NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
        [standard registerDefaults:@{kGlobalUserDefaultsCloudPredictionSupportLan:@[@"en"]}];
    }
    return self;
}


- (void)switchLanguage:(CMKeyboardLanguageType)language{
    [self.spacingAndPunctuations reset:language];
}

- (BOOL)shouldInsertSpacesAutomatically:(UIKeyboardType)keyboardType{
    return YES;
//    if(keyboardType == UIKeyboardTypeDefault){
//        return YES;
//    }
//    return NO;
}

- (BOOL)autoCorrectEnabled{
    return kCMGroupDataManager.autoCorrectEnabled;
}


- (float)autoCorrectionThreshold{
    if (self.autoCorrectEnabled) {
        return 0.185f;
    }else{
        return MAXFLOAT;
    }
}

- (BOOL)useDoubleSpacePeriod{
    return kCMGroupDataManager.useDoubleSpacePeriod;
}

- (CMKeyboardLanguageType)languageType
{
    return kCMGroupDataManager.languageType;
}

- (void)setLanguageType:(CMKeyboardLanguageType)languageType
{
    kCMGroupDataManager.languageType = languageType;
}

- (NSString *)currentThemeName {
    return [NSString stringIsEmpty:kCMGroupDataManager.currentThemeName] ? @"default" : kCMGroupDataManager.currentThemeName;
}

- (void)setCurrentThemeName:(NSString *)currentThemeName {
    if (![NSString stringIsEmpty:currentThemeName]) {
        kCMGroupDataManager.currentThemeName = currentThemeName;
    }
}

- (BOOL)showPrediction{
    return kCMGroupDataManager.showPrediction;
}

- (BOOL)showCorrection{
    return kCMGroupDataManager.showCorrection;
}
- (BOOL)autoCapitalization{
    return kCMGroupDataManager.autoCapitalization;
}

- (void)setAutoCapitalization:(BOOL)autoCapitalization
{
    kCMGroupDataManager.autoCapitalization = autoCapitalization;
}

- (BOOL)historyEnabled{
    return kCMGroupDataManager.historySuggestions;
}

- (BOOL)slideInputEnable
{
    return kCMGroupDataManager.slideInputEnable;
}

- (void)setSlideInputEnable:(BOOL)slideInputEnable
{
    kCMGroupDataManager.slideInputEnable = slideInputEnable;
}

- (BOOL)openKeyboardSound
{
    return kCMGroupDataManager.openKeyboardSound;
}

- (void)setOpenKeyboardSound:(BOOL)openKeyboardSound
{
    kCMGroupDataManager.openKeyboardSound = openKeyboardSound;
}

- (float)volume
{
    return kCMGroupDataManager.volume;
}

- (void)setVolume:(float)volume
{
    kCMGroupDataManager.volume = volume;
}

- (NSArray *)languages
{
    return kCMGroupDataManager.languageArray;
}

- (NSArray *)recentlyEmoji
{
    return kCMGroupDataManager.recentlyEmoji;
}

- (void)setRecentlyEmoji:(NSArray *)recentlyEmoji
{
    kCMGroupDataManager.recentlyEmoji = recentlyEmoji;
}

- (NSArray *)recentlyGif
{
    return kCMGroupDataManager.recentlyGif;
}

- (void)setRecentlyGif:(NSArray *)recentlyGif
{
    kCMGroupDataManager.recentlyGif = recentlyGif;
}

- (BOOL)isWordCodePoint:(int)code{
    return [Character isLetter:code] || COMBINING_SPACING_MARK == [Character getType:code] || [_spacingAndPunctuations isWordConnector:code];
}

- (BOOL)isAllowFullAccess{
    NSString * string = [UIPasteboard generalPasteboard].string;
    if(string) return YES;
    @try {
        [UIPasteboard generalPasteboard].string = @"Christmas";
        string = [UIPasteboard generalPasteboard].string;
        [UIPasteboard generalPasteboard].string = @"";
        if(string) return YES;
    } @catch (NSException *exception) {
        
    }
    
    return NO;
}

- (NSArray *)cloudSupportLan{
    NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
    return [standard objectForKey:kGlobalUserDefaultsCloudPredictionSupportLan];
}

- (void)setCloudSupportLan:(NSArray *)cloudSupportLan{
    NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
    [standard setObject:cloudSupportLan forKey:kGlobalUserDefaultsCloudPredictionSupportLan];
}

@end
