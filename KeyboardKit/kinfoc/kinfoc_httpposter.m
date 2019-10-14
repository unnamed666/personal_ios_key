//
//  kinfoc_httpposter.m
//  KEWL
//
//  Created by Jin Ye on 4/23/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import "kinfoc_httpposter.h"
#import "kinfoc_connection_data_delegate.h"
#import "NSString+Common.h"
#import "CMLogger.h"

@implementation KInfocHttpPoster

- (id) init
{
    if (self = [super init]) {
        m_OpQueueForPoster = [[NSOperationQueue alloc] init];
        [m_OpQueueForPoster setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

- (void) postData: (NSData*) pData
    toUrl: (NSString*) strUrl
    andResultCall:(id<HttpPostResult>) resultListener
{
    if (nil == pData || NO == [strUrl isNotBlank]) {
        return;
    }
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:strUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:pData];
//    NSURLConnection* connection =
//    [[NSURLConnection alloc] initWithRequest:request
//                                    delegate:[[KInfocConDataDelegate alloc]
//                                              initWithResultListener:resultListener]
//                            startImmediately:NO];
//    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (error || !data) {
                                          [resultListener onFail];
                                          return;
                                      }
                                      NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      kLogInfo(@"Response: %@", responseString);
                                      // 返回的串类似于这样三行：
                                      // [common]
                                      // result=1
                                      // time=1461572995
                                      // 其中result为1就表示成功，另一个time值不知道是干嘛用的，所以先不对外暴露。
                                      // 必须完全符合上述格式，下面的代码就是检查格式。
                                      
                                      NSArray* rstLineArray = [responseString componentsSeparatedByString:@"\n"];
                                      if (nil == rstLineArray)
                                      {
                                          [resultListener onFail];
                                          return;
                                      }
                                      
                                      if ([rstLineArray count] < 3)
                                      {
                                          [resultListener onFail];
                                          return;
                                      }
                                      
                                      NSString* line = [rstLineArray objectAtIndex:0];
                                      if (nil == line || NSOrderedSame != [[line stringByTrim] compare:@"[common]"])
                                      {
                                          [resultListener onFail];
                                          return;
                                      }
                                      
                                      NSString* rstKey = @"result=";
                                      line = [rstLineArray objectAtIndex:1];
                                      if (nil == line || NO == [(line = [line stringByTrim]) hasPrefix:rstKey])
                                      {
                                          [resultListener onFail];
                                          return;
                                      }
                                      
                                      if (NO == [@"1" isEqualToString:[[line substringFromIndex:rstKey.length] stringByTrim]])
                                      {
                                          [resultListener onFail];
                                          return;
                                      }
                                      
                                      line = [rstLineArray objectAtIndex:2];
                                      if (nil == line || NO == [(line = [line stringByTrim]) hasPrefix:@"time="])
                                      {
                                          [resultListener onFail];
                                          return;
                                      }
                                      
                                      [resultListener onSuccess];
                                  }];
    
    if (nil != m_OpQueueForPoster) {
        [m_OpQueueForPoster addOperationWithBlock:^{
//            [connection start];
            [task resume];
        }];
    } else {
//        [connection start];
        [task resume];
    }
}

@end
