//
//  UIImage+Biz.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIImage+Biz.h"
#import "NSString+Common.h"
#import "SWNinePatchImageFactory.h"
//#import "SwiftTheme-Swift.h"

@implementation UIImage (Biz)

+ (UIImage *)getProperImageNamed:(NSString *)name {
    if ([NSString stringIsEmpty:name]) {
        return nil;
    }
    if (![UIImage isNinePatchImageByName:name]) {
        return [UIImage imageNamed:name];
    }
    NSString* imageName = name;
    if ([name hasSuffix:@".png"]) {
        NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
        imageName = [name substringToIndex:NSMaxRange(range)-1];
    }

    return [SWNinePatchImageFactory createResizableNinePatchImageNamed:imageName];
}
//
//+ (UIImage *)getProperImageWithThemeKeyPath:(NSString *)keyPath {
//    if ([NSString stringIsEmpty:keyPath]) {
//        return nil;
//    }
//    NSString* imageName = [ThemeManager stringFor:keyPath];
//    if (![UIImage isNinePatchImageByName:imageName]) {
//        return [ThemeManager imageFor:keyPath];
//    }
//    UIImage* image = [ThemeManager imageFor:keyPath];
//    if (image) {
//        return [SWNinePatchImageFactory createResizableNinePatchImage:image];
//    }
//    
//    return nil;
//}

+ (BOOL)isNinePatchImageByName:(NSString *)name {
    if ([NSString stringIsEmpty:name]) {
        return NO;
    }
    if ([name hasSuffix:@".9.png"] || [name hasSuffix:@".9"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isNinePatchImageByContent {    
    return [SWNinePatchImageFactory isNinePatchImageByContent:self];
}

@end
