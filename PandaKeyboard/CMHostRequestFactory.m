//
//  CMHostRequestFactory.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMHostRequestFactory.h"

//static NSString *const kCloudVersionURLFormat = @"https://ups.ksmobile.net/%@/getversions.php";
//static NSString *const kCloudConfigURLFormat = @"https://ws.ksmobile.net/api/GetCloudMsgAdv";

@implementation CMHostRequestFactory

+ (NSURLSessionDataTask *)feedbackRequestWithContact:(NSString *)contact
                                             content:(NSString *)content
                                      imageArray:(NSArray<UIImage*>*)imageArray
                                       completeBlock:(CMRequestComplete)requestComplete
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[CMAppConfig currentLanguage] forKey:@"syslang"];
    [params setObject:[CMAppConfig deviceModel] forKey:@"model"];
    [params setObject:[CMAppConfig feedBackAppId] forKey:@"app_id"];
    [params setObject:[CMAppConfig feedBackChannel] forKey:@"chanel"];
    [params setObject:[CMAppConfig feedBackType] forKey:@"type"];
    [params setObject:[CMAppConfig systemVersion] forKey:@"sysversion"];
    [params setObject:[CMAppConfig deviceIdentify] forKey:@"uuid"];
    [params setObject:[CMAppConfig buildId] forKey:@"version"];
    
    [params setObject:[CMAppConfig bundleIdentifier] forKey:@"pkg_name"];
    [params setObject:[CMAppConfig country] forKey:@"country_setting"];
    [params setObject:[NSNumber numberWithFloat:[CMAppConfig horizontalResolution]] forKey:@"resolution"];
    [params setObject:[NSString stringWithFormat:@"%f,%f",kScreenWidth,kScreenHeight] forKey:@"screensize"];
    [params setObject:[CMAppConfig mobileCountryCode] forKey:@"mcc"];
    [params setObject:[NSString stringIsEmpty:[CMAppConfig firstLaunchTime]] ? [CMBizHelper getDate] : [CMAppConfig firstLaunchTime] forKey:@"installtime"];
    

    [params setObject:contact forKey:@"contact"];
    [params setObject:content forKey:@"content"];

    if (imageArray && imageArray.count > 0) {
        [params setObject:@"yes" forKey:@"haveimage"];
        [params setObject:[NSNumber numberWithInteger:imageArray.count] forKey:@"image_num"];
        NSURLSessionDataTask* task = [CMHttpRequest postWithMethod:@"https://tuc.ksmobile.net/report" param:params imageArray:imageArray onComplete:requestComplete];
        return task;
    }
    
    NSURLSessionDataTask* task = [CMHttpRequest postWithMethod:@"https://tuc.ksmobile.net/report" param:params onComplete:requestComplete];
    return task;
}

+ (NSURLSessionDataTask *)fetchThemeListWithPageNum:(NSUInteger)pageNum
                                           hasCount:(NSUInteger)hasCount
                                        lastModelId:(NSString *)lastModelId
                                             offset:(NSUInteger)offset
                                         fetchCount:(NSUInteger)count
                                      completeBlock:(CMRequestComplete)completeBlock {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@(1) forKey:@"class"];
    [params setObject:[CMAppConfig deviceId] forKey:@"userid"];
    [params setObject:[CMAppConfig mobileCountryCode] forKey:@"mcc"];
    [params setObject:[CMAppConfig currentLanguage] forKey:@"lang"];
    [params setObject:[CMAppConfig appVersion] forKey:@"ver"];
    [params setObject:[NSString stringWithFormat:@"%.0fx%.0f",kScreenWidth,kScreenHeight] forKey:@"vga"];
    [params setObject:[NSString stringWithFormat:@"%.0fx", round([UIScreen mainScreen].scale)] forKey:@"pt"];
    [params setObject:@(pageNum) forKey:@"page"];
    [params setObject:@(hasCount) forKey:@"has"];
    [params setObject:lastModelId?lastModelId:@"" forKey:@"pagelast"];
    [params setObject:@(offset) forKey:@"offset"];
    [params setObject:@(count) forKey:@"count"];
    NSURLSessionDataTask* task = [CMHttpRequest getWithMethod:[CMAppConfig fetchThemeListUrl] param:params onComplete:completeBlock];
