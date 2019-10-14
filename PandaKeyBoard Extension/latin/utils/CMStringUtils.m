//
//  CMStringUtils.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/13.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMStringUtils.h"
#import "Constants.h"
#import "Character.h"
@implementation CMStringUtils

+ (int)getCodePointArray:(int*)aray world:(NSString*)world{
    __block int len =0;
    [world enumerateSubstringsInRange:NSMakeRange(0, world.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if(aray!=NULL){
            *(aray+len) = [Character codePointAt:substring index:0];
        }
        len++;
    }];
    return len;
}


//判断是否有emoji
+(BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar high = [substring characterAtIndex: 0];
                                
                                // Surrogate pair (U+1D000-1F9FF)
                                if (0xD800 <= high && high <= 0xDBFF) {
                                    const unichar low = [substring characterAtIndex: 1];
                                    const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
                                    
                                    if (0x1D000 <= codepoint && codepoint <= 0x1F9FF){
                                        returnValue = YES;
                                    }
                                    
                                    // Not surrogate pair (U+2100-27BF)
                                } else {
                                    if (0x2100 <= high && high <= 0x27BF){
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}


+ (BOOL)lastPartLooksLikeURL:(NSString*)text{
    
    int i = (int)text.length;
    if (0 == i) {
        return false;
    }
    int wCount = 0;
    int slashCount = 0;
    BOOL hasSlash = NO;
    BOOL hasPeriod = NO;
    unichar codePoint = 0;
    while (i>0) {
        [text getCharacters:&codePoint range:NSMakeRange(i-1, 1)];
        if (codePoint < CODE_PERIOD || codePoint > 'z') {
            // Handwavy heuristic to see if that's a URL character. Anything between period
            // and z. This includes all lower- and upper-case ascii letters, period,
            // underscore, arrobase, question mark, equal sign. It excludes spaces, exclamation
            // marks, double quotes...
            // Anything that's not a URL-like character causes us to break from here and
            // evaluate normally.
            break;
        }
        if (CODE_PERIOD == codePoint) {
            hasPeriod = YES;
        }
        if (CODE_SLASH == codePoint) {
            hasSlash = YES;
            if (2 == ++slashCount) {
                return YES;
            }
        } else {
            slashCount = 0;
        }
        if ('w' == codePoint) {
            ++wCount;
        } else {
            wCount = 0;
        }
        i--;
    }
    
    if (wCount >= 3 && hasPeriod) {
        return YES;
    }
    // If it starts with a slash, and the code point before is whitespace, it looks like an URL.
    if (1 == slashCount && (0 == i || [[NSString stringWithCharacters:&codePoint length:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 )) {
        return YES;
    }
    // If it has both a period and a slash, it looks like an URL.
    if (hasPeriod && hasSlash) {
        return YES;
    }
    // Otherwise, it doesn't look like an URL.
    return NO;
}

//+ (int)getCharacters:(NSString*)c{
//    unichar uchar;
//    [c getCharacters:&uchar];
//    return uchar;
//}

+ (int)getTrailingSingleQuotesCount:(NSString*)str{
    int lastIndex = (int)str.length-1;
    int i = lastIndex;
    unichar codePoint;
    while (i>=0 ) {
         [str getCharacters:&codePoint range:NSMakeRange(i, 1)];
        if(codePoint == CODE_SINGLE_QUOTE){
            --i;
        }else{
            break;
        }
    }
    return lastIndex-i;
}

+ (int)getlastWordLen:(NSString*)word{
    __block int len =1;
    [word enumerateSubstringsInRange:NSMakeRange(0, word.length) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        len = (int)substringRange.length;
        *stop = YES;
    }];
    return len;
}

@end
