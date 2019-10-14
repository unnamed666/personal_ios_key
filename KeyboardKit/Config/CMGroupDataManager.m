//
//  CMGroupDataManager.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/7.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMGroupDataManager.h"
#import "NSDictionary+Common.h"
#import "CMAppConfig.h"
#import "CMBizHelper.h"
#import "NSString+Common.h"
#import "CMLogger.h"

//#import "CMTheme.h"
NSString* const kFirstLaunchTime = @"first_launch_time";
NSString* const kIS_SHOW_KEYBOARD_FIRST = @"IsShowKeyboardFirst";
NSString* const kPREF_AUTO_CORRECTION = @"pref_key_auto_correction";
NSString* const kCloudAppVersion= @"cloud_app_version";
NSString* const kCloudFetchTimestampKey = @"cloudFetchTimestampKey";

// 按键振动
NSString* const kTapVibrationKey = @"kTapVibrationKey";

static NSString * kDeviceIdentifierSetting = @"deviceIdentifier";

static NSString * kCurrentThemeName = @"currentThemeName";

static NSString * kPREF_HISTORY_ON = @"pref_key_history_on";
static NSString * kPREF_SHOW_PREDICTION = @"pref_key_show_prediciton";
static NSString * kPREF_SHOW_CORRECTION = @"pref_key_show_correction";
static NSString * kPREF_AUTO_CAPITALIZATION = @"pref_key_auto_capitalization";
static NSString * kPREF_KEY_USE_DOUBLE_SPACE_PERIOD = @"pref_key_use_double_space_period";
static NSString * kPREF_KEY_LANGUAGE_TYPE = @"pref_key_language_type";
static NSString * kLANGUAGE_ARRAY = @"language_array";
static NSString * kRECENTLY_EMOJI = @"recently_emoji";

static NSString * kOTHERS_KEYBOARD_TIMESTAMP = @"others_keyboard_timestamp";
// Add by NieCongCong
static NSString * kFOR_CONTAINER = @"KeyForContainerFullAccess";
static NSString * kFOR_KEYBOARD = @"KeyForKeyboardsssssaad2232424232222222";
static NSString * kIS_APP_FIRST_INSTALL = @"isAppFirstInstall";
static NSString * kKEYBOARD_HIDE_TIMES = @"keyboardHideTimes";
static NSString * kKEY_BOARD_BACK_TAP_TIMES = @"keyboardThemeChangeTimes";
static NSString * kIS_SHOWED_RATE_US_VIEW = @"isShowedRateUsView";
static NSString * kIS_SHOW_NEW_MARK_ON_SETTING_ICON_BY_CUSTOM_THEME = @"isShowNewMarkOnSettingIconByCustomTheme";
static NSString * kIS_SHOW_REDROUND_MARK_ON_CUSTOM_THEME_BUTTOM = @"isShowRedRoundMarkOnCustomThemeButton";
static NSString * kIS_HAS_PURCHASED_IAPP = @"haspurchasediapp";
static NSString * kIS_HAS_PURCHASED_IAPP_RECEIPT = @"haspurchasediappReceipt";
static NSString * kVerifyIappDate = @"verifyiappdate";


// Add by yaozongchao

static NSString * kPrefKeyIsSlideInputEnable = @"pref_key_is_slide_input_enable";
static NSString * kIsShowingCloudPredictTip = @"is_Showing_Clould_Predict_Tip";

#ifdef DEBUG
static NSString * kPrefKeyIsTensorFlowEnable = @"pref_key_is_tensor_flow_enable";
static NSString * kMccTestKey = @"mcc_test_key";
#endif

// 云控相关
static NSString * kCloudVersion= @"cloud_version";
static NSString * kCloudAppLanguage= @"cloud_app_lang";
static NSString * kCloudConfigInfoDic= @"cloud_config_infoDic";


//Add by zhanglu
static NSString * kSETTING_KEYBOARD_SOUND = @"setting_keyboard_sound_key";
static NSString * kSETTING_KEYBOARD_VOLUME = @"setting_keyboard_volume_key";

