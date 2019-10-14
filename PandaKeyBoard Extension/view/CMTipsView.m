//
//  CMTipsView.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/10/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTipsView.h"

@interface CMTipsView()
@property (nonatomic, strong) MASConstraint* constaint;
@end

@implementation CMTipsView
@synthesize priority = _priority;
@synthesize duration = _duration;
@synthesize tipDelegate = _tipDelegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}




- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView duration:(CGFloat)duration {
    if (!superView) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
    [superView addSubview:self];
    if (self.tipDelegate &&  [self.tipDelegate respondsToSelector:@selector(tipsView:onShowed:)]) {
        
        [self.tipDelegate tipsView:self onShowed:nil];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView.mas_centerX);
        make.width.lessThanOrEqualTo(@(kScreenWidth * 0.975));
        self.constaint = make.top.equalTo(superView.mas_top);
        make.height.greaterThanOrEqualTo(@0);
    }];
    
    [superView setNeedsLayout];
    [superView layoutIfNeeded];
    
    self.constaint.offset(30.0f);
    [UIView animateWithDuration:0.3 animations:^{
        [superView layoutIfNeeded];
    }];
    if (duration > 0) {
        [self performSelector:@selector(removeFromView) withObject:nil afterDelay:duration];
    }
}

- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView {
    [self showInView:superView anchorView:anchorView duration:self.duration];
}

- (void)removeFromViewAnimate:(BOOL)animate enableCallBack:(BOOL)enable {
    if (self.superview) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
        [self removeAllAnimation];
        self.constaint.offset(0);
        if (animate) {
            [UIView animateWithDuration:.25 animations:^{
                [self.superview layoutIfNeeded];
            }completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (self.tipDelegate && enable &&  [self.tipDelegate respondsToSelector:@selector(tipsView:onRemoved:)]) {
                    [self.tipDelegate tipsView:self onRemoved:nil];
                }
            }];
        }
        else {
            [self removeFromSuperview];
            if (self.tipDelegate && enable&&  [self.tipDelegate respondsToSelector:@selector(tipsView:onRemoved:)]) {
                [self.tipDelegate tipsView:self onRemoved:nil];
            }
        }
    }
}

- (void)removeFromView {
    [self removeFromViewAnimate:YES enableCallBack:YES];
}

- (void)tapAction
{
    if (!self.superview) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
    [self removeAllAnimation];
    self.constaint.offset(0);
    [self removeFromSuperview];
    if (self.tipDelegate && [self.tipDelegate respondsToSelector:@selector(tipsView:onTapped:)]) {
        [self.tipDelegate tipsView:self onTapped:nil];
    }
}

- (void)handleSwipeFrom
{
    if (!self.superview) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
    [self removeAllAnimation];
    self.constaint.offset(0);
    [self removeFromSuperview];
    if (self.tipDelegate && [self.tipDelegate respondsToSelector:@selector(tipsView:onSwiped:)]) {
        [self.tipDelegate tipsView:self onSwiped:nil];
    }
}

@end
