//
//  CMBlackThemeKeyboardView.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/8/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//


#import "CMBlackThemeKeyboardView.h"
#import "CMSimmeringMaskLayer.h"

@interface CMBlackThemeKeyboardView () <CAAnimationDelegate>
@property (nonatomic, strong) NSMutableArray * freeMaskViews;
@property (nonatomic, strong) CMSimmeringMaskLayer* maskLayer;
@property (nonatomic, strong) CALayer * maskLayer2;
@property (nonatomic, strong) CAAnimationGroup* groupAnnimation;
@property (nonatomic, strong)CABasicAnimation * moveAnimation;
@end

@implementation CMBlackThemeKeyboardView

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.maskView= [[UIView alloc] init];
        self.freeMaskViews = [NSMutableArray new];
//        self.layer.borderColor = [UIColor redColor].CGColor;
//        self.layer.borderWidth=1;
    }
    return self;
}

#pragma mark - get/set

- (void)setIsCircleBackground:(BOOL)isCircleBackground{
    if(_isCircleBackground == isCircleBackground)
        return;
    _isCircleBackground = isCircleBackground;
}

- (CMSimmeringMaskLayer *)maskLayer{
    if(!_maskLayer){
        _maskLayer = [CMSimmeringMaskLayer layer];
//        CGFloat length = _viewWidth;
        
        UIColor *maskedColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        UIColor *unmaskedColor = [UIColor colorWithWhite:1.0 alpha:1];
        
        // Create a gradient from masked to unmasked to masked.
        _maskLayer.colors = @[(__bridge id)maskedColor.CGColor, (__bridge id)unmaskedColor.CGColor, (__bridge id)maskedColor.CGColor];
        _maskLayer.locations = @[@(0.35),
                                 @(0.5),
                                 @(0.65)];
        
        _maskLayer.anchorPoint = CGPointMake(0.5f, 0.0f);
        _maskLayer.startPoint = CGPointMake(0, 0.0);
        _maskLayer.endPoint = CGPointMake(1, 0.0);
        _maskLayer.bounds = CGRectMake(0.0, 0.0, _viewWidth,_viewHeight);
        _maskLayer.position = CGPointMake(_viewWidth/2-_viewWidth/6, 0);
        _maskLayer.fadeLayer.opacity = 0.0;
        _maskLayer.opacity = 1.0;
        _maskLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
    }
    return _maskLayer;
}

- (CALayer *)maskLayer2{
    if(!_maskLayer2){
        _maskLayer2 = [CALayer layer];
        _maskLayer2.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
    }
    return _maskLayer2;
}

- (CAAnimationGroup *)groupAnnimation{
    if(!_groupAnnimation){
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];//"z"还可以是“x”“y”，表示沿z轴旋转
        rotationAnimation.fromValue = [NSNumber numberWithFloat:M_PI_2];
        rotationAnimation.toValue = [NSNumber numberWithFloat:-M_PI_2];
        rotationAnimation.duration = 4.5f;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        self.moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];//"z"还可以是“x”“y”，表示沿z轴旋转
        _moveAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(_viewWidth/2-_viewWidth/6, 0)];
        _moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewWidth/2+_viewWidth/6, 0)];
        _moveAnimation.duration = 4.5f;
        _moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

        _groupAnnimation = [CAAnimationGroup animation];
        _groupAnnimation.duration = 4.5f;
//        _groupAnnimation.autoreverses = YES;
        _groupAnnimation.animations = @[_moveAnimation,rotationAnimation];
        //        _groupAnnimation.repeatCount = 1;
        _groupAnnimation.fillMode = kCAFillModeBoth;
        _groupAnnimation.removedOnCompletion = NO;
        _groupAnnimation.delegate = self;
    }
    return _groupAnnimation;
}

- (void)defaultConfig:(CGSize)viewSize {
    self.viewHeight = (int)viewSize.height;
    self.viewWidth = (int)viewSize.width;

    if(_maskLayer2.frame.size.height == self.viewHeight && _maskLayer2.frame.size.width == _viewWidth && _maskLayer2.frame.size.width != 0)return;
    

    
    
    
    int width = _viewWidth;
    int height = _viewHeight ;
//    int row = 25;
    int col;
    int circleSize = _isCircleBackground?4:8;
    UIColor *color = _isCircleBackground?rgb(64, 266, 237):rgb(0x05, 0xa4, 0xff);
    int HorizontalSpace = 12;
    int VerticalSpace= HorizontalSpace;
    col = height/(HorizontalSpace +circleSize + HorizontalSpace);


    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, (VerticalSpace +circleSize+VerticalSpace)*2), NO, 0);
    if(_isCircleBackground){
        for (int col = 0; col<2; col++) {
            for (int x =HorizontalSpace+col*(circleSize/2+HorizontalSpace); x<width; x=x+circleSize+HorizontalSpace+HorizontalSpace) {
                    CGRect frame = CGRectMake(x, col*(VerticalSpace +circleSize+VerticalSpace), circleSize, circleSize);
                    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect: frame];
                    [color setFill];
                    [p fill];
                }
            }
    }else{
        for (int col = 0; col<2; col++) {
            for (int x =HorizontalSpace; x<width; x=x+circleSize+HorizontalSpace+HorizontalSpace) {
                CGRect frame = CGRectMake(x, col*(VerticalSpace +circleSize+VerticalSpace), circleSize, circleSize);
                UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect: frame cornerRadius:0];
                [color setFill];
                [p fill];
            }
        }
    }

    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:img];