@interface CMGroupDataManager (){
    NSURL * _Documents;
    NSURL * _Library;
    NSURL * _Caches;
    NSURL * _tmp;
    NSURL * _ThemePath;
    NSURL * _EmoGifPath;
    NSURL * _ThemeSoundPath;
    NSURL * _ThemeFontPath;
//    CMTheme * _currentTheme;
    NSString* _resourcePath;
    NSURL * _diyResourcePath;
    NSArray * _gifSendRecent;
}

@end

@implementation CMGroupDataManager
static CMGroupDataManager* _instance = nil;

+(instancetype) shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *appGroupId = [CMAppConfig appGroupId];
        self.shared = [[NSUserDefaults alloc] initWithSuiteName:appGroupId];
        self.containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupId];
        

        [self configDefaultLanguage];
        NSArray *languageArray = [self configMccLanguage];
        
        NSArray *emojiArray = @[@"😂", @"😘", @"😍", @"❤️", @"😙",
                                @"😭", @"💖", @"😎", @"🌚", @"☺️",
                                @"💋", @"😗", @"💩", @"😌", @"😲",
                                @"🙏", @"😅", @"🌹", @"👌", @"😡",
                                @"👏", @"😈", @"👻", @"💃", @"😵",
                                @"🙈", @"💯", @"🎀"];
        
        
        
        

        NSDictionary *defaultValues = @{kPREF_AUTO_CORRECTION:@(YES),
                                        kPREF_AUTO_CAPITALIZATION:@(YES),
                                        kPREF_SHOW_CORRECTION:@(YES),
                                        kPREF_SHOW_PREDICTION:@(YES),
                                        kLANGUAGE_ARRAY:languageArray,
                                        kPREF_KEY_USE_DOUBLE_SPACE_PERIOD:@(YES),
                                        kPREF_KEY_LANGUAGE_TYPE:@(CMKeyboardLanguageTypeUndefined),
                                        kRECENTLY_EMOJI:emojiArray,
                                        kOTHERS_KEYBOARD_TIMESTAMP:@(0.0),
                                        kPREF_HISTORY_ON:@(YES),
                                        kSETTING_KEYBOARD_VOLUME:@(1.0f),
                                        kTapVibrationKey:@(YES),
                                        kIS_SHOWED_RATE_US_VIEW:@(NO),
                                        kIS_HAS_PURCHASED_IAPP:@(NO)};
//        kFirstLaunchTime:[Common getDate]};
        [self.shared registerDefaults:defaultValues];
        if(!self.firstLaunchTime){
            [self.shared setObject:[CMBizHelper getDate] forKey:kFirstLaunchTime];
        }
        
    }
    return self;
}

