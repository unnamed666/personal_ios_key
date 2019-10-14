//
//  CMKeyButton.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/4.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyButton.h"
#import "CMKeyModel.h"
#import "CMKeyPreviewView.h"
#import "NSDictionary+Common.h"
#import "NSString+Common.h"
#import "CMNotificationConstants.h"
#import "CMKeyboardModel.h"
#import "UIColor+HexColors.h"
#import "UIView+Util.h"
#import "CMKeyboardManager.h"
#import "UIImage+Util.h"
#import "UIImage+Biz.h"
#import "UIColor+Biz.h"
#import "UIFont+Biz.h"
#import "CMThemeManager.h"
//#import "SwiftTheme-Swift.h"
#import "CMRowModel.h"
#import "UIDevice+Util.h"
#import "UIImage+Util.h"

@interface CMKeyButton () <UIGestureRecognizerDelegate>
@property (nonatomic, assign)CMKeyBtnPosition position;
@property (nonatomic, strong)CMKeyModel* keyModel;
@property (nonatomic, strong)UILabel* inputLabel;
@property (nonatomic, strong)UIImageView* bgImageView;
@property (nonatomic, strong)UIImageView* iconImageView;

@property (nonatomic, strong)UITapGestureRecognizer *doubleTapRecognizer;

@property (nonatomic, strong)UILabel* badgeLabel;

@property (nonatomic, strong)UIImageView* globalImgView;

@property (nonatomic, strong)UIImageView* emojiImgView;// 空格键右上角emoji icon

@property (nonatomic, strong)NSDate* startData;

@property (nonatomic, strong)NSMutableArray<NSString *> *keysStr;// 键盘字符
@property (nonatomic, strong)NSTimer *keyboardExpandAnimationTimer;// 键盘展开动画计时器
@property (nonatomic, assign)CGFloat addAlapha;

@end

@implementation CMKeyButton

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithKeyModel:(CMKeyModel *)keyModel {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        if (keyModel.keyType != CMKeyTypeEmoji) {
            self.userInteractionEnabled = NO;
        }
        else {
            self.userInteractionEnabled = YES;
        }
        [self setupThemeParameters:keyModel];
        self.keyModel = keyModel;
        [self setupViews];
        [self setupBadgeViewWithString:keyModel.topKeys];
    }
    return self;
}

- (void)didMoveToWindow {
    if (self.window) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShiftChangeNotification:) name:kNotificationShiftKeyTapped object:nil];
        [self handleShiftChangeNotification:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self.bgImageView setHighlighted:highlighted];
    [self.iconImageView setHighlighted:highlighted];
    [self.inputLabel setHighlighted:highlighted];
    if (![self.font.fontName isEqualToString:self.highlightFont.fontName] || self.font.pointSize != self.highlightFont.pointSize) {
        if (self.keyModel.keyType == CMKeyTypeEmoji) {
            self.inputLabel.font = kCMKeyboardManager.themeManager.emojiKeyFont;
        }else{
            self.inputLabel.font = highlighted ? self.highlightFont : self.font;
        }
    }
    [self.globalImgView setHighlighted:highlighted];
    [self.emojiImgView setHighlighted:highlighted];
    [self.badgeLabel setHighlighted:highlighted];
    [self setNeedsLayout];
}

