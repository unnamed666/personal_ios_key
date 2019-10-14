//
//  AppDelegate.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "AppDelegate.h"

#import "AddKeyBoardController.h"
#import "CMOReachability.h"
#import "CMHostInfoc.h"
#import "KeyboardMainViewController.h"
#import "CMAppConfig.h"
#import "CMCloudConfig.h"
#import "CloudConfig.h"
#import "CMRouterManager.h"
#import "CMGroupDataManager.h"
#import "InfoC.h"
#import "AppContainerData.h"
#import "InfoC.h"
#import "UserDefaultsMacro.h"
#import "CMMainContainerViewController.h"
#import "CMLaunchViewController.h"
#import "ThemeSettingViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "UIDevice+Util.h"
#import "CMLocalNotify.h"
#import "CMTabBarViewController.h"
#import "CMHostRequestFactory.h"
#import "InfoCManager.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CMKeyboardManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)dealloc {
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"Ga5Y8wyWYUt5CsGqUoiJD5";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1249925656";
    
    [kLogger setupLogger];

    kCMGroupDataManager;
    
    kLogInfo(@"lauch options%@", launchOptions);
    
    [CMOReachability start];//监测网络状态
    [self setUpInfoc];
    [CMAppConfig setupFabric];
    
    [kCMKeyboardManager initCloudConfigIfNeeded];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];

    self.window.rootViewController = [CMMainContainerViewController new];
//    self.window.rootViewController = [CMRouterManager sharedInstance].navController;
//    self.window.rootViewController = [CMTabBarViewController new];
    
    [self.window makeKeyAndVisible];
    
    if (!launchOptions)
    {
        if ([UIApplication sharedApplication].applicationIconBadgeNumber <= 0)
        {
            [CMHostInfoc reportCheetahkeyboard_main_showWithTab:1 inway:1];
        }
    }
    
//#ifdef DEBUG
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkResponseNotification:) name:AFNetworkingTaskDidCompleteNotification object:nil];
//#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //日活 上报
        [CMHostInfoc activeReport];
        [CMHostInfoc reportOthersKeyboard];
        //上报applist
        [CMHostInfoc reportCheetahkeyboard_app];
    });
        
    id time = [AppContainerData appFirstInstallTime];
    if (!time || ![time isKindOfClass:[NSDate class]])
    {
        [AppContainerData setAppFirstInstallTime:[NSDate date]];
    }

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isRecordedRedIconMark"])
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kCurrentAppVersion])
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsShowCustomThemeRedRoundMarkOnContainerApp];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [kCMGroupDataManager setIsShowNewMarkOnSettingIconByCustomTheme:NO];
            [kCMGroupDataManager setIsShowRedRoundMarkOnCustomThemeButton:NO];
        }
        else
        {
            NSString* recordVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentAppVersion];
            CMVersionCompare compareResult = [CMBizHelper versionCompareOfVersion1:[CMAppConfig appVersion] andVersion2:recordVersion];
            if (compareResult == CMVersionCompareOneBigger)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsShowCustomThemeRedRoundMarkOnContainerApp];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [kCMGroupDataManager setIsShowNewMarkOnSettingIconByCustomTheme:YES];
                [kCMGroupDataManager setIsShowRedRoundMarkOnCustomThemeButton:YES];
            }
        }

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isRecordedRedIconMark"];
    }
    
    [self updatePreviousAppVersionIfNeeded]; // 将版本号记录到userdefault中，用于做全新安装和覆盖安装的逻辑

    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0)
    {
        [CMHostInfoc reportCheetahkeyboard_main_showWithTab:1 inway:8];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    
    if ([kCMGroupDataManager keyboardHideTimes] >= 2)
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isOpenedNotifyOnView"])
        {
            if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  != UIUserNotificationTypeNone)
            {
                [CMLocalNotify scheduleLocalNotification];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOpenedNotifyOnView"];
            }
        }
    }
    else
    {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  != UIUserNotificationTypeNone)
        {
            [CMLocalNotify scheduleLocalNotification];
            kCMGroupDataManager.keyboardHideTimes = 10;
        }
    }
    
    [CMLocalNotify reportIsOpenLocalNotify];
    
    UILocalNotification *launchNotify = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (launchNotify)
    {
        NSString* theID = [launchNotify.userInfo objectForKey:@"id"];
        [CMLocalNotify reportLocalNotify:theID];
        if ((theID.intValue) % 6 == 0)
        {
            [self openDiyThemeViewController];
        }
    }
    
    return YES;
}


