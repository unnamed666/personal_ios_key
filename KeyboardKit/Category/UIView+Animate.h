//
//  UIView+Animate.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animate)

- (void)removeAllAnimation;

- (void)heartBeat;

- (void)moveAnimationFromCenter:(CGPoint)centerPoint duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction;

- (void)horizontalMoveAnimationFromCenterX:(CGFloat)centerX duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction;

- (void)verticalMoveAnimationFromCenterY:(CGFloat)centerY duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction;

- (void)transformScaleAnimationFromScale:(CGFloat)scale duration:(CGFloat)duration timingFunction:(CAMediaTimingFunction *)timingFunction;
   
@end