- (void)handleShiftChangeNotification:(NSNotification *)notification{
    if (notification == nil) {
        if (self.keyModel.keyType == CMKeyTypeShift) {
            CMShiftKeyState shiftState = self.keyModel.parent.shiftKeyState;
            if (shiftState == CMShiftKeyStateNormal) {
                [self.iconImageView setImage:kCMKeyboardManager.themeManager.shiftKeyNormalImage];
            }
            else if (shiftState == CMShiftKeyStateSelected) {
                [self.iconImageView setImage:kCMKeyboardManager.themeManager.shiftKeySelectImage];
            }
            else if (shiftState == CMShiftKeyStateLocked) {
                [self.iconImageView setImage:kCMKeyboardManager.themeManager.shiftKeyLockImage];
            }
        }
        else if ([self.keyModel shouldShowKey]) {
            self.inputLabel.text = self.keyModel.key;
            if (self.keyModel.keyType == CMKeyTypeMultiLanguage && self.keyModel.key.length == 5) {
                NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:_keyModel.key];
                [attrText addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor colorWithHexString:@"868390"]
                                 range:NSMakeRange(3, 2)];
                self.inputLabel.attributedText = attrText;
            }
        }
        return;
    }
    NSDictionary * infoDic = [notification object];
    CMShiftKeyState shiftState = [infoDic integerValueForKey:@"shiftKeyState" defaultValue:CMShiftKeyStateNormal];
    if (shiftState == CMShiftKeyStateNormal) {
        if (self.keyModel.keyType == CMKeyTypeShift) {
            [self.iconImageView setImage:kCMKeyboardManager.themeManager.shiftKeyNormalImage];
        }
        else if ([self.keyModel shouldShowKey]) {
            self.inputLabel.text = self.keyModel.key;
        }
    }
    else if (shiftState == CMShiftKeyStateSelected) {
        if (self.keyModel.keyType == CMKeyTypeShift) {
            [self.iconImageView setImage:kCMKeyboardManager.themeManager.shiftKeySelectImage];
        }
        else if ([self.keyModel shouldShowShiftedKey]) {
            self.inputLabel.text = self.keyModel.key;
        }
    }
    else if (shiftState == CMShiftKeyStateLocked) {
        if (self.keyModel.keyType == CMKeyTypeShift) {
            [self.iconImageView setImage:kCMKeyboardManager.themeManager.shiftKeyLockImage];
        }
        else if ([self.keyModel shouldShowShiftedKey]) {
            self.inputLabel.text = self.keyModel.key;
        }
    }
}

