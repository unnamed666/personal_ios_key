//
//  Character.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/18.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "Character.h"
#import <unicode/uchar.h>

Byte const COMBINING_SPACING_MARK = 8;
Byte const FORMAT = 16;

Byte const OTHER_SYMBOL = U_OTHER_SYMBOL +1;

unichar const MIN_HIGH_SURROGATE =0xD800;
//int MIN_HIGH_SURROGATE = '\uD800';
unichar const MAX_HIGH_SURROGATE = 0xDBFF;
unichar const MIN_LOW_SURROGATE  = 0xDC00;
unichar const MAX_LOW_SURROGATE  = 0xDFFF;

int const MIN_SUPPLEMENTARY_CODE_POINT = 0x010000;

@implementation Character

+ (BOOL) isUpperCase:(int) codePoint{
    return    u_isupper(codePoint);
}


+ (BOOL) isDigit:(int) codePoint{
    return u_isdigit(codePoint);
}

+ (int) getType:(int) codePoint{
    int type = u_charType(codePoint);
    if(type <= FORMAT){
        return type;
        ;
    }
    return type+1;
}
+ (int) isLetterOrDigit:(int)codePoint{
    return u_isalnum(codePoint);
}

+ (int) isLetter:(int)codePoint{
    return u_isalpha(codePoint);
}

bool isHighSurrogate(unichar ch) {
    // Help VM constant-fold; MAX_HIGH_SURROGATE + 1 == MIN_LOW_SURROGATE
    return ch >= MIN_HIGH_SURROGATE && ch < (MAX_HIGH_SURROGATE + 1);
}
bool isLowSurrogate(unichar ch) {
    return ch >= MIN_LOW_SURROGATE && ch < (MAX_LOW_SURROGATE + 1);
}
+ (BOOL)isHighSurrogate:(unichar)ch{
    return isHighSurrogate(ch);
}
+ (BOOL)isLowSurrogate:(unichar)ch{
    return isLowSurrogate(ch);
}

+ (BOOL)isSurrogatePair:(unichar) high low:(unichar)low{
    return isHighSurrogate(high) && isLowSurrogate(low);
}

int toCodePoint(unichar high, unichar low) {
    // Optimized form of:
    // return ((high - MIN_HIGH_SURROGATE) << 10)
    //         + (low - MIN_LOW_SURROGATE)
    //         + MIN_SUPPLEMENTARY_CODE_POINT;
    return ((high << 10) + low) + (MIN_SUPPLEMENTARY_CODE_POINT
                                   - (MIN_HIGH_SURROGATE << 10)
                                   - MIN_LOW_SURROGATE);
}


+ (int)codePointAt:(NSString*)seq index:(int)index
{
    unichar c1 = [seq characterAtIndex:index];
    if(isHighSurrogate(c1)){
        index++;
        if(index < seq.length){
            unichar c2 = [seq characterAtIndex:index];
            if(isLowSurrogate(c2)){
                return toCodePoint(c1,c2);
            }
        }
    }
    
    return c1;
}

+ (int)toLowerCase:(int)ch{
    return u_tolower(ch);
}

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff)
        {
            if (substring.length > 1)
            {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f)
                {
                    returnValue = YES;
                }
            }
        }
        else if (substring.length > 1)
        {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3)
            {
                returnValue = YES;
            }
        }
        else
        {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff)
            {
                returnValue = YES;
            }
            else if (0x2B05 <= hs && hs <= 0x2b07)
            {
                returnValue = YES;
            }
            else if (0x2934 <= hs && hs <= 0x2935)
            {
                returnValue = YES;
            }
            else if (0x3297 <= hs && hs <= 0x3299)
            {
                returnValue = YES;
            }
            else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
            {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}

@end
