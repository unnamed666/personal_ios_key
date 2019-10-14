//
//  CMBaseKeyboardView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseKeyboardView.h"
#import "CMBaseKeyboardViewModel.h"
#import "CMRowView.h"
#import "CMKeyPreviewView.h"
#import "UIView+Util.h"
#import "CMKeyButton.h"
#import "CMKeyModel.h"
#import "CMGroupDataManager.h"

#ifndef HostApp
#import "CMBatchInputTracker.h"
#import "InputPointers.h"
#endif
#import "UITouch+property.h"
//#import "SwiftTheme-Swift.h"

#import "CMKeyboardModel.h"
#import "CMTextInputModel.h"
#import "CMKeyboardManager.h"
#import "UIColor+HexColors.h"
#import "CMThemeManager.h"
#import "CMInputOptionView.h"
#import "CMExtensionBizHelper.h"

static NSInteger const kPointsCount = 50;
#ifndef HostApp
@interface CMBaseKeyboardView () <CMBatchInputTrackerDelegate>
#else
@interface CMBaseKeyboardView () 
#endif
//@property (nonatomic, strong)UIImageView* bgImageView;
@property (nonatomic, strong)NSMutableDictionary<NSValue*,CMKeyButton*>* touchViewDic;

@property (nonatomic, strong)NSMutableArray *layers;

@property (nonatomic, strong)NSMutableArray *points;

@property (nonatomic, assign)CGFloat trailWidth;

@property (nonatomic, strong)UIColor* trailColor;

@property (nonatomic, strong)CMKeyButton* currentTouchBtn;

@property (nonatomic, assign)BOOL isInLongPress;
@property (nonatomic, assign)BOOL isInBatchInput;

@property (nonatomic, strong)UIEvent *longPressTouchEvent;

@property (nonatomic, assign)BOOL isHideKey;

@end

@implementation CMBaseKeyboardView

- (instancetype)initWithFrame:(CGRect)frame { 
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _rowMargin = 0.0f;
        _keyMargin = 0.0f;
        _isInLongPress = NO;
        _isInBatchInput = NO;
//        self.exclusiveTouch = YES;
        self.multipleTouchEnabled = YES;
        _isHideKey = kCMKeyboardManager.themeManager.animateHidekey;
//        [self addSubview:self.bgImageView];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)didMoveToWindow {
//    if (self.window) {
//        // 注册通知
//        kLogInfo(@"注册通知 ThemeUpdateNotification");
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"ThemeUpdateNotification" object:nil];
//    }
//    else {
//        kLogInfo(@"移除通知 ThemeUpdateNotification");
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.bgImageView.frame = self.bounds;
}

- (void)switchTheme{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(switchTheme)]){
            [obj performSelector:@selector(switchTheme)];
        }
    }];
}

- (void)bindData:(CMBaseKeyboardViewModel *)viewModel {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - setter/getter
#ifndef HostApp
- (CMBatchInputTracker *)inputTracker {
    if (!_inputTracker) {
        _inputTracker = [[CMBatchInputTracker alloc] initWithDelegate:self];
    }
    return _inputTracker;
}

- (void)setIsInBatchInput:(BOOL)isInBatchInput {
    if (isInBatchInput != _isInBatchInput) {
        _isInBatchInput = isInBatchInput;
        if (!_isInBatchInput) {
            [self removeLayersAndPoints];
            [self.inputTracker reset];
        }
        else {
            [self createLayers];
        }
    }
}
#endif


//- (UIImageView *)bgImageView {
//    if (!_bgImageView) {
//        _bgImageView = [UIImageView new];
//        _bgImageView.tag = 111;
//        UIImage* image = kCMKeyboardManager.themeManager.keyboardViewBgImage;
//
//        if (image == nil) {
//            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.keyboardViewBgColor];
//        }
//        else
//        {
//            [_bgImageView setImage:image];
//        }
//    }
//    return _bgImageView;
//}

- (CMKeyPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[CMKeyPreviewView alloc] initWithFrame:self.superview.bounds];
    }
    return _previewView;
}

