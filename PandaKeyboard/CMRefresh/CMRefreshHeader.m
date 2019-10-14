//
//  CMRefreshHeader.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRefreshHeader.h"
#import <Lottie/Lottie.h>

@interface CMRefreshHeader()
@property (nonatomic, strong) LOTAnimationView * animationView;
@end

@implementation CMRefreshHeader
#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    
    _animationView = [LOTAnimationView animationNamed:@"LoadingDotsLoop"];
    _animationView.contentMode = UIViewContentModeScaleAspectFill;
    _animationView.loopAnimation = YES;
    [self addSubview:_animationView];
    
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    _animationView.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.5);
    
    _animationView.bounds = CGRectMake(0, 0, self.mj_w * 0.5, self.mj_h);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            [_animationView pause];
            break;
        case MJRefreshStatePulling:
            [_animationView pause];
            break;
        case MJRefreshStateRefreshing:
            [_animationView play];
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    _animationView.animationProgress = pullingPercent;

}

@end
