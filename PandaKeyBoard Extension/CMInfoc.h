//
//  CMInfoc.h
//  PandaKeyboard
//
//  Created by wolf on 2017/6/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSInteger, CMCType) {
//    CMCTypeUserType = 0,
//    CMCTypeCorrection,
//    CMCTypePrediction,
//    CMCTypeEmojiPredict,
//    CMCTypeGesture          // 滑动输入
//};

@interface CMInfoc : NSObject

+ (void) activeReport:(UIKeyboardType)keyboardType language:(NSString*)lang dictver:(int)dicter themeName:(NSString*)themeName;


/**
 Emoji界面的显示

 @param source 1-从工具栏icon进入的Emoji界面
               2-从预测栏最右侧的Emoji入口进入的界面
               3-长按空格键出Emoji
 */
+ (void)reportEmojiShow:(NSUInteger)source class:(int)classValue;


/**
 Emoji界面的显示
 
 @param source 1-从工具栏icon进入的Emoji界面
               2-从预测栏最右侧的Emoji入口进入的界面
               3-长按空格键成功发送Emoji
 */
+ (void)reportEmojiTapped:(NSUInteger)source emoji:(NSString *)emoji;

// 键盘收起按键的点击
+ (void)reportKeyboardDismissBtnTap;


// 键盘切换按键的点击
+ (void)reportSwitchKeyboardKeyTap;

// 单词上报
+ (void)reportCheetahKeyboard_word:(NSString *)iWord cWord:(NSString *)cWord cType:(int)cType dType:(int)dType inputType:(UIKeyboardType)inputType language:(NSString *)lang dictver:(int)dicter;

// 句子上报
+ (void)reportCheetahKeyboard_sentence:(NSString *)sentence language:(NSString *)lang inputType:(UIKeyboardType)inputType dictver:(int)dicter;

/**
 FullAccess显示消息提醒上报

 @param value 消息提醒弹出的内容：
                1- 设置引导Full Access
                2- 引导设置Full Access（声音）
 */
+ (void)reportCheetahkeyboard_tip_showWithValue:(NSInteger)value;

/**
 FullAccess点击消息提醒

 @param value 消息提醒弹出的内容：
                1- 设置引导Full Access
                2- 引导设置Full Access（声音）
 */
+ (void)reportCheetahkeyboard_tip_clickWithValue:(NSInteger)value;

/**
 FullAccess关闭消息提醒

 @param value 消息提醒弹出的内容：
                1- 设置引导Full Access
                2- 引导设置Full Access（声音）
 @param closeType  关闭消息提醒的方法：
                    1- 用户未操作，超时自动关闭
                    2- 向上滑动关闭
                    3- 若有关闭按钮，点击关闭按钮进行关闭
 */
+ (void)reportCheetahkeyboard_tip_closeWithValue:(NSInteger)value closeType:(NSInteger)closeType;


/**
 点击设置icon时

 @param value 1- 点击（打开面板）
              2- 点击（收起面板）
 @param inputType 输入框类型
 */
+ (void)reportCheetahkeyboard_setting_click:(NSInteger)value inputType:(NSInteger)inputType;


/**
 点击设置面板内的入口

 @param value   1- 语言   2- 声音   3- 自动切换大写（开）    4- 自动切换小写（关）    5- 滑动输入（关）  6- 互动输入（开）  7- rate us  8- feedback 9- settings 10- 声音（开）   11- 声音（关）
 12 - 振动开关（打开）1.6.0  13 - 振动开关（关闭）1.6.0
 @param inputType 输入框类型
 */
+ (void)reportCheetahkeyboard_setting_fun_click:(NSInteger)value inputType:(NSInteger)inputType;


/**
 点击移动光标的icon
 
 @param value 1- 点击（打开光标功能）
              2- 点击 (收起光标功能)
 @param inputType 输入框类型
 */
+(void)reportCheetahKeyboard_cursor_click:(NSInteger)value inputType:(NSInteger)inputType;


/**
 移动光标
 
 @param value 1- 滑动光标
 @param inputType 输入框类型
 */

+(void)reportCheetahKeyboard_cursor_action:(NSInteger)value inputType:(NSInteger)inputType;

+(void)reportCheetahkeyboard_input_str:(NSString *)value lang:(NSString *)lang inputType:(NSInteger)inputType;

+(void)reportCheetahkeyboard_input_str_clo:(NSString *)lang inputType:(NSInteger)inputType;

// 1.11
+ (void)report_cheetahkeyboard_switch:(NSInteger)value;

// 1.12
+ (void)report_cheetahkeyboard_emoji_switch:(NSInteger)value;
@end