- (void)setupThemeParameters:(CMKeyModel *)keyModel {
    
    if (keyModel.keyType == CMKeyTypeSpace) {
        self.font = kCMKeyboardManager.themeManager.spaceKeyFont;
        self.highlightFont = self.font;
        self.keyHighlightTextColor = kCMKeyboardManager.themeManager.spaceHighlightTextColor;
        self.keyTextColor = kCMKeyboardManager.themeManager.spaceKeyTextColor;
    }
    else if (keyModel.keyType == CMKeyTypeEmoji) {
        self.font = kCMKeyboardManager.themeManager.emojiKeyFont;
        self.highlightFont = self.font;
        self.keyHighlightTextColor = kCMKeyboardManager.themeManager.letterKeyHighlightTextColor;
        self.keyTextColor = kCMKeyboardManager.themeManager.letterKeyTextColor;
    }
    else if ([keyModel shouldUseFunctionalKeyTextFont]) {
        self.font = kCMKeyboardManager.themeManager.funcKeyFont;
        self.highlightFont = self.font;
        self.keyHighlightTextColor = kCMKeyboardManager.themeManager.funcKeyHighlightTextColor;
        self.keyTextColor = kCMKeyboardManager.themeManager.funcKeyTextColor;
    }else if (kCMKeyboardManager.keyboardType == CMKeyboardTypeLetter) {
        self.font = kCMKeyboardManager.themeManager.letterKeyFont;
        self.highlightFont = kCMKeyboardManager.themeManager.letterKeyHighlightFont;
        self.keyHighlightTextColor = kCMKeyboardManager.themeManager.letterKeyHighlightTextColor;
        self.keyTextColor = kCMKeyboardManager.themeManager.letterKeyTextColor;
    }else {
        self.font = kCMKeyboardManager.themeManager.nonLetterKeyFont;
        self.highlightFont = kCMKeyboardManager.themeManager.nonLetterKeyHighlightFont;
        self.keyHighlightTextColor = kCMKeyboardManager.themeManager.letterKeyHighlightTextColor;
        self.keyTextColor = kCMKeyboardManager.themeManager.letterKeyTextColor;
    }
    
    self.inputOptionsFont = kCMKeyboardManager.themeManager.inputOptionCellFont;
    self.inputOptionsHighlightFont = kCMKeyboardManager.themeManager.inputOptionCellHighlightFont;
    
    self.previewFont = kCMKeyboardManager.themeManager.preInputFont;
    self.badgeTextFont = kCMKeyboardManager.themeManager.keyHintFont;
    
    self.keyShadowColor = kCMKeyboardManager.themeManager.inputOptionShadowColor;
    self.previewTextColor = kCMKeyboardManager.themeManager.preInputTextColor;

    UIColor* preInputTextColor = kCMKeyboardManager.themeManager.preInputTextColor;
    if (preInputTextColor == [UIColor clearColor]) {
        self.previewTextColor = self.keyTextColor;
    }
    else {
        self.previewTextColor = preInputTextColor;
    }
    
    UIColor* inputOptionTextColor = kCMKeyboardManager.themeManager.inputOptionTextColor;
    if (inputOptionTextColor == [UIColor clearColor]) {
        self.inputOptionTextColor = self.keyTextColor;
    }
    else {
        self.inputOptionTextColor = inputOptionTextColor;
    }
    
    UIColor* inputOptionHighlightTextColor = kCMKeyboardManager.themeManager.inputOptionHighlightTextColor;
    if (inputOptionHighlightTextColor == [UIColor clearColor]) {
        self.inputOptionHighlightTextColor = self.keyTextColor;
    }
    else {
        self.inputOptionHighlightTextColor = inputOptionHighlightTextColor;
    }
    
    self.badgeTextColor = kCMKeyboardManager.themeManager.keyHintTextColor;
    
    if ([UIDevice currentDevice].isScreenPortrait) {
        self.badgeEdgeInsets = [CMBizHelper isiPhone] ? UIEdgeInsetsMake(1.5f, 0, 0, -3.6f) : UIEdgeInsetsMake(2.0f, 0, 0, -2.0f);
    }
    else {
        self.badgeEdgeInsets = [CMBizHelper isiPhone] ? UIEdgeInsetsMake(2.0f, 0, 0, -2.0f) : UIEdgeInsetsMake(2.0f, 0, 0, -2.0f);
    }
    
    self.keyTextCenterXOffset = 0.0f;
    self.keyTextCenterYOffset = 0.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateButtonPosition];
    CGRect labelRect = CGRectInset(self.bounds, 0, 0);
    self.inputLabel.frame = CGRectOffset(labelRect, self.keyTextCenterXOffset*self.width, self.keyTextCenterYOffset*self.height);
    self.bgImageView.frame = self.bounds;
//    [self addBorderWithColor:[UIColor redColor]];
    if ([self.keyModel shouldInsetBgImageKey]) {
        self.iconImageView.frame = CGRectInset(self.bgImageView.bounds, 14, 0);
    }
    else {
        self.iconImageView.frame = self.bgImageView.bounds;
    }
    
    if (self.globalImgView && self.globalImgView.superview) {
        self.globalImgView.top = self.bounds.origin.y + self.badgeEdgeInsets.top + 6;
        self.globalImgView.right = self.bounds.origin.x + self.width + self.badgeEdgeInsets.right - 2;
    }
    
    if (self.emojiImgView && self.emojiImgView.superview) {
        self.emojiImgView.top = self.bounds.origin.y + self.badgeEdgeInsets.top + 6;
        self.emojiImgView.right = self.bounds.origin.x + self.width + self.badgeEdgeInsets.right - 4;
    }
    
    if (self.badgeLabel && self.badgeLabel.superview) {
        self.badgeLabel.top = self.bounds.origin.y + self.badgeEdgeInsets.top;
        self.badgeLabel.right = self.bounds.origin.x + self.width + self.badgeEdgeInsets.right;
    }
    
    if (self.keyModel.keyType == CMKeyTypeLetter && [CMKeyboardManager sharedInstance].needKeyboardExpandAnimation) {
        if (!self.keyboardExpandAnimationTimer) {
            self.addAlapha = 0.0f;
            self.keyboardExpandAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(randomAlphaAndKeyStr) userInfo:nil repeats:YES];
            [self performSelector:@selector(invalidateTimer) withObject:nil afterDelay:KeyboardExpandAnimationTime];
        }
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return NO;
}


