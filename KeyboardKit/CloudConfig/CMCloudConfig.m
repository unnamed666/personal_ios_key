//
//  CMCloudConfig.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCloudConfig.h"
#import "CMAppConfig.h"
#import "CMGroupDataManager.h"
#import "CMLogger.h"
#import "CMRequestFactory.h"
#import "NSString+Common.h"

NSString *const kCloudConfigRefreshNotify = @"CloudConfigRefreshNotify";

static NSUInteger const kTryCount = 3;

@interface CMCloudConfig ()

@property (nonatomic, strong) NSString *productName;

@property (nonatomic, strong) NSString *pkg;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, strong) NSString *language;

/// 结构：key为func_type，value为该func_type下的所有section集合（section集合：key为section名，value为同section名的数组）
@property (nonatomic, strong) NSDictionary *cloudDataDic;

/// 结构：key为func_type + section，value为优先级最高的key_vlaue的dic集合
@property (nonatomic, strong) NSMutableDictionary *sectionDataDic;

@property (nonatomic, assign)BOOL isRequestSuccess;

@property (nonatomic, assign)   BOOL    isRequesting;

@end

@implementation CMCloudConfig


- (id) init {
    if (self = [super init]) {
        // 这里可进行初始化
        self.isRequestSuccess = NO;
        self.isRequesting = NO;
        self.productName = nil;
        self.pkg = nil;
        self.channelId = nil;
        self.cloudDataDic = nil;
        self.sectionDataDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)initCloudConfig:(NSString*)productName pkg:(NSString*)pkg channelId:(NSString*)channelId language:(NSString*)language{
    self.productName = productName;
    self.pkg = pkg;
    self.channelId = channelId;
    self.language = language;
    
    @try {
        // 读取已拉下来的云端配置，暂时放到主线程加载，先保证数据读取正常
        [self loadCloudConfig];
        // 拉取配置
        [self pullCloudConfig];
    } @catch (NSException *e) {
        kLogError(@"CloudConfig loadCloudConfig loadCloudConfig exception:%@", e);
    }
}

- (void)pullCloudConfigDataWithLanguage:(NSString*)language {
    self.language = language;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            [self pullCloudConfigData:@(kTryCount)];
        } @catch (NSException *e) {
            kLogError(@"CloudConfig CloudConfigUtils::pullCloudConfigDataWithLanguage() exception:%@", e);
        }
    });
}

- (void)pullCloudConfig {
    if (!self.productName) {
        kLog(@"productName is null!");
        return;
    }
    NSDate* lastFetchDate = kCMGroupDataManager.lastCloudFetchDate;
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:lastFetchDate];
    kLogInfo(@"lastFetchDate(%@), 距离现在(%f)", lastFetchDate, delta);
    // 距离上次拉取如果在1小时之内，则暂不拉取
#if DEBUG
    if (delta >= 5 || delta < 0) {
#else
        if (delta >= 60*60 || delta < 0) {
#endif
            NSString *currentVer = [CMGroupDataManager shareInstance].cloudConfigVer;
            NSString *appVer = [CMGroupDataManager shareInstance].cloudAppVer;
            NSString *lang = [CMGroupDataManager shareInstance].cloudAppLang;
            
            if (![NSString stringIsEmpty:currentVer] && (![[CMAppConfig appVersion] isEqualToString:appVer] || ![[CMAppConfig currentLanguage] isEqualToString:lang])) {
                // 根据APP版本号或语言不同，强制拉取数据
                [self pullCloudConfigData:@(kTryCount)];
            }
            else {
                // 根据魔方版本号去拉数据
                [self pullCloudConfigByVersion:@(kTryCount)];
            }
        }
    }

- (NSString*)getSectionKeyValue:(NSNumber*)funcType section:(NSString*)section {
    @try {
        if (self.cloudDataDic) {
            return self.cloudDataDic[funcType][section][0][@"key_value"];
        }
    } @catch (NSException *e) {
        kLog(@"CloudConfig getSectionKeyValue exception:%@", e);
    }
    
    return nil;
}

