//
//  InfoCManager.m
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "InfoCManager.h"
#import "BodyGenerator.h"
#import "PublicSection.h"
#import "FmtManager.h"
#import "NSString+Base64.h"
#import "InfoCResultParse.h"
#import <zlib.h>
#import "Utility.h"
#import "EncryptUtil.h"
#include "InfoCDefine.h"
#import "CommonKit.h"
#import "CMGroupDataManager.h"
#import "kinfoc_oc2cpp_adapter.h"
#define kLocalEventIndexKey     @"kLocalEventIndexKey"
#define kRemoteEventIndexKey    @"kRemoteEventIndexKey"

#define kLogIDKey               @"kLogIDKey"
#define kLogHeaderKey           @"kLogHeaderKey"
#define kLogDataKey             @"kLogDataKey"


@interface InfoCManager ()
{
    // 上传任务
    NSURLSessionDataTask* dataTask;
}

// 当前已上传数据位置，当前总数据位置
@property (nonatomic) NSUInteger localEventIndex;
@property (nonatomic) NSUInteger remoteEventIndex;

// 操作队列
@property (nonatomic, strong) dispatch_queue_t operationQueue;

// 上传时用到的数据
@property (nonatomic, copy) NSString* key;
@property (nonatomic) int time;
@property (nonatomic) NSInteger serialFailCount;
@property (nonatomic, strong) NSDate* failDate;

@end


@implementation InfoCManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _key = kInitKey;
        _time = kInitTime;
    }
    return self;
}

+ (instancetype)shareManager
{
    static InfoCManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[InfoCManager alloc] init];
        // 程序启动时强制发送一次记录
        [manager check:YES];
    });
    return manager;
}

