//
//  CMRouterManager.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/12.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMRouterManager : NSObject
AS_SINGLETON(CMRouterManager)

@property (nonatomic, strong)UIViewController* rootController;

@property (nonatomic, strong)UIViewController* topMostViewController;

- (void)routeAndOpenPage:(NSURL *)actionUrl infoDic:(NSDictionary *)infoDic;

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController;

@end
