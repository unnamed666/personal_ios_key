//
//  CMBlackThemeKeyboardView.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/8/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMBlackThemeKeyboardView : UIView

@property (nonatomic, assign)CGFloat viewHeight;
@property (nonatomic, assign)CGFloat viewWidth;
@property (nonatomic, assign)BOOL isCircleBackground;

- (void)defaultConfig:(CGSize)viewSize;
//- (void)myTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)myTouchesEnded:(NSSet<UITouch *> *_Nonnull)touches withEvent:(nullable UIEvent *)event;

- (void)startAnimtion;
- (void)stopAnimtion;
@end