- (void)setupViews {
    
    [self addSubview:self.bgImageView];
    [self addSubview:self.iconImageView];
    [self addSubview:self.inputLabel];
    
    if (self.keyModel.keyType == CMKeyTypeSwitchKeyboard) {
        [self addSubview:self.globalImgView];
    }else if (self.keyModel.keyType == CMKeyTypeSpace) {
        [self addSubview:self.emojiImgView];
    }
    
    // State handling
    [self addTarget:self action:@selector(handleTouchDown:event:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDownRepeat];
    
    UIControlEvents cancelEvents = UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchCancel;
    [self addTarget:self action:@selector(handleTouchCancel:event:) forControlEvents:cancelEvents];
    
    UIControlEvents dragEvents = UIControlEventTouchDragEnter | UIControlEventTouchDragInside;
    [self addTarget:self action:@selector(handleDragInside:event:) forControlEvents:dragEvents];
    
    [self addTarget:self action:@selector(handleTouchUpInside:event:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addTarget:self action:@selector(handleLongPress:event:) forControlEvents:(UIControlEvents)CMControlEventLongPress];
    
    [self addTarget:self action:@selector(handlePan:event:) forControlEvents:(UIControlEvents)CMControlEventPan];
    
    [self addTarget:self action:@selector(handlePanEndOrCancel:event:) forControlEvents:(UIControlEvents)CMControlEventPanEndOrCancel];
    
    if ([self.keyModel shouldDoubleTapKey]) {
        [self addGestureRecognizer:self.doubleTapRecognizer];
    }
    
    if (![NSString stringIsEmpty:self.keyModel.topKeys]) {
        [self addSubview:self.badgeLabel];
    }
    
//    self.shouldRasterize = YES;
}

- (void)didMoveToSuperview {
    [self updateButtonPosition];
}


- (void)setupBadgeViewWithString:(NSString *)string
{
    self.badgeLabel.hidden = ![NSString stringIsEmpty:string] ? NO : YES;
    [self.badgeLabel setText:string];
    [self.badgeLabel sizeToFit];
}


- (void)updateButtonPosition
{
    CGFloat leftPadding = CGRectGetMinX(self.frame);
    CGFloat rightPadding = CGRectGetMaxX([UIScreen mainScreen].bounds) - CGRectGetMaxX(self.frame);
    CGFloat minimumClearance = CGRectGetWidth(self.frame) / 2 + 8;
    
    if (leftPadding >= minimumClearance && rightPadding >= minimumClearance) {
        self.position = CMKeyBtnPositionInner;
    } else if (leftPadding > rightPadding) {
        self.position = CMKeyBtnPositionLeft;
    } else {
        self.position = CMKeyBtnPositionRight;
    }
}

- (void)emojiBindKeyModel:(CMKeyModel *)keyModel {
    self.keyModel = keyModel;

    if (keyModel == nil) {
        self.inputLabel.text = nil;
        self.iconImageView.image = nil;
    }else if (keyModel.keyType == CMKeyTypeDel) {
        self.inputLabel.text = nil;
        self.iconImageView.image = [self getEmojiDeleteIconImage];
    }else if (keyModel.keyType == CMKeyTypeEmoji) {
        self.iconImageView.image = nil;
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *hitTestView = [super hitTest:point withEvent:event];
//    if (hitTestView == self /*&& ![self.keyModel shouldShowInputOptionsView]*/) {
//        hitTestView = nil;
//    }
//    return hitTestView;
//}

#pragma mark - timer
- (void)randomAlphaAndKeyStr
{
    NSUInteger random = arc4random();
    self.alpha = (random % 100) / 100.0f + self.addAlapha;
    self.addAlapha = self.addAlapha + 0.05f;
    
    NSInteger index = random % self.keysStr.count;
    self.inputLabel.text = self.keysStr[index];
}

- (void)invalidateTimer
{
    if (self.keyboardExpandAnimationTimer) {
        [self.keyboardExpandAnimationTimer invalidate];
        self.keyboardExpandAnimationTimer = nil;
    }
    self.alpha = 1.0f;
    self.inputLabel.text = self.keyModel.key;
    [CMKeyboardManager sharedInstance].needKeyboardExpandAnimation = NO;
}

#pragma mark - event handler
- (void)handleTouchCancel:(id)sender event:(UIEvent *)event {
    [self setHighlighted:NO];
    if (self.keyTouchCancelHandler) {
        self.keyTouchCancelHandler(self);
    }
}

- (void)handleTouchDown:(id)sender event:(UIEvent *)event
{
    [self setHighlighted:YES];
    self.startData = [NSDate date];
    if (self.keyTouchDownHandler) {
        if (!event || event.type != UIEventTypeTouches) {
            self.keyTouchDownHandler(self, CGPointMake(-1, -1));
            return;
        }
        
        if ([event.allTouches count] > 1) {
            __block BOOL found = NO;
            [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
                if (CGRectContainsPoint(self.bounds, [touch locationInView:self]) && touch.tapCount == 1) {
                    CGPoint point = [touch locationInView:self.superview.superview];
                    self.keyTouchDownHandler(self, point);
                    found = YES;
                    *stop = YES;
                }
            }];
            if (!found) {
                [self setHighlighted:NO];
                if (self.keyTouchCancelHandler) {
                    self.keyTouchCancelHandler(self);
                }
            }
        }
        else {
            UITouch *touch = [event.allTouches anyObject];
            CGPoint point = [touch locationInView:self.superview.superview];
            self.keyTouchDownHandler(self, point);
        }
    }
}

- (void)handleLongPress:(id)sender event:(UIEvent *)event {
    if (![self.keyModel shouldLongPressKey] && ![self.keyModel shouldShowInputOptionsView]) {
        return;
    }
    if (self.keyLongPressedHandler) {
        UITouch *touch = [event.allTouches anyObject];
        CGPoint point = [touch locationInView:self];
        self.keyLongPressedHandler(self, point);
    }
}

- (void)handlePan:(id)sender event:(UIEvent *)event {
    if (![self.keyModel shouldShowInputOptionsView] && ![self.keyModel shouldShowSwitchView]) {
        return;
    }
    if (self.optionsPanHandler) {
        if (event && event.type == UIEventTypeTouches) {
            UITouch *touch = [event.allTouches anyObject];
            CGPoint point = [touch locationInView:self.superview.superview.superview];
            self.optionsPanHandler(point);
        }
    }
}

- (void)handlePanEndOrCancel:(id)sender event:(UIEvent *)event {
    [self setHighlighted:NO];
    if (![self.keyModel shouldShowInputOptionsView] && ![self.keyModel shouldShowSwitchView]) {
        return;
    }
    if (self.optionSelectedHandler) {
        self.optionSelectedHandler(self);
    }
}

- (void)handleDragInside:(id)sender event:(UIEvent *)event {
    [self setHighlighted:YES];
}

- (void)handleTouchUpInside:(id)sender event:(UIEvent *)event {
    [self setHighlighted:NO];
    if (self.keyTouchUpInsideHandler) {
        if (!event || event.type != UIEventTypeTouches) {
            self.keyTouchUpInsideHandler(self, CGPointMake(-1, -1));
            return;
        }
        
        if ([event.allTouches count] > 1) {
            __block BOOL found = NO;
            [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
                if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
                    CGPoint point = [touch locationInView:self.superview.superview.superview];
                    self.keyTouchUpInsideHandler(self, point);
                    found = YES;
                    *stop = YES;
                }
            }];
            if (!found) {
                [self setHighlighted:NO];
                if (self.keyTouchCancelHandler) {
                    self.keyTouchCancelHandler(self);
                }
            }
        }
        else {
            UITouch *touch = [event.allTouches anyObject];
            CGPoint point = [touch locationInView:self.superview.superview.superview];
            self.keyTouchUpInsideHandler(self, point);
        }
    }
}

- (void)handleTouchDown:(UITouch *)touch {
    [self setHighlighted:YES];
    self.startData = [NSDate date];
    if (self.keyTouchDownHandler) {
        if (!touch) {
            self.keyTouchDownHandler(self, CGPointMake(-1, -1));
            return;
        }
        CGPoint point = [touch locationInView:self.superview.superview];
        self.keyTouchDownHandler(self, point);
    }
}

- (void)handleTouchUpInside:(UITouch *)touch {
    [self setHighlighted:NO];
    if (self.keyTouchUpInsideHandler) {
        if (!touch) {
            self.keyTouchUpInsideHandler(self, CGPointMake(-1, -1));
            return;
        }
        CGPoint point = [touch locationInView:self.superview.superview.superview];
        self.keyTouchUpInsideHandler(self, point);
    }
}

- (void)handleTouchCancel:(UITouch *)touch {
    [self setHighlighted:NO];
    if (self.keyTouchCancelHandler) {
        self.keyTouchCancelHandler(self);
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (![self.keyModel shouldDoubleTapKey]) {
        return;
    }
    if (self.keyDoubleTappedHandler) {
        self.keyDoubleTappedHandler(self);
    }
}
- (void)switchTheme{
    [self setupThemeParameters:self.keyModel];
    [self iconImageViewUpdateTheme];
    [self badgeLabelUpdateTheme];
    [self inputLabelUpdateTheme];
    [self bgImageViewUpdateTheme];
    [self globalImgViewUpdateTheme];
}

#pragma mark - setter/getter
- (void)inputLabelUpdateTheme{
    [_inputLabel setFont:self.font];
    [_inputLabel setTextColor:self.keyTextColor];
    [_inputLabel setHighlightedTextColor:self.keyHighlightTextColor];
}
- (UILabel *)inputLabel {
    if (!_inputLabel) {
        _inputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _inputLabel.textAlignment = NSTextAlignmentCenter;
        _inputLabel.backgroundColor = [UIColor clearColor];
        _inputLabel.userInteractionEnabled = NO;
        _inputLabel.numberOfLines = 0;
        _inputLabel.adjustsFontSizeToFitWidth = YES;
        [self inputLabelUpdateTheme];
    }
    return _inputLabel;
}
- (void)bgImageViewUpdateTheme{
    if (self.keyModel.keyType == CMKeyTypeSpace) {
        UIImage* normalImage = kCMKeyboardManager.themeManager.spaceKeyNormalBgImage;
        UIImage* highlightImage = kCMKeyboardManager.themeManager.spaceKeyHighlightBgImage;
        if (normalImage) {
            [_bgImageView setImage:normalImage];
        }
        else {
            UIColor* normalColor = kCMKeyboardManager.themeManager.spaceKeyNormalBgColor;
            [_bgImageView setImage:[UIImage imageWithColor:normalColor]];
        }
        
        if (highlightImage) {
            [_bgImageView setHighlightedImage:kCMKeyboardManager.themeManager.spaceKeyHighlightBgImage];
        }
        else {
            UIColor* highlightColor = kCMKeyboardManager.themeManager.spaceKeyHighlightBgColor;
            [_bgImageView setHighlightedImage:[UIImage imageWithColor:highlightColor]];
        }
    }
    else if ((self.keyModel.keyType == CMKeyTypeDel && self.tag == EmojiDeleteKeyButtonTag) || self.keyModel == nil) {
        // self.keyModel == nil： 当初始化emoji初始化keyButton时，此时还没有setKeyModel
        [_bgImageView setImage:nil];
        [_bgImageView setHighlightedImage:nil];
    }
    else if ([self.keyModel shouldUseFunctionalBackground]) {
        UIImage* normalImage = kCMKeyboardManager.themeManager.funcKeyNormalBgImage;
        UIImage* highlightImage = kCMKeyboardManager.themeManager.funcKeyHighlightBgImage;
        if (normalImage) {
            [_bgImageView setImage:normalImage];
        }
        else {
            UIColor* normalColor = kCMKeyboardManager.themeManager.funcKeyNormalBgColor;
            [_bgImageView setImage:[UIImage imageWithColor:normalColor]];
        }
        
        if (highlightImage) {
            [_bgImageView setHighlightedImage:highlightImage];
        }
        else {
            UIColor* highlightColor = kCMKeyboardManager.themeManager.funcKeyHighlightBgColor;
            [_bgImageView setHighlightedImage:[UIImage imageWithColor:highlightColor]];
        }
    }
    else {
        UIImage* normalImage = kCMKeyboardManager.themeManager.letterKeyNormalBgImage;
        UIImage* highlightImage = kCMKeyboardManager.themeManager.letterKeyHighlightBgImage;
        if (normalImage) {
            [_bgImageView setImage:normalImage];
        }
        else {
            UIColor* normalColor = kCMKeyboardManager.themeManager.letterKeyNormalBgColor;
            [_bgImageView setImage:[UIImage imageWithColor:normalColor]];
        }
        
        if (highlightImage) {
            [_bgImageView setHighlightedImage:highlightImage];
        }
        else {
            UIColor* highlightColor = kCMKeyboardManager.themeManager.letterKeyHighlightBgColor;
            [_bgImageView setHighlightedImage:[UIImage imageWithColor:highlightColor]];
        }
    }
}
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.backgroundColor = [UIColor clearColor];
        _bgImageView.contentMode = UIViewContentModeScaleToFill;
        [self bgImageViewUpdateTheme];
    }
    return _bgImageView;
}
- (void)iconImageViewUpdateTheme{
    if (self.keyModel.keyType == CMKeyTypeDel && self.tag != EmojiDeleteKeyButtonTag) {
        
        if (kCMKeyboardManager.currentLanguageType == CMKeyboardLanguageTypeArabic ) {
            UIImage *backImage = kCMKeyboardManager.themeManager.delKeyNormalBgImage;
            UIImage *backHighLightImage = kCMKeyboardManager.themeManager.delKeyHighlightBgImage;
            
            backImage = [UIImage rotationImage:backImage rotation:UIImageOrientationDown];
            backHighLightImage = [UIImage rotationImage:backHighLightImage rotation:UIImageOrientationDown];
            [_iconImageView setImage:backImage];
            [_iconImageView setHighlightedImage:backHighLightImage];
        }else {
            [_iconImageView setImage:kCMKeyboardManager.themeManager.delKeyNormalBgImage];
            [_iconImageView setHighlightedImage:kCMKeyboardManager.themeManager.delKeyHighlightBgImage];
        }

    }
    else if (self.keyModel.keyType == CMKeyTypeDel && self.tag == EmojiDeleteKeyButtonTag) {
        [_iconImageView setImage:[self getEmojiDeleteIconImage]];
        [_iconImageView setHighlightedImage:[self getEmojiDeleteIconImage]];
    }
    else if (self.keyModel.keyType == CMKeyTypeReturn) {
        switch (self.keyModel.returnType) {
            case UIReturnKeyDefault:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.returnKeyNormalImage];
            }
                break;
            case UIReturnKeyGo:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.goKeyNormalImage];
            }
                break;
            case UIReturnKeyGoogle:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.searchKeyNormalImage];
            }
                break;
            case UIReturnKeyJoin:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.goKeyNormalImage];
            }
                break;
            case UIReturnKeyNext:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.nextKeyNormalImage];
            }
                break;
            case UIReturnKeyRoute:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.goKeyNormalImage];
            }
                break;
            case UIReturnKeySearch:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.searchKeyNormalImage];
            }
                break;
            case UIReturnKeySend:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.sendKeyNormalImage];
            }
                break;
            case UIReturnKeyYahoo:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.searchKeyNormalImage];
            }
                break;
            case UIReturnKeyDone:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.doneKeyNormalImage];
            }
                break;
            case UIReturnKeyEmergencyCall:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.sendKeyNormalImage];
            }
                break;
            case UIReturnKeyContinue:
            {
                [_iconImageView setImage:kCMKeyboardManager.themeManager.tabKeyNormalImage];
            }
                break;
            default:
                break;
        }
    }
}
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.contentMode = UIViewContentModeCenter;
        [self iconImageViewUpdateTheme];
    }
    return _iconImageView;
}

