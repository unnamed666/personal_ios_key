//
//  UserDefaultsMacro.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#ifndef UserDefaultsMacro_h
#define UserDefaultsMacro_h

#import "CMError.h"

typedef void(^CMCompletionBlock)(CMError* error);


#define kGlobalUserDefaultsCloudPredictionSupportLan              @"kGlobalUserDefaultsCloudPredictionSupportLan"
#define kGlobalUserDefaultsCloudPredictionConfigServerRequstTime              @"kGlobalUserDefaultsCloudPredictionConfigServerRequstTime"
#define kGlobalUserDefaultsCloudPredictionAddres              @"kGlobalUserDefaultsCloudPredictionAddres"
#define kGlobalUserDefaultsFullAccessFirstDate                  @"full_access_first_date_"
#define kGlobalUserDefaultsFullAccessTodayDate                  @"full_access_today_date_"
#define kHasShowedLongPressSpaceTip                             @"hasShowedLongPressSpaceTip"
#define kHasShowedCloudPredictedTip                       @"hasShowedCloudPredictedTip"
#define kThemeNewIconDate                                 @"theme_new_icon_date"
#define kShouldShowThemeNewIcon                           @"shouldShowThemeNewIcon"
#define kThemeNewIconFirstShake                           @"themeNewIconFirstShake"
#define kThemeNewIconLastShakeTime                        @"themeNewIcon_LastShake_Time"
#define kShouldShowDeleteAllSuggest                       @"shouldShowDeleteAllSuggest"
#define kDeleteAllSuggestHasClicked                       @"deleteAllSuggest_HasClicked"

#define kLastKeyboardAnimationTime                                 @"last_Keyboard_Animation_Time" // 上一次键盘弹出动画展示的时间
#define kLastIsRecentlyEmojiSection                       @"lastIsRecentlyEmojiSection"
#define kEmojiEmoticonIndex                       @"Emoji_Emoticon_Index"//记录 emoji 界面先显示 emoji 还是先显示 emoticon

#define kMainBoardEmojiClick                           @"main_board_emoji_click"//主面板 emoji 按钮点击过
#define kEmojiBoardEmoticonClick                           @"emoji_board_emoticon_click"//emoticon  按钮点击过
#define kEmojiBoardGifSegmentClick                           @"emoji_board_gif_Segment_click"//gif  按钮点击过

#define kCurrentAppVersion                                 @"current_appversion" // 记录当前版本号到userdefault里，用于判断是否全新安装或者进行覆盖安装的逻辑, 1.5.0开始记录
#define kPreviousAppVersion          @"previous_appversion" // 记录当前版本号到userdefault里，得到升级上来的版本号，新用户为nil 1.7.0开始记录
#define kCursorMoveUseCount                                @"cursor_move_use_count"// 光标移动功能使用次数（两次以后不再展示光标移动功能引导文案）
#define kHasShowedFullAccessTipForCursorMove                @"has_show_full_access_tip_for_cursor_move"
#define kHasShowedSplashFunctionGuide                 @"has_show_splash_function_guide"
#define kIsShowCustomThemeRedRoundMarkOnContainerApp                @"is_Show_Custom_Theme_Red_Round_Mark"
#endif /* UserDefaultsMacro_h */