//- (CMMoreKeysView *)inputOptionView {
//    if (!_inputOptionView) {
//        _inputOptionView = [[CMMoreKeysView alloc] initWithFrame:self.superview.bounds];
//    }
//    return _inputOptionView;
//}

- (CMInputOptionView *)inputOptionView {
    if (!_inputOptionView) {
        _inputOptionView = [[CMInputOptionView alloc] initWithFrame:self.superview.bounds];
    }
    return _inputOptionView;
}

#pragma mark - touch event handler
- (NSMutableDictionary *)touchViewDic {
    if (!_touchViewDic) {
        _touchViewDic = [NSMutableDictionary dictionary];
    }
    return _touchViewDic;
}

- (BOOL)validateTouch:(UITouch *)newTouch ownView:(UIView *)ownView {
    BOOL foundView = YES;
    if (ownView != nil) {
        for (NSValue* key in self.touchViewDic) {
            if(self.touchViewDic[key]==ownView){
                foundView = NO;
            }
        }
//        [self.touchViewDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull touch, id  _Nonnull view, BOOL * _Nonnull stop) {
//            if (ownView == view) {
//                *stop = YES;
//            }
//            else {
//                [self.touchViewDic removeObjectForKey:touch];
//                foundView = YES;
//            }
//            *stop = YES;
//
//        }];
        NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(newTouch)];
        [self.touchViewDic setObject:(CMKeyButton*)ownView forKey:key];
    }
    return foundView;
}

- (void)showPreview:(CMKeyButton *)keyBtn {
    if (![keyBtn.keyModel shouldShowPreView]) {
        return;
    }
    if (_previewView && _previewView.superview) {
        if (self.isHideKey) {
            self.previewView.button.alpha = 0.0f;
        }
        return;
    }
    self.previewView.button = keyBtn;
    if (self.isHideKey) {
        self.previewView.button.alpha = 0.0f;
    }
    
    if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] &&
        self.previewView.button.keyModel.keyType == CMKeyTypeLetter) {
        [self showLightAnimation];
    }
    
    [self.superview addSubview:self.previewView];
}

// 展示按键发光效果
- (void)showLightAnimation
{
    if (!_previewView || !_previewView.superview) {
        return;
    }
    UIImageView *upperLight = [UIImageView new];// 灯光效果 上层的imageView
    upperLight.image = [UIImage imageNamed:@"preview_light"];
    upperLight.contentMode = UIViewContentModeScaleToFill;
    
    UIImageView *lowerLight = [UIImageView new];
    lowerLight.image = [UIImage imageNamed:@"preview_light"];// 灯光效果 下层的imageView
    lowerLight.contentMode = UIViewContentModeScaleToFill;

    [self insertSubview:lowerLight belowSubview:self.previewView.button.superview];
    [self insertSubview:upperLight belowSubview:self.previewView.button.superview];
    
    CGRect keyRect = [self.superview convertRect:self.previewView.button.frame fromView:self.previewView.button.superview];// 统一参考坐标系
    upperLight.height = CGRectGetMaxY(keyRect) - CGRectGetMaxY(self.previewView.containerFrame) + 28.0f + 8.0f;
    upperLight.width = CGRectGetWidth(self.previewView.containerFrame) * 1.5;
    upperLight.centerX = CGRectGetMidX(self.previewView.containerFrame);
    CGRect rect = [self convertRect:self.previewView.button.frame fromView:self.previewView.button.superview];
    upperLight.top = CGRectGetMaxY(self.previewView.containerFrame) - 28.0f - (CGRectGetMinY(keyRect) - CGRectGetMinY(rect));
    lowerLight.frame = upperLight.frame;
    
    lowerLight.alpha = 0.0;
    [UIView animateWithDuration:0.13 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        lowerLight.alpha = 1.0;
    } completion:nil];
    [UIView animateWithDuration:0.13 delay:0.33 options:UIViewAnimationOptionCurveLinear animations:^{
        lowerLight.alpha = 0.0;
    } completion:^(BOOL finished) {
        [lowerLight removeFromSuperview];
    }];
    
    
    upperLight.alpha = 0.0;
    [UIView animateWithDuration:0.1 animations:^{
        upperLight.alpha = 1.0;
    }];
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        upperLight.alpha = 0.0;
    } completion:^(BOOL finished) {
        [upperLight removeFromSuperview];
    }];
}


