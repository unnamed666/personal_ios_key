//
//  CMMainContainerViewController.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/9/14.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMMainContainerViewController.h"
#import "CMLaunchViewController.h"
#import "CMLaunchFunctionGuideViewController.h"
#import "ThemeSettingViewController.h"
#import "CMRouterManager.h"

@interface CMMainContainerViewController ()<GuideIntroduceDelegate>

@end

@implementation CMMainContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSplashViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSplashViewController {
    if ([self.rootViewController isKindOfClass:[CMLaunchViewController class]]) {
        return;
    }
    
    if (self.rootViewController) {
        [self.rootViewController willMoveToParentViewController:nil];
        [self.rootViewController removeFromParentViewController];
        [self.rootViewController.view removeFromSuperview];
        [self.rootViewController didMoveToParentViewController:nil];
    }
    
    CMLaunchViewController* lauchViewController = [[CMLaunchViewController alloc] init];
    self.rootViewController = lauchViewController;
    
    [lauchViewController willMoveToParentViewController:self];
    [self addChildViewController:lauchViewController];
    [self.view addSubview:lauchViewController.view];
    [lauchViewController didMoveToParentViewController:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isShowFunGuid = [[NSUserDefaults standardUserDefaults] boolForKey:kHasShowedSplashFunctionGuide];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kPreviousAppVersion] && !isShowFunGuid) {
            [self showSplashFunctionGuidViewController];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kHasShowedSplashFunctionGuide];
        }else {
            [self showThemeSettingViewController];

        }
    });
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)showSplashFunctionGuidViewController {
    if ([self.rootViewController isKindOfClass:[CMLaunchFunctionGuideViewController class]]) {
        return;
    }
    CMLaunchFunctionGuideViewController *funGuidViewController = [[CMLaunchFunctionGuideViewController alloc]init];
    funGuidViewController.delegate = self;
    if (funGuidViewController) {
        [funGuidViewController willMoveToParentViewController:self];
        [self addChildViewController:funGuidViewController];
        if (self.rootViewController) {
            [self transitionFromViewController:self.rootViewController toViewController:funGuidViewController duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseOut animations:nil completion:^(BOOL finished) {
                [funGuidViewController didMoveToParentViewController:self];
                [self.rootViewController removeFromParentViewController];
                [self.rootViewController didMoveToParentViewController:nil];
                self.rootViewController = funGuidViewController;
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }else {
            [self.view addSubview:funGuidViewController.view];
            [funGuidViewController didMoveToParentViewController:self];
            self.rootViewController = funGuidViewController;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}
- (void)showThemeSettingViewController {
    if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    UIViewController* vc = [CMRouterManager sharedInstance].rootController;
    if (vc) {
        [vc willMoveToParentViewController:self];
        [self addChildViewController:vc];
        if (self.rootViewController) {
            [self transitionFromViewController:self.rootViewController toViewController:vc duration:0.55 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseOut animations:nil completion:^(BOOL finished) {
                [vc didMoveToParentViewController:self];
                [self.rootViewController removeFromParentViewController];
                [self.rootViewController didMoveToParentViewController:nil];
                self.rootViewController = vc;
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }
        else {
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
            self.rootViewController = vc;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.rootViewController;
}

#pragma mark - GuideIntroduceDelegate
- (void)dismissGuidIntroduce {
    [self showThemeSettingViewController];
    [CMHostInfoc reportCheetahkeyboard_welcom];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
