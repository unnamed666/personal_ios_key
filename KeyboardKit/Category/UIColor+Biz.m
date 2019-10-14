//
//  UIColor+Biz.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIColor+Biz.h"
#import "NSString+Common.h"
//#import "SwiftTheme-Swift.h"

@implementation UIColor (Biz)

//+ (UIColor *)getProperColorWithThemeKeyPath:(NSString *)keyPath {
//    return [UIColor getProperColorWithThemeKeyPath:keyPath defaultColor:[UIColor clearColor]];
//}
//
//+ (UIColor *)getProperColorWithThemeKeyPath:(NSString *)keyPath defaultColor:(UIColor *)defColor {
//    if ([NSString stringIsEmpty:keyPath]) {
//        return defColor;
//    }
//    UIColor* color = [ThemeManager colorFor:keyPath];
//    return color ? color : defColor;
//}
- (CGColorSpaceModel) colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *) colorSpaceString
{
    switch ([self colorSpaceModel])
    {
        case kCGColorSpaceModelUnknown:
            return @"kCGColorSpaceModelUnknown";
        case kCGColorSpaceModelMonochrome:
            return @"kCGColorSpaceModelMonochrome";
        case kCGColorSpaceModelRGB:
            return @"kCGColorSpaceModelRGB";
        case kCGColorSpaceModelCMYK:
            return @"kCGColorSpaceModelCMYK";
        case kCGColorSpaceModelLab:
            return @"kCGColorSpaceModelLab";
        case kCGColorSpaceModelDeviceN:
            return @"kCGColorSpaceModelDeviceN";
        case kCGColorSpaceModelIndexed:
            return @"kCGColorSpaceModelIndexed";
        case kCGColorSpaceModelPattern:
            return @"kCGColorSpaceModelPattern";
        default:
            return @"Not a valid color space";
    }
}

- (CGFloat) red
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat) green
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat) blue
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (CGFloat) alpha
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}

- (UIColor *)reverseColor
{
    float r= 1 - [self red];
    float g= 1 - [self green];
    float b= 1 - [self blue];
    float alpha= [self alpha];
    UIColor *rcolor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return rcolor;
}
@end
