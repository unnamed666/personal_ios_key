//
//  CMAutoCorrectionUtils.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/16.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SuggestedWordInfo;
@interface CMAutoCorrectionUtils : NSObject

+(BOOL)suggestionExceedsThreshold:(SuggestedWordInfo*)suggestion consideredWord:(NSString*)consideredWord threshold:(float)threshold;
@end
