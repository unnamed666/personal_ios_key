//
//  CMRefreshFooter.m
//  iMessage
//
//  Created by yanzhao on 2017/9/30.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCollectionRefreshFooter.h"
#import <objc/message.h>

@interface CMCollectionRefreshFooter(){
    int _viewHight;
    BOOL isRefreshing;
}
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation CMCollectionRefreshFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    self.refreshingTarget = target;
    self.refreshingAction = action;
}
#define CMRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define CMRefreshMsgTarget(target) (__bridge void *)(target)
- (void)executeRefreshingCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{

        if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
            CMRefreshMsgSend(CMRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
        }
    });
}
- (void)beginRefreshing
{
    if(isRefreshing == YES)return;
    
    isRefreshing = YES;
    
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
    [self.loadingView startAnimating];
    [self executeRefreshingCallback];
}

- (void)endRefreshing{
    isRefreshing = NO;
    self.alpha = 0;
     [self.loadingView stopAnimating];
    self.hidden = YES;
}
- (void)setHidden:(BOOL)hidden
{
    BOOL lastHidden = self.isHidden;
    
    [super setHidden:hidden];
    
    if (!lastHidden && hidden) {
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom = inset.bottom - self.frame.size.height;
        self.scrollView.contentInset = inset;
    } else if (lastHidden && !hidden) {
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom = inset.bottom + self.frame.size.height;
        self.scrollView.contentInset = inset;
        // 设置位置
        self.frame = CGRectMake(0,  self.scrollView.contentSize.height, self.frame.size.width, _viewHight);
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    _viewHight  = 20;
    // 如果不是UIScrollView，不做任何事情
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    // 旧的父控件移除监听
    [self removeObservers];
    
    if (newSuperview) { // 新的父控件
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        
        if (self.hidden == NO) {
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.bottom = inset.bottom + self.frame.size.height;
            self.scrollView.contentInset = inset;
        }
        
//        self.frame = CGRectMake(0, _scrollView.contentSize.height, newSuperview.frame.size.width, _viewHight);
        self.frame = CGRectMake(0, _scrollView.contentSize.height, kScreenWidth, _viewHight);
        

        // 记录UIScrollView最开始的contentInset
//        _scrollViewOriginalInset = _scrollView.contentInset;
        
        // 添加监听
        [self addObservers];
    }else{
        if (self.hidden == NO) {
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.bottom = inset.bottom - self.frame.size.height;
            self.scrollView.contentInset = inset;
        }
    }

}
- (void)layoutSubviews{
    
    if (self.loadingView.constraints.count) return;
    
    // 圈圈
    CGFloat loadingCenterX = self.frame.size.width * 0.5;
//    if (!self.isRefreshingTitleHidden) {
//        loadingCenterX -= self.stateLabel.mj_textWith * 0.5 + self.labelLeftInset;
//    }
    CGFloat loadingCenterY = self.frame.size.height * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);
}
#pragma mark - KVO监听
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:options context:nil];
}

- (void)removeObservers
{
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    [self.superview removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self scrollViewContentSizeDidChange:change];
    }else if([keyPath isEqualToString:@"contentOffset"]){
        [self scrollViewContentOffsetDidChange:change];
        
    }

}


- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
   
     self.frame = CGRectMake(0,  self.scrollView.contentSize.height, self.frame.size.width, _viewHight);
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    if(isRefreshing)return;
    
    if (_scrollView.contentInset.top + _scrollView.contentSize.height > _scrollView.frame.size.height) { // 内容超过一个屏幕
        // 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
        if (_scrollView.contentOffset.y >= _scrollView.contentSize.height - _scrollView.frame.size.height + self.frame.size.height  + _scrollView.contentInset.bottom - self.frame.size.height) {
            // 防止手松开时连续调用
            CGPoint old = [change[@"old"] CGPointValue];
            CGPoint new = [change[@"new"] CGPointValue];
            if (new.y <= old.y) return;
            
            // 当底部刷新控件完全出现时，才刷新
            [self beginRefreshing];
        }
    }
}
#pragma mark - get
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}
@end
