//
//  InfoCResultParse.m
//  InfoC
//
//  Created by wei_wei on 16/4/12.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "InfoCResultParse.h"
#import "CommonKit.h"
@implementation InfoCResultParse

+ (NSDictionary *)parseResult:(NSString *)responseString
{
    if (!responseString) {
        return nil;
    }
    
    if ([responseString hasSuffix:@"\0"]) {
        responseString = [responseString substringToIndex:responseString.length -1];
    }
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSArray* lines = [responseString componentsSeparatedByString:@"\r\n"];
    for (NSString* line in lines) {
        if ([line hasPrefix:@"result="]) {
            int value = [[line substringFromIndex:7] intValue];
            if (value != 1) {
                ERROR(@"InfoC report failed");
                return nil;
            }
        } else if ([line hasPrefix:@"key="]) {
            dictionary[kReportKeyKey] = [line substringFromIndex:4];
        } else if ([line hasPrefix:@"time="]) {
            dictionary[kReportTimeKey] = [line substringFromIndex:5];
        }
    }
    
//    ERROR(@"InfoC report result:%@",dictionary);
    
    return dictionary;
}

@end
