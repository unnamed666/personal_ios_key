//
//  CMKeyButton.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/4.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EmojiDeleteKeyButtonTag         1000 //用来标记emoji页面的删除按钮

#define KeyboardExpandAnimationTime   0.72  //键盘展开动画时长 0.7s
#define KeyboardExpandOriginalScale   0.7  //键盘展开动画最开始按键大小比例
#define KeyboardExpandTimingFunction   [CAMediaTimingFunction functionWithControlPoints:0.13f :0.75f :0.48f :0.99f]


typedef NS_ENUM(NSUInteger, CMKeyBtnPosition) {
    CMKeyBtnPositionLeft,
    CMKeyBtnPositionInner,
    CMKeyBtnPositionRight,
    CMKeyBtnPositionCount
};

typedef NS_OPTIONS(NSUInteger, CMControlEvent) {
    CMControlEventLongPress = 0x01000000,
    CMControlEventPan = 0x02000000,
    CMControlEventLongPressEndOrCancel = 0x03000000,
    CMControlEventPanEndOrCancel = 0x04000000
};

@class CMKeyButton;
@class CMKeyModel;

typedef void(^onKeyTouchDownHandler)(CMKeyButton* keyButton, CGPoint touchPt);

typedef void(^onKeyTouchUpInsideHandler)(CMKeyButton* keyButton, CGPoint touchPt);

typedef void(^onKeyTouchCancelHandler)(CMKeyButton* keyButton);

typedef void(^onKeyDoubleTappedHandler)(CMKeyButton* keyButton);

typedef void(^onKeyLongPressedHandler)(CMKeyButton* keyButton, CGPoint touchPt);

typedef void(^onOptionPanGestureHandler)(CGPoint pt);

typedef void(^onOptionSelectedHandler)(CMKeyButton* keyButton);


@interface CMKeyButton : UIControl

@property (nonatomic, strong)UIFont *font UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIFont *highlightFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIFont *inputOptionsFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIFont *inputOptionsHighlightFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *keyShadowColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *keyColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *keyHighlightColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *keyTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *keyHighlightTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *previewTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIFont *previewFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *inputOptionTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *inputOptionHighlightTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIColor *badgeTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)UIFont *badgeTextFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong)NSString *badgeString;

@property (nonatomic) UIEdgeInsets badgeEdgeInsets;

// keyTextPadding
@property (nonatomic, assign)CGFloat keyTextCenterXOffset;
@property (nonatomic, assign)CGFloat keyTextCenterYOffset;

@property (nonatomic, assign)BOOL shouldRasterize;

@property (nonatomic, readonly)CMKeyBtnPosition position;

@property (nonatomic, readonly, strong)CMKeyModel* keyModel;

@property (nonatomic, copy)onKeyTouchDownHandler keyTouchDownHandler;
@property (nonatomic, copy)onKeyTouchUpInsideHandler keyTouchUpInsideHandler;
@property (nonatomic, copy)onKeyTouchCancelHandler keyTouchCancelHandler;

@property (nonatomic, copy)onKeyDoubleTappedHandler keyDoubleTappedHandler;
@property (nonatomic, copy)onKeyLongPressedHandler keyLongPressedHandler;
@property (nonatomic, copy)onOptionPanGestureHandler optionsPanHandler;
@property (nonatomic, copy)onOptionSelectedHandler optionSelectedHandler;

@property (nonatomic, weak) id<UITextInput> textInput;

@property (nonatomic,readonly, strong)UIImageView* iconImageView;

- (instancetype)initWithKeyModel:(CMKeyModel *)keyModel;

// emoji页面cell绑定keyModel
- (void)emojiBindKeyModel:(CMKeyModel *)keyModel;


- (void)handleTouchDown:(UITouch *)touch;
- (void)handleTouchUpInside:(UITouch *)touch;
- (void)handleTouchCancel:(UITouch *)touch;

@end
