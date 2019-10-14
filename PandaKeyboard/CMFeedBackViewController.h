//
//  CMFeedBackViewController.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/5/30.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseViewController.h"

@interface CMFeedBackViewController : CMBaseViewController

@property (nonatomic, assign)NSUInteger inSource; // 进入此页面的来源  1:代表点击设置页的Feedback按钮进入（默认） 2：代表点击键盘的feedback按钮进入

@end

//@interface CMCustomLabel : UILabel
//
//@end

@interface CMCustomBgView : UIView

@end