- (void)hidePreView:(BOOL)animate {
    if (!_previewView || !_previewView.superview) {
        return;
    }
    
    if (animate) {
        @weakify(self);
        [self.previewView removeWithAnimation:^(BOOL finished) {
            @stronglize(self);
            if (finished) {
                self.previewView.button.alpha = 1.0f;
                [self.previewView removeFromSuperview];
                self.previewView = nil;
            }
        }];
    }
    else {
        self.previewView.button.alpha = 1.0f;
        [self.previewView removeFromSuperview];
        self.previewView = nil;
    }
}

- (void)showInputOptionView:(CMKeyButton *)keyBtn {
    if (![keyBtn.keyModel shouldShowInputOptionsView]) {
        return;
    }
    if (_inputOptionView && _inputOptionView.superview) {
        return;
    }
    [self.superview addSubview:self.inputOptionView];
    self.inputOptionView.button = keyBtn;
    if (self.isHideKey) {
        self.inputOptionView.button.alpha = 0.0f;
    }
}


- (void)hideInputOptionView {
    if (!_inputOptionView || !_inputOptionView.superview) {
        return;
    }
    self.inputOptionView.button.alpha = 1.0f;
    [self.inputOptionView removeFromSuperview];
    self.inputOptionView = nil;
}

- (void)handleLongPress {
    if (self.currentTouchBtn && !self.isInLongPress) {
        [self handleControl:self.currentTouchBtn controlEvent:(UIControlEvents)CMControlEventLongPress withEvent:self.longPressTouchEvent];
        self.isInLongPress = YES;
        self.isInBatchInput = NO;
    }
}

- (BOOL)shouldUseBatchInpupt {
    if(UITextAutocorrectionTypeNo == self.viewModel.keyboadModel.inputModel.autocorrectionType)return NO;
    if (self.viewModel.keyboadModel.inputModel.keyboardType == UIKeyboardTypeURL || self.viewModel.keyboadModel.inputModel.keyboardType == UIKeyboardTypeEmailAddress) {
        return NO;
    }
    
    BOOL enable = [CMGroupDataManager shareInstance].isSlideInputEnable;
    BOOL dicEnabel = (self.dataSource && [self.dataSource respondsToSelector:@selector(isMainDicValidInkeyboardView:)]) ? [self.dataSource isMainDicValidInkeyboardView:self] : NO;
    return enable && dicEnabel;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.isInLongPress) {
        self.isInBatchInput = NO;
        return;
    }
#ifndef HostApp
    if ([self shouldUseBatchInpupt] && event.allTouches.count == 1) {
        UITouch *touch = [touches anyObject] ;
        CGPoint curP =   [touch locationInView:self];
        NSValue *value = [NSValue valueWithCGPoint:curP];
        CMKeyButton* aKeyButton = [CMExtensionBizHelper findNearestKeyButtonInView:self point:curP];
        if (aKeyButton) {
            if ([aKeyButton.keyModel shouldUseBatchInput]) {
                [self.inputTracker addDownEventPoint:curP identify:touch keyModel:aKeyButton.keyModel downEventTime:event.timestamp*1000 lastLetterTypingTime:0 activePointerCount:touch.tapCount];
                [self.points addObject:value];
            }
        }
    }