//    self.layer.contents = (id)img.CGImage;
    
    self.layer.anchorPoint = CGPointMake(0.5, 1);
    [self transformStateEvent];
    self.layer.mask = self.maskLayer;
//    [self.layer addSublayer:self.maskLayer];
    
    _maskLayer2.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
    _maskLayer.bounds = CGRectMake(0, 0, _viewWidth, _viewWidth>_viewHeight?_viewWidth:_viewHeight);
    if(_viewWidth > _viewHeight){
        _maskLayer.locations = @[@(0.45),
                                 @(0.5),
                                 @(0.55)];
        
    }else{
        _maskLayer.locations = @[@(0.35),
                                 @(0.5),
                                 @(0.65)];
    }
    _maskLayer.position = CGPointMake(_viewWidth/2-_viewWidth/6, 0);
    _moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewWidth/2+_viewWidth/6, 0)];
    
        [self startAnimtion];
}

- (void)startAnimtion{
    
    self.layer.mask = self.maskLayer;
    [self.maskLayer removeAllAnimations];
    [self.maskLayer addAnimation:self.groupAnnimation forKey:@"groupAnnimation"];
    
}

- (void)stopAnimtion{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.maskLayer removeAllAnimations];
    self.groupAnnimation.delegate = nil;
    self.groupAnnimation = nil;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    [self.maskLayer removeAllAnimations];
    
    self.layer.mask = self.maskLayer2;
    
}
//
//- (void)myTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
////    return;
//    [super touchesBegan:touches withEvent:event];
//    CGPoint p = [[touches anyObject] locationInView:self];
//    
//    CGRect frame = CGRectMake(p.x - 75, p.y-75,150,150);
//
//    
//    UIView *maskView = [_freeMaskViews lastObject];
//    if(!maskView){
//        maskView = [[UIView alloc] initWithFrame:frame];
//        UIImage *image      = [UIImage imageNamed:@"dt_mask"];
//        maskView.layer.contents = (__bridge id)(image.CGImage);
//        kLog(@"xin-----------------------");
//        [self.maskView addSubview:maskView];
//    }else{
//        [self.freeMaskViews removeObject:maskView];
//        maskView.frame = frame;
//    }
//    
//    
//    maskView.alpha = 1.f;
//
////    [UIView animateWithDuration:0.6
////                          delay:0.1
////                        options:UIViewAnimationOptionCurveEaseInOut
////                     animations:^{
////                         maskView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2, -CGRectGetHeight(self.frame),80,80);
////                     } completion:^(BOOL finished) {
////                         [self.freeMaskViews addObject:maskView];
////                     }];
////
////    [UIView animateWithDuration:0.5
////                          delay:0.0
////                        options:UIViewAnimationOptionCurveEaseInOut
////                     animations:^{
////                         maskView.alpha = 0.f;
////                     } completion:^(BOOL finished) {
////                         [self.freeMaskViews addObject:maskView];
////                     }];
//    
//
//    
////    if(!_rotationAnimation1){
////    self.rotationAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];//"z"还可以是“x”“y”，表示沿z轴旋转
////    _rotationAnimation1.toValue = [NSNumber numberWithFloat:-M_PI_2];
////    _rotationAnimation1.duration = 4.5f;
////    _rotationAnimation1.autoreverses = YES;
////        _rotationAnimation1.repeatCount = HUGE_VALF;
////    _rotationAnimation1.removedOnCompletion = NO;
////    _rotationAnimation1.delegate = self;
////        _rotationAnimation1.fillMode = kCAFillModeForwards;
////    _rotationAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
////    [self.maskLayer addAnimation:_rotationAnimation1 forKey:@"rotationAnimation1"];
////        
////        
////    }
//
////    [self.maskLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
//    
//}
- (void)myTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startAnimtion) withObject:nil afterDelay:1.5f];
}


+ (CGFloat)radianFromDegree:(CGFloat)degree {
    
    return ((degree) * M_PI / 180.f);
}
- (void)transformStateEvent {
    
    // 初始化3D变换,获取默认值
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    
    // 透视
    perspectiveTransform.m34 = -1.0/500.0;
    
    // 位移
//        perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -10);
    
    // 空间旋转
    perspectiveTransform = CATransform3DRotate(perspectiveTransform, [CMBlackThemeKeyboardView radianFromDegree:55], 1, 0, 0);
    
    // 缩放变换
    //    perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.75, 0.75, 0.75);
    
    self.layer.transform              = perspectiveTransform;
    self.layer.allowsEdgeAntialiasing = YES; // 抗锯齿
    self.layer.speed                  = 1.0;
}
@end
