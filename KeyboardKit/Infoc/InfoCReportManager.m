//
//  InfoCReportManager.m
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/5.
//  Copyright © 2016年 cm. All rights reserved.
//

#import "InfoCReportManager.h"
#import <sys/utsname.h>
#import "CMAppConfig.h"
#import "CMBizHelper.h"
#import "CMLogger.h"

#import "InfoCReportRequestManager.h"

#define InfoC_Cache_FilePath @""

@interface InfoCReportManager() {
    NSMutableDictionary *eventLogInfos;
    NSMutableDictionary *eventNameTimedInfos;
    NSDictionary        *basicParam;
    
    BOOL isEnteredBackground;
}
@property (nonatomic , copy)NSString *apiKey;

@end

@implementation InfoCReportManager

#pragma mark -
#pragma mark Lifecycle
+ (InfoCReportManager *)sharedManager {
    static InfoCReportManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.apiKey = [CMAppConfig infocApiKey];
    eventLogInfos       = [[NSMutableDictionary alloc] init];//记录数量事件的次数
    eventNameTimedInfos = [[NSMutableDictionary alloc] init];//记录时长事件的TimeStamp
    isEnteredBackground = NO;
    
    [self initBasicParams];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecameActiveHandleByInfoC)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundHandleByInfoC)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    return self;
}

