//
//  InfoCReportRequestManager.h
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/6.
//  Copyright © 2016年 cm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoCReportRequestManager : NSObject

+ (InfoCReportRequestManager *)sharedManager;

- (void)addReportInfoToManager:(NSDictionary *)reportInfo;

@end
