//
//  CMRouterManager.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/12.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRouterManager.h"
#import "ThemeSettingViewController.h"
#import "LanguageViewController.h"
#import "CMFeedBackViewController.h"
#import "KeyboardMainViewController.h"
#import "CMAnimojiViewController.h"
#import "CMTabBarViewController.h"
#import "CMHostInfoc.h"
#import "CMSettingViewController.h"
#import "CMMakeAREmoticonViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTabBarViewController.h"
#import "CMDIYThemeViewController.h"
#import "CMInappController.h"
#import "CMKeyboardManager.h"

@interface CMRouterManager ()

@end

@implementation CMRouterManager
DEF_SINGLETON(CMRouterManager)

- (void)routeAndOpenPage:(NSURL *)actionUrl infoDic:(NSDictionary *)infoDic {
    if (!actionUrl) {
        return;
    }
    NSInteger pageType = [[actionUrl host] integerValue];
    switch (pageType) {
        case CMPageIdentify_OpenApp:
            //
            break;
        case CMPageIdentify_ThemeCenter:
        {
            if ([self.rootController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabController =  (UITabBarController *)self.rootController;
                tabController.selectedIndex = 0;
                UIViewController* selectedVC = tabController.selectedViewController;
                if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                    [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
                }
            }
            else if ([self.rootController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)self.rootController popToRootViewControllerAnimated:NO];
            }
            
            if (pageType == CMPageIdentify_ThemeCenter) {
                [CMHostInfoc reportCheetahkeyboard_main_showWithTab:1 inway:4];
            }
        }
            break;
        case CMPageIdentify_SettingCenter:
        {
            if ([self.rootController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabController =  (UITabBarController *)self.rootController;
                tabController.selectedIndex = 2;
                UIViewController* selectedVC = tabController.selectedViewController;
                if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                    [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
                }
            }
            else if ([self.rootController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)self.rootController popToRootViewControllerAnimated:NO];
            }

            if (pageType == CMPageIdentify_SettingCenter) {
                [CMHostInfoc reportCheetahkeyboard_main_showWithTab:2 inway:6];
            }
        }
            break;
        case CMPageIdentify_Language:
        {
            if (![[CMRouterManager topViewControllerWithRootViewController:self.rootController] isKindOfClass:[LanguageViewController class]]) {
                if ([self.rootController isKindOfClass:[UITabBarController class]]) {
                    UITabBarController *tabController =  (UITabBarController *)self.rootController;
                    tabController.selectedIndex = 2;
                    UIViewController* selectedVC = tabController.selectedViewController;
                    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                        [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
                        LanguageViewController *languageVC = [LanguageViewController new];
                        [(UINavigationController *)selectedVC pushViewController:languageVC animated:YES];
                    }
                }
                else if ([self.rootController isKindOfClass:[UINavigationController class]]) {
                    [(UINavigationController *)self.rootController popToRootViewControllerAnimated:NO];
                    LanguageViewController *languageVC = [LanguageViewController new];
                    [(UINavigationController *)self.rootController pushViewController:languageVC animated:YES];
                }
            }
            [CMHostInfoc reportCheetahkeyboard_main_showWithTab:2 inway:5];
        }
            break;
        case CMPageIdentify_Feedback:
        {
            if (![[CMRouterManager topViewControllerWithRootViewController:self.rootController] isKindOfClass:[CMFeedBackViewController class]]) {
                if ([self.rootController isKindOfClass:[UITabBarController class]]) {
                    UITabBarController *tabController =  (UITabBarController *)self.rootController;
                    tabController.selectedIndex = 2;
                    UIViewController* selectedVC = tabController.selectedViewController;
                    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                        [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
                        CMFeedBackViewController *feedbackVC = [CMFeedBackViewController new];
                        [(UINavigationController *)selectedVC pushViewController:feedbackVC animated:YES];
                    }
                }
                else if ([self.rootController isKindOfClass:[UINavigationController class]]) {
                    [(UINavigationController *)self.rootController popToRootViewControllerAnimated:NO];
                    CMFeedBackViewController *feedbackVC = [CMFeedBackViewController new];
                    [(UINavigationController *)self.rootController pushViewController:feedbackVC animated:YES];
                }
            }

            [CMHostInfoc reportCheetahkeyboard_main_showWithTab:2 inway:7];
        }
            break;
        case CMPageIdentify_AREmoticon:
            //跳转到 AR-Emoticon viewController中
        {
            NSInteger subType = [[[actionUrl host] substringFromIndex:2] integerValue];
            NSInteger inway = 0;
            switch (subType) {
                case 0:
                    inway = 2;
                    break;
                case 1:
                    inway = 4;
                    break;
                case 2:
                    inway = 5;
                    break;
                    
                default:
                    break;
            }
            
            if (![[CMRouterManager topViewControllerWithRootViewController:self.rootController] isKindOfClass:[CMMakeAREmoticonViewController class]]) {
                if ([self.rootController isKindOfClass:[UITabBarController class]]) {
                    UITabBarController *tabController =  (UITabBarController *)self.rootController;
                    tabController.selectedIndex = 1;
                    UIViewController* selectedVC = tabController.selectedViewController;
                    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                        [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
                        if ([UIDevice isIpad])
                        {
                            [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
                        }
                        CMMakeAREmoticonViewController * makeAREmoticon = [CMMakeAREmoticonViewController new];
                        makeAREmoticon.inway = inway;
                        [(UINavigationController *)selectedVC pushViewController:makeAREmoticon animated:YES];
                    }
                }
                else if ([self.rootController isKindOfClass:[UINavigationController class]]) {
                    [(UINavigationController *)self.rootController popToRootViewControllerAnimated:NO];
                    if ([UIDevice isIpad])
                    {
                        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
                    }
                    CMMakeAREmoticonViewController * makeAREmoticon = [CMMakeAREmoticonViewController new];
                    makeAREmoticon.inway = inway;
                    [(UINavigationController *)self.rootController pushViewController:makeAREmoticon animated:YES];
                }
            } else {
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                NSInteger classType = 0;
                switch (authStatus) {
                    case AVAuthorizationStatusNotDetermined:
                        classType = 1;
                        break;
                    case AVAuthorizationStatusDenied:
                        classType = 2;
                        break;
                    case AVAuthorizationStatusAuthorized:
                        classType = 3;
                        break;
                    default:
                        break;
                }
                [CMHostInfoc reportCheetahkeyboard_ar_show:inway classType:classType];
            }
        }
            break;
        case CMPageIdentify_DiyTheme:
        {
            NSInteger subType = [[[actionUrl host] substringFromIndex:3] integerValue];
            
            if (![[CMRouterManager topViewControllerWithRootViewController:self.rootController] isKindOfClass:[CMDIYThemeViewController class]]) {
                if ([self.rootController isKindOfClass:[UITabBarController class]]) {
                    UITabBarController *tabController =  (UITabBarController *)self.rootController;
                    tabController.selectedIndex = 0;
                    UIViewController* selectedVC = tabController.selectedViewController;
                    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                        [(UINavigationController *)selectedVC popToRootViewControllerAnimated:NO];
                        if ([UIDevice isIpad]) {
                            [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
                        }
                        
                        BOOL iappEnable = [kCMKeyboardManager.cloundConfig getCloudBoolValue:3 section:@"forced_subscription" key:@"forced_subscription" defValue:NO];
                        NSLog(iappEnable ? @"lxm iappEnable Yes" : @"lxm iappEnable No");

                        BOOL hasPurchased = [kCMGroupDataManager hasPurchasedIAP];
                        
                        NSString *versionPrevious = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousAppVersion];
                        NSString *inappVersion = [CMAppConfig inappVersion];
                        if ((versionPrevious == nil || [versionPrevious compare:inappVersion options:NSNumericSearch] == NSOrderedDescending) && iappEnable && !hasPurchased)
                        {
                            CMInappController* inappVC = [[CMInappController alloc] init];
                            [(UINavigationController *)selectedVC pushViewController:inappVC animated:YES];
                        } else
                        {
                            CMDIYThemeViewController *diyThemeVC = [CMDIYThemeViewController new];
                            diyThemeVC.delegate = (ThemeSettingViewController *)(((UINavigationController *)selectedVC).viewControllers.firstObject);
                            diyThemeVC.inway = subType;
                            [(UINavigationController *)selectedVC pushViewController:diyThemeVC animated:YES];
                        }
                         }
                }
                else if ([self.rootController isKindOfClass:[UINavigationController class]]) {
                    [(UINavigationController *)self.rootController popToRootViewControllerAnimated:NO];
                    if ([UIDevice isIpad]) {
                        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
                    }
                    CMDIYThemeViewController *diyThemeVC = [CMDIYThemeViewController new];
                    diyThemeVC.delegate = (ThemeSettingViewController *)(((UINavigationController *)self.rootController).viewControllers.firstObject);
                    diyThemeVC.inway = subType;
                    [(UINavigationController *)self.rootController pushViewController:diyThemeVC animated:YES];
                }
            }else{
                CMDIYThemeViewController *diyThemeVC = (CMDIYThemeViewController *)[CMRouterManager topViewControllerWithRootViewController:self.rootController];
                diyThemeVC.inway = subType;
            }
        }
            break;
        default:
            break;
    }
}

- (UIViewController *)topMostViewController {
    return [CMRouterManager topViewControllerWithRootViewController:self.rootController];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if (!rootViewController) {
        return nil;
    }
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        return [CMRouterManager topViewControllerWithRootViewController:[(UITabBarController *)rootViewController selectedViewController]];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        return [CMRouterManager topViewControllerWithRootViewController:[(UINavigationController *)rootViewController visibleViewController]];
    }
    else if (rootViewController.presentedViewController) {
        return [CMRouterManager topViewControllerWithRootViewController:rootViewController.presentedViewController];
    }
    
    if ([rootViewController isKindOfClass:[CMBaseViewController class]]) {
        return rootViewController;
    }
    return rootViewController;
}

#pragma mark - setter/getter
- (UIViewController *)rootController {
    if (!_rootController) {
        _rootController = [[CMTabBarViewController alloc] init];
    }
    return _rootController;
}

@end
