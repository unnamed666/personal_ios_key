//
//  CMTipsViewProtocol.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/10.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CMTipsViewPriority) {
    spaceKeyLongPressTip = 0,
    cloudSuggestTip = 1,
    fullAccessTipCloud = 2,
    fullAccessTipSound = 3,
    fullAccessTipCursorMove = 4,
    fullAccessTipEmoticon = 5,
    fullAccessTipGif = 6,
};
@protocol CMTipsViewProtocol;

@protocol CMTipsViewDelegate <NSObject>

@optional
- (void)tipsView:(id<CMTipsViewProtocol>)view onShowed:(NSDictionary *)infoDic;

- (void)tipsView:(id<CMTipsViewProtocol>)view onTapped:(NSDictionary *)infoDic;

- (void)tipsView:(id<CMTipsViewProtocol>)view onSwiped:(NSDictionary *)infoDic;

- (void)tipsView:(id<CMTipsViewProtocol>)view onRemoved:(NSDictionary *)infoDic;

@end

@protocol CMTipsViewProtocol <NSObject>
@property (nonatomic, assign)CMTipsViewPriority priority;
@property (nonatomic, assign)CGFloat duration;
@property (nonatomic, weak)id<CMTipsViewDelegate> tipDelegate;

@optional

- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView duration:(CGFloat)duration;

- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView;

- (void)removeFromViewAnimate:(BOOL)animate enableCallBack:(BOOL)enable;

@end
