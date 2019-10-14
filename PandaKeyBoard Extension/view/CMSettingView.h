//
//  CMSettingView.h
//  PandaKeyboard
//
//  Created by duwenyan on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseKeyboardView.h"

@class CMSettingView;

@protocol CMSettingViewDelegate <NSObject>

@required
- (void)onSettingViewLanguageBtnTapped:(CMSettingView *)settingView;

- (void)onSettingViewFeedbackBtnTapped:(CMSettingView *)settingView;

- (void)onSettingViewSoundBtnTapped:(CMSettingView *)settingView;// 点击设置页面声音按钮

- (void)onSettingViewSoundBtnTapped:(CMSettingView *)settingView openKeyboardSound:(BOOL)openKeyboardSound;// 点击声音开关按钮

- (void)onSettingView:(CMSettingView *)settingView vibrationBtnTapped:(BOOL)enable;// 点击键盘振动开关

- (void)onSettingViewSoundVolumeChanged:(CMSettingView *)settingView volume:(float)volume;

- (void)onSettingViewRateUsBtnTapped:(CMSettingView *)settingView;

- (void)onSettingViewAutoCapsBtnTapped:(CMSettingView *)settingView;

- (void)onSettingViewSettingBtnTapped:(CMSettingView *)settingView;

- (void)onSettingViewGesureTypingBtnTapped:(CMSettingView *)settingView;

- (void)onSettingViewDiyBtnTapped:(CMSettingView *)settingView;

@end


@interface CMSettingView : UIView

@property (nonatomic, weak) id<CMSettingViewDelegate> pDelegate;

@property (nonatomic, copy)NSString* layoutId; //从设置键盘返回时要回到的键盘类型

@end
