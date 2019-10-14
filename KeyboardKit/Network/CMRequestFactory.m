//
//  CMRequestFactory.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/10/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRequestFactory.h"
#import "CMAppConfig.h"
#import "CMBizHelper.h"
#import "CMMacro.h"
#import "NSString+Common.h"
#import "CMHttpClient.h"
#import "CMLogger.h"
#import "CMError.h"
#import "CMGroupDataManager.h"

// 测试host：123.206.86.246
static NSString *const kCloudVersionURLFormat = @"https://ups.ksmobile.net/%@/getversions.php";
static NSString *const kCloudConfigURLFormat = @"https://ws.ksmobile.net/api/GetCloudMsgAdv";

#ifdef DEBUG
static NSString *const kCloudPredictionConfigURLFormat = @"http://cfg.panda.ksmobile.com/v1/cfg";
#else
static NSString *const kCloudPredictionConfigURLFormat = @"https://cfgpanda.ksmobile.com/v1/cfg";
#endif

static NSString *const kGiphyKey = @"i9w53N2uaSXjhkRhEUhv8Y0vOyQLYugz";
static NSString *const kGiphyHttps = @"https://api.giphy.com/v1/gifs";
@implementation CMRequestFactory

+ (NSURLSessionDataTask *)cloudVersionRequestWithProductName:(NSString *)productName completeBlock:(CMRequestComplete)requestComplete
{
    NSString *pullUrl = [NSString stringWithFormat:kCloudVersionURLFormat, productName];
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    NSURLSessionDataTask * task = [CMHttpRequest getWithMethod:pullUrl param:param onComplete:requestComplete];
    return task;
}

+ (NSURLSessionDataTask *)cloudMessageRequestWithLanguage:(NSString *)language channelId:(NSString *)channelId pkg:(NSString *)pkg completeBlock:(CMRequestComplete)requestComplete
{
    
    NSString *mcc = [CMAppConfig mobileCountryCode];
    if ([mcc isEqualToString:@""] || [mcc isEqualToString:@"0"]) {
        mcc = @"null";
    }
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    
    [param setObject:![NSString stringIsEmpty:language] ? language : [CMAppConfig currentLanguage] forKey:@"lan"];
    [param setObject:[CMAppConfig appVersion] forKey:@"apkversion"];
    [param setObject:![NSString stringIsEmpty:channelId] ? channelId : [CMAppConfig channelId] forKey:@"channelid"];
    [param setObject:[CMAppConfig systemVersion] forKey:@"osversion"];
    [param setObject:mcc forKey:@"mcc"];
    [param setObject:[CMAppConfig deviceModel] forKey:@"device"];
    [param setObject:[NSString stringWithFormat:@"%f*%f",[CMAppConfig horizontalResolution],[CMAppConfig verticalResolution]] forKey:@"resolution"];
    [param setObject:[NSNumber numberWithLong:[CMAppConfig getPhysicalMemory]] forKey:@"mem_size"];
    [param setObject:![NSString stringIsEmpty:pkg] ? pkg : [CMAppConfig bundleIdentifier] forKey:@"pkg"];
    [param setObject:@"1" forKey:@"version"];
    [param setObject:[CMAppConfig deviceId] forKey:@"aid"];
    
    NSURLSessionDataTask * task = [CMHttpRequest getWithMethod:kCloudConfigURLFormat param:param onComplete:requestComplete];
    
    
    return task;
}

+ (NSURLSessionDataTask *)cloudPredictionConfigRequestWithLanguage:(NSString*)language completeBlock:(CMRequestComplete)requestComplete{
    
    int net = [CMBizHelper getNetType];
    NSString *netstr;
    switch (net) {
        case 1:
            netstr = @"0";
            break;
        case 2:
            netstr = @"2";
            break;
        case 3:
            netstr = @"3";
            break;
        case 4:
            netstr = @"4";
            break;
        case 5:
            netstr = @"1";
            break;
        default:
            netstr = @"0";
            break;
    }
    
    NSDictionary * param = @{@"pid":@"2",
                             @"lan":[CMAppConfig currentLanguage],
                             @"dictlang":language,
                             @"net":netstr,
                             @"aid":[CMAppConfig deviceId],
                             @"barnd":@"0",
                             @"model":[CMAppConfig deviceModel],
                             @"osv":[CMAppConfig systemVersion],
                             @"appv":[CMAppConfig appVersion],
                             @"mcc":[CMAppConfig mobileCountryCode],
                             @"mnc":[CMAppConfig mobileNetworkCode],
                             @"vga":[NSString stringWithFormat:@"%dx%d", (int)kScreenWidth, (int)kScreenHeight],
                             @"srv":@"prediction",
                             @"scene":@"1"};//1 键盘弹出
    
    NSURLSessionDataTask * task = [CMHttpRequest getWithMethod:kCloudPredictionConfigURLFormat param:param onComplete:requestComplete];
    
    return task;
}

