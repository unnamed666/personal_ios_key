//
//  CMToolBarView.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/13.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMToolBarView.h"
#import "UIView+Util.h"
#import "UIImage+Util.h"
#import "UIButton+Util.h"
#import "CMGroupDataManager.h"
#import "NSDictionary+Common.h"
#import "NSString+Common.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "CMRowView.h"
#import "CMKeyButton.h"
#import "UIView+Animate.h"
#import "UIDevice+Util.h"
#import "UIView+Shake.h"
#ifndef HostApp
#import "CMInfoc.h"
#import "CMCloudConfig.h"
#endif
@interface CMToolBarView ()
@property (nonatomic, strong)UIView* animationView;
@property (nonatomic, strong)UIButton* settingBtn;
@property (nonatomic, strong)UIButton* themeBtn;
@property (nonatomic, strong)UIButton* emojiBtn;
@property (nonatomic, strong)UIButton* cursorMoveBtn;

@property (nonatomic, strong)UIButton* dismissBtn;

//@property (nonatomic, strong)UIImageView* bgImageView;

@property (nonatomic, strong)UIImageView * themeNewIconView;
@property (nonatomic, strong)UIImageView * settingNewIconView;
@property (nonatomic, assign) BOOL isAfterOneHour;

@end

@implementation CMToolBarView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.bgImageView];
        [self addSubview:self.animationView];
        [self.animationView addSubview:self.emojiBtn];
        [self.animationView addSubview:self.dismissBtn];
        [self.animationView addSubview:self.cursorMoveBtn];
        
        [self cloudConfigUpdate];
        
        if ([kCMGroupDataManager isShowNewMarkOnSettingIconByCustomTheme])
        {
            [self.animationView addSubview:self.settingNewIconView];
        }
        
        if ([self canShowTipForOneDayNotFirst])
        {
            //除第一天不展示，24小时就展示
            [self.animationView addSubview:self.themeNewIconView];
            
            if ([self themeNewIconCanShake] == YES) {
                [self performSelector:@selector(themeNewIconShake) withObject:nil afterDelay:0.5];
            }
            #ifndef HostApp
            [CMInfoc reportCheetahkeyboard_tip_showWithValue:5];
            #endif
        }
        else
        {
            //每个生命周期，展示过就展示，没展示过就不展示
#ifndef HostApp
            if (_isAfterOneHour == YES)
            {
                [CMInfoc reportCheetahkeyboard_tip_closeWithValue:5 closeType:1];
            }
#endif
        }
       
    }
    return self;
}