// 返回emoji页面删除按钮的icon图片
- (UIImage *)getEmojiDeleteIconImage
{
    UIImage *image = [UIImage imageNamed:@"delete_icon"];
    UIColor *color = kCMKeyboardManager.themeManager.tintColor;
    image = color ? [image imageWithTintColor:color] : image;
    return image;
}

- (UITapGestureRecognizer *)doubleTapRecognizer {
    if (!_doubleTapRecognizer) {
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapRecognizer;
}


- (void)setKeyModel:(CMKeyModel *)keyModel {
    _keyModel = keyModel;
    if (_keyModel && [_keyModel shouldShowKey]) {
        self.inputLabel.text = keyModel.key;
    }
    if (_keyModel && _keyModel.keyType == CMKeyTypeSpace) {
        keyModel.inputOptionArray = [CMKeyboardManager sharedInstance].spaceKeyPopupCharacters;
    }
    if (keyModel.keyType == CMKeyTypeEmoji) {
        self.inputLabel.font = kCMKeyboardManager.themeManager.emojiKeyFont;
    }
    
    if (keyModel.keyType == CMKeyTypeEmoji) {
        self.userInteractionEnabled = YES;
        [self removeTarget:self action:@selector(handleTouchDown:event:) forControlEvents:UIControlEventTouchDownRepeat];
    }
    else {
        self.userInteractionEnabled = NO;
    }
}
- (void)badgeLabelUpdateTheme{
    
    [_badgeLabel setFont:self.badgeTextFont];
    [_badgeLabel setTextColor:self.badgeTextColor];
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [UILabel new];
        [_badgeLabel setClipsToBounds:YES];
        [_badgeLabel setTextAlignment:NSTextAlignmentCenter];
        _badgeLabel.backgroundColor = [UIColor clearColor];
        [self badgeLabelUpdateTheme];
    }
    return _badgeLabel;
}