#endif
    [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
        
        
        NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
        
        if(touch.phase == UITouchPhaseBegan){
            CGPoint position = [touch locationInView:self];
            CMKeyButton* view = [CMExtensionBizHelper findNearestKeyButtonInView:self point:position];
            if (view){
                touch.onScreen = NO;
                [self.touchViewDic setObject:view forKey:key];
                
                    if (touch.tapCount > 1) {
                        [self handleControl:view controlEvent:UIControlEventTouchDownRepeat withEvent:event];
                    }
                    else
                    {
                        [view handleTouchDown:touch];
//                        [self handleControl:view controlEvent:UIControlEventTouchDown withEvent:event];
                    }
                    
                    if ([view.keyModel shouldLongPressKey] || [view.keyModel shouldShowInputOptionsView]) {
                            self.currentTouchBtn = (CMKeyButton *)view;
                            self.longPressTouchEvent = event;
                            [self performSelector:@selector(handleLongPress)
                                       withObject:nil
                                       afterDelay:0.6];
                    }

            }
        }else if(touch.phase == UITouchPhaseMoved ||  touch.phase == UITouchPhaseStationary){
            CMKeyButton* buttonView =  self.touchViewDic[key];
            if(buttonView){
                touch.onScreen = YES;
                [buttonView handleTouchUpInside:touch];
//                [self handleControl:buttonView controlEvent:UIControlEventTouchUpInside withEvent:event];
                
            }
        }
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.isInLongPress && self.currentTouchBtn) {
        [self handleControl:self.currentTouchBtn controlEvent:(UIControlEvents)CMControlEventPan withEvent:event];
        self.isInBatchInput = NO;
        return;
    }

    UITouch *touch = [touches anyObject] ;
    CGPoint position =   [touch locationInView:self];
    NSValue *value = [NSValue valueWithCGPoint:position];
#ifndef HostApp
    if ([self shouldUseBatchInpupt] && event.allTouches.count == 1) {
        CMKeyButton* theView = [CMExtensionBizHelper findNearestKeyButtonInView:self point:position];
        if (theView) {
            CMKeyButton* keyButton = (CMKeyButton *)theView;
            BOOL onValidArea = [self.inputTracker addMoveEventPoint:position identify:touch moveEventTime:touch.timestamp*1000 keyModel:keyButton.keyModel isMajorEvent:NO];
            if (!onValidArea) {
                self.isInBatchInput = NO;
                return;
            }
            if (!self.isInBatchInput) {
                CMKeyButton* keyButton = (CMKeyButton *)theView;
                if ([keyButton.keyModel shouldUseBatchInput] && [self.inputTracker mayStartBatchInput]) {
                    self.isInBatchInput = YES;
                }
                
            }
        }
    }
#endif
    if (self.isInBatchInput) {
#ifndef HostApp
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleLongPress) object:nil];
        [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
            CMKeyButton* view = [self.touchViewDic objectForKey:key];
            touch.onScreen = NO;
            [self hidePreView:NO];
            [view handleTouchCancel:touch];
//            [self handleControl:view controlEvent:UIControlEventTouchCancel withEvent:event];
            [self.touchViewDic removeObjectForKey:key];
        }];

        CMKeyButton* theView = [CMExtensionBizHelper findNearestKeyButtonInView:self point:position];
        if (theView) {
            [self.inputTracker updateBatchInput:touch.timestamp*1000];
        }
        [self.points addObject:value];
        [self startAnim];
        
