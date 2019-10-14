//
//  CMStringUtils.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/13.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMStringUtils : NSObject

+ (BOOL)lastPartLooksLikeURL:(NSString*)text;

//+ (int)getCharacters:(NSString*)c;

+ (int)getTrailingSingleQuotesCount:(NSString*)str;

+ (int)getlastWordLen:(NSString*)word;

+ (int)getCodePointArray:(int*)aray world:(NSString*)world;

+(BOOL)stringContainsEmoji:(NSString *)string;

@end
