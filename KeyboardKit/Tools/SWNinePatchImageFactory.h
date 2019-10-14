//
//  SWNinePatchImageFactory.h
//  SWNinePatchImageFactory
//
//  Created by shiami on 7/10/14.
//  Copyright (c) 2014 TaccoTap. All rights reserved.

#import <UIKit/UIKit.h>

@interface SWNinePatchImageFactory : NSObject

+ (UIImage*)createResizableNinePatchImageNamed:(NSString*)name;
// 该方法参数image必须为点九图
+ (UIImage*)createResizableNinePatchImage:(UIImage*)image;

// 若参数image为点九图 则返回ResizableImage；若参数image不为点九图，返回nil
+ (UIImage *)createResizableImageIfIsNinePatch:(UIImage*)image;

// 若参数image为点九图 则返回ResizableImage； 若参数image不为点九图，则返回默认拉伸位置(UIEdgeInsetsMake(height/2 - 1, width/2 - 1, height/2 + 1, width/2 + 1) 即拉伸中间的区域)的ResizableImage
+ (UIImage *)createResizableImage:(UIImage *)image;

//+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy;

+ (BOOL)isNinePatchImageByContent:(UIImage *)image;

@end

#pragma mark - UIImage Extension

@interface UIImage (Crop)

- (UIImage*)crop:(CGRect)rect;

- (UIImage *)cropEdge;

@end

@implementation UIImage (Crop)

- (UIImage*)crop:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);

    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)cropEdge {
    CGRect rect = CGRectMake(1, 1, CGImageGetWidth(self.CGImage)-2, CGImageGetHeight(self.CGImage)-2);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end
