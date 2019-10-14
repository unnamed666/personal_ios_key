//
//  CMRequestFactory.h
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/10/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMHttpRequest.h"

@interface CMRequestFactory : NSObject

+ (NSURLSessionDataTask *)cloudVersionRequestWithProductName:(NSString *)productName completeBlock:(CMRequestComplete)requestComplete;

+ (NSURLSessionDataTask *)cloudMessageRequestWithLanguage:(NSString *)language channelId:(NSString *)channelId pkg:(NSString *)pkg completeBlock:(CMRequestComplete)requestComplete;

+ (NSURLSessionDataTask *)cloudPredictionConfigRequestWithLanguage:(NSString*)language completeBlock:(CMRequestComplete)requestComplete;

+ (NSURLSessionDownloadTask *)downloadRequestWithURL:(NSString *)url
                                       progressBlock:(CMProgressBlock)progressBlock
                                       completeBlock:(CMDownloadCompleteBlock)completeBlock;

+ (NSURLSessionDownloadTask *)downloadRequestWithUrl:(NSString *)url
                                        themeVersion:(NSString *)version
                                       progressBlock:(CMProgressBlock)progressBlock
                                       completeBlock:(CMDownloadCompleteBlock)completeBlock;

+ (NSURLSessionDownloadTask *)downloadDiyResourceRequestWithURL:(NSString *)url
                                                 targetFilePath:(NSURL *)filePath
                                                  progressBlock:(CMProgressBlock)progressBlock
                                                  completeBlock:(CMDownloadCompleteBlock)completeBlock;

+ (NSURLSessionDataTask*) fetchGifTags:(CMRequestComplete) completeBlock;
+ (NSURLSessionDataTask*) giphyTrendingRequestWithLimit:(NSUInteger) limit offset:(NSUInteger) offset lang:(NSString*)lang completion:(CMRequestComplete) completeBlock;
+ (NSURLSessionDataTask*) giphySearchTagWithQ:(NSString*)q Limit:(NSUInteger) limit offset:(NSUInteger) offset  lang:(NSString*)lang completion:(CMRequestComplete) completeBlock;

@end