- (NSArray*)getAllSectionData:(NSNumber*)funcType section:(NSString*)section {
    @try {
        if (self.cloudDataDic) {
            return self.cloudDataDic[funcType][section];
        }
    } @catch (NSException *e) {
        kLog(@"CloudConfig getAllSectionData exception:%@", e);
    }
    
    return nil;
}

- (NSString*)getAllCloudData {
    @try {
        NSError* error = nil;
        id resultJson = [NSJSONSerialization dataWithJSONObject:self.cloudDataDic options:kNilOptions error:&error];
        if (error == nil) {
            NSString* dataJson = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding];
            
            return dataJson;
        }
    } @catch (NSException *e) {
        kLog(@"CloudConfig getAllCloudData exception:%@", e);
    }
    
    return nil;
}

- (NSDictionary*)getFieldInKeyValue:(NSNumber*)funcType section:(NSString*)section {
    @try {
        NSString *sectionKey = [NSString stringWithFormat:@"%@,%@", funcType, section];
        if (!self.sectionDataDic[sectionKey]) {
            NSString *keyValue = [self getSectionKeyValue:funcType section:section];
            if (keyValue) {
                NSDictionary *keyValueDic = [NSJSONSerialization JSONObjectWithData:[keyValue dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if (keyValueDic) {
                    // 主线程赋值，保证线程安全
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.sectionDataDic setObject:keyValueDic forKey:sectionKey];
                    });
                    return keyValueDic;
                }
            }
        } else {
            return self.sectionDataDic[sectionKey];
        }
    } @catch (NSException *e) {
        kLog(@"CloudConfig getFieldInKeyValue exception:%@", e);
    }
    
    return nil;
}

- (void)loadCloudConfig {
    if (!_cloudDataDic) {
        NSDictionary* cloudConfigDic = [CMGroupDataManager shareInstance].cloudConfigDic;
        if (cloudConfigDic) {
            [self refreshCloudConfig:cloudConfigDic];
            NSString *currentVer = [CMGroupDataManager shareInstance].cloudConfigVer;
            if (self.cloudDataDic) {
                // 加载本地数据成功，上报
                [self reportMagic:currentVer action:1 remark:nil];
            } else {
                // 加载本地数据失败，上报，1解析失败
                [self reportMagic:currentVer action:2 remark:@"1"];
            }
        }
    }
}

- (void)refreshCloudConfig:(NSDictionary*)cloudDic {
    NSArray *dataArray = cloudDic[@"data"];
    if (dataArray) {
        NSMutableDictionary *allDataDic = [NSMutableDictionary dictionary];
        for(NSDictionary * obj in dataArray){
            // 先检查有没有func_type
            NSMutableDictionary *funcTypeDic = allDataDic[obj[@"func_type"]];
            if (!funcTypeDic) {
                funcTypeDic = [NSMutableDictionary dictionary];
                [allDataDic setObject:funcTypeDic forKey:obj[@"func_type"]];
            }
            
            // 再检查section
            NSMutableArray *sectionArray = funcTypeDic[obj[@"section"]];
            if (!sectionArray) {
                sectionArray = [NSMutableArray arrayWithCapacity:1];
                [funcTypeDic setObject:sectionArray forKey:obj[@"section"]];
            }
            
            [sectionArray addObject:obj];
        }
        
        // 对所有section进行优先级排序
        NSEnumerator * funcTypeEnumerator = [allDataDic keyEnumerator];
        for (NSNumber *key in funcTypeEnumerator) {
            NSDictionary *funcTypeDic = allDataDic[key];
            
            NSEnumerator * sectionEnumerator = [funcTypeDic keyEnumerator];
            for (NSString *section in sectionEnumerator) {
                NSMutableArray *sectionArray = funcTypeDic[section];
                if ([sectionArray count] > 1) {
                    [sectionArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        @try {
                            NSDictionary *section1 = obj1;
                            NSDictionary *section2 = obj2;
                            
                            NSNumber *priority1 = section1[@"priority"];
                            NSNumber *priority2 = section2[@"priority"];
                            
                            if (priority1 > priority2) {
                                return NSOrderedDescending;
                            } else if (priority1 < priority2) {
                                return NSOrderedAscending;
                            } else {
                                NSNumber *id1 = section1[@"id"];
                                NSNumber *id2 = section2[@"id"];
                                
                                if (id1 < id2) {
                                    return NSOrderedDescending;
                                } else if (id1 > id2) {
                                    return NSOrderedAscending;
                                } else {
                                    return NSOrderedSame;
                                }
                            }
                        } @catch (NSException *e) {
                            kLog(@"CloudConfig NSEnumerator exception:%@", e);
                        }
                        
                        return NSOrderedSame;
                    }];
                }
            }
        }
        @synchronized(self) {
            self.cloudDataDic = allDataDic;
            self.sectionDataDic = [NSMutableDictionary dictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kCloudConfigRefreshNotify object:nil];
            });
        }
    }
}

