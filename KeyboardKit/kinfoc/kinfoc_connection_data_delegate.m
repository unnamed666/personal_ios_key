//
//  kinfoc_connection_data_delegate.m
//  KEWL
//
//  Created by Jin Ye on 4/23/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import "kinfoc_log.h"
#import "kinfoc_connection_data_delegate.h"
#import "NSString+Common.h"

@implementation KInfocConDataDelegate

- (id) initWithResultListener: (id<HttpPostResult>) resultListener
{
    if(self = [super init])
    {
        m_ResultListener = resultListener;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (nil == m_ResultListener)
    {
        return;
    }
    
    [m_ResultListener onFail];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    m_ReturnData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == data || nil == m_ReturnData)
    {
        return;
    }
    
    [m_ReturnData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (nil == m_ResultListener)
    {
        return;
    }

    NSString *responseString = [[NSString alloc] initWithData:m_ReturnData encoding:NSUTF8StringEncoding];
    KkLog(@"Response: %@", responseString);
    // 返回的串类似于这样三行：
    // [common]
    // result=1
    // time=1461572995
    // 其中result为1就表示成功，另一个time值不知道是干嘛用的，所以先不对外暴露。
    // 必须完全符合上述格式，下面的代码就是检查格式。
    
    NSArray* rstLineArray = [responseString componentsSeparatedByString:@"\n"];
    if (nil == rstLineArray)
    {
        [m_ResultListener onFail];
        return;
    }
    
    if ([rstLineArray count] < 3)
    {
        [m_ResultListener onFail];
        return;
    }
    
    NSString* line = [rstLineArray objectAtIndex:0];
    if (nil == line || NSOrderedSame != [[line stringByTrim] compare:@"[common]"])
    {
        [m_ResultListener onFail];
        return;
    }
    
    NSString* rstKey = @"result=";
    line = [rstLineArray objectAtIndex:1];
    if (nil == line || NO == [(line = [line stringByTrim]) hasPrefix:rstKey])
    {
        [m_ResultListener onFail];
        return;
    }
    
    if (NO == [@"1" isEqualToString:[[line substringFromIndex:rstKey.length] stringByTrim]])
    {
        [m_ResultListener onFail];
        return;
    }
    
    line = [rstLineArray objectAtIndex:2];
    if (nil == line || NO == [(line = [line stringByTrim]) hasPrefix:@"time="])
    {
        [m_ResultListener onFail];
        return;
    }
    
    [m_ResultListener onSuccess];
}

@end
