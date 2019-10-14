//
//  CMInfociMessage.m
//  iMessage
//
//  Created by yanzhao on 2017/10/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMInfociMessage.h"
#import "kinfoc_client.h"
#import "CMOReachability.h"

@implementation CMInfociMessage
+ (void) reportData:(NSDictionary*) dataDic toTable:(NSString*) tableName//上报
{
#ifdef DEBUG
    [[KInfocClient getInstance] forceReportData:dataDic toTable:tableName];
    return;
#else
    [[KInfocClient getInstance] reportData:dataDic toTable:tableName];
#endif
    
}
+ (void) forceReportData:(NSDictionary*) dataDic toTable:(NSString*) tableName//强制上报
{
    [[KInfocClient getInstance] forceReportData:dataDic toTable:tableName];
}

+ (void) activeReport{
    
    NSString * tableName = @"cheetahkeyboard_active";
    kNavNetWorkStatus  networkReachabilityStatus =[CMOReachability status];
    int network = 0;
    switch (networkReachabilityStatus) {
        case kNavNetWorkWIFI:
            network = 1;
            break;
        case kNavNetWorkWWAN:
            network = 2;
            break;
        case kNavNetWorkNotReachable:
            network = 3;
            break;
        default:
            network = 0;
            break;
    }
    //    NSDate * date = [NSDate date];
    //    time_t t = time(NULL);
    //    struct tm * time = localtime(&t);
    int clktime = (int)time(NULL);
    
    NSDictionary* dataDic3 = @{@"network":@(network),
                               @"clktime":@(clktime),
                               @"inputtype":@(100),
                               @"lang":@"0",
                               @"dictver":@"0",
                               @"theme":@"0"};
    [CMInfociMessage forceReportData:dataDic3 toTable:tableName];
    
}

+ (void)gifClickReport:(int)index link:(NSString*)link{
    NSString * path = [link stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"&"withString:@"%26"];
    int clktime = (int)time(NULL);
    NSString * tableName = @"cheetahkeyboard_ime_gif_send";
    NSDictionary* dataDic = @{@"value":@(index),
                               @"clktime":@(clktime),
                               @"link":path};
    [CMInfociMessage forceReportData:dataDic toTable:tableName];
    
}

@end
