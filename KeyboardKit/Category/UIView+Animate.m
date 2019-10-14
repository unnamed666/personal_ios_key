//
//  UIView+Animate.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIView+Animate.h"

@implementation UIView (Animate)

- (void)removeAllAnimation {
    [self.layer removeAllAnimations];
}

- (void)heartBeat {
    [self.layer removeAllAnimations];
    
    CASpringAnimation* pulse = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    pulse.duration = 0.68;
    pulse.fromValue = @(1.0);
    pulse.toValue = @(0.93);
    pulse.autoreverses = true;
    pulse.repeatCount = 1;
    pulse.initialVelocity = 0.5;
    pulse.damping = 0.8;
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup new];
    animationGroup.duration = 2.6;
    animationGroup.repeatCount = NSIntegerMax;
    animationGroup.animations = @[pulse];
    
    [self.layer addAnimation:animationGroup forKey:@"pulse"];
}

- (void)moveAnimationFromCenter:(CGPoint)centerPoint duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAnimation.duration = duration;
    basicAnimation.timingFunction = timingFunction;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    basicAnimation.fromValue = [NSValue valueWithCGPoint:centerPoint];
    [self.layer addAnimation:basicAnimation forKey:@"positionAni"];
}

- (void)horizontalMoveAnimationFromCenterX:(CGFloat)centerX duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction
{
    [self moveAnimationFromCenter:CGPointMake(centerX, self.center.y) duration:duration timingFunction:timingFunction];
}

- (void)verticalMoveAnimationFromCenterY:(CGFloat)centerY duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction
{
    [self moveAnimationFromCenter:CGPointMake(self.center.x, centerY) duration:duration timingFunction:timingFunction];
}

- (void)transformScaleAnimationFromScale:(CGFloat)scale duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = timingFunction;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.fromValue = @(scale);
    transformAnimation.toValue = @(1.0f);
    [self.layer addAnimation:transformAnimation forKey:@"transformAni"];
}

@end