- (void)pullCloudConfigByVersion:(NSNumber *)tryNum {
    NSUInteger tryCount = tryNum ? [tryNum integerValue] : 1;
    
    if (tryCount <= 0) {
        kLogError(@"%lu次重试后请求(拉取云控版本)最终失败", (unsigned long)kTryCount);
        if (!self.isRequestSuccess) {
            [self performSelector:@selector(pullCloudConfigByVersion:) withObject:@(kTryCount) afterDelay:5*60];
        }
    }
    else {
        if (self.isRequesting) return;
        self.isRequesting = YES;
        NSURLSessionDataTask * task = [CMRequestFactory cloudVersionRequestWithProductName:self.productName completeBlock:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
            self.isRequesting = NO;
            if (errorMsg) {
                kLogError(@"第%lu次请求(拉取云控版本)失败，错误信息(%@)", (unsigned long)(kTryCount - tryCount + 1), errorMsg);
                [self pullCloudConfigByVersion:@(tryCount-1)];
            }
            else {
                kLogInfo(@"%@", dicOrArray);
                NSDictionary * responseDic = dicOrArray;
                NSString *version = @"";
                
                if (responseDic) {
                    if ([responseDic.allKeys containsObject:@"data"] && [responseDic[@"data"] isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary * dataDic = responseDic[@"data"];
                        if ([dataDic.allKeys containsObject:@"business_config"]) {
                            version = dataDic[@"business_config"];
                        }
                    }
                    if (version.length > 0) {
                        if ([self isNeedUpdateVersion:version]) {
                            kLogInfo(@"版本有更新，拉取新的云控配置");
                            [CMGroupDataManager shareInstance].cloudConfigVer = version;
                            [self pullCloudConfigData:@(kTryCount)];
                        } else {
                            kLogInfo(@"版本无更新，使用本地云控配置");
                            // 加载服务器数据成功，上报，1版本号未变
                            [self refreshCloudConfig:[CMGroupDataManager shareInstance].cloudConfigDic];
                            [self reportMagic:version action:3 remark:@"1"];
                            kCMGroupDataManager.lastCloudFetchDate = [NSDate dateWithTimeIntervalSinceNow:0];
                        }
                    }
                    else {
                        kLogError(@"第%lu次请求(拉取云控版本)失败，错误信息(版本信息为空)", (unsigned long)(kTryCount - tryCount + 1));
                        [self pullCloudConfigByVersion:@(tryCount-1)];
                    }
                } else {
                    // 加载服务器版本接口失败，上报
                    kLogError(@"第%lu次请求(拉取云控版本)失败，错误信息(responseDic为空)", (unsigned long)(kTryCount - tryCount + 1));
                    [self pullCloudConfigByVersion:@(tryCount-1)];
                    [self reportMagic:@"" action:5 remark:nil];
                }
                
            }
        }];
        [task resume];
    }
}