#endif
    }
    else {
        [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            if(touch.onScreen)return;
            NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
            CMKeyButton* oldView = [self.touchViewDic objectForKey:key];
            
            CGPoint position = [touch locationInView:self];
            CMKeyButton* newView = [CMExtensionBizHelper findNearestKeyButtonInView:self point:position];

            if (oldView != newView && oldView != nil) {
                [self hidePreView:NO];
                [self handleControl:oldView controlEvent:UIControlEventTouchDragExit withEvent:event];
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleLongPress) object:nil];
                BOOL viewChangedOwnership = [self validateTouch:touch ownView:newView];
                
                if (!viewChangedOwnership) {
                    [self showPreview:(CMKeyButton *)newView];
                    [self handleControl:newView controlEvent:UIControlEventTouchDragEnter withEvent:event];
                    self.currentTouchBtn = nil;
                }
                else {
                    [self showPreview:(CMKeyButton *)newView];
                    [self handleControl:newView controlEvent:UIControlEventTouchDragInside withEvent:event];
                }
            }
            else if (oldView != nil) {
                [self showPreview:(CMKeyButton *)oldView];
                [self handleControl:oldView controlEvent:UIControlEventTouchDragInside withEvent:event];
            }
        }];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.isInLongPress && self.currentTouchBtn) {
        [self handleControl:self.currentTouchBtn controlEvent:(UIControlEvents)CMControlEventPanEndOrCancel withEvent:event];
        [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
            CMKeyButton* view = [self.touchViewDic objectForKey:key];
            [self hidePreView:NO];
            [view handleTouchCancel:touch];
//            [self handleControl:view controlEvent:UIControlEventTouchCancel withEvent:event];
            [self.touchViewDic removeObjectForKey:key];
        }];
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleLongPress) object:nil];
        self.currentTouchBtn = nil;
        self.isInLongPress = NO;
    }
    else {
        if([self shouldUseBatchInpupt] && self.isInBatchInput) {
            #ifndef HostApp
            if ([self.inputTracker mayEndBatchInput:event.timestamp*1000 activePointerCount:1]) {
                [self removeLayersAndPoints];
                self.isInBatchInput = NO;
            }
#endif
        }
        else {
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleLongPress) object:nil];
            self.currentTouchBtn = nil;
            self.isInLongPress = NO;
            [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
                
                if(touch.phase == UITouchPhaseEnded){
                    NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
                    CMKeyButton* view = [self.touchViewDic objectForKey:key];
                    if(view){
                        if(!touch.onScreen){
                            CGPoint touchPosition = [touch locationInView:self];
                            if (CGRectContainsPoint(self.bounds, touchPosition)) {
                                [view handleTouchUpInside:touch];
//                                [self handleControl:view controlEvent:UIControlEventTouchUpInside withEvent:event];
                            }
                            else {
                                [view handleTouchCancel:touch];
//                                [self handleControl:view controlEvent:UIControlEventTouchCancel withEvent:event];
                            }
                        }else{
                            touch.onScreen = NO;
                        }
                        [self.touchViewDic removeObjectForKey:key];
                    }
                }
            }];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isInLongPress && self.currentTouchBtn) {
        [self handleControl:self.currentTouchBtn controlEvent:(UIControlEvents)CMControlEventPanEndOrCancel withEvent:event];
    }

    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleLongPress) object:nil];
    self.currentTouchBtn = nil;
    self.isInLongPress = NO;

    if ([self shouldUseBatchInpupt] && self.isInBatchInput) {
        #ifndef HostApp
        if ([self.inputTracker mayEndBatchInput:event.timestamp*1000 activePointerCount:1]) {
            [self removeLayersAndPoints];
            self.isInBatchInput = NO;
        }
#endif
    }
    else {
        [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            NSValue* key = [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
            CMKeyButton* view = [self.touchViewDic objectForKey:key];
            [self hidePreView:NO];
            [view handleTouchCancel:touch];
//            [self handleControl:view controlEvent:UIControlEventTouchCancel withEvent:event];
            [self.touchViewDic removeObjectForKey:key];
            touch.onScreen = NO;
        }];
    }
}

- (void)handleControl:(UIView *)view controlEvent:(UIControlEvents)controlEvent withEvent:(UIEvent *)event {
    if (view == nil && ![view isMemberOfClass:[UIControl class]]) {
        return;
    }
    UIControl* control = (UIControl *)view;
    [control.allTargets enumerateObjectsUsingBlock:^(id  _Nonnull target, BOOL * _Nonnull stop) {
        NSArray<NSString *>* actions = [control actionsForTarget:target forControlEvent:controlEvent];
        for (NSString* action in actions) {
            [control sendAction:NSSelectorFromString(action) to:target forEvent:event];
        }
    }];
    
}

- (void)resetTrackedViews {
    [self.touchViewDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull touch, id  _Nonnull view, BOOL * _Nonnull stop) {
        [self handleControl:view controlEvent:UIControlEventTouchCancel withEvent:touch];
    }];
    [self.touchViewDic removeAllObjects];
}

- (void)createLayers{
    [self removeLayersAndPoints];
    
    for(int i = 0 ; i < kPointsCount + 1; i++){
        //图层
        CAShapeLayer *layer = [CAShapeLayer layer] ;
        [self.layer addSublayer:layer] ;
        [self.layers insertObject:layer atIndex:0];
    }
}

