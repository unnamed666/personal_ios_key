//
//  CMImageCropHelper.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMImageCropHelper : NSObject

/// 裁剪框背景的处理
+ (void)overlayClippingWithView:(UIView *)view cropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop;

/// 获得裁剪后的图片
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView;

// 获取圆形图片
+ (UIImage *)circularClipImage:(UIImage *)image;

@end
