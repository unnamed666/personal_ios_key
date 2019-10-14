//
//  UIColor+HexColors.m
//  KiwiHarness
//
//  Created by Tim on 07/09/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "UIColor+HexColors.h"

@implementation UIColor (HexColors)

//0XRGBA or 0XRGB or #RGBA or #RGB
+(UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // 判断前缀并剪切掉
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    
    if([cString length] == 6){
        return [UIColor colorWithHexString:cString alpha:1.0f];
    }
    if([cString length] == 8){
        NSRange range;
        range.location =6;
        range.length = 2;
        NSString *aString = [cString substringWithRange:range];
        
        unsigned int a;
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        return [UIColor colorWithHexString:cString alpha:((float) a / 255.0f)];
    }
    
    return [UIColor clearColor];
}

+(UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    //    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    //    // String should be 6 or 8 characters
    //    if ([cString length] < 6) {
    //        return [UIColor clearColor];
    //    }
    //
    //    // 判断前缀并剪切掉
    //    if ([cString hasPrefix:@"0X"])
    //        cString = [cString substringFromIndex:2];
    //    if ([cString hasPrefix:@"#"])
    //        cString = [cString substringFromIndex:1];
    //    if ([cString length] != 6)
    //        return [UIColor clearColor];
    
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //R、G、B
    NSString *rString = [hexString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [hexString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [hexString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

+(NSString *)hexValuesFromUIColor:(UIColor *)color {
    
    if (!color) {
        return nil;
    }
    
    if (color == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"ffffff";
    }
 
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSString *returnString = [NSString stringWithFormat:@"%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255)];

    return returnString;
}

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random() % 256) / 255.f
                           green:(arc4random() % 256) / 255.f
                            blue:(arc4random() % 256) / 255.f
                           alpha:1.f];
}

@end