-(void)removeLayersAndPoints{
    [self.points removeAllObjects];
    [self.layers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.layers removeAllObjects];
}

- (CGPoint)getRecursiveMidPt:(CGPoint)point1 point2:(CGPoint)point2 {
    if ([self distanceWithPoint1:point1 point2:point2] < 10) {
        CGPoint midPt = [self midPointWithPoint1:point1 Point2:point2];
        return midPt;
    }
    
    return [self getRecursiveMidPt:point1 point2:[self midPointWithPoint1:point1 Point2:point2]];
}

- (void)addRecursivePath:(CGPoint)point1 point2:(CGPoint)point2 path:(UIBezierPath *)path {
    CGPoint midPt = [self getRecursiveMidPt:point1 point2:point2];
    if ([self distanceWithPoint1:midPt point2:point2] < 10) {
        [path addQuadCurveToPoint:point2 controlPoint:[self midPointWithPoint1:point2 Point2:midPt]];
        return;
    }
    [path addQuadCurveToPoint:midPt controlPoint:[self midPointWithPoint1:point1 Point2:midPt]];
    [self addRecursivePath:midPt point2:point2 path:path];
}


- (void)startAnim{
    self.trailWidth = 3;
    
    [self.points enumerateObjectsUsingBlock:^(NSValue*  _Nonnull ptValue, NSUInteger idx, BOOL * _Nonnull stop) {
        self.trailWidth += 12.0/kPointsCount;
        CGPoint curPt = [ptValue CGPointValue];
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:curPt];
        
        CGPoint pre1Pt = CGPointZero;
        if(idx >= 1){
            NSValue *value= [self.points objectAtIndex:idx - 1];
            pre1Pt = [value CGPointValue];
            //            [self addRecursivePath:curPt point2:pre1Pt path:path];
            
            //            //取两个点的中间点
            CGPoint midP = [self midPointWithPoint1:pre1Pt Point2:curPt];
            [path addQuadCurveToPoint:pre1Pt controlPoint:midP];
        }
        
        if(idx >= 2){
            NSValue *value= [self.points objectAtIndex:idx - 2];
            CGPoint pre2Pt = [value CGPointValue];
            
            if(!CGPointEqualToPoint(pre1Pt, CGPointZero)){
                //取两个点的中间点
                CGPoint midP = [self midPointWithPoint1:pre2Pt Point2:pre1Pt];
                [path addQuadCurveToPoint:pre2Pt controlPoint:midP];
            }
        }
        
        //        if(i >= 3){
        //        }
        
        CAShapeLayer *layer = [self.layers objectAtIndex:idx];
        layer.path = path.CGPath;
        layer.lineWidth = self.trailWidth;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineJoin = kCALineJoinRound;
        layer.lineCap = kCALineCapRound;
        layer.strokeColor = self.trailColor.CGColor;
    }];
    
    if(self.points.count >20){
        [self.points removeObjectAtIndex:0];
    }
}



