//
//  InfoCResultParse.h
//  InfoC
//
//  Created by wei_wei on 16/4/12.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kReportTimeKey          @"kReportTimeKey"
#define kReportKeyKey           @"kReportKeyKey"

@interface InfoCResultParse : NSObject

+ (NSDictionary*)parseResult:(NSString*)responseString;

@end
