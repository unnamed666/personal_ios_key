//
//  UIImage+Util.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/9.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

/**
 *  通过UIColor构建UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  改变UIImage颜色生成新图片
 */
- (UIImage *)imageWithTintColor:(UIColor *)color;

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

+(UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;

+(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;//图片缩放

/// view 生成 image
+(UIImage *)convertViewToImage:(UIView *)view;


//图片旋转
+(UIImage *)rotationImage:(UIImage *)image rotation:(UIImageOrientation)orientation;


///改变图片模糊度 blur from 0 to 1
+(void)applyBlurCoreImage:(UIImage *)image blur:(CGFloat)blur completion:(void (^)(UIImage *image))completionBlock;

///改变图片透明度 alpha from 0 to 1
+(void)applyAlphaImage:(UIImage *)image alpha:(CGFloat)alpha completion:(void (^)(UIImage *image))completionBlock;

// 点九图改变图片透明度 alpha from 0 to 1
+ (void)applyAlphaNinePatchImage:(UIImage *)image alpha:(CGFloat)alpha completion:(void (^)(UIImage *))completionBlock;
+ (void)applyAlphaImage:(UIImage *)image isNinePatch:(BOOL)isNinePatch alpha:(CGFloat)alpha completion:(void (^)(UIImage *))completionBlock;

///同时改变图片的模糊度和透明度
+(void)applyBlurImage:(UIImage *)image blur:(CGFloat)blur alpha:(CGFloat)alpha completion:(void (^)(UIImage *image))completionBlock;

///同时修改图片的模糊度和亮度 light from -1 to 1,正常是0
+(void)applyBlurImage:(UIImage *)image blur:(CGFloat)blur light:(CGFloat)light completion:(void (^)(UIImage *image))completionBlock;

// 将两张图片拼接成一张图片
+(UIImage *)compoundImage:(UIImage *)image1 image:(UIImage *)image2;

// 将image1添加到image2上（image1的位置为x = 0，y = 0）
+(UIImage *)addImage:(UIImage *)image1 toImageTop:(UIImage *)image2;

// 将image1添加到image2上（image1.center = image2.center）
+(UIImage *)addImage:(UIImage *)image1 toImageCenter:(UIImage *)image2;

@end
