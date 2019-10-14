//
//  CMCustomTransitioningAnimation.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/9/4.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCustomTransitioningAnimation.h"

@implementation CMCustomTransitioningAnimation

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor blackColor];
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
}
@end
