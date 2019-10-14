//
//  CMLocalNotify.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/9/15.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMLocalNotify.h"
#import "AppContainerData.h"


@implementation CMLocalNotify

static NSString* pushIconArray[6] = {
    @"Push_icon_4@2x",
    @"Push_icon_1@2x",
    @"Push_icon_2@2x",
    @"Push_icon_3@2x",
    @"Push_icon_5@2x",
    @"Push_icon_6@2x",
};

static NSString* titleArray[6] = {
    @"Custome_Theme",
    @"Just_for_you",
    @"Tips_Send_Emoji",
    @"Tips_Swipe_Typing",
    @"Tips_Auto_Correct_words",
    @"Coolest_3D_Keyboard"
};

static NSString* subTitleArray[6] = {
    @"Create_your",
    @"All_free_themes_are_waiting_for_you_now",
    @"Hold_backspace_to_send_Emoji_quickly",
    @"Try_swipe_letters_by_letters_to_type_words_fast",
    @"Type_fast_and_we_will_help_you_correct_words_automatically",
    @"Smooth_animation_with_glowing_buttons_you_havent_seen",
};

+ (void) registLocalNotify
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (IOS10_OR_LATER)
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
        center.delegate = (id <UNUserNotificationCenterDelegate>) ((AppDelegate*)[UIApplication sharedApplication].delegate);
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if (!error)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"didRegisterUserNotificationSettings" object:nil];
             }
             
             if (granted)
             {
                 [self scheduleMutableNotificationType];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOpenedNotifyOnView"];
                 [CMHostInfoc reportCheetahkeyboard_noti_perm_choo:1];
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isOpenedNotifyOnView"];
                 [CMHostInfoc reportCheetahkeyboard_noti_perm_choo:2];
             }
         }];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings)
         {
             kLog(@"%@", settings);
         }];
    }
    else if (IOS8_OR_LATER)
    {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        
        [CMLocalNotify scheduleLocalNotificationType];
    }
}

+ (void) removeAllLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (IOS10_OR_LATER)
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    }
}

+ (void) scheduleLocalNotification
{
    [self removeAllLocalNotification];
    if (IOS10_OR_LATER)
    {
        [self scheduleMutableNotificationType];
    }
    else if (IOS8_OR_LATER)
    {
        [self scheduleLocalNotificationType];
    }
}

+ (void)scheduleLocalNotificationType
{
    for (int i = 0; i < 64; i++)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(i+1)*2];
        localNotification.alertLaunchImage = pushIconArray[i%6];
        localNotification.alertTitle = CMLocalizedString(titleArray[i%6], nil) ;
        localNotification.alertBody = CMLocalizedString(subTitleArray[i%6], nil);
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.repeatInterval = 0;
        localNotification.applicationIconBadgeNumber = 1;
        localNotification.userInfo = @{@"id" : [NSString stringWithFormat:@"%d", i]};
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

+ (void)scheduleMutableNotificationType
{
    for (int i = 0; i < 64; i++)
    {
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:CMLocalizedString(titleArray[i%6], nil) arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:CMLocalizedString(subTitleArray[i%6], nil) arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.badge = @(1);
        content.userInfo = @{@"id" : [NSString stringWithFormat:@"%d", i]};
        NSURL *url = [[NSBundle mainBundle] URLForResource:pushIconArray[i%6] withExtension:@"jpg"];
        UNNotificationAttachment *attch = [UNNotificationAttachment attachmentWithIdentifier:@"photo" URL:url options:nil error:nil]; content.attachments = @[attch];
        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60*60*24*2*(i+1) repeats:NO];
        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"FiveSecond%d", i] content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error)
        {
            if(error)
            {
                kLogError(@"%@",error);
            }
        }];

    }
}

+ (void) reportLocalNotify:(NSString*) theID
{
    [CMHostInfoc reportCheetahkeyboard_main_showWithTab:1 inway:(theID.intValue%6) + 9];
}

+ (void) reportIsOpenLocalNotify
{
    id appStartTime = [AppContainerData appStartTimeForReport];
    if (!appStartTime)
    {
        [AppContainerData setAppStartTimeForReport:[NSDate date]];
    }
    else
    {
        if (appStartTime && [appStartTime isKindOfClass:[NSDate class]])
        {
            NSDate* lastDate = (NSDate *)appStartTime;
            NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:lastDate];
            BOOL valid = (delta >= 60*60*24 || delta < 0);
            if (valid)
            {
                NSInteger isOpen = [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone ? 2 : 1;
                [CMHostInfoc reportCheetahkeyboard_noti_perm:isOpen];
            }
            
            [AppContainerData setAppStartTimeForReport:[NSDate date]];
        }
    }
}

@end
