//
//  InfoCReportRequest.m
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/5.
//  Copyright © 2016年 cm. All rights reserved.
//

#import "InfoCReportRequest.h"
#import "InfoCReportManager.h"

@interface InfoCReportRequest() {
    NSString *_requestMethod;
    NSDictionary *requestParameters;
    NSString     *host;
}

@end

@implementation InfoCReportRequest
@synthesize requestMethod = _requestMethod;

- (void)setRequestHost:(NSString *)hostURLString {
    host = [hostURLString copy];
}

- (void)setRequestParameters:(NSDictionary *)parameters {
    requestParameters = parameters;
}

- (void)startGetReuqest {
    _requestMethod = @"GET";
    
    if (!host) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFailed:andErrorDescription:)]) {
            [self.delegate reportRequestDidFailed:self andErrorDescription:@"host 为空"];
        }
        
        return;
    }
    
    if (!requestParameters) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFailed:andErrorDescription:)]) {
            [self.delegate reportRequestDidFailed:self andErrorDescription:@"Parameters 为空"];
        }
        
        return;
    }
    
    NSMutableString *requestURLString = [NSMutableString stringWithString:host];
    
    if (requestParameters.allKeys.count > 0) {
        [requestURLString appendString:@"?"];
        NSArray *parametersKey = [requestParameters allKeys];
        
        for (int i = 0; i < parametersKey.count ; i++) {
            NSString *key = [parametersKey objectAtIndex:i];
            NSString *value = [requestParameters objectForKey:key];
            if (i == parametersKey.count - 1) {
                [requestURLString appendFormat:@"%@=%@",key,value];
            }else {
                [requestURLString appendFormat:@"%@=%@&",key,value];
            }
        }
    }
    
    NSString *encodeRequestURLString = [requestURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //1.确定请求路径
    NSURL *url = [NSURL URLWithString:encodeRequestURLString];

    //2.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];

    //3.根据会话对象创建一个Task(发送请求）
    /*
        第一个参数：请求路径
        第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
        data：响应体信息（期望的数据）
        response：响应头信息，主要是对服务器端的描述
        error：错误信息，如果请求失败，则error有值
        注意：
        1）该方法内部会自动将请求路径包装成一个请求对象，该请求对象默认包含了请求头信息和请求方法（GET）
        2）如果要发送的是POST请求，则不能使用该方法
    */
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFailed:andErrorDescription:)]) {
                [self.delegate reportRequestDidFailed:self andErrorDescription:error.description];
            }
            
            return;
        }
        
        if (data) {
            //5.解析数据
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"%@",data);
            if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFinished:)]) {
                if (![NSThread isMainThread]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate reportRequestDidFinished:self];
                    });
                }else {
                    [self.delegate reportRequestDidFinished:self];
                }
            }
            
            return;
        }
    }];

    //4.执行任务
    [dataTask resume];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidStarted:)]) {
        [self.delegate reportRequestDidStarted:self];
    }
}

- (void)startPostReuqest {
    _requestMethod = @"POST";
    
    if (!host) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFailed:andErrorDescription:)]) {
            [self.delegate reportRequestDidFailed:self andErrorDescription:@"host 为空"];
        }
        
        return;
    }
    
    if (!requestParameters) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFailed:andErrorDescription:)]) {
            [self.delegate reportRequestDidFailed:self andErrorDescription:@"Parameters 为空"];
        }
        
        return;
    }
    
    NSMutableString *requestURLString = [NSMutableString stringWithString:host];
    NSMutableString *requestBody      = [[NSMutableString alloc] init];
    if (requestParameters.allKeys.count > 0) {
        NSArray *parametersKey = [requestParameters allKeys];
        for (int i = 0; parametersKey.count > 0 ; i++) {
            NSString *key = [parametersKey objectAtIndex:0];
            NSString *value = [requestParameters objectForKey:key];
            if (i == parametersKey.count - 1) {
                [requestBody appendFormat:@"%@=%@",key,value];
            }else {
                [requestBody appendFormat:@"%@=%@&",key,value];
            }
        }
    }
    
    NSString *encodeRequestURLString = [requestURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //对请求路径的说明
    //POST请求需要修改请求方法为POST，并把参数转换为二进制数据设置为请求体

    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];

    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:encodeRequestURLString];

    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";

    //5.设置请求体
    request.HTTPBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];

    //6.根据会话对象创建一个Task(发送请求）
    /*
      第一个参数：请求对象
      第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
                 data：响应体信息（期望的数据）
                 response：响应头信息，主要是对服务器端的描述
                 error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFailed:andErrorDescription:)]) {
                [self.delegate reportRequestDidFailed:self andErrorDescription:error.description];
            }
            
            return;
        }
        
        if (data) {
            //8.解析数据
            //            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSLog(@"%@",data);
            if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidFinished:)]) {
                if (![NSThread isMainThread]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate reportRequestDidFinished:self];
                    });
                }else {
                    [self.delegate reportRequestDidFinished:self];
                }
            }
            
            return;
        }

     }];

    //7.执行任务
    [dataTask resume];
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportRequestDidStarted:)]) {
        [self.delegate reportRequestDidStarted:self];
    }
}
@end
