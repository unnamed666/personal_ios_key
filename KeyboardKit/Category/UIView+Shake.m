//
//  UIView+Shake.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/9/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIView+Shake.h"

@implementation UIView (Shake)

- (void)shakeWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^ __nullable)(BOOL finished))completion
{
    CGFloat centerX = self.center.x;
    CGFloat centerY = self.center.y;
    
    [UIView animateKeyframesWithDuration:duration delay:delay options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX - 3, centerY);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX + 3, centerY);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX - 2, centerY);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX + 2, centerY);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX - 2, centerY);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX + 2, centerY);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            self.center = CGPointMake(centerX , centerY);
        }];
    } completion:completion];
    
}

@end