- (NSArray *)configDefaultLanguage
{
    NSArray *languageArray = nil;
    NSString *preferredLanguage = [CMBizHelper getPreferredLanguage];
    if ([preferredLanguage hasPrefix:@"en"]) {
        languageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];
    }else if ([preferredLanguage hasPrefix:@"es"]) {
        languageArray = @[@(CMKeyboardLanguageTypeSpanish)];
    }else if ([preferredLanguage hasPrefix:@"id"]) {
        languageArray = @[@(CMKeyboardLanguageTypeIndonesian)];
    }else if ([preferredLanguage hasPrefix:@"az"]) {
        languageArray = @[@(CMKeyboardLanguageTypeAzerbaijani)];
    }else if ([preferredLanguage hasPrefix:@"ca"]) {
        languageArray = @[@(CMKeyboardLanguageTypeCatalan)];
    }else if ([preferredLanguage hasPrefix:@"cs"]) {
        languageArray = @[@(CMKeyboardLanguageTypeCzech)];
    }else if ([preferredLanguage hasPrefix:@"da"]) {
        languageArray = @[@(CMKeyboardLanguageTypeDanish)];
    }else if ([preferredLanguage hasPrefix:@"de"]) {
        languageArray = @[@(CMKeyboardLanguageTypeGerman)];
    }else if ([preferredLanguage hasPrefix:@"et"]) {
        languageArray = @[@(CMKeyboardLanguageTypeEstonian)];
    }else if ([preferredLanguage hasPrefix:@"fi"]) {
        languageArray = @[@(CMKeyboardLanguageTypeFinnish)];
    }else if ([preferredLanguage hasPrefix:@"fr"]) {
        languageArray = @[@(CMKeyboardLanguageTypeFrench)];
    }else if ([preferredLanguage hasPrefix:@"hr"]) {
        languageArray = @[@(CMKeyboardLanguageTypeCroatian)];
    }else if ([preferredLanguage hasPrefix:@"hu"]) {
        languageArray = @[@(CMKeyboardLanguageTypeHungarian)];
    }else if ([preferredLanguage hasPrefix:@"pt"]) {
        languageArray = @[@(CMKeyboardLanguageTypePortuguese)];
    }else if ([preferredLanguage hasPrefix:@"ms"]) {
        languageArray = @[@(CMKeyboardLanguageTypeMalay)];
    }else if ([preferredLanguage hasPrefix:@"tl"]) {
        languageArray = @[@(CMKeyboardLanguageTypeFilipino)];
    }else if ([preferredLanguage hasPrefix:@"tr"]) {
        languageArray = @[@(CMKeyboardLanguageTypeTurkish)];
    }else if ([preferredLanguage hasPrefix:@"it"]) {
        languageArray = @[@(CMKeyboardLanguageTypeItalian)];
    }else if ([preferredLanguage hasPrefix:@"pl"]) {
        languageArray = @[@(CMKeyboardLanguageTypePolish)];
    }else if ([preferredLanguage hasPrefix:@"ro"]) {
        languageArray = @[@(CMKeyboardLanguageTypeRomanian)];
    }else if ([preferredLanguage hasPrefix:@"nl"]) {
        languageArray = @[@(CMKeyboardLanguageTypeDutch)];
    }else if ([preferredLanguage hasPrefix:@"sk"]) {
        languageArray = @[@(CMKeyboardLanguageTypeSlovak)];
    }else if ([preferredLanguage hasPrefix:@"lv"]) {
        languageArray = @[@(CMKeyboardLanguageTypeLatvian)];
    }else if ([preferredLanguage hasPrefix:@"nb"]) {
        languageArray = @[@(CMKeyboardLanguageTypeNorwegianBokmal)];
    }else if ([preferredLanguage hasPrefix:@"sv"]) {
        languageArray = @[@(CMKeyboardLanguageTypeSwedish)];
    }else if ([preferredLanguage hasPrefix:@"ru"]) {
        languageArray = @[@(CMKeyboardLanguageTypeRussian)];
    }else if ([preferredLanguage hasPrefix:@"be"]) {
        languageArray = @[@(CMKeyboardLanguageTypeBelarusian)];
    }else if ([preferredLanguage hasPrefix:@"uk"]) {
        languageArray = @[@(CMKeyboardLanguageTypeUkrainian)];
    }else if ([preferredLanguage hasPrefix:@"sr"]) {
        languageArray = @[@(CMKeyboardLanguageTypeSerbian)];
    }else if ([preferredLanguage hasPrefix:@"bg"]) {
        languageArray = @[@(CMKeyboardLanguageTypeBulgarian)];
    }else if ([preferredLanguage hasPrefix:@"mk"]) {
        languageArray = @[@(CMKeyboardLanguageTypeMacedonian)];
    }else if ([preferredLanguage hasPrefix:@"ar"]) {
        languageArray = @[@(CMKeyboardLanguageTypeArabic)];
    }else{
        languageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];
    }
    return languageArray;
}

