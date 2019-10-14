//
//  CMGifHelper.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/10/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMGifHelper : NSObject

/*
 通过 图片数组生成gif图, loopCount = 0时无限循坏
 */
+ (void)createNormalGifFromImages:(NSInteger )imageCount loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock;

/*
 将视频生成gif 快速默认参数
 */

+ (void)createNormalGifFromVideo:(NSURL*)videoURL loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock;

/*
 将视频生成gif 自定义各项参数
 */
+ (void)createCustomGifFromVideo:(NSURL*)videoURL frameCount:(int)frameCount delayTime:(float)delayTime loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock;

@end
