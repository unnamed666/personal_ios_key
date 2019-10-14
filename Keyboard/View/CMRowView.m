//
//  CMRowView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/16.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import "CMRowView.h"
#import "UIView+Util.h"
#import "CMKeyButton.h"
#import "CMKeyboardManager.h"
#import "CMKeyModel.h"
#import "UIView+Animate.h"
#import "UIDevice+Util.h"
#import "CMThemeManager.h"


@interface CMRowView ()

@end

@implementation CMRowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    if (self = [super init]) {
//        [self addBorderWithColor:[UIColor blueColor]];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return NO;
}

- (void)switchTheme{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(switchTheme)]){
            [obj performSelector:@selector(switchTheme)];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger keyHeight = [CMKeyboardManager keyHeight];
    NSUInteger keyMargin = [CMKeyboardManager keyMargin];
    
    NSUInteger rowTopPadding = [CMKeyboardManager rowTopPadding];
    NSUInteger rowBottomPadding = [CMKeyboardManager rowBottomPadding];
    
    __block CGFloat keyRectWidth = 0;
    __block CMKeyButton* lastBtn = nil;
    [self.buttonArray enumerateObjectsUsingBlock:^(CMKeyButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.width = ceil(self.width * button.keyModel.keyWidthRatio);
        if (lastBtn) {
            button.height = lastBtn.height;
            button.centerY = lastBtn.centerY;
        }
        else {
            button.height = keyHeight;
            if (self.isTopMost) {
                button.top = self.bounds.origin.y + rowTopPadding;
            }
            else if (self.isBottomMost) {
                button.bottom = self.bounds.origin.y+self.height - rowBottomPadding;
            }
            else {
                button.centerY = self.bounds.origin.y+self.height/2;
            }
        }
        
        lastBtn = button;
        keyRectWidth = keyRectWidth + button.width + keyMargin;
    }];
    
    lastBtn = nil;
    CGFloat viewWidth = [CMKeyboardManager sharedInstance].themeManager.keyboardViewControllerWidth == 0 ? [CMBizHelper adapterScreenWidth] : [CMKeyboardManager sharedInstance].themeManager.keyboardViewControllerWidth;
    CGFloat padding = (viewWidth - keyRectWidth + keyMargin)/2;
    [self.buttonArray enumerateObjectsUsingBlock:^(CMKeyButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lastBtn) {
            button.left = lastBtn.right + keyMargin;
        }
        else {
            button.left = padding >= 0 ? self.bounds.origin.x + padding : self.bounds.origin.x;
        }
        
        if ([CMKeyboardManager sharedInstance].needKeyboardExpandAnimation) {
            [button horizontalMoveAnimationFromCenterX:self.bounds.size.width / 2 - (self.bounds.size.width / 2 - button.left) * KeyboardExpandOriginalScale duration:KeyboardExpandAnimationTime timingFunction:KeyboardExpandTimingFunction];
            [button transformScaleAnimationFromScale:KeyboardExpandOriginalScale duration:KeyboardExpandAnimationTime timingFunction:KeyboardExpandTimingFunction];
        }
        
        lastBtn = button;
    }];
    
    lastBtn.right = padding >= 0 ? self.bounds.origin.x + self.width - padding : self.bounds.origin.x + self.width;
    self.rowMargin = self.height - lastBtn.height;
}


@end