//    NSURLSessionDataTask* task = [CMHttpRequest postWithMethod:[CMAppConfig fetchThemeListUrl] param:params onComplete:completeBlock];
    return task;
}

+ (NSURLSessionDataTask *)fetchDiySourceWithType:(CMDiySourceType)sourceType offset:(NSUInteger)offset fetchCount:(NSUInteger)count completeBlock:(CMRequestComplete)completeBlock
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@(count) forKey:@"count"];
    [params setObject:@(offset) forKey:@"offset"];
    [params setObject:[CMAppConfig mobileCountryCode] forKey:@"mcc"];
    [params setObject:[CMAppConfig appVersion] forKey:@"appv"];
    NSString *urlStr = nil;
    switch (sourceType) {
        case CMDiySourceTypeBackground:
            urlStr = [CMAppConfig fetchDiyBgSourcesUrl];
            break;
        case CMDiySourceTypeSounds:
            urlStr = [CMAppConfig fetchDiySoundSourcesUrl];
            break;
        case CMDiySourceTypeFonts:
            urlStr = [CMAppConfig fetchDiyFontSourcesUrl];
            break;
        default:
            break;
    }
    NSURLSessionDataTask* task = [CMHttpRequest getWithMethod:urlStr param:params onComplete:completeBlock];
    return task;
}

//+ (NSURLSessionDataTask *)cloudVersionRequestWithProductName:(NSString *)productName completeBlock:(CMRequestComplete)requestComplete
//{
//    NSString *pullUrl = [NSString stringWithFormat:kCloudVersionURLFormat, productName];
//    
//    CMHttpRequest * request = [[CMHttpRequest alloc] init];
//    NSMutableDictionary * param = [NSMutableDictionary dictionary];
//    NSURLSessionDataTask * task = [request getWithMethod:pullUrl param:param onComplete:requestComplete];
//    return task;
//}
//
//+ (NSURLSessionDataTask *)cloudMessageRequestWithLanguage:(NSString *)language channelId:(NSString *)channelId pkg:(NSString *)pkg completeBlock:(CMRequestComplete)requestComplete
//{
//    CMHttpRequest * request = [[CMHttpRequest alloc] init];
//    
//    NSString *mcc = [CMAppConfig mobileCountryCode];
//    if ([mcc isEqualToString:@""]) {
//        mcc = @"null";
//    }
//    
//    NSMutableDictionary * param = [NSMutableDictionary dictionary];
//    
//    [param setObject:language ? language : CloudDefaultLan forKey:@"lan"];
//    [param setObject:[CMAppConfig buildId] forKey:@"apkversion"];
//    [param setObject:channelId ? channelId : CloudDefaultChId forKey:@"channelid"];
//    [param setObject:[CMAppConfig systemVersion] forKey:@"osversion"];
//    [param setObject:mcc forKey:@"mcc"];
//    [param setObject:[CMAppConfig deviceModel] forKey:@"device"];
//    [param setObject:[NSString stringWithFormat:@"%f*%f",[CMAppConfig horizontalResolution],[CMAppConfig verticalResolution]] forKey:@"resolution"];
//    [param setObject:[NSNumber numberWithLong:[CMAppConfig getPhysicalMemory]] forKey:@"mem_size"];
//    [param setObject:pkg ? pkg : CloudPackageName forKey:@"pkg"];
//    [param setObject:@"1" forKey:@"version"];
//    [param setObject:[CMAppConfig idfa] forKey:@"aid"];
//    
//    NSURLSessionDataTask * task = [request getWithMethod:kCloudConfigURLFormat param:param onComplete:requestComplete];
//    
//    return task;
//}

@end