- (void)pullCloudConfigData:(NSNumber *)tryNum {
    NSUInteger tryCount = tryNum ? [tryNum integerValue] : 1;
    if (tryCount <= 0) {
        kLogError(@"%lu次重试后请求(拉取云控版本)最终失败", (unsigned long)kTryCount);
        if (!self.isRequestSuccess) {
            [self performSelector:@selector(pullCloudConfigData:) withObject:@(kTryCount) afterDelay:5*60];
        }
    }
    else {
        NSString* configVersion = [CMGroupDataManager shareInstance].cloudConfigVer;
        NSURLSessionDataTask * task = [CMRequestFactory cloudMessageRequestWithLanguage:self.language channelId:self.channelId pkg:self.pkg completeBlock:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg)
                                       {
                                           if (errorMsg) {
                                               kLogError(@"第%lu次请求(拉取云控数据)失败，错误信息(%@)", (unsigned long)(kTryCount - tryCount + 1), errorMsg);
                                               [self pullCloudConfigData:@(tryCount-1)];
                                           }
                                           else {
                                               NSDictionary *responseDic = dicOrArray;
                                               if (responseDic) {
                                                   if (![responseDic[@"error"] isEqualToString:@"0"]) {
                                                       // 接口返回错误
                                                       kLogError(@"第%lu次请求(拉取云控数据)失败，错误信息(%@)", (unsigned long)(kTryCount - tryCount + 1), responseDic[@"error"]);
                                                       [self pullCloudConfigData:@(tryCount-1)];
                                                       // 加载服务器数据失败，上报
                                                       [self reportMagic:configVersion
                                                                  action:4
                                                                  remark:[NSString stringWithFormat:@"server:%@", responseDic[@"error"]]];
                                                       return;
                                                   }
                                                   kLogInfo(@"%@", responseDic);
                                                   [CMGroupDataManager shareInstance].cloudConfigDic = responseDic;
                                                   [CMGroupDataManager shareInstance].cloudAppVer = [CMAppConfig appVersion];
                                                   [CMGroupDataManager shareInstance].cloudAppLang = [CMAppConfig currentLanguage];
                                                   
                                                   [self refreshCloudConfig:responseDic];
                                                   
                                                   // 加载服务器数据成功，上报
                                                   [self reportMagic:configVersion action:3 remark:nil];
                                                   
                                                   self.isRequestSuccess = YES;
                                                   kCMGroupDataManager.lastCloudFetchDate = [NSDate dateWithTimeIntervalSinceNow:0];
                                                   kLogError(@"第%lu次请求(拉取云控数据)成功", (unsigned long)(kTryCount - tryCount + 1));
                                               }
                                           }
                                       }];
        [task resume];
    }
}

- (BOOL)isNeedUpdateVersion:(NSString*)serverVer {
    NSString *currentVer = [CMGroupDataManager shareInstance].cloudConfigVer;
    if ([NSString stringIsEmpty:currentVer]) {
        return YES;
    }
    
    // APP版本号不同
    NSString *appVer = [CMGroupDataManager shareInstance].cloudAppVer;
    if (![[CMAppConfig appVersion] isEqualToString:appVer]) {
        return YES;
    }
    
    // APP语言不同
    NSString *lang = [CMGroupDataManager shareInstance].cloudAppLang;
    if (![[CMAppConfig currentLanguage] isEqualToString:lang]) {
        return YES;
    }
    
    @try {
        NSArray *currentVerArray = [currentVer componentsSeparatedByString:@"."];
        NSArray *serverVerArray = [serverVer componentsSeparatedByString:@"."];
        
        if (currentVerArray.count >= 2 && serverVerArray.count >= 2) {
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
            
            long curDateVer = [[formatter numberFromString:currentVerArray[0]] longValue];
            long serverDateVer = [[formatter numberFromString:serverVerArray[0]] longValue];
            
            if (curDateVer < serverDateVer) {
                return YES;
            } else if (curDateVer == serverDateVer) {
                curDateVer = [[formatter numberFromString:currentVerArray[1]] longValue];
                serverDateVer = [[formatter numberFromString:serverVerArray[1]] longValue];
                
                if (curDateVer < serverDateVer) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                return NO;
            }
        }
    } @catch (NSException *e) {
        kLog(@"CloudConfig isNeedUpdateVersion exception:%@", e);
    }
    
    return ![currentVer isEqualToString:serverVer];
}

