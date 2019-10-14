//
//  InfoCReportRequestManager.m
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/6.
//  Copyright © 2016年 cm. All rights reserved.
//

#import "InfoCReportRequestManager.h"
#import "InfoCReportRequest.h"
#import "InfoCReportManager.h"
#import "InfoCReachability.h"
#import "CMDirectoryHelper.h"
#import "CMHttpRequest.h"
#import "NSString+Common.h"
#import "CMLogger.h"
#import "CMMacro.h"

#define INFOC_REQUEST_MAX_RETRY_TIMES 2

@interface InfoCReportRequestManager() <InfoCReportRequestDelegate>@property (nonatomic, strong)NSMutableArray* reportInfoList;
@property (nonatomic, strong)NSMutableArray* offlineReportInfoList;
@property (nonatomic, copy)NSDictionary* uploadingInfo;
@property (nonatomic, strong)InfoCReachability  *reachability;
@property (nonatomic, strong)InfoCReportRequest *currentReportRequest;
@property (nonatomic, assign)NSUInteger currentRetryTimes;
@property (nonatomic, assign)BOOL isReporting;

@end

@implementation InfoCReportRequestManager
#pragma mark -
#pragma mark Lifecycle
+ (InfoCReportRequestManager *)sharedManager {
    static InfoCReportRequestManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _isReporting = NO;
        _currentRetryTimes = 0;
        self.reachability = [InfoCReachability reachabilityForInternetConnection];
        
        [self initReportInfos];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveReportInfosToLocal)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)initReportInfos {
    NSString *filePath = [self getLocalFilePathName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        self.reportInfoList        = [[NSMutableArray alloc] init];
        self.offlineReportInfoList = [[NSMutableArray alloc] init];
    }else {
        NSArray *localInfoList = [NSArray arrayWithContentsOfFile:filePath];
        
        self.reportInfoList        = [[NSMutableArray alloc] initWithArray:localInfoList];
        self.offlineReportInfoList = [[NSMutableArray alloc] initWithArray:localInfoList];
    }
}

- (void)dealloc {
    
}
#pragma mark -
#pragma mark Handle RequestInfo
- (NSString *)getLocalFilePathName {
    NSString *filePath = [[CMDirectoryHelper infocDir] stringByAppendingPathComponent:@"infoc_offline"];
    return filePath;
}

- (void)saveReportInfosToLocal {
    kLogInfo(@"Saving To Local");
    
    NSString *filePath = [self getLocalFilePathName];
    [self.offlineReportInfoList writeToFile:filePath atomically:YES];
}

- (void)addReportInfoToManager:(NSDictionary *)reportInfo {
    if ([self.reachability currentReachabilityStatus] == InfoCNotReachable) {
        [self.offlineReportInfoList addObject:reportInfo];
    }else {
        [self.reportInfoList addObject:reportInfo];
        [self checkReportListAndUpload];
    }
}

- (void)removeFirstReportInfoFromList {
    NSDictionary *info = [self.reportInfoList objectAtIndex:0];
    if ([self.offlineReportInfoList containsObject:info]) {
        [self.offlineReportInfoList removeObject:info];
    }
    
    [self.reportInfoList removeObject:info];
}

- (void)checkReportListAndUpload {
    if (self.isReporting) {
        return;
    }
    if (self.reportInfoList.count == 0) {
        return;
    }
    
    NSDictionary *reportInfo = [self.reportInfoList objectAtIndex:0];
    NSArray      *reportInfoAllKeys = reportInfo.allKeys;
    if (![reportInfoAllKeys containsObject:@"host"]
        || ![reportInfoAllKeys containsObject:@"public_param"]
        || ![reportInfoAllKeys containsObject:@"biz_param"]
        || ![reportInfoAllKeys containsObject:@"method"]) {
        
        [self removeFirstReportInfoFromList];
        [self checkReportListAndUpload];
        
        return;
    }
    
    NSString     *host      = [reportInfo objectForKey:@"host"];
    NSDictionary *pubParams = [reportInfo objectForKey:@"public_param"];
    NSDictionary *bizParams = [reportInfo objectForKey:@"biz_param"];

    NSString     *identifer = nil;
    if ([reportInfoAllKeys containsObject:@"identifer"]) {
        identifer = [reportInfo objectForKey:@"identifer"];
    }
    
    NSString     *method    = [reportInfo objectForKey:@"method"];
    
    self.uploadingInfo = reportInfo;
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        @weakify(self)
        NSURLSessionDataTask* task = [CMHttpRequest postInfoCWithMethod:host publicParam:pubParams bizParam:bizParams onComplete:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
            @stronglize(self)
            kLogInfo(@"dicOrArray: (%@)", dicOrArray);
            if (!errorMsg) {
                self.isReporting = NO;
                self.currentRetryTimes = 0;
                kLogInfo(@"%@ isReported",task.taskDescription);
                if (self.reportInfoList.count > 0) {
                    [self removeFirstReportInfoFromList];
                    [self checkReportListAndUpload];
                }
            }
            else {
                self.isReporting = NO;
                self.currentRetryTimes++;
                
                if (self.currentRetryTimes < INFOC_REQUEST_MAX_RETRY_TIMES) {
                    [self checkReportListAndUpload];
                    return;
                }
                
                kLogInfo(@"%@ isReporting Timeout", task.taskDescription);
                if (self.reportInfoList.count > 0) {
                    [self removeFirstReportInfoFromList];
                    [self checkReportListAndUpload];
                }
            }
        }];
        if (task) {
            task.taskDescription = [NSString stringIsEmpty:identifer] ? @"identifer" : identifer;
            [task resume];
            self.isReporting = YES;
            kLogInfo(@"%@ isReporting",task.taskDescription);
        }
    }else {
//        @weakify(self)
//        NSURLSessionDataTask* task = [CMHttpRequest getWithMethod:host param:parameter onComplete:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
//            @stronglize(self)
//            kLogInfo(@"dicOrArray: (%@)", dicOrArray);
//            if (!errorMsg) {
//                self.isReporting = NO;
//                self.currentRetryTimes = 0;
//                kLogInfo(@"%@ isReported",task.taskDescription);
//                if (self.reportInfoList.count > 0) {
//                    [self removeFirstReportInfoFromList];
//                    [self checkReportListAndUpload];
//                }
//            }
//            else {
//                self.isReporting = NO;
//                self.currentRetryTimes++;
//                
//                if (self.currentRetryTimes < INFOC_REQUEST_MAX_RETRY_TIMES) {
//                    [self checkReportListAndUpload];
//                    return;
//                }
//                
//                kLogInfo(@"%@ isReporting Timeout", task.taskDescription);
//                if (self.reportInfoList.count > 0) {
//                    [self removeFirstReportInfoFromList];
//                    [self checkReportListAndUpload];
//                }
//            }
//        }];
//        if (task) {
//            task.taskDescription = [NSString stringIsEmpty:identifer] ? @"identifer" : identifer;
//            [task resume];
//        }
    }
}

@end
