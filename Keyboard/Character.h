//
//  Character.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/18.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

extern Byte const OTHER_SYMBOL;
extern Byte const COMBINING_SPACING_MARK;
@interface Character : NSObject
+ (BOOL) isUpperCase:(int) codePoint;
+ (BOOL) isDigit:(int) codePoint;
+ (int) getType:(int) codePoint;
+ (int) isLetterOrDigit:(int)codePoint;
+ (BOOL)isSurrogatePair:(unichar) high low:(unichar)low;
+ (BOOL)isHighSurrogate:(unichar)ch;
+ (BOOL)isLowSurrogate:(unichar)ch;
+ (int)codePointAt:(NSString*)seq index:(int)index;
+ (int) isLetter:(int)codePoint;
+ (int)toLowerCase:(int)ch;
+ (BOOL)stringContainsEmoji:(NSString *)string;
@end
