//
//  CMCommUtil.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/13.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMBizHelper.h"

@interface CMCommUtil : NSObject

+ (UIImage *) makeNinePatchImage:(UIImage *)image;


+ (NSMutableArray *)tokenizationStringByNSString:(NSString*)str options:(NSStringEnumerationOptions)opts;
+ (NSMutableSet *)tokenizationSetByNSString:(NSString*)str options:(NSStringEnumerationOptions)opts;

+ (NSString*)keyboardLanguageTypeToLang:(int)languageType;
//+ (NSString*)keyboardLanguageTypeToCountry:(int)languageType;
+ (NSString*)keyboardLanguageTypeToLocaleString:(int)languageType;
+ (NSString *)keyboardLanguageTypeToLanguageString:(int)languageType;
+ (NSString*)keyboardLanguageTypeToLocaleLanguageStr:(int)languageType;

+ (BOOL)isLetterPartOfScriptWithcodePoint:(int)codePoint languageType:(int)languageType;

//
+ (long)evaluate:(float)fraction startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor;

@end
