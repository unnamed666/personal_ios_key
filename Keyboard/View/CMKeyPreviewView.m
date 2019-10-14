//
//  CMKeyPreviewView.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/3.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyPreviewView.h"
#import "CMKeyModel.h"
#import "TurtleBezierPath.h"
#import "CMKeyButton.h"
#import "NSDictionary+Common.h"
#import "NSString+Common.h"
#import "UIView+Util.h"
#import "CMBizHelper.h"
#import "CMKeyboardManager.h"
#import "UIImage+Biz.h"
#import "UIColor+Biz.h"
#import "CMThemeManager.h"
//#import "SwiftTheme-Swift.h"
#import "UIDevice+Util.h"

@interface CMKeyPreviewView ()
@property (nonatomic, strong)UIColor* bgColor;
@property (nonatomic, strong)UIImage* bgImage;

@property (nonatomic, strong)UIView* containerView;
@property (nonatomic, strong)UIImageView* bgImageView;
@property (nonatomic, strong)UILabel* titleLabel;

@property (nonatomic, readwrite, assign)CGRect containerFrame;

@property (nonatomic, assign)CGFloat widthRatio;
@property (nonatomic, assign)CGFloat heightRatio;

@property (nonatomic, assign)UIEdgeInsets labelInset;

@property (nonatomic, assign)CMPreviewAnimateType animateType;

@property (nonatomic, assign)BOOL isAnimating;

@end

@implementation CMKeyPreviewView

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isAnimating = NO;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        _bgImage = kCMKeyboardManager.themeManager.preInputBgImage;
        _bgColor = kCMKeyboardManager.themeManager.preInputBgColor;
        
        _widthRatio = 1.5f;
        _heightRatio = 1.34f;
        _labelInset = UIEdgeInsetsMake(0, 0, 6, 0);
        
        NSString* animateType =  kCMKeyboardManager.themeManager.animateType;
        if ([animateType isEqualToString:@"dropdown"]) {
            _animateType = CMPreviewAnimateTypeDropDown;
            [self.containerView addSubview:self.bgImageView];
            [self.containerView addSubview:self.titleLabel];
            [self addSubview:self.containerView];
        }
        else if ([animateType isEqualToString:@"default"]) {
            _animateType = CMPreviewAnimateTypeDefault;
        }
    }
    return self;
}

- (instancetype)initWithkeyButton:(CMKeyButton *)button {
    self = [self init];
    self.button = button;
    return self;
}

- (void)dealloc {
//    kLogTrace();
}

#pragma mark - getter/setter
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    return _containerView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isAnimating) {
        return;
    }
    if (self.animateType == CMPreviewAnimateTypeDropDown) {
        self.containerView.frame = [self inputViewPath].bounds;
        
        if (self.containerView.top <= 0) {
            self.containerView.top = 2;
        }
        
        if (self.containerView.right >= self.boundRight) {
            self.containerView.right = self.boundRight - 2;
        }
        
        if (self.containerView.left <= 0) {
            self.containerView.left = 2;
        }
        self.bgImageView.frame = self.containerView.bounds;
        self.titleLabel.frame = UIEdgeInsetsInsetRect(self.bgImageView.bounds, self.labelInset);
    }
}

- (void)setButton:(CMKeyButton *)button {
    if (button != _button) {
        _button = button;
        self.titleLabel.font = _button.previewFont;
        self.titleLabel.textColor = _button.previewTextColor;
        self.titleLabel.text = _button.keyModel.key;
        [self.titleLabel sizeToFit];
        if (self.bgImage) {
            [self.bgImageView setImage:self.bgImage];
        }
        else if (self.bgColor) {
            [self.bgImageView setBackgroundColor:self.bgColor];
        }
        else {
            [self.bgImageView setBackgroundColor:_button.keyColor];
        }
        CGRect rect = [self inputViewPath].bounds;
        self.containerFrame = rect;
    }
}