- (dispatch_queue_t)operationQueue
{
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.keyboard.infoc", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (NSUInteger)localEventIndex
{
    NSUserDefaults *userDefaults = kCMGroupDataManager.shared;
    return [userDefaults integerForKey:kLocalEventIndexKey];
}

- (void)setLocalEventIndex:(NSUInteger)localEventIndex
{
    NSUserDefaults *userDefaults = kCMGroupDataManager.shared;
    [userDefaults setInteger:localEventIndex forKey:kLocalEventIndexKey];
    [userDefaults synchronize];
}

- (NSUInteger)remoteEventIndex
{
     NSUserDefaults *userDefaults = kCMGroupDataManager.shared;
    return [userDefaults integerForKey:kRemoteEventIndexKey];
}

- (void)setRemoteEventIndex:(NSUInteger)remoteEventIndex
{
     NSUserDefaults *userDefaults = kCMGroupDataManager.shared;
    [userDefaults setInteger:remoteEventIndex forKey:kRemoteEventIndexKey];
    [userDefaults synchronize];
}

- (NSString*)eventFileFloder
{
    return [Utility subPathForCacheDirectory:@"InfoC"];
}

- (void)event:(NSInteger)eventID params:(NSDictionary *)params
{
    if (!params || params.count == 0) {
        return;
    }
    
    if (![[BodyGenerator shareGenerator] checkQuery:eventID params:params]) {
        return;
    }
    
    // 先缓存数据，然后判断是否发送
    NSString* path = [[self eventFileFloder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.dat",(unsigned long)self.localEventIndex++]];
    NSDictionary* info = @{kLogIDKey : @(eventID),
                           kLogDataKey : params,
                           kLogHeaderKey : [PublicSection querys]};
    [info writeToFile:path atomically:YES];
    
    NSMutableString *reportStr = [[NSMutableString alloc] initWithFormat:@"Infoc report %ld, data:", (long)eventID];
    for(NSString *key in [params allKeys]) {
        [reportStr appendFormat:@"%@=%@, ", key, params[key]];
    }
    DLOG(@"%@", reportStr);

    [self check:NO];
}

- (void)check:(BOOL)force
{
    // 上次上报失败条数过多，要30s之后才继续上报
    if (_failDate && [[NSDate date] timeIntervalSinceDate:_failDate] < kRestTimeAfterTooMuchFail) {
        ERROR(@"Wait some seconds to report");
        return;
    }
    
    if (self.remoteEventIndex + kMaxInfoCCacheCount < self.localEventIndex || force) {
        static BOOL isReporting = NO;
        if (isReporting) {
            return;
        }
        isReporting = YES;
        dispatch_async(self.operationQueue, ^{
            [self startReport:^{
                isReporting = NO;
                [self check:NO];
            }];
        });
    }
}

- (void)forceReport
{
    [self check:YES];
}

- (void)startReport:(void(^)(void))completionBlock
{
    __block NSInteger singleReportFailCount = 0;
    __block NSUInteger i = 0;
    for (i = 0; i <= kMaxInfoCCacheCount; ) {
        if (!_networkReachable || self.remoteEventIndex >= self.localEventIndex) {
            if (completionBlock) {
                completionBlock();
            }
            return;
        }
        
        NSString* path = [[self eventFileFloder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.dat",(unsigned long)self.remoteEventIndex]];
        NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:path];
        NSInteger eventID = [info[kLogIDKey] integerValue];
        NSDictionary* params = info[kLogDataKey];
        NSDictionary* header = info[kLogHeaderKey];
        if (eventID != 0 && params) {            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            __weak typeof(self) weakSelf = self;
            [self sendEvent:eventID params:params withHeader:header completion:^(NSDictionary *result, NSError *error) {
                if (result && !error) { // 成功上报
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    self.remoteEventIndex++;
                    i++;
                    
                    if (result[kReportTimeKey] && result[kReportKeyKey]) {
                        weakSelf.time = [result[kReportTimeKey] intValue];
                        weakSelf.key  = result[kReportKeyKey];
                    }
                } else {
                    if (singleReportFailCount < kRetryTimes) { // 继续尝试单个上报
                        singleReportFailCount++;
                    } else {
                        singleReportFailCount = 0;
                        
                        if (weakSelf.networkReachable) {
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                            weakSelf.remoteEventIndex++;
                            i++;
                        }
                        
                        weakSelf.serialFailCount++;
                        if (weakSelf.serialFailCount >= kMaxFailTimes) { // 失败次数超过最大限度，取消本次上传
                            i = kMaxInfoCCacheCount + 100;
                            weakSelf.failDate = [NSDate date];
                            weakSelf.serialFailCount = 0;
                            ERROR(@"Too much fail report,and will wait!");
                        }
                    }
                }
                
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        } else { // 数据损毁
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            self.remoteEventIndex++;
            i++;
        }
    }
    
    if (completionBlock) {
        
        completionBlock();
    }
}


#pragma mark - Net Work
- (void)sendEvent:(NSInteger)eventID params:(NSDictionary *)params withHeader:(NSDictionary*)publicInfo completion:(void(^)(NSDictionary* result, NSError* error))block
{
    [self infoCEncryptPost:eventID params:params withHeader:publicInfo completion:block];
}

- (void)infoCGet:(NSInteger)eventID params:(NSDictionary *)params withHeader:(NSDictionary*)publicInfo completion:(void(^)(NSDictionary* result, NSError* error))block
{
    NSString* queryString = [[BodyGenerator shareGenerator] getQueryString:eventID params:params withHeader:publicInfo];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/g/v1/?%@",kHost,queryString]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary* result = [InfoCResultParse parseResult:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
        block(result, error);
    }];
}

- (void)infoCEncryptGet:(NSInteger)eventID params:(NSDictionary *)params withHeader:(NSDictionary*)publicInfo completion:(void(^)(NSDictionary* result, NSError* error))block
{
    NSString* queryString = [[BodyGenerator shareGenerator] getQueryString:eventID params:params withHeader:publicInfo];
    
    NSData* keyData = [_key base64DecodeString];
    NSString* encode = [queryString AES128EncryptWithKey:keyData andIV:keyData];
    NSData* s = [encode dataUsingEncoding:NSUTF8StringEncoding];
    
    uLong crc = crc32(0, s.bytes, (uInt)s.length);
    crc = crc32(crc, keyData.bytes, (uInt)keyData.length);
    crc &= 0xffffffff;
    
    NSString* query = [NSString stringWithFormat:@"time=%d&crc32=%lu&data=%@",_time,crc,encode];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/eg/v1/?%@",kHost,query]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary* result = [InfoCResultParse parseResult:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
        block(result, error);
    }];
}

- (void)infoCPost:(NSInteger)eventID params:(NSDictionary *)params withHeader:(NSDictionary*)publicInfo completion:(void(^)(NSDictionary* result, NSError* error))block
{
    NSMutableData* body = [NSMutableData data];
    
    short public_index = [publicInfo[@"public_index"] intValue];
    [body appendData:[[BodyGenerator shareGenerator] buildSection:public_index withQuerys:publicInfo]];
    
    [body appendData:[[BodyGenerator shareGenerator] buildSection:eventID withQuerys:params]];
    
    uLong crc = crc32(0, body.bytes, (uInt)body.length);
    crc = crc & 0xffffffff;
    
    short size = body.length + sizeof(short) + sizeof(Byte) + sizeof(Byte) + sizeof(short) + sizeof(int);
    NSMutableData* header = [NSMutableData dataWithBytes:&size length:sizeof(size)];
    Byte version = 1;
    Byte product = kProductNo;
    short count = 2;

    [header appendBytes:&version length:sizeof(version)];
    [header appendBytes:&product length:sizeof(product)];
    [header appendBytes:&count length:sizeof(count)];
    [header appendBytes:&crc length:sizeof(int)];
    
    [header appendBytes:body.bytes length:body.length];
    
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/c/",kHost]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    dataTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:header completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary* result = [InfoCResultParse parseResult:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
        block(result, error);
    }];
    [dataTask resume];
}

