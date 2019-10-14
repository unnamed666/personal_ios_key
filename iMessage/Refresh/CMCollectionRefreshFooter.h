//
//  CMRefreshFooter.h
//  iMessage
//
//  Created by yanzhao on 2017/9/30.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMCollectionRefreshFooter : UIView{
    
    __weak UIScrollView *_scrollView;
}
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

- (void)beginRefreshing;
- (void)endRefreshing;

/** 设置回调对象和回调方法 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;

/** 回调对象 */
@property (weak, nonatomic) id refreshingTarget;
/** 回调方法 */
@property (assign, nonatomic) SEL refreshingAction;

@end
