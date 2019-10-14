//
//  CMCursorMoveView.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/9/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCursorMoveView.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "CMFullAccessTipView.h"

typedef NS_ENUM(NSUInteger, CMCursorMoveDirection) {
    CMCursorMoveLeft,
    CMCursorMoveRight
};

@interface CMCursorMoveView ()

@property (nonatomic, strong) UIImageView* bgImageView;

@property (nonatomic, strong) UIImageView* circleImageView;
@property (nonatomic, strong) UIImageView* leftSmallImageView;
@property (nonatomic, strong) UIImageView* leftBigImageView;
@property (nonatomic, strong) UIImageView* rightSmallImageView;
@property (nonatomic, strong) UIImageView* rightBigImageView;

@property (nonatomic, assign) CGFloat horizontalIncreaseDistance;// 水平方向上累计移动的距离

@property (nonatomic, assign) BOOL isMove;// 是否正在左右移动调整光标位置
@property (nonatomic, assign) CMCursorMoveDirection cursorMoveDirection;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSTimer *holdTimer;
@property (nonatomic, assign) NSUInteger charOffsetBak;

@property (nonatomic, readwrite, assign) NSInteger cursorMoveUseCount;// 使用光标移动次数（两次以后不再展示引导文案）

@end

@implementation CMCursorMoveView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.bgImageView];
        [self addSubview:self.circleImageView];
        [self addSubview:self.leftSmallImageView];
        [self addSubview:self.leftBigImageView];
        [self addSubview:self.rightSmallImageView];
        [self addSubview:self.rightBigImageView];
        
        self.isMove = NO;
        self.cursorMoveUseCount = [[NSUserDefaults standardUserDefaults] integerForKey:kCursorMoveUseCount];
    }
    return self;
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgImageView.frame = self.bounds;
    
    self.circleImageView.width = self.isMove ?  50.0f : 37.0f;
    self.circleImageView.height = self.circleImageView.width;
    self.circleImageView.centerX = CGRectGetMidX(self.bounds);
    self.circleImageView.centerY = CGRectGetMidY(self.bounds);
    
    self.leftSmallImageView.width = 14.0f;
    self.leftSmallImageView.height = 24.0f;
    self.leftSmallImageView.right = self.bgImageView.centerX - 70.0f;
    self.leftSmallImageView.centerY = self.bgImageView.centerY;
    
    self.leftBigImageView.width = 16.0f;
    self.leftBigImageView.height = 29.0f;
    self.leftBigImageView.right = self.bgImageView.centerX - 55.0f;
    self.leftBigImageView.centerY = self.bgImageView.centerY;
    
    self.rightSmallImageView.width = 14.0f;
    self.rightSmallImageView.height = 24.0f;
    self.rightSmallImageView.left = self.bgImageView.centerX + 70.0f;
    self.rightSmallImageView.centerY = self.bgImageView.centerY;
    
    self.rightBigImageView.width = 16.0f;
    self.rightBigImageView.height = 29.0f;
    self.rightBigImageView.left = self.bgImageView.centerX + 55.0f;
    self.rightBigImageView.centerY = self.bgImageView.centerY;
    
}

#pragma mark - 
- (void)didMoveToWindow {
    if (self.window) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(arrowFlash) userInfo:nil repeats:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.cursorMoveUseCount < 2) {
                [self makeToast:CMLocalizedString(@"Slide right or left to move the cursor", nil) duration:NSIntegerMax position:CSToastPositionTop];
                [[NSUserDefaults standardUserDefaults] setInteger:self.cursorMoveUseCount + 1 forKey:kCursorMoveUseCount];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
    }else{
        [self invalidateTimer];
        if (_holdTimer) {
            [self.holdTimer invalidate];
            self.holdTimer = nil;
        }
    }
}

#pragma mark - dealloc
- (void)dealloc {
    kLogTrace();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - getter/setter
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
//        _bgImageView.backgroundColor = kCMKeyboardManager.themeManager.settingViewBgColor;
//        UIImage* image = kCMKeyboardManager.themeManager.keyboardViewBgImage;
//        if (image == nil) {
//            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.keyboardViewBgColor];
//        }
//        else {
//            [_bgImageView setImage:image];
//        }
    }
    return _bgImageView;
}

