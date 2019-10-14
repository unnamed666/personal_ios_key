//
//  CMErrorRefreshView.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/27.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMErrorRefreshViewDelegate <NSObject>
@optional
- (void)refreshDidClick;
@end

@interface CMErrorRefreshView : UIView
@property (nonatomic, weak) id<CMErrorRefreshViewDelegate> delegate;
@end