//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    if (self.animateType != CMPreviewAnimateTypeDefault) {
//        return [super drawRect:rect];
//    }
//    UIBezierPath *bezierPath = [self inputViewPath];
//    NSString *inputString = self.button.keyModel.key;
//
//    // Position the overlay
//    CGRect keyRect = [self convertRect:self.button.frame fromView:self.button.superview];
//    
////    NSLog(@"~~~~~drawRect rect=%@, keyRect=%@", NSStringFromCGRect(rect), NSStringFromCGRect(keyRect));
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Overlay path & shadow
//    {
//        //// Shadow Declarations
//        UIColor* shadow = [[UIColor blackColor] colorWithAlphaComponent: 0.5];
//        CGSize shadowOffset = CGSizeMake(0, 0.5);
//        CGFloat shadowBlurRadius = 2;
//        //// Rounded Rectangle Drawing
//        CGContextSaveGState(context);
//        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
//        
//        [self.button.keyColor setFill];
//        [bezierPath fill];
//        CGContextRestoreGState(context);
//    }
//    
//    // Draw the key shadow sliver
//    {
//        //// Color Declarations
//        UIColor *color = self.button.keyColor;
//        
//        //// Shadow Declarations
//        UIColor *shadow = self.button.keyShadowColor;
//        CGSize shadowOffset = CGSizeMake(0.1, 1.1);
//        CGFloat shadowBlurRadius = 0;
//        
//        //// Rounded Rectangle Drawing
//        UIBezierPath *roundedRectanglePath =
//        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(keyRect.origin.x, keyRect.origin.y, keyRect.size.width, keyRect.size.height - 1) cornerRadius:4];
//        CGContextSaveGState(context);
//        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
//        [color setFill];
//        [roundedRectanglePath fill];
//        
//        CGContextRestoreGState(context);
//    }
//    
//    // Text drawing
//    {
//        NSMutableParagraphStyle *p = [NSMutableParagraphStyle new];
//        p.alignment = NSTextAlignmentCenter;
//
//        NSAttributedString *attributedString = [[NSAttributedString alloc]
//                                                initWithString:inputString
//                                                attributes:
//                                                @{NSFontAttributeName : self.button.previewFont, NSForegroundColorAttributeName : self.button.previewTextColor, NSParagraphStyleAttributeName : p}];
//
//        
//        CGRect maxTextRect = UIEdgeInsetsInsetRect(bezierPath.bounds, UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyRect), 0));
//
//        
//        //Find the rect that the string will draw into **inside the maxTextRect**
//        CGRect actualRect = [attributedString boundingRectWithSize:maxTextRect.size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//        
//        //Offset the actual rect inside the maxTextRect
//        // this will center vertically and horizontally
//        CGRect stringRect = CGRectMake(CGRectGetMinX(maxTextRect) + ((CGRectGetWidth(maxTextRect) - CGRectGetWidth(actualRect)) * 0.5)
//                                     , CGRectGetMinY(maxTextRect) + ((CGRectGetHeight(maxTextRect) - CGRectGetHeight(actualRect)) * 0.5)
//                                     , CGRectGetWidth(actualRect)
//                                     , CGRectGetHeight(actualRect));
//        
//        [attributedString drawInRect:stringRect];
//    }
//
//}

