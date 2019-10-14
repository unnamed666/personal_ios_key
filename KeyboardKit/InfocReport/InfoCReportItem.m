//
//  InfoCReportItem.m
//  PhotoGrid
//
//  Created by deafbreeds on 2016/10/18.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "InfoCReportItem.h"
#import "InfoCManager.h"

@implementation InfoCReportItem

-(NSInteger)eventID
{
    return 0;
}

-(NSDictionary *)params
{
    return nil;
}

-(void)reportWithForce:(BOOL)_forceReport
{
    [[InfoCManager shareManager] event:self.eventID params:self.params];
    if(_forceReport)
    {
        [[InfoCManager shareManager] forceReport];
    }
}

@end