-(void)startAnim2{
    self.trailWidth = 3;
    if (self.points.count < 4) {
        [self.points enumerateObjectsUsingBlock:^(NSValue*  _Nonnull ptValue, NSUInteger idx, BOOL * _Nonnull stop) {
            self.trailWidth += 20.0/kPointsCount;
            CGPoint curPt = [ptValue CGPointValue];
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            [path moveToPoint:curPt];
            
            CGPoint pre1Pt = CGPointZero;
            if(idx >= 1){
                NSValue *value= [self.points objectAtIndex:idx - 1];
                pre1Pt = [value CGPointValue];
                //            [self addRecursivePath:curPt point2:pre1Pt path:path];
                
                //            //取两个点的中间点
                CGPoint midP = [self midPointWithPoint1:pre1Pt Point2:curPt];
                [path addQuadCurveToPoint:pre1Pt controlPoint:midP];
            }
            
            CAShapeLayer *layer = [self.layers objectAtIndex:idx];
            layer.path = path.CGPath;
            layer.lineWidth = self.trailWidth;
            layer.fillColor = [UIColor clearColor].CGColor;
            layer.lineJoin = kCALineJoinRound;
            layer.lineCap = kCALineCapRound;
            layer.strokeColor = self.trailColor.CGColor;
        }];
    }
    else {
        NSUInteger index = 0;
        NSUInteger mod = self.points.count%4;
        NSArray* subArray1 = [self.points subarrayWithRange:NSMakeRange(0, self.points.count - mod)];

        NSInteger i;
        for (i = 0; i < subArray1.count; i=i+4) {
            self.trailWidth += 20.0/kPointsCount;
            CGPoint Pt1 = [[subArray1 objectAtIndex:i] CGPointValue];
            CGPoint Pt2 = [[subArray1 objectAtIndex:i+1] CGPointValue];
            CGPoint Pt3 = [[subArray1 objectAtIndex:i+2] CGPointValue];
            CGPoint Pt4 = [[subArray1 objectAtIndex:i+3] CGPointValue];
            UIBezierPath *path = [UIBezierPath bezierPath];

            if (i != 0) {
                CGPoint lastPt = [[subArray1 objectAtIndex:i-1] CGPointValue];
                [path moveToPoint:lastPt];
                [path addCurveToPoint:Pt4 controlPoint1:Pt1 controlPoint2:Pt3];
            }
            else {
                [path moveToPoint:Pt1];
                [path addCurveToPoint:Pt4 controlPoint1:Pt2 controlPoint2:Pt3];
            }
            CAShapeLayer *layer = [self.layers objectAtIndex:index++];
            layer.path = path.CGPath;
            layer.lineWidth = self.trailWidth;
            layer.lineJoin = kCALineJoinRound;
            layer.lineCap = kCALineCapRound;
            layer.fillColor = [UIColor clearColor].CGColor;
            layer.strokeColor = self.trailColor.CGColor;
        }
        if (mod > 0) {
            NSArray* subArray2 = [self.points subarrayWithRange:NSMakeRange(self.points.count - mod - 1, mod)];
            if (subArray2.count == 1) {
                self.trailWidth += 20.0/kPointsCount;
                CGPoint lastPt = [[subArray1 objectAtIndex:i-1] CGPointValue];
                CGPoint last2Pt = [[subArray1 objectAtIndex:i-2] CGPointValue];
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:last2Pt];
                [path addQuadCurveToPoint:[[subArray2 objectAtIndex:0] CGPointValue] controlPoint:lastPt];
                CAShapeLayer *layer = [self.layers objectAtIndex:index++];
                layer.path = path.CGPath;
                layer.lineWidth = self.trailWidth;
                layer.lineJoin = kCALineJoinRound;
                layer.lineCap = kCALineCapRound;
                layer.strokeColor = self.trailColor.CGColor;
            }
            else if (subArray2.count == 2) {
                self.trailWidth += 20.0/kPointsCount;
                CGPoint lastPt = [[subArray1 objectAtIndex:i-1] CGPointValue];
                CGPoint last2Pt = [[subArray1 objectAtIndex:i-2] CGPointValue];
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:last2Pt];
                [path addCurveToPoint:[[subArray2 objectAtIndex:1] CGPointValue] controlPoint1:lastPt controlPoint2:[[subArray2 objectAtIndex:0] CGPointValue]];
                CAShapeLayer *layer = [self.layers objectAtIndex:index++];
                layer.path = path.CGPath;
                layer.lineWidth = self.trailWidth;
                layer.lineJoin = kCALineJoinRound;
                layer.lineCap = kCALineCapRound;
                layer.fillColor = [UIColor clearColor].CGColor;
                layer.strokeColor = self.trailColor.CGColor;
            }
            else if (subArray2.count == 3) {
                self.trailWidth += 20.0/kPointsCount;
                CGPoint lastPt = [[subArray1 objectAtIndex:i-1] CGPointValue];
                CGPoint last2Pt = [[subArray1 objectAtIndex:i-2] CGPointValue];
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:last2Pt];
                [path addCurveToPoint:[[subArray2 objectAtIndex:2] CGPointValue] controlPoint1:lastPt controlPoint2:[[subArray2 objectAtIndex:1] CGPointValue]];
                CAShapeLayer *layer = [self.layers objectAtIndex:index++];
                layer.path = path.CGPath;
                layer.lineWidth = self.trailWidth;
                layer.lineJoin = kCALineJoinRound;
                layer.lineCap = kCALineCapRound;
                layer.fillColor = [UIColor clearColor].CGColor;
                layer.strokeColor = self.trailColor.CGColor;
            }
        }
    }

    if(self.points.count >20){
        [self.points removeObjectAtIndex:0];
    }
}