- (void)globalImgViewUpdateTheme{
    
    [_globalImgView setImage:kCMKeyboardManager.themeManager.globalImage];
}

- (UIImageView *)globalImgView {
    if (!_globalImgView) {
        _globalImgView = [UIImageView new];
        _globalImgView.backgroundColor = [UIColor clearColor];
        _globalImgView.size = CGSizeMake(9, 9);
        
        [self globalImgViewUpdateTheme];
    }
    return _globalImgView;
}

- (UIImageView *)emojiImgView
{
    if (!_emojiImgView) {
        _emojiImgView = [UIImageView new];
        _emojiImgView.backgroundColor = [UIColor clearColor];
        _emojiImgView.size = CGSizeMake(12, 12);
        if (self.keyModel.keyType == CMKeyTypeSpace) {
            _emojiImgView.image = [[UIImage imageNamed:@"emoji_icon"] imageWithTintColor:self.keyTextColor];
        }
    }
    return _emojiImgView;
}

- (void)setBadgeString:(NSString *)badgeString
{
    _badgeString = [badgeString copy];
    [self setupBadgeViewWithString:badgeString];
}

- (void)setShouldRasterize:(BOOL)shouldRasterize {
    _shouldRasterize = shouldRasterize;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        subview.layer.shouldRasterize = shouldRasterize;
    }];
}

- (NSArray<NSString *> *)keysStr
{
    if (!_keysStr) {
        _keysStr = [NSMutableArray array];
        [self.keyModel.parent.rowModelArray enumerateObjectsUsingBlock:^(CMRowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.keyArray enumerateObjectsUsingBlock:^(CMKeyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.keyType == CMKeyTypeLetter) {
                    [_keysStr addObject:obj.key];
                }
            }];
        }];
        // 容错处理
        if (_keysStr.count == 0) {
            [_keysStr addObject:@" "];
        }
    }
    return _keysStr;
}

@end