- (void)dealloc {
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    self.productName = nil;
    self.pkg = nil;
    self.channelId = nil;
    self.cloudDataDic = nil;
    self.sectionDataDic = nil;
}

- (void)reportMagic:(NSString*)magicVer action:(int)action remark:(NSString*)remark {
    // TODO 埋点上报可以在这里上报，表结构可以参考上述参数字段
}

- (void)updateLocalCloudConfig {
    [self loadCloudConfig];
}

- (NSString*)getCloudData:(int)function section:(NSString*)section {
    NSString *data = [self getSectionKeyValue:[NSNumber numberWithInt:function] section:section];
    return data;
}

- (NSArray*) getCloudDatas:(int)function section:(NSString*)section {
    NSArray *data = [self getAllSectionData:[NSNumber numberWithInt:function] section:section];
    return data;
}

- (NSString*)getCloudStringValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(NSString*)defValue {
    NSDictionary *keyValue = [self getFieldInKeyValue:[NSNumber numberWithInt:function] section:section];
    
    if (keyValue) {
        @try {
            id data = [keyValue objectForKey:key];
            
            if (!data) {
                return defValue;
            }
            else if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSError* error = nil;
                id resultJson = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error];
                if (error == nil) {
                    NSString* data = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding];
                    
                    return data ? data : defValue;
                }
            } else if (data && ![data isKindOfClass:[NSString class]]) {
                data = [NSString stringWithFormat:@"%@", data];
            }
            
            return data;
        } @catch (NSException *exception) {
            kLogError(@"CloudConfigHelper getCloudStringValue excepetion:%@, key:%@", exception, key);
        }
    }
    
    return defValue;
}

- (int)getCloudIntValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(int)defValue {
    NSDictionary *keyValue = [self getFieldInKeyValue:[NSNumber numberWithInt:function] section:section];
    
    if (keyValue) {
        @try {
            NSNumber *data = [keyValue objectForKey:key];
            return data ? [data intValue] : defValue;
        } @catch (NSException *exception) {
            kLogError(@"CloudConfigHelper getCloudIntValue excepetion:%@, key:%@", exception, key);
        }
    }
    
    return defValue;
}

- (long)getCloudLongValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(long)defValue {
    NSDictionary *keyValue = [self getFieldInKeyValue:[NSNumber numberWithInt:function] section:section];
    
    if (keyValue) {
        @try {
            NSNumber *data = [keyValue objectForKey:key];
            return data ? [data longValue] : defValue;
        } @catch (NSException *exception) {
            kLogError(@"CloudConfigHelper getCloudLongValue excepetion:%@, key:%@", exception, key);
        }
    }
    
    return defValue;
}

- (BOOL)getCloudBoolValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(BOOL)defValue {
    NSDictionary *keyValue = [self getFieldInKeyValue:[NSNumber numberWithInt:function] section:section];
    
    if (keyValue) {
        @try {
            NSString* data = [keyValue objectForKey:key];
            if ([NSString stringIsEmpty:data]) {
                return defValue;
            }
            if ([data compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
            else if ([data compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return NO;
            }
            return defValue;
        } @catch (NSException *exception) {
            kLogError(@"CloudConfigHelper getCloudBoolValue excepetion:%@, key:%@", exception, key);
        }
    }
    
    return defValue;
}

- (double)getCloudDoubleValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(double)defValue {
    NSDictionary *keyValue = [self getFieldInKeyValue:[NSNumber numberWithInt:function] section:section];
    
    if (keyValue) {
        @try {
            NSNumber *data = [keyValue objectForKey:key];
            return data ? [data doubleValue] : defValue;
        } @catch (NSException *exception) {
            kLogError(@"CloudConfigHelper getCloudDoubleValue excepetion:%@, key:%@", exception, key);
        }
    }
    
    return defValue;
}


@end
