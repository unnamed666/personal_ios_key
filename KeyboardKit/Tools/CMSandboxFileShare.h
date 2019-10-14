//
//  CMSandboxFileShare.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/26.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kCMSandboxFileShare [CMSandboxFileShare shareInstance]
@interface CMSandboxFileShare : NSObject
+ (instancetype)shareInstance;
//- (void)showSandboxBrowser;

- (void)showSandboxBrowser:(UIViewController *)viewController;
@end
