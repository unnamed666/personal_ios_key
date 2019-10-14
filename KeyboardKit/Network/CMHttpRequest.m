//
//  CMHttpRequest.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMHttpRequest.h"
#import "CMHttpClient.h"
#import "CMDirectoryHelper.h"
#import "CMError.h"
#import "NSString+Common.h"
#import "NSDictionary+Common.h"
#import "CMGroupDataManager.h"

@implementation CMHttpRequest

+(NSURLSessionDataTask *)postInfoCWithMethod:(NSString*)method
                                 publicParam:(NSDictionary*)pParam
                                    bizParam:(NSDictionary*)bParam
                                  onComplete:(CMRequestComplete)requestComplete {
    if ([NSString stringIsEmpty:method]) {
        return nil;
    }
    NSMutableString *requestBody = [[NSMutableString alloc] init];
    if (pParam.allKeys.count > 0) {
        NSArray *parametersKey = [pParam allKeys];
        for (int i = 0; i < parametersKey.count; i++) {
            NSString *key = [parametersKey objectAtIndex:i];
            NSString *value = [pParam objectForKey:key];
            if (i == parametersKey.count - 1) {
                [requestBody appendFormat:@"%@:%@",key,value];
            }else {
                [requestBody appendFormat:@"%@:%@ ",key,value];
            }
        }
    }

    if ([NSString stringIsEmpty:requestBody]) {
        return nil;
    }

    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:method parameters:nil error:nil];
    NSData* data = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:data];

    NSURLSessionDataTask *sessionTask = [[CMHttpClient sharedClient] dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                requestComplete(nil, responseObject, nil);
            }
            else {
                requestComplete(nil, nil, [CMError errorWithCode:httpResponse.statusCode errorMessage:[NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]]);
            }
        }
        else {
            requestComplete(nil, nil, [CMError errorWithNSError:error]);
        }
    }];
    return sessionTask;
}