+ (NSURLSessionDownloadTask *)downloadRequestWithURL:(NSString *)url
                                       progressBlock:(CMProgressBlock)progressBlock
                                       completeBlock:(CMDownloadCompleteBlock)completeBlock {
    NSURLSessionDownloadTask* task = [CMHttpRequest downloadWithUrl:url onProgress:progressBlock onComplete:completeBlock];
    return task;
}

+ (NSURLSessionDownloadTask *)downloadRequestWithUrl:(NSString *)url
                                        themeVersion:(NSString *)version
                                       progressBlock:(CMProgressBlock)progressBlock
                                       completeBlock:(CMDownloadCompleteBlock)completeBlock {
    //    NSString* url1 = @"http://yaozongchao.info/wp-content/uploads/2017/07/purple_hologram.zip";
    NSURLSessionDownloadTask* task = [CMHttpRequest downloadWithUrl:url onProgress:progressBlock onComplete:completeBlock];
    return task;
}

+ (NSURLSessionDownloadTask *)downloadDiyResourceRequestWithURL:(NSString *)url targetFilePath:(NSURL *)filePath progressBlock:(CMProgressBlock)progressBlock completeBlock:(CMDownloadCompleteBlock)completeBlock
{
    NSURLSessionDownloadTask* task = [CMHttpRequest downloadDiyResourceWithUrl:url targetFilePath:filePath onProgress:progressBlock onComplete:completeBlock];
    return task;
    
}


+ (void)jsonDataCache:(NSString*)dataPath overtimeSec:(int)sec completion:(void (^)(NSData * data, NSError *error))block{
    
    
    NSFileManager *fileMgr = [NSFileManager defaultManager] ;
    if(![fileMgr fileExistsAtPath:dataPath]){block(nil, nil);return;}
    NSError *error = nil;
    NSDictionary *fileAttrs = [fileMgr attributesOfItemAtPath:dataPath error:&error];
    NSDate *fileModifiedDate = [fileAttrs objectForKey:NSFileModificationDate];
    NSDate * data = [NSDate date];
    NSTimeInterval intervalTime = [data timeIntervalSinceDate:fileModifiedDate];
    if(sec != 0 && intervalTime > sec){block(nil, nil);return;}
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * data = [NSData dataWithContentsOfFile:dataPath];
        if(data){
            block(data, nil);
        }else{
            [fileMgr removeItemAtPath:dataPath error:nil];
            block(nil, nil);
        }
    });

}


