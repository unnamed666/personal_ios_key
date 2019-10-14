//
//  CMInfociMessage.h
//  iMessage
//
//  Created by yanzhao on 2017/10/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMInfociMessage : NSObject
+ (void) activeReport;
+ (void)gifClickReport:(int)index link:(NSString*)link;
@end
