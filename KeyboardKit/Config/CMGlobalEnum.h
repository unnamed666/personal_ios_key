//
//  CMGlobalEnum.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/10.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#ifndef CMGlobalEnum_h
#define CMGlobalEnum_h

typedef NS_ENUM(NSUInteger, CMPageIdentify) {
    CMPageIdentify_OpenApp = 0,
    CMPageIdentify_ThemeCenter = 1,
    CMPageIdentify_SettingCenter = 2,
    CMPageIdentify_Language = 3,// 语言设置页
    CMPageIdentify_Feedback = 4,
    CMPageIdentify_AREmoticon = 5,
    CMPageIdentify_SwitchKeyboard = 6,
    CMPageIdentify_AddKeyboard = 7,
    CMPageIdentify_FullAccessGuide = 8,
    CMPageIdentify_About = 9,
    CMPageIdentify_AREmoticonPreview = 10,
    CMPageIdentify_Privacy = 11,
    CMPageIdentify_TextCorrect = 12,
    CMPageIdentify_Preference = 13,
    CMPageIdentify_DiyTheme = 14,
};

typedef NS_ENUM(int, KeyboardShiftState) {
    KeyboardShiftStateAlpha = 1,
    KeyboardShiftStateManualShiftedAlpha,
    KeyboardShiftStateAutomaticShiftedAlpha,
    KeyboardShiftStateShiftedLockAlpha,
};

/*
 ar Arabic 阿拉伯语
 hy Armenian 亚美尼亚语
 bn Bengali 孟加拉语
 bg
 sr Cyrillic 西里尔(Cyril)字母
 ru
 ka Georgian 格鲁吉亚语
 el Greek 希腊语
 iw Hebrew 希伯来语
 km Khmer 高棉语
 lo Lao 老挝???
 ml Malayalam 马拉雅拉姆语 印度西南部的 Dravidian 语的一方言
 my Myanmar 缅甸
 si Sinhala 僧伽罗语
 ta Tamil 泰米尔语
 te Telugu 泰卢固语 (印度东部德拉维拉语言）
 th Thai 泰国
 
 这些语言 isLetterPartOfScriptWithcodePoint 函数需要特殊处理
 */
typedef NS_ENUM(NSInteger, CMKeyboardLanguageType) {
    CMKeyboardLanguageTypeUndefined          = -1,
    CMKeyboardLanguageTypeEnglishUnitedState    , // 英语（美国）
    CMKeyboardLanguageTypeSpanish               , // 西班牙语
    CMKeyboardLanguageTypeIndonesian            , // 印尼语
    CMKeyboardLanguageTypeAzerbaijani           , // 阿塞拜疆语
    CMKeyboardLanguageTypeCatalan               , // 加泰罗尼亚文
    CMKeyboardLanguageTypeCzech                 , // 捷克语
    CMKeyboardLanguageTypeDanish                , // 丹麦语
    CMKeyboardLanguageTypeGerman                , // 德语
    CMKeyboardLanguageTypeEstonian              , // 爱沙尼亚语
    CMKeyboardLanguageTypeFinnish               , // 芬兰语
    CMKeyboardLanguageTypeFrench                , // 法语
    CMKeyboardLanguageTypeCroatian              , // 克罗地亚语
    CMKeyboardLanguageTypeHungarian             , // 匈牙利语
    CMKeyboardLanguageTypePortuguese            , // 葡萄牙语
    CMKeyboardLanguageTypeMalay                 , // 马来语
    CMKeyboardLanguageTypeFilipino              , // 菲律宾文
    CMKeyboardLanguageTypeTurkish               , // 土耳其语
    CMKeyboardLanguageTypeItalian               , // 意大利语
    CMKeyboardLanguageTypePolish                , // 波兰语
    CMKeyboardLanguageTypeRomanian              , // 罗马尼亚语
    CMKeyboardLanguageTypeDutch                 , // 荷兰语
    CMKeyboardLanguageTypeSlovak                , // 斯洛伐克语
    CMKeyboardLanguageTypeLatvian               , // 拉脱维亚语
    CMKeyboardLanguageTypeNorwegianBokmal       , // 挪威博克马尔文
    CMKeyboardLanguageTypeSwedish               , // 瑞典语
    
    CMKeyboardLanguageTypeRussian               , // 俄语
    CMKeyboardLanguageTypeBelarusian               , // 白俄罗斯语
    CMKeyboardLanguageTypeUkrainian               , // 乌克兰语
    CMKeyboardLanguageTypeSerbian               , // 塞尔维亚语
    CMKeyboardLanguageTypeBulgarian               , // 保加利亚语
    CMKeyboardLanguageTypeMacedonian               , // 马其顿语
    CMKeyboardLanguageTypeArabic                   , // 阿拉伯语
};

#endif /* CMGlobalEnum_h */
