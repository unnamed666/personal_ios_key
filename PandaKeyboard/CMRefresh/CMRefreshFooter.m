//
//  CMRefreshFooter.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRefreshFooter.h"
#import <Lottie/Lottie.h>

@interface CMRefreshFooter ()
@property (nonatomic, strong) LOTAnimationView * animationView;
@end

@implementation CMRefreshFooter
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
    
    if(self.state == MJRefreshStateNoMoreData){
        [_animationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@0);
            make.height.equalTo(@0);
        }];
    }else{
        [_animationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@(self.mj_w * 0.5));
            make.height.equalTo(@(self.mj_h));
        }];
    }
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
    _animationView.hidden = YES;
    switch (state) {
        case MJRefreshStateIdle:
        {
            [_animationView pause];
        }
            break;
        case MJRefreshStateRefreshing:
        {
            _animationView.hidden = NO;
            [_animationView play];
        }
            break;
        case MJRefreshStateNoMoreData:
        {
            [_animationView pause];
        }
            break;
        default:
            break;
    }
    
    [self setNeedsLayout];
}

@end
