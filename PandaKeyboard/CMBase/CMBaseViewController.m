//
//  CMBaseViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseViewController.h"
#import "UIDevice+Util.h"
#import "CMRouterManager.h"
#import "CMTabBarViewController.h"

@interface CMBaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation CMBaseViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkBottomBarHideState:YES];
    if ([[CMRouterManager sharedInstance].rootController isKindOfClass:[CMTabBarViewController class]]) {
        CMTabBarViewController* tabbarVC = (CMTabBarViewController *)[CMRouterManager sharedInstance].rootController;
        if ([self shouldShowKeyboardBtn] && [self hasTextField]) {
            [tabbarVC setKeyboardButtonHidden:NO];
        }
        else {
            [tabbarVC setKeyboardButtonHidden:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkBottomBarHideState:NO];
}

- (void)checkBottomBarHideState:(BOOL)isWillState
{
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        if (isWillState) {
            self.tabBarController.hidesBottomBarWhenPushed = YES;
        }
    }else{
        if (!isWillState) {
            self.tabBarController.hidesBottomBarWhenPushed = NO;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    kLog(@"进入当前VC : %@",NSStringFromClass([self class]));
    
    if ([self shouldSwipeBack]) {
        self.canSwipRightToPopViewController = YES;
        
        id target = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
        panGesture.delegate = self;
        [self.view addGestureRecognizer:panGesture];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)handleNavigationTransition:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self gestureRecognizerShouldBegin:panGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(self.navigationController.childViewControllers.count == 1 || self.canSwipRightToPopViewController == NO)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)hasTextField {
    NSArray* array = [self.view allSubviewsWithClass:[UITextField class]];
    return array && array.count > 0;
}

- (BOOL)shouldAutorotate {
    if ([UIDevice isIpad]) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldShowKeyboardBtn {
    return NO;
}

- (BOOL)shouldSwipeBack {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        return YES;
    }
    return NO;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)showKeyboardBtn
{
    if ([[CMRouterManager sharedInstance].rootController isKindOfClass:[CMTabBarViewController class]]) {
        CMTabBarViewController* tabbarVC = (CMTabBarViewController *)[CMRouterManager sharedInstance].rootController;
        if ([self hasTextField]) {
            [tabbarVC setKeyboardButtonHidden:NO];
        }
    }
}

- (void)hideKeyboardBtn
{
    if ([[CMRouterManager sharedInstance].rootController isKindOfClass:[CMTabBarViewController class]]) {
        CMTabBarViewController* tabbarVC = (CMTabBarViewController *)[CMRouterManager sharedInstance].rootController;
        [tabbarVC setKeyboardButtonHidden:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
