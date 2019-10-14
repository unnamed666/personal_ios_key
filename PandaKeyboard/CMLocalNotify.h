//
//  CMLocalNotify.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/9/15.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "UIDevice+Util.h"
#import "CMGroupDataManager.h"
#import "AppDelegate.h"

@interface CMLocalNotify : NSObject

+ (void) registLocalNotify;
+ (void)scheduleLocalNotificationType;
+ (void) removeAllLocalNotification;
+ (void) scheduleLocalNotification;
+ (void) reportLocalNotify:(NSString*) theID;
+ (void) reportIsOpenLocalNotify;

@end