- (UIBezierPath *)inputViewPath
{
    CGRect keyRect = [self convertRect:self.button.frame fromView:self.button.superview];
    
    if (self.button.keyModel.keyType == CMKeyTypeEmoji) {
        keyRect.origin.y -= 10.0f;
    }
    
    TurtleBezierPath *path = [TurtleBezierPath new];
    [path home];
    path.lineWidth = 0;
    path.lineCapStyle = kCGLineCapRound;
    [path removeAllPoints];
    
    if (self.animateType == CMPreviewAnimateTypeDefault) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 13, 0, 13);

        CGFloat upperWidth = CGRectGetWidth(self.button.frame) + insets.left + insets.right;
        CGFloat lowerWidth = CGRectGetWidth(self.button.frame);
        CGFloat majorRadius = 10.f;
        CGFloat minorRadius = 4.f;

        switch (self.button.position) {
            case CMKeyBtnPositionInner:
            {
                [path rightArc:majorRadius turn:90]; // #1
                [path forward:upperWidth - 2 * majorRadius]; // #2 top
                [path rightArc:majorRadius turn:90]; // #3
                [path forward:CGRectGetHeight(keyRect) - 2 * majorRadius + insets.top + insets.bottom]; // #4 right big
                [path rightArc:majorRadius turn:48]; // #5
                [path forward:8.5f];
                [path leftArc:majorRadius turn:48]; // #6
                [path forward:CGRectGetHeight(keyRect) - 8.5f + 1];
                [path rightArc:minorRadius turn:90];
                [path forward:lowerWidth - 2 * minorRadius]; //  lowerWidth - 2 * minorRadius + 0.5f
                [path rightArc:minorRadius turn:90];
                [path forward:CGRectGetHeight(keyRect) - 2 * minorRadius];
                [path leftArc:majorRadius turn:48];
                [path forward:8.5f];
                [path rightArc:majorRadius turn:48];
                
                CGFloat offsetX = 0, offsetY = 0;
                CGRect pathBoundingBox = path.bounds;
                
                offsetX = CGRectGetMidX(keyRect) - CGRectGetMidX(path.bounds);
                offsetY = CGRectGetMaxY(keyRect) - CGRectGetHeight(pathBoundingBox) + 10;
                
                [path applyTransform:CGAffineTransformMakeTranslation(offsetX, offsetY)];
            }
                break;
                
            case CMKeyBtnPositionLeft:
            {
                [path rightArc:majorRadius turn:90]; // #1
                [path forward:upperWidth - 2 * majorRadius]; // #2 top
                [path rightArc:majorRadius turn:90]; // #3
                [path forward:CGRectGetHeight(keyRect) - 2 * majorRadius + insets.top + insets.bottom]; // #4 right big
                [path rightArc:majorRadius turn:45]; // #5
                [path forward:28]; // 6
                [path leftArc:majorRadius turn:45]; // #7
                [path forward:CGRectGetHeight(keyRect) - 26 + (insets.left + insets.right) / 4]; // #8
                [path rightArc:minorRadius turn:90]; // 9
                [path forward:path.currentPoint.x - minorRadius]; // 10
                [path rightArc:minorRadius turn:90]; // 11
                
                
                CGFloat offsetX = 0, offsetY = 0;
                CGRect pathBoundingBox = path.bounds;
                
                offsetX = CGRectGetMaxX(keyRect) - CGRectGetWidth(path.bounds);
                offsetY = CGRectGetMaxY(keyRect) - CGRectGetHeight(pathBoundingBox) - CGRectGetMinY(path.bounds);
                
                [path applyTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(-1, 1), -offsetX - CGRectGetWidth(path.bounds), offsetY)];
            }
                break;
                
            case CMKeyBtnPositionRight:
            {
                [path rightArc:majorRadius turn:90]; // #1
                [path forward:upperWidth - 2 * majorRadius]; // #2 top
                [path rightArc:majorRadius turn:90]; // #3
                [path forward:CGRectGetHeight(keyRect) - 2 * majorRadius + insets.top + insets.bottom]; // #4 right big
                [path rightArc:majorRadius turn:45]; // #5
                [path forward:28]; // 6
                [path leftArc:majorRadius turn:45]; // #7
                [path forward:CGRectGetHeight(keyRect) - 26 + (insets.left + insets.right) / 4]; // #8
                [path rightArc:minorRadius turn:90]; // 9
                [path forward:path.currentPoint.x - minorRadius]; // 10
                [path rightArc:minorRadius turn:90]; // 11
                
                CGFloat offsetX = 0, offsetY = 0;
                CGRect pathBoundingBox = path.bounds;
                
                offsetX = CGRectGetMinX(keyRect);
                offsetY = CGRectGetMaxY(keyRect) - CGRectGetHeight(pathBoundingBox) - CGRectGetMinY(path.bounds);
                
                [path applyTransform:CGAffineTransformMakeTranslation(offsetX, offsetY)];
            }
                break;
                
            default:
                break;
        }
    }
    else if (self.animateType == CMPreviewAnimateTypeDropDown) {
        UIEdgeInsets insets = UIEdgeInsetsZero;

        CGFloat upperWidth = CGRectGetWidth(self.button.frame)*self.widthRatio;
        CGFloat lowerWidth = CGRectGetWidth(self.button.frame)*self.widthRatio;
        CGFloat rectHeight = CGRectGetHeight(self.button.frame)*self.heightRatio;
        
        [path moveToPoint:keyRect.origin]; // pen directon up
        [path turn:90];
        [path forward:lowerWidth];
        [path turn:-90];
        [path forward:rectHeight + insets.top + insets.bottom];
        [path turn:-90];
        [path forward:upperWidth];
        [path turn:-90];
        [path forward:rectHeight + insets.top + insets.bottom];
        [path up];

        
        CGFloat offsetX = 0, offsetY = 0;
        
        offsetX = CGRectGetMidX(keyRect) - CGRectGetMidX(path.bounds);
        CGFloat deltaOriginY = path.bounds.origin.y + self.labelInset.bottom;
        if (deltaOriginY > 2) {
            offsetY = self.labelInset.bottom;
        }
        else {
            offsetY = self.labelInset.bottom + fabs(deltaOriginY);
        }

        
        [path applyTransform:CGAffineTransformMakeTranslation(offsetX, offsetY)];
    }
    
    return path;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
}

- (void)removeWithAnimation:(void (^)(BOOL finished))completion {
    if (self.isAnimating) {
        [self.containerView.layer removeAllAnimations];
        self.isAnimating = NO;
        if (completion) {
            completion(YES);
        }
        return;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if (self.animateType == CMPreviewAnimateTypeDefault) {
        if (completion) {
            completion(YES);
        }
    }
    else if (self.animateType == CMPreviewAnimateTypeDropDown) {
        CGRect keyRect = [self convertRect:self.button.frame fromView:self.button.superview];
        
        CGFloat heightDiff = self.containerView.frame.size.height - keyRect.size.height;
        CGFloat dy = keyRect.origin.y - heightDiff / 2 - self.containerView.frame.origin.y;
        CGAffineTransform trans = CGAffineTransformMakeTranslation(0, dy);

        [UIView animateWithDuration:0.15 animations:^{
            self.isAnimating = YES;
            self.containerView.transform = trans;
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            if (finished && completion) {
                completion(finished);
            }
        }];
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

@end
