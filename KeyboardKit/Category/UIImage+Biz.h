//
//  UIImage+Biz.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Biz)

+ (UIImage *)getProperImageNamed:(NSString *)name;

//+ (UIImage *)getProperImageWithThemeKeyPath:(NSString *)keyPath;

+ (BOOL)isNinePatchImageByName:(NSString *)name;

- (BOOL)isNinePatchImageByContent;

@end