#pragma mark - UNUserNotificationCenterDelegate
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge = 0;
    NSString* theID = [notification.userInfo objectForKey:@"id"];
    [CMLocalNotify reportLocalNotify:theID];
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    if (application.applicationState == UIApplicationStateActive)
    {
        kLog(@"Niecong == UIApplicationStateActive");
    }
    else if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)
    {
        [self openDiyThemeViewController];
    }
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOpenedNotifyOnView"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isOpenedNotifyOnView"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRegisterUserNotificationSettings" object:nil];
}

- (void)handleNetworkResponseNotification:(NSNotification *)notify
{
//    if (!notify || !notify.userInfo || !notify.object) {
//        return;
//    }
//    
//    if ([notify.object isKindOfClass:[NSURLSessionTask class]] && [notify.userInfo isKindOfClass:[NSDictionary class]]) {
//        NSURLSessionTask* task = notify.object;
//        NSDictionary* userInfo = notify.userInfo;
//        NSData* jsonData = [userInfo valueForKey:AFNetworkingTaskDidCompleteResponseDataKey];
//        NSString* body = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
//        if (jsonData) {
//            NSError *error = nil;
//            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
//            if (!error) {
//                kLogInfo(@"[NET]\n\nRequest Url:%@\n\nRequest body:\n%@\n\nResponse Json: \n%@\n\njsonDict:\n%@\n", task.originalRequest.URL,body, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], jsonDic);
//            }
//            else {
//                kLogInfo(@"[NET]\n\nRequest Url:%@\n\nRequest body:\n%@\n\nResponse Json: \n%@\n\njsonDict:\n解析错误%@\n", task.originalRequest.URL,body, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], error);
//            }
//        }
//    }
}


// iOS 9.0+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    kLogInfo(@"options(%@), openURL(%@)", options, url);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsShowCustomThemeRedRoundMarkOnContainerApp])
    {
        if ([[url absoluteString] isEqualToString:@"CMKeyboard://14.3"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsShowCustomThemeRedRoundMarkOnContainerApp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeCustomThemeRedRoundMark" object:nil];
        }
    }
    CMMainContainerViewController* mainVC = (CMMainContainerViewController *)self.window.rootViewController;
    if (mainVC) {
        if ([mainVC.rootViewController isKindOfClass:[CMLaunchViewController class]]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[CMRouterManager sharedInstance] routeAndOpenPage:url infoDic:nil];
            });
        }
        else {
            [[CMRouterManager sharedInstance] routeAndOpenPage:url infoDic:nil];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // 拉取最新云控数据
//    [CMCloudConfigHelper setupCloudConfig:[CMAppConfig cloudProductName] pkg:[CMAppConfig bundleIdentifier] channelId:[CMAppConfig channelId] language:[CMAppConfig currentLanguage]];
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    [FBSDKAppEvents activateApp];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIViewController* rootViewController = [CMRouterManager topViewControllerWithRootViewController:window.rootViewController];
    if ([rootViewController isKindOfClass:[CMMainContainerViewController class]])
    {
        rootViewController = [CMRouterManager topViewControllerWithRootViewController:((CMMainContainerViewController*) window.rootViewController).rootViewController];
    }
    if (rootViewController && [rootViewController shouldAutorotate]) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - add by zhoujing
- (void)setUpInfoc {
    [InfoCManager shareManager].networkReachable = ([CMOReachability status] != kNavNetWorkNotReachable);
    
}
- (void)updatePreviousAppVersionIfNeeded
{
    NSString* appVerFromPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentAppVersion];
    NSString* appVerFromBundle = [CMAppConfig appVersion];
    if (appVerFromPrefs&&appVerFromPrefs.length!=0&&![appVerFromPrefs isEqualToString:appVerFromBundle]) {
        [[NSUserDefaults standardUserDefaults] setObject:appVerFromPrefs forKey:kPreviousAppVersion];
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:appVerFromBundle forKey:kCurrentAppVersion];
}

#pragma mark -
- (void)openDiyThemeViewController
{
    NSString* pageIdentifier = [NSString stringWithFormat:@"%lud.4",CMPageIdentify_DiyTheme];// .4代表是通过点击本地通知进入的diy页面
    NSString* scheme = [NSString stringWithFormat:@"%@://%@", [CMAppConfig appURLScheme], pageIdentifier];
    [self application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme] options:@{}];
}

@end
