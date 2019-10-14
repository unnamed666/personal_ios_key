//
//  CMOReachability.h
//  osvideo
//
//  Created by wolf on 16/7/7.
//  Copyright © 2016年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __kNavNetWorkStatus
typedef enum
{
    kNavNetWorkUnknow,
    kNavNetWorkNotReachable,
    kNavNetWorkWWAN,
//    kNavNetWork2G,
//    kNavNetWork3G,
//    kNavNetWork4G,
    kNavNetWorkWIFI
}kNavNetWorkStatus;
#define __kNavNetWorkStatus
#endif

@interface CMOReachability : NSObject
+(void)start;
+(void)stop;
+(kNavNetWorkStatus)status;
@end