//+ (BOOL)requiresConstraintBasedLayout {
//    return NO;
//}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.bgImageView.frame = self.bounds;
    self.animationView.frame = self.bounds;
    
    UIView* lastView = nil;
    if (self.settingBtn.superview) {
        //self.settingBtn.width = 37.0f;
        //self.settingBtn.height = 27.0f;
        self.settingBtn.size = kCMKeyboardManager.themeManager.settingImage.size;
        self.settingBtn.left = self.bounds.origin.x + 10;
        self.settingBtn.centerY = self.bounds.origin.y + self.height/2;
        lastView = self.settingBtn;
    }
    
    if (self.themeBtn.superview) {
        //self.themeBtn.width = 37.0f;
        //self.themeBtn.height = 27.0f;
        self.themeBtn.size = kCMKeyboardManager.themeManager.themeImage.size;
        self.themeBtn.left = lastView ? lastView.right + 20 : self.bounds.origin.x + 20;
        self.themeBtn.centerY = self.bounds.origin.y + self.height/2;
        lastView = self.themeBtn;
    }
    
    if (self.emojiBtn.superview) {
        //self.emojiBtn.width = 37.0f;
        //self.emojiBtn.height = 27.0f;
        self.emojiBtn.size = kCMKeyboardManager.themeManager.emojiImage.size;
        self.emojiBtn.left = lastView ? lastView.right + 20 : self.bounds.origin.x + 20;
        self.emojiBtn.centerY = self.bounds.origin.y + self.height/2;
        UIView * redDot =  [_emojiBtn viewWithTag:100];
        if(redDot){
            redDot.frame = CGRectMake(CGRectGetWidth(_emojiBtn.frame)-6, 0, 6, 6);
        }
        lastView = self.emojiBtn;
    }
    
    if (self.cursorMoveBtn.superview) {
        self.cursorMoveBtn.size = self.cursorMoveBtn.currentImage.size;
        self.cursorMoveBtn.left = lastView ? lastView.right + 20 : self.bounds.origin.x + 20;
        self.cursorMoveBtn.centerY = self.bounds.origin.y + self.height/2;
        lastView = self.cursorMoveBtn;
    }
    
    if (self.dismissBtn.superview) {
        [self.dismissBtn sizeToFit];
        self.dismissBtn.right = self.bounds.origin.x + self.width - 15;
        self.dismissBtn.centerY = self.bounds.origin.y + self.height/2;
    }
    
    if (self.themeNewIconView.superview) {
        [self.themeNewIconView sizeToFit];
        self.themeNewIconView.top = self.themeBtn.top - 6;
        self.themeNewIconView.left = self.themeBtn.right - 6;
        self.themeNewIconView.size = CGSizeMake(23, 13);
    }
    
    if (self.settingNewIconView.superview) {
        [self.settingNewIconView sizeToFit];
        self.settingNewIconView.top = self.settingBtn.top - 6;
        self.settingNewIconView.left = self.settingBtn.right - 6;
        self.settingNewIconView.size = CGSizeMake(23, 13);
    }
    
    if ([CMKeyboardManager sharedInstance].needKeyboardExpandAnimation) {
        CGFloat keyboardHeight = 0.0f;
        keyboardHeight = [CMKeyboardManager keyboardHeight];
                
        [self.animationView verticalMoveAnimationFromCenterY:self.animationView.centerY + keyboardHeight / 2 - keyboardHeight / 2 * KeyboardExpandOriginalScale
                                                    duration:KeyboardExpandAnimationTime
                                              timingFunction:KeyboardExpandTimingFunction];
    }
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

-(void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(themeNewIconShake) object:nil];
}