+(NSURLSessionDataTask *)postWithMethod:(NSString*)method
                                  param:(NSDictionary*)param
                             onComplete:(CMRequestComplete) requestComplete {
    if ([NSString stringIsEmpty:method]) {
        return nil;
    }
    
    NSURLSessionDataTask *sessionTask = [[CMHttpClient sharedClient] POST:method parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (requestComplete) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary* infoDic = (NSDictionary *)responseObject;
                if ([infoDic.allKeys containsObject:@"code"]) {
                    NSInteger statusCode = [infoDic integerValueForKey:@"code" defaultValue:-1];
                    if (statusCode == 0) {
                        requestComplete(task, infoDic, nil);
                    }
                    else {
                        requestComplete(task, nil, [CMError errorWithCode:statusCode errorMessage:[infoDic stringValueForKey:@"msg"]]);
                    }
                }
                else if ([infoDic.allKeys containsObject:@"ret"]) {
                    NSInteger statusCode = [infoDic integerValueForKey:@"ret" defaultValue:-1];
                    if (statusCode == 1) {
                        requestComplete(task, infoDic, nil);
                    }
                    else {
                        requestComplete(task, nil, [CMError errorWithCode:statusCode errorMessage:[infoDic stringValueForKey:@"msg"]]);
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (requestComplete) {
            requestComplete(task, nil, [CMError errorWithNSError:error]);
        }
    }];
    return sessionTask;
}

+(NSURLSessionDataTask *)postWithMethod:(NSString*)method
                                  param:(NSDictionary*)param
                              imageData:(NSData*)imageData
                              imageName:(NSString*)imageName
                             onComplete:(CMRequestComplete)requestComplete {
    if ([NSString stringIsEmpty:method] || imageData == nil || imageName == nil) {
        return nil;
    }
    
    NSURLSessionDataTask* sessionTask = [[CMHttpClient sharedClient] POST:method parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if(imageData)[formData appendPartWithFileData:imageData name:imageName fileName:imageName mimeType:@"image/jpg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (requestComplete) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary* infoDic = (NSDictionary *)responseObject;
                NSInteger statusCode = [infoDic integerValueForKey:@"code" defaultValue:-1];
                if (statusCode == 0) {
                    requestComplete(task, infoDic, nil);
                }
                else {
                    requestComplete(task, nil, [CMError errorWithCode:statusCode errorMessage:[infoDic stringValueForKey:@"msg"]]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (requestComplete) {
            requestComplete(task, nil, [CMError errorWithNSError:error]);
        }
    }];
    return sessionTask;
}

+(NSURLSessionDataTask *)postWithMethod:(NSString*)method
                                  param:(NSDictionary*)param
                             imageArray:(NSArray<UIImage*>*)imageArray
                             onComplete:(CMRequestComplete)requestComplete {
    if ([NSString stringIsEmpty:method] || imageArray == nil || imageArray.count <= 0) {
        return nil;
    }
    
    NSURLSessionDataTask* sessionTask = [[CMHttpClient sharedClient] POST:method parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [imageArray enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:[NSString stringWithFormat:@"image_%lu", (unsigned long)idx] fileName:[NSString stringWithFormat:@"image_%lu", (unsigned long)idx] mimeType:@"image/jpg"];
        }];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (requestComplete) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary* infoDic = (NSDictionary *)responseObject;
                NSInteger statusCode = [infoDic integerValueForKey:@"code" defaultValue:-1];
                if (statusCode == 0) {
                    requestComplete(task, infoDic, nil);
                }
                else {
                    requestComplete(task, nil, [CMError errorWithCode:statusCode errorMessage:[infoDic stringValueForKey:@"msg"]]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (requestComplete) {
            requestComplete(task, nil, [CMError errorWithNSError:error]);
        }
    }];
    return sessionTask;
}



+(NSURLSessionDataTask *)getWithMethod:(NSString*)method
                                 param:(NSDictionary*)param
                            onComplete:(CMRequestComplete) requestComplete {
    if ([NSString stringIsEmpty:method]) {
        return nil;
    }
    NSURLSessionDataTask *sessionTask = [[CMHttpClient sharedClient] GET:method parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (requestComplete) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary* infoDic = (NSDictionary *)responseObject;
                NSInteger statusCode = [infoDic integerValueForKey:@"code" defaultValue:-1];
                id responseData = [infoDic objectForKey:@"data"];
                if (statusCode == 0) {
                    requestComplete(task, infoDic, nil);
                }
                else if (statusCode == -1 && responseData) {
                    requestComplete(task, infoDic, nil);
                }
                else {
                    requestComplete(task, nil, [CMError errorWithCode:statusCode errorMessage:[infoDic stringValueForKey:@"msg"]]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (requestComplete) {
            requestComplete(task, nil, [CMError errorWithNSError:error]);
        }
    }];
    return sessionTask;
}


+(NSURLSessionDownloadTask *)downloadWithUrl:(NSString*)url
                                  onProgress:(CMProgressBlock)progressBlock
                                  onComplete:(CMDownloadCompleteBlock)completeBlock {
    if ([NSString stringIsEmpty:url]) {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask* downloadTask = [[CMHttpClient sharedClient] downloadTaskWithRequest:request progress:progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [CMGroupDataManager shareInstance].Documents;
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completeBlock) {
            CMError* cmError = [CMError errorWithNSError:error];
            completeBlock(response, filePath, cmError);
        }
    }];
    return downloadTask;
}

+ (NSURLSessionDownloadTask *)downloadDiyResourceWithUrl:(NSString *)url targetFilePath:(NSURL *)filePath onProgress:(CMProgressBlock)progressBlock onComplete:(CMDownloadCompleteBlock)completeBlock {
    if ([NSString stringIsEmpty:url]) {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask* downloadTask = [[CMHttpClient sharedClient] downloadTaskWithRequest:request progress:progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return filePath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completeBlock) {
            CMError* cmError = [CMError errorWithNSError:error];
            completeBlock(response, filePath, cmError);
        }
    }];
    return downloadTask;
}

+(NSURLSessionUploadTask *)uploadWithUrl:(NSString*)url
                                filePath:(NSString*)filePath
                              onProgress:(CMProgressBlock)progressBlock
                              onComplete:(CMUploadCompleteBlock)completeBlock {
    if ([NSString stringIsEmpty:url] || [NSString stringIsEmpty:filePath]) {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionUploadTask* uploadTask = [[CMHttpClient sharedClient] uploadTaskWithRequest:request fromFile:[NSURL URLWithString:filePath] progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completeBlock) {
            completeBlock(response, responseObject, [CMError errorWithNSError:error]);
        }
    }];
    return uploadTask;
}

+(NSURLSessionUploadTask *)uploadWithUrl:(NSString*)url
                                    data:(NSData*)data
                              onProgress:(CMProgressBlock)progressBlock
                              onComplete:(CMUploadCompleteBlock)completeBlock {
    if ([NSString stringIsEmpty:url] || data == nil) {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionUploadTask* uploadTask = [[CMHttpClient sharedClient] uploadTaskWithRequest:request fromData:data progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completeBlock) {
            completeBlock(response, responseObject, [CMError errorWithNSError:error]);
        }
    }];
    return uploadTask;
}

@end
