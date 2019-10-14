//
//  UIImage+Util.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/9.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIImage+Util.h"
#import <Accelerate/Accelerate.h>
#import "CMLogger.h"
#import "CMCommUtil.h"

@implementation UIImage (Util)

/**
 *  通过UIColor构建UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithTintColor:(UIColor *)color {
    UIImage *newImage = [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(self.size, NO, newImage.scale);
    [color set];
    [newImage drawInRect:CGRectMake(0, 0, self.size.width, newImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

+(UIImage *)convertViewToImage:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,[UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
                                
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
    return scaledImage;
 }

+(UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        kLogInfo(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        kLogInfo(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}



+(UIImage *)rotationImage:(UIImage *)image rotation:(UIImageOrientation)orientation {
    
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
}


#pragma mark - 图片模糊、透明度处理


+(void)applyBlurCoreImage:(UIImage *)image blur:(CGFloat)blur completion:(void (^)(UIImage *image))completionBlock{
    if (!image) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    if (blur < 0) {
        blur = 0.0;
    }else if (blur > 1){
        blur = 1.0;
    }

    UIImage *finalImage = [self applyBlurImage:image blur:blur];
    if (completionBlock) {
        completionBlock(finalImage);
    }
}

+(void)applyAlphaImage:(UIImage *)image alpha:(CGFloat)alpha completion:(void (^)(UIImage *image))completionBlock{
    
    if (!image) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    if (alpha < 0) {
        alpha = 0.0;
    }else if (alpha > 1){
        alpha = 1.0;
    }
    UIImage *newImage = [self applyAlphaImage:image alpha:alpha];
    if (completionBlock) {
        completionBlock(newImage);
    }
}

+ (void)applyAlphaNinePatchImage:(UIImage *)image alpha:(CGFloat)alpha completion:(void (^)(UIImage *))completionBlock
{
    if (!image) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    if (alpha < 0) {
        alpha = 0.0;
    }else if (alpha > 1){
        alpha = 1.0;
    }
    
    UIImage *newImage = [self applyAlphaNinePatchImage:image alpha:alpha];
    if (completionBlock) {
            completionBlock(newImage);
    }
}

+ (void)applyAlphaImage:(UIImage *)image isNinePatch:(BOOL)isNinePatch alpha:(CGFloat)alpha completion:(void (^)(UIImage *))completionBlock
{
    if (isNinePatch) {
        [self applyAlphaNinePatchImage:image alpha:alpha completion:completionBlock];
    }else{
        [self applyAlphaImage:image alpha:alpha completion:completionBlock];
    }
}

+(void)applyBlurImage:(UIImage *)image blur:(CGFloat)blur alpha:(CGFloat)alpha
           completion:(void (^)(UIImage *image))completionBlock{
    if (!image) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    if (alpha < 0) {
        alpha = 0.0;
    }else if (alpha > 1){
        alpha = 1.0;
    }
    
    if (blur < 0) {
        blur = 0.0;
    }else if (blur > 1){
        blur = 1.0;
    }
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    //毛玻璃滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                        
                                  keysAndValues:kCIInputImageKey, inputImage,
                        
                        @"inputRadius", @(blur * 100), nil]; //范围 0 - 100
    //透明滤镜
    CGFloat rgba[4] = {0.0, 0.0, 0.0, alpha};
    CIFilter *alphaFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [alphaFilter setDefaults];
    [alphaFilter setValue:filter.outputImage forKey:kCIInputImageKey];
    [alphaFilter setValue:[CIVector vectorWithValues:rgba count:4] forKey:@"inputAVector"];
    
    CIImage *outputImage = alphaFilter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    if (completionBlock) {
        completionBlock(finalImage);
    }
}

+(void)applyBlurImage:(UIImage *)image blur:(CGFloat)blur light:(CGFloat)light completion:(void (^)(UIImage *image))completionBlock{
    if (!image) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    if (blur < 0.0f || blur > 1.0f) {
        blur =  blur < 0.0f ? 0.0f : 1.0f;
    }
    
    if (light < -1.0f || light > 1.0f) {
        light = light > 1.0f ? 1.0f : -1.0f;
    }
    
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    //毛玻璃滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                        
                                  keysAndValues:kCIInputImageKey, inputImage,
                        
                        @"inputRadius", @(blur * 100), nil]; //范围 0 - 100
    //亮度滤镜
    CIFilter *lightFilter = [CIFilter filterWithName:@"CIColorControls"];
    [lightFilter setValue:filter.outputImage forKey:kCIInputImageKey];
    [lightFilter setValue:@(light) forKey:@"inputBrightness"];
    
    CIImage *outputImage = lightFilter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    if (completionBlock) {
        completionBlock(finalImage);
    }
}

+(UIImage *)applyBlurImage:(UIImage *)image blur:(CGFloat)blur{
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                        
                                  keysAndValues:kCIInputImageKey, inputImage,
                        
                        @"inputRadius", @(blur * 100), nil]; //范围 0 - 100
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return finalImage;
}

+(UIImage *)applyAlphaImage:(UIImage *)image alpha:(CGFloat)alpha{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage;
}

+(UIImage *)applyAlphaNinePatchImage:(UIImage *)image alpha:(CGFloat)alpha{
    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage); // 图片宽度
    size_t height = CGImageGetHeight(cgImage); // 图片高度
    unsigned char *data = (unsigned char *)calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
    size_t bitsPerComponent = 8; // r g b a 每个component bits数目
    size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB(); // 创建rgb颜色空间
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    
    for (size_t i = 1; i < height - 1; i++)
    {
        for (size_t j = 1; j < width - 1; j++)
        {
            size_t pixelIndex = i * width * 4 + j * 4;
            unsigned char currentAlpha = data[pixelIndex + 3];
            
            // 修改透明度
            unsigned char alphaChar = (unsigned char)((NSInteger)(alpha * (NSInteger)currentAlpha));
            data[pixelIndex + 3] = (unsigned char)alphaChar;
        }
    }
    
    cgImage = CGBitmapContextCreateImage(context);
    free(data);
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(cgImage);
    return newImage;
}

+ (UIImage *)compoundImage:(UIImage *)image1 image:(UIImage *)image2
{
    UIGraphicsBeginImageContext(CGSizeMake(MAX(image1.size.width, image2.size.width), image1.size.height + image2.size.height));
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, image1.size.height, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

+ (UIImage *)addImage:(UIImage *)image1 toImageTop:(UIImage *)image2
{
    UIGraphicsBeginImageContext(CGSizeMake(MAX(image1.size.width, image2.size.width), image2.size.height));
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
                                
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

+(UIImage *)addImage:(UIImage *)image1 toImageCenter:(UIImage *)image2
{
    UIGraphicsBeginImageContext(CGSizeMake(image2.size.width, image2.size.height));
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    // Draw image1
    [image1 drawInRect:CGRectMake((image2.size.width - image1.size.width) / 2, (image2.size.height - image1.size.height) / 2, image1.size.width, image1.size.height)];
    
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end
