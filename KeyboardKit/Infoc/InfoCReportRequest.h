//
//  InfoCReportRequest.h
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/5.
//  Copyright © 2016年 cm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InfoCReportRequestDelegate;

@interface InfoCReportRequest : NSObject

@property (nonatomic,weak) id<InfoCReportRequestDelegate> delegate;
@property (nonatomic,copy) NSString *requestIdentifer;
@property (nonatomic,readonly) NSString *requestMethod;

- (void)setRequestHost:(NSString *)hostURLString;
- (void)setRequestParameters:(NSDictionary *)parameters;
- (void)startGetReuqest;
- (void)startPostReuqest;

@end

@protocol InfoCReportRequestDelegate <NSObject>
@optional
- (void)reportRequestDidStarted:(InfoCReportRequest *)reportRequest;
@optional
- (void)reportRequestDidFinished:(InfoCReportRequest *)reportRequest;
@optional
- (void)reportRequestDidFailed:(InfoCReportRequest *)reportRequest andErrorDescription:(NSString *)errorDescription;
@end