- (NSArray *)configMccLanguage
{
    NSMutableArray * tempArray = nil;
    NSArray * mcclanguageArray = nil;
    NSArray * languageArray = nil;
    NSString *mccString = [CMAppConfig mobileCountryCode];
#ifdef DEBUG
    mccString = self.mccTestString;
#endif
    if ([mccString isEqualToString:@"404"] || [mccString isEqualToString:@"405"] || [mccString isEqualToString:@"406"]) {
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];//en,hi
    }else if ([mccString isEqualToString:@"510"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeIndonesian)];//id,en
    }else if ([mccString isEqualToString:@"334"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeSpanish)];//es,en
    }else if ([mccString isEqualToString:@"515"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeFilipino)];//tl,en
    }else if ([mccString isEqualToString:@"724"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypePortuguese)];//pt,en
    }else if ([mccString isEqualToString:@"520"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];//th,en
    }else if ([mccString isEqualToString:@"250"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeRussian)];//ru,en
    }else if ([mccString isEqualToString:@"310"] || [mccString isEqualToString:@"311"] || [mccString isEqualToString:@"312"] || [mccString isEqualToString:@"313"] || [mccString isEqualToString:@"314"] || [mccString isEqualToString:@"315"] || [mccString isEqualToString:@"316"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeSpanish)];//es,en
    }else if ([mccString isEqualToString:@"452"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];//vi,en
    }else if ([mccString isEqualToString:@"722"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeSpanish)];//es,en
    }else if ([mccString isEqualToString:@"222"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeItalian)];//it,en
    }else if ([mccString isEqualToString:@"502"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeMalay)];//ms,en
    }else if ([mccString isEqualToString:@"262"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeGerman)];//de,en
    }else if ([mccString isEqualToString:@"736"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeSpanish)];//en,es
    }else if ([mccString isEqualToString:@"208"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeFrench)];//fr,en
    }else if ([mccString isEqualToString:@"655"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];//en
    }else if ([mccString isEqualToString:@"732"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),@(CMKeyboardLanguageTypeSpanish)];//es,en
    }else if ([mccString isEqualToString:@"234"]){
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];//en
    }else{
        mcclanguageArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState)];//en
    }
    
    tempArray = [NSMutableArray arrayWithArray:[self configDefaultLanguage]];
    [tempArray addObjectsFromArray:mcclanguageArray];
    languageArray = [[NSSet setWithArray:tempArray] allObjects];
    
    return languageArray;
}

- (void)stop{
//    _currentTheme = nil;
}