+ (NSURLSessionDataTask*) fetchGifTags:(CMRequestComplete) completeBlock
{
    if (!completeBlock)
    {
        return nil;
    }
    __block NSURLSessionDataTask* theTask = nil;
    
    NSString * urlStr;
    if (@available(iOS 11.2, *)) {
        urlStr = @"http://api.tenor.com/v1/tags?key=XJOKQ19E4PPO";
    } else {
        urlStr = @"https://api.tenor.com/v1/tags?key=XJOKQ19E4PPO";
    }
    
    NSString *md5 = [urlStr md5];
    NSFileManager *fileMgr = [NSFileManager defaultManager] ;
    NSString *tmpDir =  [kCMGroupDataManager.Caches.path stringByAppendingPathComponent:@"cmcm.tenor"];
    if(![fileMgr fileExistsAtPath:tmpDir]){
        [fileMgr createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString * dataPath = [tmpDir stringByAppendingPathComponent:md5];
    [self jsonDataCache:dataPath overtimeSec:24*60*60 completion:^(NSData *data, NSError *error) {
        BOOL needRequest = YES;
        if(data){
            NSError * error;
                id results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if (results && [results isKindOfClass:[NSArray class]]){
                    completeBlock(nil, results, nil);
                    needRequest= NO;
                }
        }
        if(!needRequest)return ;
        
        theTask = [[CMHttpClient sharedClient] GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* infoDic = (NSDictionary*) responseObject;
                id responseData = [infoDic objectForKey:@"tags"];
                completeBlock(task, responseData, nil);
                
                NSData * arrToData = [NSJSONSerialization dataWithJSONObject:responseData options:NSJSONWritingPrettyPrinted error:nil];
                [arrToData writeToFile:dataPath atomically:YES];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                   {
                       [CMRequestFactory jsonDataCache:dataPath overtimeSec:0 completion:^(NSData *data, NSError *error) {
                           if(data){
                               id results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                               if (results && [results isKindOfClass:[NSArray class]]){
                                   completeBlock(nil, results, nil);
                               }
                           }else{
                               completeBlock(task, nil, [CMError errorWithNSError:error]);
                           }
                       }];
                       
                   }];
        
        [theTask resume];
    }];
    
    return theTask;
}

+ (NSURLSessionDataTask*) giphyRequestGet:(NSString*)urlStr completion:(CMRequestComplete) completeBlock{
    
    __block NSURLSessionDataTask* theTask = nil;
    NSString *md5 = [urlStr md5];
    NSFileManager *fileMgr = [NSFileManager defaultManager] ;
//    NSString *tmpDir =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"cmcm.giphyData"];
    NSString *tmpDir =  [kCMGroupDataManager.Caches.path stringByAppendingPathComponent:@"cmcm.giphyData"];
    if(![fileMgr fileExistsAtPath:tmpDir]){
        [fileMgr createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString * dataPath = [tmpDir stringByAppendingPathComponent:md5];
    
    [self jsonDataCache:dataPath overtimeSec:2*60*60 completion:^(NSData *data, NSError *error) {
        BOOL needRequest = YES;
        if(data){
            NSError * error;
            id results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (results && [results isKindOfClass:[NSDictionary class]]){
                completeBlock(nil, results, nil);
                needRequest= NO;
            }
        }
        if(!needRequest)return ;
        
        theTask = [[CMHttpClient sharedClient] GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* infoDic = (NSDictionary*) responseObject;
                completeBlock(task, infoDic, nil);
                
                NSData * arrToData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
                [arrToData writeToFile:dataPath atomically:YES];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                   {
                       [CMRequestFactory jsonDataCache:dataPath overtimeSec:0 completion:^(NSData *data, NSError *error) {
                           if(data){
                               NSError * error;
                               id results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                               if (results && [results isKindOfClass:[NSDictionary class]]){
                                   completeBlock(nil, results, nil);
                               }
                           }else{
                               completeBlock(task, nil, [CMError errorWithNSError:error]);
                           }
                       }];
                   }];
        
        [theTask resume];
    }];
    return theTask;
}

+ (NSURLSessionDataTask*) giphyTrendingRequestWithLimit:(NSUInteger) limit offset:(NSUInteger) offset  lang:(NSString*)lang completion:(CMRequestComplete) completeBlock{
    if (!completeBlock) return nil;

    NSString * urlStr = [NSString stringWithFormat:@"%@/trending?api_key=%@&limit=%d&offset=%d&rating=G&lang=%@",kGiphyHttps,kGiphyKey,(int)limit,(int)offset,lang];
    
    NSURLSessionDataTask* theTask = [self giphyRequestGet:urlStr completion:completeBlock];
   
   
    return theTask;
    
}

+ (NSURLSessionDataTask*) giphySearchTagWithQ:(NSString*)q Limit:(NSUInteger) limit offset:(NSUInteger) offset  lang:(NSString*)lang completion:(CMRequestComplete) completeBlock{
     if (!completeBlock) return nil;
    NSString * tab = [q stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];

    NSString * urlStr = [NSString stringWithFormat:@"%@/search?api_key=%@&limit=%d&offset=%d&rating=G&lang=%@&q=%@",kGiphyHttps,kGiphyKey,(int)limit,(int)offset,lang,tab];
    NSURLSessionDataTask* theTask = [self giphyRequestGet:urlStr completion:completeBlock];
    
    return theTask;
}


@end
