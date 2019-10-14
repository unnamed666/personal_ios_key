//
//  SettingData.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/10.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "SettingData.h"
#import "CMGroupDataManager.h"

@interface SettingData ()

@end

@implementation SettingData

- (NSArray *)languageArray{
    return kCMGroupDataManager.languageArray;
}

- (void)setLanguageArray:(NSArray *)languageArray
{
    kCMGroupDataManager.languageArray = languageArray;
}

- (BOOL)autoCapital{
    return kCMGroupDataManager.autoCapitalization;
}

- (void)setAutoCapital:(BOOL)autoCapital
{
    kCMGroupDataManager.autoCapitalization = autoCapital;
}

- (BOOL)doubleSpacePeriod{
    return kCMGroupDataManager.useDoubleSpacePeriod;
}

- (void)setDoubleSpacePeriod:(BOOL)doubleSpacePeriod
{
    kCMGroupDataManager.useDoubleSpacePeriod = doubleSpacePeriod;
}

- (BOOL)showCorrectionSuggestions{
    return kCMGroupDataManager.showCorrection;
}

- (void)setShowCorrectionSuggestions:(BOOL)showCorrectionSuggestions
{
    kCMGroupDataManager.showCorrection = showCorrectionSuggestions;
}

- (BOOL)autoCorrectionSuggestions{
    return kCMGroupDataManager.autoCorrectEnabled;
}

- (void)setAutoCorrectionSuggestions:(BOOL)autoCorrectionSuggestions
{
    kCMGroupDataManager.autoCorrectEnabled = autoCorrectionSuggestions;
}

- (BOOL)nextWordSuggestions{
    return kCMGroupDataManager.showPrediction;
}

- (void)setNextWordSuggestions:(BOOL)nextWordSuggestions
{
    kCMGroupDataManager.showPrediction = nextWordSuggestions;
}

- (BOOL)historySuggestions{
    return kCMGroupDataManager.historySuggestions;
}

- (void)setHistorySuggestions:(BOOL)historySuggestions{
    kCMGroupDataManager.historySuggestions = historySuggestions;
}

- (BOOL)isSlideInputEnable {
    return kCMGroupDataManager.isSlideInputEnable;
}

- (void)setSlideInputEnable:(BOOL)slideInputEnable {
    kCMGroupDataManager.slideInputEnable = slideInputEnable;
}

#ifdef DEBUG
- (BOOL)isTensorFlowABTestEnable {
    return kCMGroupDataManager.isTensorFlowABTestEnable;
}

- (void)setTensorFlowABTestEnable:(BOOL)tensorFlowABTestEnable {
    kCMGroupDataManager.tensorFlowABTestEnable = tensorFlowABTestEnable;
}

- (NSString *)mccTestString
{
    return kCMGroupDataManager.mccTestString;
}

- (void)setMccTestString:(NSString *)mccTestString
{
    kCMGroupDataManager.mccTestString = mccTestString;
}
#endif

-(void)setOpenKeyboardSound:(BOOL)openKeyboardSound
{
    kCMGroupDataManager.openKeyboardSound = openKeyboardSound;
}

- (BOOL)openKeyboardSound
{
   return kCMGroupDataManager.openKeyboardSound;
}

- (void)setVibrationEnable:(BOOL)vibrationEnable {
    kCMGroupDataManager.vibrationEnable = vibrationEnable;
}

- (BOOL)vibrationEnable {
    return kCMGroupDataManager.vibrationEnable;
}

@end
