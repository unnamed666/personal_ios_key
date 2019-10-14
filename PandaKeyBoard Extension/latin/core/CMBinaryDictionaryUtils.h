//
//  CMBinaryDictionaryUtils.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/16.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMBinaryDictionaryUtils : NSObject
+ (float)calcNormalizedScore:(NSString*)before after:(NSString*)after score:(int)score;
@end
