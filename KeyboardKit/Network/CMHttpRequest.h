//
//  CMHttpRequest.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CMError;

// errorNum －1表示网络错误, 0表示成功，其它数据表示接口错误代码
typedef void (^CMRequestComplete)(NSURLSessionDataTask* task, id dicOrArray, CMError* errorMsg);

typedef void (^CMProgressBlock)(NSProgress *downloadProgress);
typedef void (^CMDownloadCompleteBlock)(NSURLResponse *response, NSURL *filePath, CMError *error);
typedef void (^CMUploadCompleteBlock)(NSURLResponse *response, id responseObject, CMError *error);

@interface CMHttpRequest : NSObject

/**
 *发送请求
 */

+(NSURLSessionDataTask *)postInfoCWithMethod:(NSString*)method
                                 publicParam:(NSDictionary*)pParam
                                    bizParam:(NSDictionary*)bParam
                                  onComplete:(CMRequestComplete)requestComplete;

+(NSURLSessionDataTask *)postWithMethod:(NSString*)method
                                  param:(NSDictionary*)param
                             onComplete:(CMRequestComplete)requestComplete;


+(NSURLSessionDataTask *)postWithMethod:(NSString*)method
                                  param:(NSDictionary*)param
                              imageData:(NSData*)imageData
                              imageName:(NSString*)imageName
                             onComplete:(CMRequestComplete)requestComplete;

+(NSURLSessionDataTask *)postWithMethod:(NSString*)method
                                  param:(NSDictionary*)param
                              imageArray:(NSArray<UIImage*>*)imageArray
                             onComplete:(CMRequestComplete)requestComplete;

+(NSURLSessionDataTask *)getWithMethod:(NSString*)method
                                 param:(NSDictionary*)param
                            onComplete:(CMRequestComplete) requestComplete;


+(NSURLSessionDownloadTask *)downloadWithUrl:(NSString*)url
                                  onProgress:(CMProgressBlock)progressBlock
                                  onComplete:(CMDownloadCompleteBlock)completeBlock;

+(NSURLSessionDownloadTask *)downloadDiyResourceWithUrl:(NSString*)url
                                         targetFilePath:(NSURL *)filePath
                                             onProgress:(CMProgressBlock)progressBlock
                                             onComplete:(CMDownloadCompleteBlock)completeBlock;

+(NSURLSessionUploadTask *)uploadWithUrl:(NSString*)url
                                filePath:(NSString*)filePath
                              onProgress:(CMProgressBlock)progressBlock
                              onComplete:(CMUploadCompleteBlock)completeBlock;

+(NSURLSessionUploadTask *)uploadWithUrl:(NSString*)url
                                    data:(NSData*)data
                              onProgress:(CMProgressBlock)progressBlock
                              onComplete:(CMUploadCompleteBlock)completeBlock;


@end