- (UIImageView *)circleImageView {
    if (!_circleImageView) {
        _circleImageView = [UIImageView new];
        _circleImageView.userInteractionEnabled = YES;
        [_circleImageView setImage:[[UIImage imageNamed:@"cursor_circle"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor]];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [panGestureRecognizer addTarget:self action:@selector(handlePan:)];
        [_circleImageView addGestureRecognizer:panGestureRecognizer];
    }
    return _circleImageView;
}

- (UIImageView *)leftSmallImageView {
    if (!_leftSmallImageView) {
        _leftSmallImageView = [UIImageView new];
        _leftSmallImageView.image = [[UIImage imageNamed:@"left_arrow"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor];
        _leftSmallImageView.alpha = 0.24f;
    }
    return _leftSmallImageView;
}

- (UIImageView *)leftBigImageView {
    if (!_leftBigImageView) {
        _leftBigImageView = [UIImageView new];
        _leftBigImageView.image = self.leftSmallImageView.image;
        _leftBigImageView.alpha = 1.0f;
    }
    return _leftBigImageView;
}

- (UIImageView *)rightSmallImageView {
    if (!_rightSmallImageView) {
        _rightSmallImageView = [UIImageView new];
        _rightSmallImageView.image = [[UIImage imageNamed:@"right_arrow"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor];
        _rightSmallImageView.alpha = 0.24f;
    }
    return _rightSmallImageView;
}

- (UIImageView *)rightBigImageView {
    if (!_rightBigImageView) {
        _rightBigImageView = [UIImageView new];
        _rightBigImageView.image = self.rightSmallImageView.image;
        _rightBigImageView.alpha = 1.0f;
    }
    return _rightBigImageView;
}

#pragma mark - Handle PanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        kLogInfo(@"[Gesture]UIGestureRecognizerStateBegan");
        if (_holdTimer) {
            [self.holdTimer invalidate];
            self.holdTimer = nil;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(holdOnCursorMove) object:nil];
        
        self.charOffsetBak = 0;

        if (self.cursorMoveUseCount < 2) {
            [self hideToasts];
        }
        self.horizontalIncreaseDistance = 0.0f;
        self.circleImageView.width = 47.0f;
        self.circleImageView.height = 47.0f;
        self.isMove = YES;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        kLogInfo(@"[Gesture]UIGestureRecognizerStateChanged...velocityInView(%@)", NSStringFromCGPoint([gestureRecognizer velocityInView:self.circleImageView.superview]));
        if (_holdTimer) {
            [self.holdTimer invalidate];
            self.holdTimer = nil;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(holdOnCursorMove) object:nil];

        CGPoint translation = [gestureRecognizer translationInView:self.circleImageView.superview];
    
        self.horizontalIncreaseDistance += translation.x;
        
        CGFloat originX = self.circleImageView.left + translation.x;
        if (originX <= 20.0f) {
            self.circleImageView.left = 20.0f;
        }else if (originX >= self.width - self.circleImageView.width - 20.0f) {
            self.circleImageView.right = self.width - 20.0f;
        }else {
            self.circleImageView.left += translation.x;
        }
        
        [gestureRecognizer setTranslation:CGPointZero inView:self.circleImageView.superview];
        
        NSInteger characterOffset = self.horizontalIncreaseDistance * 0.1;
        if (self.delegate && (characterOffset >= 1 || characterOffset <= -1)) {
            self.cursorMoveDirection = characterOffset >= 1 ? CMCursorMoveRight : CMCursorMoveLeft;
            self.horizontalIncreaseDistance = 0.0f;
            self.charOffsetBak = characterOffset;
            [self.delegate onCursorMoveViewMove:self characterOffset:characterOffset];
        }
        
        [self performSelector:@selector(holdOnCursorMove) withObject:nil afterDelay:0.35];
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
//        kLogInfo(@"[Gesture]UIGestureRecognizerStateBegan || UIGestureRecognizerStateCancelled(%ld)", (long)gestureRecognizer.state);
        if (_holdTimer) {
            [self.holdTimer invalidate];
            self.holdTimer = nil;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(holdOnCursorMove) object:nil];

        self.charOffsetBak = 0;

        self.circleImageView.centerX = CGRectGetMidX(self.bounds);
        self.circleImageView.centerY = CGRectGetMidY(self.bounds);
        self.isMove = NO;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)holdOnCursorMove {
    [self.holdTimer fire];
//    [self.holdTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

- (void)handleHoldOnTimer {
    if (self.delegate && (self.charOffsetBak >= 1 || self.charOffsetBak <= -1)) {
        self.cursorMoveDirection = self.charOffsetBak >= 1 ? CMCursorMoveRight : CMCursorMoveLeft;
        [self.delegate onCursorMoveViewMove:self characterOffset:self.charOffsetBak];
    }
}

- (NSTimer *)holdTimer {
    if (!_holdTimer) {
        _holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(handleHoldOnTimer) userInfo:nil repeats:YES];
    }
    return _holdTimer;
}

#pragma mark -
- (void)arrowFlash {
    if (self.isMove) {
        switch (self.cursorMoveDirection) {
            case CMCursorMoveLeft:
            {
                if (self.rightSmallImageView.alpha == 1.0f) {
                    self.rightSmallImageView.alpha = 0.24;
                    self.rightBigImageView.alpha = 1.0f;
                }
                if (self.leftSmallImageView.alpha == 1.0f) {
                    self.leftSmallImageView.alpha = 0.24f;
                    self.leftBigImageView.alpha = 1.0f;
                }else{
                    self.leftSmallImageView.alpha = 1.0f;
                    self.leftBigImageView.alpha = 0.24f;
                }
            }
                break;
            case CMCursorMoveRight:
            {
                if (self.leftSmallImageView.alpha == 1.0f) {
                    self.leftSmallImageView.alpha = 0.24;
                    self.leftBigImageView.alpha = 1.0f;
                }
                if (self.rightSmallImageView.alpha == 1.0f) {
                    self.rightSmallImageView.alpha = 0.24f;
                    self.rightBigImageView.alpha = 1.0f;
                }else{
                    self.rightSmallImageView.alpha = 1.0f;
                    self.rightBigImageView.alpha = 0.24f;
                }
            }
                
            default:
                break;
        }
    }else{
        if (self.leftSmallImageView.alpha == 1.0f) {
            self.leftSmallImageView.alpha = 0.24f;
            self.leftBigImageView.alpha = 1.0f;
            self.rightSmallImageView.alpha = 0.24f;
            self.rightBigImageView.alpha = 1.0f;
        }else{
            self.leftSmallImageView.alpha = 1.0f;
            self.leftBigImageView.alpha = 0.24f;
            self.rightSmallImageView.alpha = 1.0f;
            self.rightBigImageView.alpha = 0.24f;
            
        }
    }
}

- (void)invalidateTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
