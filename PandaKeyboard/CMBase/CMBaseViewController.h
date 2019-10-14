//
//  CMBaseViewController.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMBaseViewController : UIViewController
@property (nonatomic, assign) BOOL canSwipRightToPopViewController;//控制是否支持侧滑返回，默认支持

- (BOOL)shouldSwipeBack;

- (BOOL)shouldShowKeyboardBtn;

- (void)showKeyboardBtn;
- (void)hideKeyboardBtn;
@end