#pragma mark -获取两点的中间点

-(CGPoint)midPointWithPoint1:(CGPoint) p1 Point2:(CGPoint) p2{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

-(CGFloat)distanceWithPoint1:(CGPoint)pt1 point2:(CGPoint)pt2
{
    CGFloat dx = pt2.x - pt1.x;
    CGFloat dy = pt2.y - pt1.y;
    return sqrtf(dx * dx + dy * dy);
}

-(NSMutableArray *)layers{
    if(!_layers){
        _layers = [NSMutableArray new] ;
    }
    return _layers ;
}

-(NSMutableArray *)points{
    if(!_points){
        _points = [NSMutableArray new] ;
    }
    return _points ;
}

- (UIColor *)trailColor {
    if (!_trailColor) {
        UIColor* color = kCMKeyboardManager.themeManager.tintColor;
        _trailColor = color ? color : [UIColor redColor];
    }
    return _trailColor;
}

- (void)startDeleteRepeate:(NSNumber*)repeateType;
{
    if ([repeateType isEqual:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeNormal]])
    {
        [self.delegate onKeyboard:self touchDownKeyModel:self.deleteKeyModel touchPt:self.deleteTouchPoint fromeRepeate:NO];
        return;
    }
    
    if (self.isDeleteButtonDown && self.deleteKeyModel.keyType == CMKeyTypeDel)
    {
        [self.delegate onKeyboard:self touchDownKeyModel:self.deleteKeyModel touchPt:self.deleteTouchPoint fromeRepeate:YES];
        
        CGFloat timeFloat = 0.6;
        
        if (![repeateType  isEqual:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeLong]])
        {
            timeFloat = 0.1;
        }
        
        [self performSelector:@selector(startDeleteRepeate:) withObject:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeShort] afterDelay:timeFloat];
    }
}

- (void)cancleDeleteRepeate:(CMBaseKeyboardView*)keyboardView deleteButton:(CMKeyButton*) deleteButton
{
    [NSObject cancelPreviousPerformRequestsWithTarget:keyboardView selector:@selector(startDeleteRepeate:) object:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeLong]];
    [NSObject cancelPreviousPerformRequestsWithTarget:keyboardView selector:@selector(startDeleteRepeate:) object:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeShort]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - CMBatchInputTrackerDelegate
- (void)onStartbatchInput:(CMBatchInputTracker *)tracker {
//    kLogInfo(@"[BATCH]onStartbatchInput   : tracker=%@", tracker);
    if (self.delegate) {
        [self.delegate onKeyboard:self startbatchInput:nil];
    }
}

- (void)onUpateBatchInput:(CMBatchInputTracker *)tracker pointModel:(InputPointers *)inputPointerModel moveEventTime:(NSTimeInterval)moveTime {
    kLogInfo(@"[BATCH]onUpateBatchInput   : batchPoints=%@", inputPointerModel);
    if (self.delegate && inputPointerModel) {
        [self.delegate onKeyboard:self upateBatchInputPointerModel:inputPointerModel];
    }
}

- (void)onStartUpdateBatchInputTimer:(CMBatchInputTracker *)tracker {
//    kLogInfo(@"[BATCH]onStartUpdateBatchInputTimer   : tracker=%@", tracker);
}

- (void)onEndBatchInput:(CMBatchInputTracker *)tracker pointModel:(InputPointers *)inputPointerModel upEventTime:(NSTimeInterval)upTime {
//    kLogInfo(@"[BATCH]onEndBatchInput   : batchPoints=%@", inputPointerModel);
    if (self.delegate && inputPointerModel) {
        [self.delegate onKeyboard:self endBatchInputPointerModel:inputPointerModel];
    }
}


@end
