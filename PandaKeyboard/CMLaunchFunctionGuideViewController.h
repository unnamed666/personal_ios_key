//
//  CMLaunchFunctionGuideViewController.h
//  PandaKeyboard
//
//  Created by zhoujing on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseViewController.h"
@protocol GuideIntroduceDelegate<NSObject>
-(void)dismissGuidIntroduce;
@end
@interface CMLaunchFunctionGuideViewController : CMBaseViewController
@property(nonatomic,weak)id<GuideIntroduceDelegate> delegate;
@end