- (void)setObject:(nullable id)value forKey:(NSString *)defaultName{
    if(value){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
        [self.shared setObject:data forKey:defaultName];
        
    }else{
        [self.shared setObject:nil forKey:defaultName];
    }
}
- (id)objectForKey:(NSString *)defaultName{
    NSData *data = [self.shared objectForKey:defaultName];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSURL*) Documents{
    if(!_Documents){
        _Documents = [self.containerURL URLByAppendingPathComponent:@"Documents"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_Documents.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_Documents.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _Documents;
}
- (NSURL*) Library{
    if(!_Library){
        _Library = [self.containerURL URLByAppendingPathComponent:@"Library"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_Library.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_Library.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _Library;
}

- (NSURL *)ThemePath {
    if (!_ThemePath) {
        _ThemePath = [self.Library URLByAppendingPathComponent:@"Themes"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_ThemePath.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_ThemePath.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _ThemePath;
}

- (NSURL *)ThemeSoundPath{
    if (!_ThemeSoundPath) {
        _ThemeSoundPath = [self.diyResourcePath URLByAppendingPathComponent:@"ThemeSounds"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_ThemeSoundPath.path]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:_ThemeSoundPath.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _ThemeSoundPath;
}

-(NSURL *)ThemeFontPath{
    if (!_ThemeFontPath) {
        _ThemeFontPath = [self.diyResourcePath URLByAppendingPathComponent:@"ThemeFonts"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_ThemeFontPath.path]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:_ThemeFontPath.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _ThemeFontPath;
}

- (NSURL*) Caches{
    if(!_Caches){
        _Caches = [self.containerURL URLByAppendingPathComponent:@"Library/Caches"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_Caches.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_Caches.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _Caches;
}
- (NSURL*) tmp{
    if(!_tmp){
        _tmp = [self.containerURL URLByAppendingPathComponent:@"tmp"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_tmp.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_tmp.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _tmp;
}

- (NSString*)resourcePath{
    if(!_resourcePath){
        _resourcePath = [self.Documents URLByAppendingPathComponent:@"Theme"].path;
        if(![[NSFileManager defaultManager] fileExistsAtPath:_resourcePath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_resourcePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _resourcePath;
}

- (NSString *)firstLaunchTime{
    return [self.shared objectForKey:kFirstLaunchTime];
}

- (void)setDeviceIdentifier:(NSString *)deviceIdentifier{
    [self.shared setObject:deviceIdentifier forKey:kDeviceIdentifierSetting];
//    [self.shared synchronize];
}
- (NSString *)deviceIdentifier{
    return [self.shared stringForKey:kDeviceIdentifierSetting];
}

- (NSURL *)EmoGifPath{
    if (!_EmoGifPath) {
        _EmoGifPath = [self.Documents URLByAppendingPathComponent:@"EmoGif"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_EmoGifPath.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_EmoGifPath.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _EmoGifPath;
}

- (NSURL *)diyResourcePath
{
    if (!_diyResourcePath) {
        _diyResourcePath = [self.Library URLByAppendingPathComponent:@"DiyThemeResource"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_diyResourcePath.path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:_diyResourcePath.path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _diyResourcePath;
}

- (NSString *)currentThemeName {
#if defined(SCHEME)
    id themeObj = [self.shared objectForKey:kCurrentThemeName];
    if (!themeObj) {
        [self setCurrentThemeName:@"purple_hologram"];
        return @"purple_hologram";
    }
    return [themeObj respondsToSelector:@selector(stringValue)] ? [themeObj stringValue] : themeObj;
#else
    id themeObj = [self.shared objectForKey:kCurrentThemeName];
    if (!themeObj) {
        [self setCurrentThemeName:@"default"];
        return @"default";
    }
    return [themeObj respondsToSelector:@selector(stringValue)] ? [themeObj stringValue] : themeObj;
#endif
}

- (void)setCurrentThemeName:(NSString *)currentThemeName {
    [self.shared setObject:currentThemeName forKey:kCurrentThemeName];
//    [self.shared synchronize];
}

- (BOOL)autoCorrectEnabled{
   return [self.shared boolForKey:kPREF_AUTO_CORRECTION];
}

- (void)setAutoCorrectEnabled:(BOOL)autoCorectEnabled{
    [self.shared setBool:autoCorectEnabled forKey:kPREF_AUTO_CORRECTION];
//    [self.shared synchronize];
}

- (BOOL)isAppFirstInstall
{
    return [self.shared boolForKey:kIS_APP_FIRST_INSTALL];
}

- (void)setIsAppFirstInstall:(BOOL)isAppFirstInstall
{
    [self.shared setBool:isAppFirstInstall forKey:kIS_APP_FIRST_INSTALL];
//    [self.shared synchronize];
}

- (NSInteger)keyboardHideTimes
{
    return [self.shared integerForKey:kKEYBOARD_HIDE_TIMES];
}

- (void)setKeyboardHideTimes:(NSInteger)keyboardHideTimes
{
    [self.shared setInteger:keyboardHideTimes forKey:kKEYBOARD_HIDE_TIMES];
//    [self.shared synchronize];
}

- (NSInteger)keyboardThemeChangeTimes
{
    return [self.shared integerForKey:kKEY_BOARD_BACK_TAP_TIMES];
}

- (void)setKeyboardThemeChangeTimes:(NSInteger)keyboardThemeChangeTimes
{
    [self.shared setInteger:keyboardThemeChangeTimes forKey:kKEY_BOARD_BACK_TAP_TIMES];
//    [self.shared synchronize];
}

- (BOOL)autoCapitalization{
    return [self.shared boolForKey:kPREF_AUTO_CAPITALIZATION];
}

- (void)setAutoCapitalization:(BOOL)autoCapitalization{
    [self.shared setBool:autoCapitalization forKey:kPREF_AUTO_CAPITALIZATION];
//    [self.shared synchronize];
}

-(BOOL)useDoubleSpacePeriod{
    return [self.shared boolForKey:kPREF_KEY_USE_DOUBLE_SPACE_PERIOD];
}

- (void)setUseDoubleSpacePeriod:(BOOL)useDoubleSpacePeriod{
    
    [self.shared setBool:useDoubleSpacePeriod forKey:kPREF_KEY_USE_DOUBLE_SPACE_PERIOD];
//    [self.shared synchronize];
}

- (BOOL)showCorrection{
    return [self.shared boolForKey:kPREF_SHOW_CORRECTION];

}

- (void)setShowCorrection:(BOOL)showCorrection{
    [self.shared setBool:showCorrection forKey:kPREF_SHOW_CORRECTION];
//    [self.shared synchronize];
}

- (BOOL)showPrediction{
    return [self.shared boolForKey:kPREF_SHOW_PREDICTION];
}

- (void)setShowPrediction:(BOOL)showPrediction{
    [self.shared setBool:showPrediction forKey:kPREF_SHOW_PREDICTION];
//    [self.shared synchronize];
}

- (BOOL)historySuggestions{
    return [self.shared boolForKey:kPREF_HISTORY_ON];
}

-(void)setHistorySuggestions:(BOOL)historySuggestions{
    [self.shared setBool:historySuggestions forKey:kPREF_HISTORY_ON];
//    [self.shared synchronize];
}

- (BOOL)isSlideInputEnable {
#if defined(SCHEME)
    return NO;
#else
    id configObj = [self.shared objectForKey:kPrefKeyIsSlideInputEnable];
    if (!configObj) {
        [self setSlideInputEnable:YES];
        return YES;
    }
    return [configObj boolValue];
#endif
}

- (void)setSlideInputEnable:(BOOL)slideInputEnable {
#if defined(SCHEME)
    [self.shared setBool:NO forKey:kPrefKeyIsSlideInputEnable];
    [self.shared synchronize];
#else
    [self.shared setBool:slideInputEnable forKey:kPrefKeyIsSlideInputEnable];
//    [self.shared synchronize];
#endif
}

#ifdef DEBUG
- (BOOL)isTensorFlowABTestEnable {
    id configObj = [self.shared objectForKey:kPrefKeyIsTensorFlowEnable];
    if (!configObj) {
        [self setTensorFlowABTestEnable:YES];
        return YES;
    }
    return [configObj boolValue];
}

- (void)setTensorFlowABTestEnable:(BOOL)tensorFlowABTestEnable {
    [self.shared setBool:tensorFlowABTestEnable forKey:kPrefKeyIsTensorFlowEnable];
//    [self.shared synchronize];
}
#endif

- (NSArray *)languageArray {
    return [self.shared objectForKey:kLANGUAGE_ARRAY];
}

- (void)setLanguageArray:(NSArray *)languageArray {
    [self.shared setObject:languageArray forKey:kLANGUAGE_ARRAY];
//    [self.shared synchronize];
}

- (NSArray *)recentlyEmoji
{
    return [self.shared objectForKey:kRECENTLY_EMOJI];
}

- (void)setRecentlyEmoji:(NSArray *)recentlyEmoji
{
    [self.shared setObject:recentlyEmoji forKey:kRECENTLY_EMOJI];
//    [self.shared synchronize];
}

- (NSArray *)recentlyGif{
    if(!_gifSendRecent){
        NSString *tmpDir =  [self.Documents.path stringByAppendingPathComponent:@"cmcm.giphyData"];
        _gifSendRecent = [NSKeyedUnarchiver unarchiveObjectWithFile:[tmpDir stringByAppendingPathComponent:@"emoji_gif_send_recent"]];
    }
    return _gifSendRecent;
}

-(void)setRecentlyGif:(NSArray *)recentlyGif{
    if(recentlyGif.count < 1)return;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager] ;
    NSString *tmpDir =  [self.Documents.path stringByAppendingPathComponent:@"cmcm.giphyData"];
    if(![fileMgr fileExistsAtPath:tmpDir]){
        [fileMgr createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [NSKeyedArchiver archiveRootObject:recentlyGif toFile:[tmpDir stringByAppendingPathComponent:@"emoji_gif_send_recent"]];
    _gifSendRecent = recentlyGif;
}


- (NSTimeInterval)othersKeyboardTimestamp
{
    return [self.shared doubleForKey:kOTHERS_KEYBOARD_TIMESTAMP];
}

- (void)setOthersKeyboardTimestamp:(NSTimeInterval)othersKeyboardTimestamp
{
    [self.shared setDouble:othersKeyboardTimestamp forKey:kOTHERS_KEYBOARD_TIMESTAMP];
//    [self.shared synchronize];
}

// 云控相关
- (NSString *)cloudConfigVer {
    return [self.shared stringForKey:kCloudVersion];
}

- (void)setCloudConfigVer:(NSString *)cloudConfigVer {
    if ([NSString stringIsEmpty:cloudConfigVer]) {
        return;
    }
    [self.shared setObject:cloudConfigVer forKey:kCloudVersion];
//    [self.shared synchronize];
}

- (NSString *)cloudAppVer {
    return [self.shared stringForKey:kCloudAppVersion];
}

- (void)setCloudAppVer:(NSString *)cloudAppVer {
    if ([NSString stringIsEmpty:cloudAppVer]) {
        return;
    }
    [self.shared setObject:cloudAppVer forKey:kCloudAppVersion];
//    [self.shared synchronize];
}

- (NSString *)cloudAppLang {
    return [self.shared stringForKey:kCloudAppLanguage];
}

- (void)setCloudAppLang:(NSString *)cloudAppLang {
    if ([NSString stringIsEmpty:cloudAppLang]) {
        return;
    }
    [self.shared setObject:cloudAppLang forKey:kCloudAppLanguage];
//    [self.shared synchronize];
}

- (NSDictionary *)cloudConfigDic {
    return [self.shared dictionaryForKey:kCloudConfigInfoDic];
}

- (void)setCloudConfigDic:(NSDictionary *)cloudConfigDic {
    if (!cloudConfigDic) {
        return;
    }
    [self.shared setObject:cloudConfigDic forKey:kCloudConfigInfoDic];
//    [self.shared synchronize];
}

- (NSDate *)lastCloudFetchDate {
    id date = [self.shared objectForKey:kCloudFetchTimestampKey];
    return date ? date : [NSDate dateWithTimeIntervalSince1970:0];
}

- (void)setLastCloudFetchDate:(NSDate *)lastCloudFetchDate {
    [self.shared setObject:lastCloudFetchDate forKey:kCloudFetchTimestampKey];
//    [self.shared synchronize];
}

- (NSDate *)lastVerifyRIAPPDate {
    id date = [self.shared objectForKey:kVerifyIappDate];
    return date ? date : [NSDate dateWithTimeIntervalSince1970:0];
}

- (void)setLastVerifyRIAPPDate:(NSDate *)lastVerifyRIAPPDate
{
    [self.shared setObject:lastVerifyRIAPPDate forKey:kVerifyIappDate];
    [self.shared synchronize];
}

#pragma mark - Add by Niecongcong Beign

- (BOOL)isShowedKeyboardFirstTime
{
    return [self.shared boolForKey:kIS_SHOW_KEYBOARD_FIRST];
}

- (void)setIsShowedKeyboardFirstTime:(BOOL)isShowedKeyboardFirstTime
{
    [self.shared setBool:isShowedKeyboardFirstTime forKey:kIS_SHOW_KEYBOARD_FIRST];
//    [self.shared synchronize];
}

-  (NSString*) isOpenFullAccessByContainer
{
    return [self.shared objectForKey:kFOR_KEYBOARD];
}

-  (NSString*) isOpenFullAccessByKeyboard
{
    return [self.shared objectForKey:kFOR_CONTAINER];
}

- (void)setIsOpenFullAccessByContainer:(NSString *)isOpenFullAccessByContainer
{
    [self.shared setObject:@"From Container" forKey:kFOR_CONTAINER];
//    [self.shared synchronize];
}

- (void) setIsOpenFullAccessByKeyboard:(NSString *)isOpenFullAccessByKeyboard
{
    [self.shared setObject:@"From Keyboard" forKey:kFOR_KEYBOARD];
//    [self.shared synchronize];
}



#pragma mark - Add by Niecongcong End


- (CMKeyboardLanguageType)languageType
{
    return (CMKeyboardLanguageType)[self.shared integerForKey:kPREF_KEY_LANGUAGE_TYPE];
}

- (void)setLanguageType:(CMKeyboardLanguageType)languageType
{
    [self.shared setInteger:languageType forKey:kPREF_KEY_LANGUAGE_TYPE];
//    [self.shared synchronize];
}

#pragma mark - Add by zhanglu
- (void)setOpenKeyboardSound:(BOOL)openKeyboardSound
{
    [self.shared setBool:openKeyboardSound forKey:kSETTING_KEYBOARD_SOUND];
//    [self.shared synchronize];
}

- (BOOL)openKeyboardSound
{
    id configObj = [self.shared objectForKey:kSETTING_KEYBOARD_SOUND];
    if (!configObj) {
//        if (IOS9_OR_LATER) {
//            [self setOpenKeyboardSound:YES];
//            return YES;
//        }
        [self setOpenKeyboardSound:NO];
        return NO;
    }
    return [configObj respondsToSelector:@selector(boolValue)] ? [configObj boolValue] : YES;
}

- (BOOL)vibrationEnable {
    return [self.shared boolForKey:kTapVibrationKey];
}

- (void)setVibrationEnable:(BOOL)vibrationEnable {
    [self.shared setBool:vibrationEnable forKey:kTapVibrationKey];
//    [self.shared synchronize];
}

- (void)setVolume:(float)volume
{
    [self.shared setFloat:volume forKey:kSETTING_KEYBOARD_VOLUME];
//    [self.shared synchronize];
}

- (float)volume
{
    return [self.shared floatForKey:kSETTING_KEYBOARD_VOLUME];
}

- (void)setIsShowingCloudPredictTip:(BOOL)isShowingCloudPredictTip
{
    [self.shared setBool:isShowingCloudPredictTip forKey:kIsShowingCloudPredictTip];
//    [self.shared synchronize];
}

- (BOOL)isShowingCloudPredictTip
{
    return [self.shared boolForKey:kIsShowingCloudPredictTip];
}

- (BOOL)isShowNewMarkOnSettingIconByCustomTheme
{
    BOOL bTemp = [self.shared boolForKey:kIS_SHOW_NEW_MARK_ON_SETTING_ICON_BY_CUSTOM_THEME];
    return bTemp;
}

- (void)setIsShowNewMarkOnSettingIconByCustomTheme:(BOOL)isShowNewMarkOnSettingIconByCustomTheme
{
    [self.shared setBool:isShowNewMarkOnSettingIconByCustomTheme forKey:kIS_SHOW_NEW_MARK_ON_SETTING_ICON_BY_CUSTOM_THEME];
    [self.shared synchronize];
}

- (BOOL)isShowRedRoundMarkOnCustomThemeButton
{
    BOOL bTemp = [self.shared boolForKey:kIS_SHOW_REDROUND_MARK_ON_CUSTOM_THEME_BUTTOM];
    return bTemp;
}

- (void)setIsShowRedRoundMarkOnCustomThemeButton:(BOOL)isShowRedRoundMarkOnCustomThemeButton
{
    [self.shared setBool:isShowRedRoundMarkOnCustomThemeButton forKey:kIS_SHOW_REDROUND_MARK_ON_CUSTOM_THEME_BUTTOM];
    [self.shared synchronize];
}

- (BOOL)hasPurchasedIAP
{
    BOOL bTemp = [self.shared boolForKey:kIS_HAS_PURCHASED_IAPP];
    BOOL flag = bTemp;
    NSLog(flag ? @"lxm hasPurchasedIAP = Yes" : @"lxm hasPurchasedIAP = No");
    return bTemp;
}

- (void)setHasPurchasedIAP:(BOOL)hasPurchasedIAP
{
    [self.shared setBool:hasPurchasedIAP forKey:kIS_HAS_PURCHASED_IAPP];
    [self.shared synchronize];
    BOOL flag = hasPurchasedIAP;
    NSLog(flag ? @"lxm sethasPurchasedIAP = Yes" : @"lxm sethasPurchasedIAP = No");
}

-(NSData *)purchasedIAPReceipt{
    NSData* bTemp = [self.shared objectForKey:kIS_HAS_PURCHASED_IAPP_RECEIPT];
    return bTemp;
}

- (void)setPurchasedIAPReceipt:(NSData *)purchasedIAPReceipt
{
    [self.shared setObject:purchasedIAPReceipt forKey:kIS_HAS_PURCHASED_IAPP_RECEIPT];
    [self.shared synchronize];
}

#pragma mark - Add by zhanglu end

#ifdef DEBUG
-(NSString *)mccTestString
{
    return [self.shared objectForKey:kMccTestKey];
}
-(void)setMccTestString:(NSString *)mccTestString
{
    [self.shared setObject:mccTestString forKey:kMccTestKey];
    [self.shared synchronize];
}
#endif
@end
