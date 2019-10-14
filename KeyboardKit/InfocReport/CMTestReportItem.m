//
//  CMTestReportItem.m
//  KeyboardKit
//
//  Created by zhoujing on 2017/11/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTestReportItem.h"

@implementation CMTestReportItem
-(NSDictionary *)params {
    //cheetahkeyboard_ar_done:150 videtime:short anim:short
    return @{@"videtime" : @(300),@"anim" : @(3)
             };
}
- (NSInteger)eventID {
    return 150;
}
@end