- (void)initBasicParams {
    NSMutableDictionary *commonDic = [[NSMutableDictionary alloc] init];
    
    //电话国家编号
    NSString* mcc = [CMAppConfig mobileCountryCode];
    
    //电话供应商网络编号
    NSString* mnc = [CMAppConfig mobileNetworkCode];
    
    //软件版本
    NSString *appVer = @"";
#ifdef DEBUG
    appVer = [CMAppConfig buildId];
#else
    appVer = [CMAppConfig appVersion];
#endif
    
    /*
     
     1	string(50)	userid	设备唯一标识
     2	string(20)	ver	应用版本
     3	string(50)	channel	渠道号
     4	string(50)	pkg_name	包名
     5	string(20)	child_channel	子渠道号，具体的推广位
     6	short(2字节)	mcc	移动国家号码
     7	short(2字节)	mnc	移动网络码
     8	string(20)	language_setting	语言
     9	string(20)	brand	品牌
     10	string(50)	model	机型
     11	string(20)	country_setting	国家
     12	string(20)	osver	系统版本号
     13	int(4字节)	installtime	首次安装时间
     14	short(2字节)	resolution	横向分辨率
     15	string(20)	screensize	屏幕大小
     */
    
    [commonDic setObject:[CMAppConfig deviceId] forKey:@"userid"];//产品类型
    [commonDic setObject:appVer forKey:@"ver"];//App版本
    [commonDic setObject:[CMAppConfig channelId] forKey:@"channel"];//渠道
    [commonDic setObject:[CMAppConfig channelId] forKey:@"child_channel"];//渠道
    [commonDic setObject:[CMAppConfig bundleIdentifier] forKey:@"pkg_name"];//渠道
    [commonDic setObject:mcc forKey:@"mcc"];//移动国家号码
    [commonDic setObject:mnc forKey:@"mnc"];//网络id
    [commonDic setObject:[CMAppConfig country] forKey:@"country_setting"];//网络id
    [commonDic setObject:[CMAppConfig currentLanguage] forKey:@"language_setting"];//网络id
    [commonDic setObject:@"Apple" forKey:@"brand"];//网络id
    [commonDic setObject:[CMAppConfig deviceModel] forKey:@"model"];//网络id
    [commonDic setObject:[CMAppConfig systemVersion] forKey:@"osver"];//网络id
    [commonDic setObject:[CMAppConfig firstLaunchTime] forKey:@"installtime"];//网络id
    [commonDic setObject:[NSString stringWithFormat:@"%.0f", [CMAppConfig horizontalResolution]] forKey:@"resolution"];//网络id
    [commonDic setObject:[NSString stringWithFormat:@"%.0fx%.0f", [CMBizHelper adapterScreenWidth], [CMBizHelper adapterScreenHeight]] forKey:@"screensize"];//网络id
    
    basicParam = [[NSDictionary alloc] initWithDictionary:commonDic];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackgroundHandleByInfoC {
    isEnteredBackground = YES;
    
    NSArray *allKeys = [NSArray arrayWithArray:eventNameTimedInfos.allKeys];
    for(int i = 0;i < allKeys.count ;i++) {
        NSString *key = [allKeys objectAtIndex:i];
        [self endTimedEvent:key andParameters:nil];
    }
    
    [self uploadEventLogInfos];
}

- (void)applicationDidBecameActiveHandleByInfoC {
    isEnteredBackground = NO;
    
    NSArray *allKeys = [NSArray arrayWithArray:eventNameTimedInfos.allKeys];
    for(int i = 0;i < allKeys.count ;i++) {
        NSString *key = [allKeys objectAtIndex:i];
        NSDictionary *timedEventInfo = [eventNameTimedInfos objectForKey:key];
        NSNumber *eventRecordLevel = [timedEventInfo objectForKey:@"eventRecordLevel"];
        NSString *timeStamp        = [self getTimeStamp];
        NSDictionary *parameters   = [timedEventInfo objectForKey:@"parameters"];
        NSDictionary *newTimedEventInfo = @{@"eventRecordLevel":eventRecordLevel,@"timeStamp":timeStamp,@"parameters":parameters};
        
        [eventNameTimedInfos setObject:newTimedEventInfo forKey:key];
    }
}

#pragma mark -
#pragma mark InfoCLogEvent methods
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel{
    
    return [self logEvent:eventName
                    timed:NO
           andRecordLevel:recordLevel
            andParameters:nil];
}
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                             timed:(BOOL)timed
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel{
    
    return [self logEvent:eventName
                    timed:timed
           andRecordLevel:recordLevel
            andParameters:nil];
}
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel
                     andParameters:(NSDictionary *)parameters {
    
    return [self logEvent:eventName
                    timed:NO
           andRecordLevel:recordLevel
            andParameters:parameters];
}
- (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                             timed:(BOOL)timed
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel
                     andParameters:(NSDictionary *)parameters {
    if (!eventName || eventName.length == 0) {
        kLogInfo(@"%s InfoC WithoutEventName Record Failed",__func__);
        return InfoCEventFailedWithoutEventName;
    }
    
    if (!parameters) {
        parameters = [NSDictionary dictionary];
    }
    
    if (recordLevel > InfoCEventRecordLevelUploadLater) {
        recordLevel = InfoCEventRecordLevelUploadLater;
    }
    
    NSString *business_index = [InfoC getBussinessIndexWithEventName:eventName];
    
    if (timed) {
        //计时事件先保留部分信息，在endTimedEvent方法中构件全部上报信息
        NSNumber *eventRecordLevel = [NSNumber numberWithInteger:recordLevel];
        NSString *timeStamp        = [self getTimeStamp];
        
        NSDictionary *timedEventInfo = @{@"eventRecordLevel":eventRecordLevel,@"timeStamp":timeStamp,@"parameters":parameters};
        [eventNameTimedInfos setObject:timedEventInfo forKey:eventName];
    }else {
        //其他事件构件全部全部上报信息
        NSMutableDictionary *publicParams = [NSMutableDictionary dictionary];
        [publicParams setObject:@"cheetahkeyboard_public" forKey:@"tablename"];
        [publicParams setObject:@(1) forKey:@"index"];
        [publicParams addEntriesFromDictionary:basicParam];
        
        NSMutableDictionary *bizParams = [NSMutableDictionary dictionary];
        [bizParams setObject:eventName forKey:@"tablename"];
        [bizParams setObject:business_index forKey:@"index"];
        [bizParams addEntriesFromDictionary:parameters];
        
        NSString *host = [CMAppConfig infocHostUrl];
        
        NSMutableDictionary *reportInfo = [NSMutableDictionary dictionary];
        [reportInfo setObject:host forKey:@"host"];
        [reportInfo setObject:publicParams forKey:@"public_param"];
        [reportInfo setObject:bizParams forKey:@"biz_param"];
        [reportInfo setObject:eventName forKey:@"identifer"];
        [reportInfo setObject:@"POST" forKey:@"method"];
        if (recordLevel == InfoCEventRecordLevelUploadNow) {
            //立即上报
            [[InfoCReportRequestManager sharedManager] addReportInfoToManager:reportInfo];
        }else {
            //加入队列上报
            if (parameters.allValues.count == 0) {
                [self setEventName:eventName toEventLogInfosWithInfo:nil];
            }else {
                [self setEventName:eventName toEventLogInfosWithInfo:parameters];
            }
        }
    }
    if (timed) {
        kLogInfo(@"%s InfoC Timed EventName:%@ Start Recording",__func__,eventName);
    }else {
        kLogInfo(@"%s InfoC EventName:%@ Will Record",__func__,eventName);
    }
    
    return InfoCEventRecorded;
}

- (void)endTimedEvent:(NSString *)eventName {
    [self endTimedEvent:eventName andParameters:nil];
}

- (void)endTimedEvent:(NSString *)eventName andParameters:(NSDictionary *)parameters {
    if (![eventNameTimedInfos.allKeys containsObject:eventName]) {
        kLogError(@"CAUTION!!! eventName:%@ Timed not exist",eventName);
        return;
    }
    if (!parameters) {
        parameters = [NSDictionary dictionary];
    }
    
    NSString *business_index = [InfoC getBussinessIndexWithEventName:eventName];
    
    NSDictionary *timedEventInfo = [eventNameTimedInfos objectForKey:eventName];
    NSDictionary *originalParameters = [timedEventInfo objectForKey:@"parameters"];
    //    NSNumber     *eventRecordLevel   = [timedEventInfo objectForKey:@"eventRecordLevel"];
    NSString     *originalTimeStamp  = [timedEventInfo objectForKey:@"timeStamp"];
    NSString     *nowTimeStamp       = [self getTimeStamp];
    long long     gap = [nowTimeStamp longLongValue] - [originalTimeStamp longLongValue];
    if (gap < 0) {
        gap = 0;
    }
    NSString     *duration = [NSString stringWithFormat:@"%lld",gap];
    
    NSMutableDictionary *completeParameters = [NSMutableDictionary dictionaryWithDictionary:basicParam];
    [completeParameters addEntriesFromDictionary:originalParameters];
    [completeParameters addEntriesFromDictionary:parameters];
    NSString *uptime = [self getTimeStamp];
    [completeParameters setObject:uptime forKey:@"uptime"];
    [completeParameters setObject:business_index forKey:@"business_index"];
    if (self.apiKey && self.apiKey.length > 0) {
        [completeParameters setObject:self.apiKey forKey:@"product_no"];
    }
    [completeParameters setObject:duration forKey:@"duration"];
    
    NSString *host = [CMAppConfig infocHostUrl];
    
    NSMutableDictionary *reportInfo = [NSMutableDictionary dictionary];
    [reportInfo setObject:host forKey:@"host"];
    [reportInfo setObject:completeParameters forKey:@"parameter"];
    [reportInfo setObject:eventName forKey:@"identifer"];
    [reportInfo setObject:@"GET" forKey:@"method"];
    
    [[InfoCReportRequestManager sharedManager] addReportInfoToManager:reportInfo];
    
    if (!isEnteredBackground) {
        [eventNameTimedInfos removeObjectForKey:eventName];
    }
    
    kLogInfo(@"%s InfoC Timed EventName:%@ Will Record Duration:%@",__func__,eventName,duration);
}

- (void)setEventName:(NSString *)eventName toEventLogInfosWithInfo:(NSDictionary *)info {
    if (!eventName || eventName.length == 0) {
        return;
    }
    
    if (!info) {
        //无固定信息时，自增加
        if (![eventLogInfos.allKeys containsObject:eventName]) {
            NSNumber *valueNum = [NSNumber numberWithInteger:1];
            [eventLogInfos setObject:valueNum forKey:eventName];
        }else {
            NSNumber *oldValueNum = [eventLogInfos objectForKey:eventName];
            NSInteger newValue = [oldValueNum integerValue] + 1;
            NSNumber *newValueNum = [NSNumber numberWithInteger:newValue];
            [eventLogInfos setObject:newValueNum forKey:eventName];
        }
        
        return;
    }
    
    if (![eventLogInfos.allKeys containsObject:eventName]) {
        [eventLogInfos setObject:info forKey:eventName];
    }else {
        NSMutableDictionary *newInfo = [NSMutableDictionary dictionary];
        
        NSArray *infoKeys = info.allKeys;
        NSDictionary *oldInfo = [eventLogInfos objectForKey:eventName];
        NSArray *oldInfoKeys = oldInfo.allKeys;
        
        for (NSString *key in infoKeys) {
            if (![key isKindOfClass:[NSString class]]) {
                kLogInfo(@"InfoC中上报Key需要为NSString类型");
                continue;
            }
            
            if (![oldInfoKeys containsObject:key]) {
                [newInfo setObject:[info objectForKey:key] forKey:key];
                continue;
            }
            
            id value = [info objectForKey:key];
            if ([value isKindOfClass:[NSNumber class]]) {
                NSNumber *oldValueNum = [oldInfo objectForKey:key];
                NSNumber *newValueNum = (NSNumber *)value;
                NSInteger newValue = [oldValueNum integerValue] + [newValueNum integerValue];
                NSNumber *num = [NSNumber numberWithInteger:newValue];
                [newInfo setObject:num forKey:key];
            }else {
                [newInfo setObject:value forKey:key];
            }
        }
        
        [eventLogInfos setObject:newInfo forKey:eventName];
    }
}

- (void)uploadEventLogInfos {
    NSString *host = [CMAppConfig infocHostUrl];
    
    for (NSString *eventName in eventLogInfos.allKeys) {
        NSMutableDictionary *reportInfo = [NSMutableDictionary dictionary];
        [reportInfo setObject:host forKey:@"host"];
        [reportInfo setObject:@{} forKey:@"parameter"];
        [reportInfo setObject:eventName forKey:@"identifer"];
        [reportInfo setObject:@"GET" forKey:@"method"];
        [[InfoCReportRequestManager sharedManager] addReportInfoToManager:reportInfo];
    }
    
    [eventLogInfos removeAllObjects];
}

#pragma mark -
#pragma mark Util methods

- (NSString *)getTimeStamp {
    return [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
}

@end