- (void)cloudConfigUpdate {
    //    BOOL showSetting = [CMCloudConfigHelper getCloudBoolValue:3 section:@"ex_toolbar_setting_button" key:@"isShow" defValue:NO];
    //    BOOL showTheme = [CMCloudConfigHelper getCloudBoolValue:3 section:@"ex_toolbar_theme_button" key:@"isShow" defValue:NO];
    BOOL showSetting = YES;
    BOOL showTheme = YES;
    if (showSetting && !self.settingBtn.superview) {
        [self.animationView addSubview:self.settingBtn];
    }
    else if (!showSetting && self.settingBtn.superview) {
        [self.settingBtn removeFromSuperview];
    }
    
    if (showTheme && !self.themeBtn.superview) {
        [self.animationView addSubview:self.themeBtn];
    }
    else if (!showTheme && self.themeBtn.superview) {
        [self.themeBtn removeFromSuperview];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)switchTheme{
#ifndef HostApp
    if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
        [_settingBtn setImage:kCMKeyboardManager.themeManager.settingImage forState:UIControlStateNormal];
    }else{
        [_settingBtn setImage:[[UIImage imageNamed:@"toolbar_setting_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
    }
    
    if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
        [_themeBtn setImage:kCMKeyboardManager.themeManager.themeImage forState:UIControlStateNormal];
    }else{
        [_themeBtn setImage:[[UIImage imageNamed:@"toolbar_skin_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
    }
    
    if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
        [_emojiBtn setImage:kCMKeyboardManager.themeManager.emojiImage forState:UIControlStateNormal];
    }else{
        [_emojiBtn setImage:[[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
    }
     UIImage *image = nil;
    if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"]) {
        image = [UIImage imageNamed:@"toolbar_cursor_default_icon"];
    }else if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"])
    {
        image = [UIImage imageNamed:@"toolbar_cursor_hologram_icon"];
    }else{
        image = [[UIImage imageNamed:@"toolbar_cursor_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
    }
#else
    [_settingBtn setImage:[[UIImage imageNamed:@"toolbar_setting_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
    [_themeBtn setImage:[[UIImage imageNamed:@"toolbar_skin_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
    [_emojiBtn setImage:[[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
     UIImage *image = nil;
    image = [[UIImage imageNamed:@"toolbar_cursor_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
    [_cursorMoveBtn setImage:image forState:UIControlStateNormal];
#endif
    [_dismissBtn setImage:[[UIImage imageNamed:@"btn_keyboard_dismiss"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
}
-(void)removeEmojiRedPoint{
    UIView * redDot =  [_emojiBtn viewWithTag:100];
    if(redDot){
        [redDot removeFromSuperview];
    }
}

#pragma mark - setter/getter
- (UIView *)animationView
{
    if (!_animationView) {
        _animationView = [UIView new];
        _animationView.backgroundColor = [UIColor clearColor];
    }
    return _animationView;
}

//- (UIImageView *)bgImageView {
//    if (!_bgImageView) {
//        _bgImageView = [UIImageView new];
//        UIImage* image = kCMKeyboardManager.themeManager.predictViewBgImage;
////        [_bgImageView setBackgroundColor:[UIColor greenColor]];
//        if (image == nil) {
//            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.predictViewBgColor];
//        }
//        else {
//            [_bgImageView setImage:image];
//        }
//    }
//    return _bgImageView;
//}

- (UIButton *)settingBtn {
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
#ifndef HostApp
        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
            [_settingBtn setImage:kCMKeyboardManager.themeManager.settingImage forState:UIControlStateNormal];
        }else{
            [_settingBtn setImage:[[UIImage imageNamed:@"toolbar_setting_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
        }
#else
            [_settingBtn setImage:[[UIImage imageNamed:@"toolbar_setting_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
#endif
        [_settingBtn addTarget:self action:@selector(handleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
#ifdef DEBUG
        [_settingBtn addTarget:self action:@selector(handleBtnDownRepeatTapped:) forControlEvents:UIControlEventTouchDownRepeat];
#endif
    }
    return _settingBtn;
}

- (UIButton *)themeBtn {
    if (!_themeBtn) {
        _themeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        #ifndef HostApp
        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
        [_themeBtn setImage:kCMKeyboardManager.themeManager.themeImage forState:UIControlStateNormal];
        }else{
            [_themeBtn setImage:[[UIImage imageNamed:@"toolbar_skin_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
        }
#else
            [_themeBtn setImage:[[UIImage imageNamed:@"toolbar_skin_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
#endif
        [_themeBtn addTarget:self action:@selector(handleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _themeBtn;
}

- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
#ifndef HostApp
        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
        [_emojiBtn setImage:kCMKeyboardManager.themeManager.emojiImage forState:UIControlStateNormal];
        }else{
            [_emojiBtn setImage:[[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
        }
        BOOL emotionClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardEmoticonClick];
        BOOL gifClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardGifSegmentClick];
        if(!(emotionClick && gifClick)){
            UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
            v.tag = 100;
            v.backgroundColor = [UIColor redColor];
            v.layer.cornerRadius = 3;
            [_emojiBtn addSubview:v];
        }
#else
        [_emojiBtn setImage:[[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
#endif
        [_emojiBtn addTarget:self action:@selector(handleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
}

- (UIButton *)cursorMoveBtn {
    if (!_cursorMoveBtn) {
        _cursorMoveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = nil;
#ifndef HostApp
        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"]) {
            image = [UIImage imageNamed:@"toolbar_cursor_default_icon"];
        }else if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"])
        {
            image = [UIImage imageNamed:@"toolbar_cursor_hologram_icon"];
        }else{
            image = [[UIImage imageNamed:@"toolbar_cursor_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
        }
#else
        image = [[UIImage imageNamed:@"toolbar_cursor_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
#endif
        [_cursorMoveBtn setImage:image forState:UIControlStateNormal];
        [_cursorMoveBtn addTarget:self action:@selector(handleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cursorMoveBtn;
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = [UIImage imageNamed:@"btn_keyboard_dismiss"];
        [_dismissBtn setImage:[image imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(handleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_dismissBtn setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    }
    return _dismissBtn;
}

- (UIImageView *)themeNewIconView
{
    if (!_themeNewIconView) {
        _themeNewIconView = [[UIImageView alloc] init];
        UIImage * image = [[UIImage imageNamed:@"theme_new"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
        if (image) {
            [_themeNewIconView setImage:image];
        }
    }
    return _themeNewIconView;
}

- (UIImageView *)settingNewIconView
{
    if (!_settingNewIconView) {
        _settingNewIconView = [[UIImageView alloc] init];
        UIImage * image = [[UIImage imageNamed:@"theme_new"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
        if (image) {
            [_settingNewIconView setImage:image];
        }
    }
    return _settingNewIconView;
}

- (void)handleBtnTapped:(UIButton *)sender {
    if (!self.delegate) {
        return;
    }
    if (sender == self.settingBtn)
    {
        [self.delegate onToolBarView:self settingBtnTapped:nil];
        if (self.settingNewIconView.superview)
        {
            [self.settingNewIconView removeFromSuperview];
            self.settingNewIconView = nil;
            [kCMGroupDataManager setIsShowNewMarkOnSettingIconByCustomTheme:NO];
        }
    }
    else if (sender == self.themeBtn) {
        [self.delegate onToolBarView:self themeBtnTapped:nil];
        if (self.themeNewIconView.superview) {
            [self.themeNewIconView removeFromSuperview];
            self.themeNewIconView = nil;

#ifndef HostApp
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowThemeNewIcon];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [CMInfoc reportCheetahkeyboard_tip_clickWithValue:7];
            [CMInfoc reportCheetahkeyboard_tip_closeWithValue:5 closeType:4];
#endif
        }
    }
    else if (sender == self.emojiBtn) {
        [self.delegate onToolBarView:self emojiBtnTapped:nil];
        
    }else if (sender == self.cursorMoveBtn) {
        [self.delegate onToolBarView:self cursorMoveBtnTapped:nil];
    }
    else if (sender == self.dismissBtn) {
        [self.delegate onToolBarView:self dismissBtnTapped:nil];
    }
}

- (void)handleBtnDownRepeatTapped:(UIButton*)sender{
    if (sender == self.settingBtn) {
        [self.delegate onToolBarView:self settingBtnDownRepeatTapped:nil];
    }
}

- (BOOL)canShowTipForOneDayNotFirst
{
    _isAfterOneHour = NO;
    NSDate * date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSTimeInterval preTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kThemeNewIconDate];
    if (preTime == 0) {
        [[NSUserDefaults standardUserDefaults] setDouble:time forKey:kThemeNewIconDate];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowThemeNewIcon];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (time - preTime >= 24 * 60 * 60 - 60) {
        [[NSUserDefaults standardUserDefaults] setDouble:time forKey:kThemeNewIconDate];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShouldShowThemeNewIcon];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (time - preTime > 60 * 60 * 2 - 60) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowThemeNewIcon];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _isAfterOneHour = YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldShowThemeNewIcon];
}

- (void)themeNewIconShake
{
    if (self.themeNewIconView && self.themeNewIconView.superview) {
        [_themeNewIconView shakeWithDuration:0.8 delay:0 completion:nil];
        [_themeBtn shakeWithDuration:0.8 delay:0 completion:nil];
    }
}

- (BOOL)themeNewIconCanShake
{
    BOOL themeNewIconFirstShake = [[NSUserDefaults standardUserDefaults] boolForKey:kThemeNewIconFirstShake];
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastShakeTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kThemeNewIconLastShakeTime];
    
    if (themeNewIconFirstShake == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kThemeNewIconFirstShake];
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kThemeNewIconLastShakeTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }else if (currentTime - lastShakeTime >= 60 * 60 - 60)
    {
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kThemeNewIconLastShakeTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }

    return NO;
}
@end
