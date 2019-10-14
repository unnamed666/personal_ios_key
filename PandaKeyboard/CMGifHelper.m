//
//  CMGifHelper.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/10/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMGifHelper.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMGroupDataManager.h"

#define timeInterval @(600)
#define tolerance    @(0.01)

//static NSString* const kSaveEmotGifToPathName = @"kSaveEmotGifToPathName";

typedef NS_ENUM(NSInteger, GIFSize) {
    GIFSizeVeryLow  = 2,
    GIFSizeLow      = 3,
    GIFSizeMedium   = 5,
    GIFSizeHigh     = 7,
    GIFSizeOriginal = 10
};

@implementation CMGifHelper

+ (void)createNormalGifFromImages:(NSInteger )imageCount loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock{
    
    //设置destination
    NSDictionary *fileProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @(loopCount), // 0 means loop forever
                                             (__bridge id)kCGImagePropertyGIFHasGlobalColorMap:@(NO),
                                             (__bridge id)kCGImagePropertyDepth:@(8),
                                             (__bridge id)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB
                                             }
                                     };
    //单个图片
    NSDictionary *frameProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(0.1),
                                              //@(5.0/imageCount)
//                                              (__bridge id)kCGImagePropertyGIFHasGlobalColorMap: @(NO),
                                              },

                                      };
   
    
    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *fileURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        fileURL = [self animojiGifPath];
        if (fileURL) {
   
            CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, imageCount, NULL);
            CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
            for (NSUInteger i = 0; i < imageCount; i++) {
                @autoreleasepool {
                    CFDataRef data = (__bridge CFDataRef)[NSData dataWithContentsOfFile:[[CMDirectoryHelper getPathCacheScreenshot] URLByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png",(unsigned long)i]].path];
                    CGDataProviderRef dProv = CGDataProviderCreateWithCFData(data);
                    if (dProv) {
                        CGImageRef imageRef = CGImageCreateWithPNGDataProvider(dProv, NULL, false, kCGRenderingIntentDefault);
                        CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
                        CGImageRelease(imageRef);
                        CGDataProviderRelease(dProv);
                    }
                }
            }
            if (!CGImageDestinationFinalize(destination)) {
                kLogError(@"Failed to write image to %@", fileURL.path);
                fileURL = nil;
            }
            else
            {
                fileURL = [self moveGifFromTemToGroup:fileURL];
                kLogInfo(@"gif create success！%@",fileURL.path);
                //[shareBtn setHidden:NO];
            }
            CFRelease(destination);
        }
        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(fileURL);
    });
  
}

+ (void)createNormalGifFromVideo:(NSURL*)videoURL loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock{
    
    float delayTime = 0.2f;
    
    // Create properties dictionaries
    NSDictionary *fileProperties = @{(NSString *)kCGImagePropertyGIFDictionary:
                                         @{(NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}
                                     };;

    NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary:
                                          @{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
                                      (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB
                                      };
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Switch_Keyboard" ofType:@"mp4"];
//    videoURL = [[NSURL alloc]initFileURLWithPath:imagePath];
//    videoURL = [[NSURL alloc]initFileURLWithPath:[videoURL absoluteString]];
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    
    float videoWidth = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width;
    float videoHeight = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height;
    
    GIFSize optimalSize = GIFSizeMedium;
    if (videoWidth >= 1200 || videoHeight >= 1200)
        optimalSize = GIFSizeVeryLow;
    else if (videoWidth >= 800 || videoHeight >= 800)
        optimalSize = GIFSizeLow;
    else if (videoWidth >= 400 || videoHeight >= 400)
        optimalSize = GIFSizeMedium;
    else if (videoWidth < 400|| videoHeight < 400)
        optimalSize = GIFSizeHigh;
    
    // Get the length of the video in seconds
    float videoLength = (float)asset.duration.value/asset.duration.timescale;
    int framesPerSecond = 4;
    int frameCount = videoLength*framesPerSecond;
    
    // How far along the video track we want to move, in seconds.
    float increment = (float)videoLength/frameCount;
    
    // Add frames to the buffer
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame<frameCount; ++currentFrame) {
        float seconds = (float)increment * currentFrame;
        CMTime time = CMTimeMakeWithSeconds(seconds, [timeInterval intValue]);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    
    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *gifURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        gifURL = [self createGIFforTimePoints:timePoints fromURL:videoURL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:optimalSize];
         if (!gifURL) {
             kLogError(@"生成gif 失败");
//             [self deleteFileGifImage];
         }else{
             gifURL = [self moveGifFromTemToGroup:gifURL];
         }
        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(gifURL);
    });
    
}

