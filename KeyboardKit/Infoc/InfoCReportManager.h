//
//  InfoCReportManager.h
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/5.
//  Copyright © 2016年 cm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InfoC.h"

@interface InfoCReportManager : NSObject

+ (InfoCReportManager *)sharedManager;

- (InfoCEventRecordStatus)logEvent:(NSString *)eventName andRecordLevel:(InfoCEventRecordLevel)recordLevel;
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName timed:(BOOL)timed andRecordLevel:(InfoCEventRecordLevel)recordLevel;
- (void)endTimedEvent:(NSString *)eventName;
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName andRecordLevel:(InfoCEventRecordLevel)recordLevel andParameters:(NSDictionary *)parameters;
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName timed:(BOOL)timed andRecordLevel:(InfoCEventRecordLevel)recordLevel andParameters:(NSDictionary *)parameters;
- (void)endTimedEvent:(NSString *)eventName andParameters:(NSDictionary *)parameters;
@end
