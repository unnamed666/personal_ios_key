//
//  CMHostRequestFactory.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMDiySourceViewModel.h"

@interface CMHostRequestFactory : NSObject

+ (NSURLSessionDataTask *)feedbackRequestWithContact:(NSString *)contact
                                             content:(NSString *)content
                                          imageArray:(NSArray<UIImage*>*)imageArray
                                       completeBlock:(CMRequestComplete)requestComplete;

+ (NSURLSessionDataTask *)fetchThemeListWithPageNum:(NSUInteger)pageNum
                                           hasCount:(NSUInteger)hasCount
                                        lastModelId:(NSString *)lastModelId
                                             offset:(NSUInteger)offset
                                         fetchCount:(NSUInteger)count
                                      completeBlock:(CMRequestComplete)completeBlock;

+ (NSURLSessionDataTask *)fetchDiySourceWithType:(CMDiySourceType)sourceType offset:(NSUInteger)offset fetchCount:(NSUInteger)count completeBlock:(CMRequestComplete)completeBlock;


//+ (NSURLSessionDataTask *)cloudVersionRequestWithProductName:(NSString *)productName completeBlock:(CMRequestComplete)requestComplete;
//
//+ (NSURLSessionDataTask *)cloudMessageRequestWithLanguage:(NSString *)language channelId:(NSString *)channelId pkg:(NSString *)pkg completeBlock:(CMRequestComplete)requestComplete;

@end
