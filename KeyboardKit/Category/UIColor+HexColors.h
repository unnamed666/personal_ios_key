//
//  UIColor+HexColors.h
//  KiwiHarness
//
//  Created by Tim Duckett on 07/09/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//RGB颜色获取
#define COLOR_WITH_RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface UIColor (HexColors)

+(UIColor *)colorWithHexString:(NSString *)hexString;

+(UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+(NSString *)hexValuesFromUIColor:(UIColor *)color;

/**
 * Return a random color
 */
+ (UIColor *)randomColor;

@end