+ (void)createCustomGifFromVideo:(NSURL*)videoURL frameCount:(int)frameCount delayTime:(float)delayTime loopCount:(int)loopCount completion:(void(^)(NSURL *GifURL))completionBlock{
    
    // Create properties dictionaries
    NSDictionary *fileProperties = @{(NSString *)kCGImagePropertyGIFDictionary:
                                         @{(NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}
                                     };;
    NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary:
                                          @{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
                                      (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB
                                      };
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    
    // Get the length of the video in seconds
    float videoLength = (float)asset.duration.value/asset.duration.timescale;
    
    // How far along the video track we want to move, in seconds.
    float increment = (float)videoLength/frameCount;
    
    // Add frames to the buffer
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame<frameCount; ++currentFrame) {
        float seconds = (float)increment * currentFrame;
        CMTime time = CMTimeMakeWithSeconds(seconds, [timeInterval intValue]);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    
    // Prepare group for firing completion block
    dispatch_group_t gifQueue = dispatch_group_create();
    dispatch_group_enter(gifQueue);
    
    __block NSURL *gifURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        gifURL = [self createGIFforTimePoints:timePoints fromURL:videoURL fileProperties:fileProperties frameProperties:frameProperties frameCount:frameCount gifSize:GIFSizeMedium];
        if (!gifURL) {
//            [self deleteFileGifImage];
        }else{
            gifURL = [self moveGifFromTemToGroup:gifURL];
        }
        dispatch_group_leave(gifQueue);
    });
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
        // Return GIF URL
        completionBlock(gifURL);
    });
}

#pragma mark - Base methods

+ (NSURL *)createGIFforTimePoints:(NSArray *)timePoints fromURL:(NSURL *)url fileProperties:(NSDictionary *)fileProperties frameProperties:(NSDictionary *)frameProperties frameCount:(NSInteger)frameCount gifSize:(GIFSize)gifSize{
    NSURL *fileURL = [self animojiGifPath]; //gif 输出路径
    if (fileURL == nil)
        return nil;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF , frameCount, NULL); //图像目标
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime tol = CMTimeMakeWithSeconds([tolerance floatValue], [timeInterval intValue]);
    generator.requestedTimeToleranceBefore = tol;
    generator.requestedTimeToleranceAfter = tol;
    
    NSError *error = nil;
    CGImageRef previousImageRefCopy = nil;
    for (NSValue *time in timePoints) {
        CGImageRef imageRef;
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        imageRef = (float)gifSize/10 != 1 ? createImageWithScale([generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error], (float)gifSize/10) : [generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error];
#elif TARGET_OS_MAC
        imageRef = [generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error];
#endif
        
        if (error) {
            kLogError(@"Error copying image: %@", error);
        }
        if (imageRef) {
            CGImageRelease(previousImageRefCopy);
            previousImageRefCopy = CGImageCreateCopy(imageRef);
        } else if (previousImageRefCopy) {
            imageRef = CGImageCreateCopy(previousImageRefCopy);
        } else {
            kLogError(@"Error copying image and no previous frames to duplicate");
            return nil;
        }
        CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
        CGImageRelease(imageRef);
    }
    CGImageRelease(previousImageRefCopy);
    
    // Finalize the GIF
    if (!CGImageDestinationFinalize(destination)) {
        kLogError(@"Failed to finalize GIF destination: %@", error);
        if (destination != nil) {
            CFRelease(destination);
        }
        return nil;
    }
    CFRelease(destination);
    
    return fileURL;
}

+(void)deleteFileGifImage{
    //失败后删除
//    NSString *gifName = [[NSUserDefaults standardUserDefaults] objectForKey:kSaveEmotGifToPathName];
//    kLogWarn(@"Gif 生成失败,进行删除 %@",gifName);
//    [CMDirectoryHelper deleteFileContentName:gifName underPath:[CMDirectoryHelper getPathCacheScreenshot].path];
}

+(NSURL *)moveGifFromTemToGroup:(NSURL *)filePath{
    
    NSURL *targetPath = [NSURL fileURLWithPath:[kCMGroupDataManager.EmoGifPath.path stringByAppendingPathComponent:filePath.lastPathComponent]];
    BOOL suc =  [CMDirectoryHelper moveDirOrFileAtPath:filePath.path toPath:targetPath.path];
    if (suc) {
        return targetPath;
    }
    return nil;
}

+(NSURL *)animojiGifPath{
    //临时path
    long long dateNum = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000] longLongValue];
    //(long long)([date timeIntervalSince1970] * 1000)
    NSString *fileName = [NSString stringWithFormat:@"Emoticon_%lld.gif",(long long)dateNum];
    while ([[NSFileManager defaultManager] isExecutableFileAtPath:[kCMGroupDataManager.EmoGifPath.path stringByAppendingPathComponent:fileName]]) {
        dateNum++;
        fileName = [NSString stringWithFormat:@"Emoticon_%lld.gif",(long long)dateNum];
    }
//    NSURL * fileURL = [NSURL fileURLWithPath:[kCMGroupDataManager.EmoGifPath.path stringByAppendingPathComponent:fileName]];
    NSURL * fileURL = [NSURL fileURLWithPath:[[CMDirectoryHelper getPathCacheScreenshot].path stringByAppendingPathComponent:fileName]];
    return fileURL;
}

#pragma mark - Helpers

CGImageRef createImageWithScale(CGImageRef imageRef, float scale) {
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    CGSize newSize = CGSizeMake(CGImageGetWidth(imageRef)*scale, CGImageGetHeight(imageRef)*scale);
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return nil;
    }
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    //Release old image
    CFRelease(imageRef);
    // Get the resized image from the context and a UIImage
    imageRef = CGBitmapContextCreateImage(context);
    
    UIGraphicsEndImageContext();
#endif
    
    return imageRef;
}

@end
