//
//  SWNinePatchImageFactory.m
//  SWNinePatchImageFactory
//
//  Created by shiami on 7/10/14.
//  Copyright (c) 2014 TaccoTap. All rights reserved.

#import "SWNinePatchImageFactory.h"
#import "CMLogger.h"

@interface SWNinePatchImageFactory (Private)
//+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy count:(int)count;
+ (UIImage*)createResizableImageFromNinePatchImage:(UIImage*)ninePatchImage;
@end

@implementation SWNinePatchImageFactory

/*
+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy
{
    NSMutableArray* result = [NSMutableArray new];

    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char* rawData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0; ii < width*height; ++ii) {
        CGFloat red = (rawData[byteIndex] * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;

        NSArray* aColor = [NSArray arrayWithObjects:[NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], [NSNumber numberWithFloat:alpha], nil];
        [result addObject:aColor];
    }

    free(rawData);

    return result;
}
 */

+ (BOOL)isNinePatchImageByContent:(UIImage *)image
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char* rawData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSInteger left = -1;
    for (int i = 0; i < width; i++) {
        if ((rawData[i * 4 + 3] * 1.0) / 255.0 == 1) {
            left = i;
            break;
        }
    }
    free(rawData);
    
    if (left != -1) {
        return YES;
    }
    
    return NO;
}

+ (UIImage*)createResizableNinePatchImageNamed:(NSString*)name
{
    NSAssert([name hasSuffix:@".9"], @"The image name is not ended with .9");

    NSString* fixedImageFilename = [NSString stringWithFormat:@"%@%@", name, @".png"];
    UIImage* oriImage = [UIImage imageNamed:fixedImageFilename];

    NSAssert(oriImage != nil, @"The input image is incorrect: ");

    NSString* fixed2xImageFilename = [NSString stringWithFormat:@"%@%@", [name substringWithRange:NSMakeRange(0, name.length - 2)], @"@2x.9.png"];
    UIImage* ori2xImage = [UIImage imageNamed:fixed2xImageFilename];
    if (ori2xImage != nil) {
        oriImage = ori2xImage;
        kLogInfo(@"NinePatchImageFactory[Info]: Using 2X image: %@", fixed2xImageFilename);
    } else {
        kLogInfo(@"NinePatchImageFactory[Info]: Using image: %@", fixedImageFilename);
    }

    return [self createResizableImageFromNinePatchImage:oriImage];
}

+ (UIEdgeInsets)getResizableEdgeInsets:(UIImage *)image
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char* rawData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSInteger top = -1, left = -1, bottom = -1, right = -1;
    for (int i = 0; i < width; i++) {
        if ((rawData[i * 4 + 3] * 1.0) / 255.0 == 1) {
            left = i;
            break;
        }
    }
    for (int i = width - 1; i >= 0; i--) {
        if (rawData[i * 4 + 3] * 1.0 / 255.0 == 1) {
            right = i;
            break;
        }
    }
    for (int i = left + 1; i <= right - 1; i++) {
        if (rawData[i * 4 + 3] * 1.0 / 255.0 < 1) {
            left = -1;
            right = -1;
            break;
        }
    }
    
    for (int i = 0; i <= height - 1; i++) {
        if ((rawData[i * width * 4 + 3] * 1.0) / 255.0 == 1) {
            top = i;
            break;
        }
    }
    for (int i = height - 1; i >= 0; i--) {
        if ((rawData[i * width * 4 + 3] * 1.0) / 255.0 == 1) {
            bottom = i;
            break;
        }
    }
    for (int i = top + 1; i <= bottom - 1; i++) {
        if ((rawData[i * width * 4 + 3] * 1.0) / 255.0 < 0) {
            top = -1;
            bottom = -1;
            break;
        }
    }
    free(rawData);
    return UIEdgeInsetsMake(round(top/image.scale), round(left/image.scale), round(bottom/image.scale), round(right/image.scale));
}

+ (UIImage*)createResizableNinePatchImage:(UIImage*)image
{
    return [self createResizableImageFromNinePatchImage:image];
}

+ (UIImage *)createResizableImageIfIsNinePatch:(UIImage *)image
{
    UIEdgeInsets edgeInsets = [self getResizableEdgeInsets:image];
    if (edgeInsets.left == -1 || edgeInsets.right == -1 || edgeInsets.top == -1 || edgeInsets.bottom == -1) {
        return nil;
    }
    UIImage* cropImage = [image cropEdge];
    
    return [cropImage resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)createResizableImage:(UIImage *)image
{
    UIEdgeInsets edgeInsets = [self getResizableEdgeInsets:image];
    if (edgeInsets.left == -1 || edgeInsets.right == -1 || edgeInsets.top == -1 || edgeInsets.bottom == -1) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        edgeInsets = UIEdgeInsetsMake(height/2 - 1, width/2 - 1, height/2 + 1, width/2 + 1);
    }
    UIImage* cropImage = [image cropEdge];
    
    return [cropImage resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)createResizableImageFromNinePatchImage:(UIImage*)ninePatchImage
{
    UIEdgeInsets edgeInsets = [self getResizableEdgeInsets:ninePatchImage];
    NSAssert(edgeInsets.left != -1, @"The 9-patch PNG format is not correct.");
    NSAssert(edgeInsets.right != -1, @"The 9-patch PNG format is not correct.");
    NSAssert(edgeInsets.top != -1, @"The 9-patch PNG format is not correct.");
    NSAssert(edgeInsets.bottom != -1, @"The 9-patch PNG format is not correct.");
    
    UIImage* cropImage = [ninePatchImage cropEdge];
    
    return [cropImage resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
}

@end