- (void)infoCEncryptPost:(NSInteger)eventID params:(NSDictionary *)params withHeader:(NSDictionary*)publicInfo completion:(void(^)(NSDictionary* result, NSError* error))block
{
    NSMutableData* body = [NSMutableData data];

    short public_index = [publicInfo[@"public_index"] intValue];
    [body appendData:[[BodyGenerator shareGenerator] buildSection:public_index withQuerys:publicInfo]];

    [body appendData:[[BodyGenerator shareGenerator] buildSection:eventID withQuerys:params]];

    //add emtpy header
    NSMutableData* header = [NSMutableData data];
    short size = 0;
    Byte version = 1;
    Byte product = kProductNo;
    short count = 2;
    uLong crc = 0;

    [header appendBytes:&size length:sizeof(size)];
    [header appendBytes:&version length:sizeof(version)];
    [header appendBytes:&product length:sizeof(product)];
    [header appendBytes:&count length:sizeof(count)];
    [header appendBytes:&crc length:sizeof(int)];
    [header appendData:body];
    
    short headerSize = sizeof(short) + sizeof(Byte) + sizeof(Byte) + sizeof(short) + sizeof(int) ;
    size = header.length;

    crc = crc32(0, header.bytes+headerSize, (uInt)header.length-headerSize);
    [header replaceBytesInRange:NSMakeRange(0, 0) withBytes:&crc length:sizeof(int)];
    [header replaceBytesInRange:NSMakeRange(0, 0) withBytes:&size length:sizeof(size)];
    
    NSMutableData *reportDate = [NSMutableData data];
    [reportDate appendData:body];
    [reportDate replaceBytesInRange:NSMakeRange(0, 0) withBytes:&crc length:sizeof(int)];
    [reportDate replaceBytesInRange:NSMakeRange(0, 0) withBytes:&count length:sizeof(count)];
     [reportDate replaceBytesInRange:NSMakeRange(0, 0) withBytes:&product length:sizeof(product)];
    [reportDate replaceBytesInRange:NSMakeRange(0, 0) withBytes:&version length:sizeof(version)];
     [reportDate replaceBytesInRange:NSMakeRange(0, 0) withBytes:&size length:sizeof(size)];
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",kHost]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];

    dataTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:reportDate completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary* result = [InfoCResultParse parseResult:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
        block(result, error);
    }];
    [dataTask resume];
}
@end
