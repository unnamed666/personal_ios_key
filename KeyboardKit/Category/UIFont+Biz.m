//
//  UIFont+Biz.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIFont+Biz.h"
#import "NSString+Common.h"
#import "NSDictionary+Common.h"
//#import "SwiftTheme-Swift.h"
#import "CMBizHelper.h"

@implementation UIFont (Biz)

//+ (UIFont *)getProperFontWithThemeKeyPath:(NSString *)keyPath {
//    return [UIFont getProperFontWithThemeKeyPath:keyPath defaultFontSize:16.0 bold:NO];
//}
//
//+ (UIFont *)getProperFontWithThemeKeyPath:(NSString *)keyPath defaultFontSize:(CGFloat)defFontSize bold:(BOOL)needBold {
//    if ([NSString stringIsEmpty:keyPath]) {
//        return needBold ? [UIFont boldSystemFontOfSize:defFontSize] : [UIFont systemFontOfSize:defFontSize];
//    }
//    NSDictionary* hintFontDic = [ThemeManager dictionaryFor:keyPath];
//    NSString* fontNameHint;
//    CGFloat fontSizeHint = defFontSize;
//    if (hintFontDic) {
//        fontNameHint = [hintFontDic stringValueForKey:@"fontName"];
//        fontSizeHint = [hintFontDic floatValueForKey:@"fontSize" defaultValue:defFontSize];
//    }
//    UIFont* font;
//    if (![NSString stringIsEmpty:fontNameHint]) {
//        if (![CMBizHelper isFontRegistered:fontNameHint]) {
//            [CMBizHelper registerFont:fontNameHint];
//            if ([CMBizHelper isFontRegistered:fontNameHint]) {
//                font = [UIFont fontWithName:fontNameHint size:fontSizeHint];
//            }
//            else {
//                font = needBold ? [UIFont boldSystemFontOfSize:fontSizeHint] : [UIFont systemFontOfSize:fontSizeHint];
//            }
//        }
//        else {
//            font = [UIFont fontWithName:fontNameHint size:fontSizeHint];
//        }
//    }
//
//    return font ? font : (needBold ? [UIFont boldSystemFontOfSize:fontSizeHint] : [UIFont systemFontOfSize:fontSizeHint]);
//}

@end
