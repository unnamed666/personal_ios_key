
//
//  CMScreenRecordManager.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMScreenRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import <SceneKit/SceneKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMGifHelper.h"

@interface CMScreenRecordManager(){
    
    // ui 相关
    UIView *_scrView; //要汇制的view
    CGSize _viewSize; //view大小
    CGFloat _scale;
    
    //绘制相关
    CGColorSpaceRef _rgbColorSpace;
    CVPixelBufferPoolRef _outputBufferPool;
    CGContextRef  _context; //绘制layer的context

    //状态相关
    ScreenRecordChannle _channel;
    BOOL _ifscnView;
}

//录制
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *videoWirterAdaptor;
@property (nonatomic, strong) NSURL *videoPath;
@property (nonatomic, strong) NSURL *shotTemPath;
@property (nonatomic, strong) UIView *scrView;
@property (nonatomic, assign, readwrite) BOOL isRecording;
@property (nonatomic, assign) NSInteger imageCount;
//循环
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval firstTimeStamp;

//线程相关
@property (nonatomic, strong) dispatch_queue_t render_queue;
@property (nonatomic, strong) dispatch_queue_t append_pixelBuffer_queue;
@property (nonatomic, strong) dispatch_semaphore_t frameRenderingSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t pixelAppendSemaphore;

@end
@implementation CMScreenRecordManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static CMScreenRecordManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _scale = [UIScreen mainScreen].scale;
        // record half size resolution for retina iPads
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && _scale > 1) {
            _scale = 1.0;
        }
//        dispatch_set_target_queue(self.render_queue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    }
    return self;
}
- (void)dealloc {
    kLogTrace();
}

#pragma mark - 屏幕录制method
-(void)startScreenRecord:(UIView *_Nullable)targetView channel:(ScreenRecordChannle)chanel
{
    _channel = chanel;
    if (!_isRecording) {
        [self deleteTemScreenshot];
        kLogInfo(@"启动屏幕录制任务");
        self.scrView = targetView;
        _imageCount = 0;
        SEL method ;
        switch (_channel) {
            case ScreenRecordChannleByVideo:
            {
                [self setUpVideoWriter];
                _isRecording = (self.videoWriter.status == AVAssetWriterStatusWriting);
                method  = @selector(writeViedoFrameStep);
            }
                break;
            case ScreenRecordChannleByImage:
                _isRecording = YES;
                method  = @selector(writeImageFrameStep);
                break;
        }
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:method];
        _displayLink.frameInterval = 6;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)cancleScreenRecord{
    [self unexpectStopRecord];
//    SCNView *snView = (SCNView *)_scrView;
//    [snView audioEngine];
}

-(void)stopScreenRecord:(CMScreenRecordFinishBlock)completeBlock{
    //结束录屏
    if (_isRecording) {
        [self invalidateDisplayLink];
        switch (_channel) {
            case ScreenRecordChannleByVideo:
                //视频方式
                [self completeRecordSession:completeBlock];
                break;
            case ScreenRecordChannleByImage:
                //截图方式
                [self completeShotSession:completeBlock];
                break;
        }
    }else{
        if (completeBlock) {
            completeBlock(nil);
        }
    }
}

-(void)unexpectStopRecord {
    [self invalidateDisplayLink];
    [self cleanUp];
}



-(void)completeShotSession:(CMScreenRecordFinishBlock)completeBlock{
    dispatch_async(self.render_queue, ^{
        kLogInfo(@"截屏任务结束");
        if (_imageCount > 0) {
            [CMGifHelper createNormalGifFromImages:_imageCount loopCount:0 completion:^(NSURL *GifURL) {
                NSURL *fileUrl = self.isRecording ? GifURL : nil;
                if (completeBlock) {
                   completeBlock(fileUrl);
                }
                [self cleanUp];
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completeBlock) {
                    completeBlock(nil);
                }
                [self cleanUp];
            });
        }
        
    });
}

-(void)completeRecordSession:(CMScreenRecordFinishBlock)completeBlock{
    dispatch_async(self.render_queue, ^{
        kLogInfo(@"录制任务结束");
        dispatch_sync(self.append_pixelBuffer_queue, ^{
            [self.videoWriterInput markAsFinished];
            [self.videoWriter finishWritingWithCompletionHandler:^{
                kLogInfo(@"视频录制完成");
                if (self.videoPath) {
                    [CMGifHelper createNormalGifFromVideo:self.videoPath loopCount:0 completion:^(NSURL *GifURL) {
                        NSURL *fileUrl = self.isRecording ? GifURL : nil;
                        completeBlock(fileUrl);
                        [self cleanUp];
                    }];
                    
                }else{
                    completeBlock(nil);
                    [self cleanUp];
                }
                
            }];
        });
    });
}

-(void)cleanUp{
    _videoWriter = nil;
    _videoWirterAdaptor = nil;
    _videoWriterInput = nil;
//    _firstTimeStamp = 0;
    _imageCount = 0;
    _isRecording = false;
    CGColorSpaceRelease(_rgbColorSpace);
    CVPixelBufferPoolRelease(_outputBufferPool);
    CGContextRelease(_context);
    [self deleteTemScreenshot];
    //6、关闭上下文
//    UIGraphicsEndImageContext();
}

-(void)invalidateDisplayLink{
    if (_displayLink) {
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_displayLink invalidate];
        _displayLink = nil;
        _firstTimeStamp = 0;
    }
}

#pragma mark - Private method

-(void)setUpVideoWriter{
    // add input
    
    _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    //    _context =  UIGraphicsGetCurrentContext();
    
    //    _rgbColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    
    _scale = 0.5;
    NSInteger width = (NSInteger)_viewSize.width*_scale;
    NSInteger height = (NSInteger)_viewSize.height*_scale;
    while (width % 2 != 0) {
        width--;
    }
    
    while (height %2 != 0) {
        height--;
    }
    _viewSize = CGSizeMake(width, height);
    
    //    _context =  CGBitmapContextCreate(NULL,
    //                                      width,
    //                                      height,
    //                                      8,
    //                                      4 * width,
    //                                      _rgbColorSpace,
    //                                      kCGImageAlphaPremultipliedLast);
    
    
    
    //1、开启上下文
    //    UIGraphicsBeginImageContext(_viewSize);
    //    //2、获取当前上下文
    //    _context =  UIGraphicsGetCurrentContext();
    NSDictionary *bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                       (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
                                       (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                       (id)kCVPixelBufferWidthKey : @(width),
                                       (id)kCVPixelBufferHeightKey : @(height),
                                       (id)kCVPixelBufferBytesPerRowAlignmentKey : @(width* 4)
                                       };
    
    NSError* error = nil;
    _videoWriter = [[AVAssetWriter alloc]initWithURL:self.videoPath fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(_videoWriter);
    
    NSInteger pixelNumber = width * height / _scale;
    NSDictionary* videoCompression = @{AVVideoAverageBitRateKey: @(pixelNumber * 11.4)};
    NSDictionary* videoSettings = @{
                                    AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:height],
                                    AVVideoCompressionPropertiesKey: videoCompression
                                    };
    
    //    NSInteger pixelNumber = _viewSize.width * _viewSize.height * _scale;
    //    NSDictionary* videoCompression = @{AVVideoAverageBitRateKey: @(pixelNumber * 11.4)};
    //    NSDictionary* videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
    //                                    AVVideoWidthKey: [NSNumber numberWithInt:_viewSize.width*_scale],
    //                                    AVVideoHeightKey: [NSNumber numberWithInt:_viewSize.height*_scale],
    //                                    AVVideoCompressionPropertiesKey: videoCompression};
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSParameterAssert(_videoWriterInput);
    
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    _videoWriterInput.transform = [self videoTransformForDeviceOrientation];
    
    _videoWirterAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    [_videoWriter addInput:_videoWriterInput];
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
    kLogInfo(@"AVAssetWriter 读写准备完成");
}

- (CGAffineTransform)videoTransformForDeviceOrientation
{
    CGAffineTransform videoTransform;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            videoTransform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoTransform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            videoTransform = CGAffineTransformIdentity;
    }
    return videoTransform;
}

-(void)deleteTemScreenshot{
    //删除所有截屏图片、视频
//    [CMDirectoryHelper deleteDirOrFile:self.videoPath.path];
    [CMDirectoryHelper deleteDirOrFile:self.shotTemPath.path];
}

-(void)writeImageFrameStep{
    //创建单张图片
    dispatch_async(self.render_queue, ^{
        if (!self.firstTimeStamp) {
            self.firstTimeStamp = _displayLink.timestamp;
            kLog(@"截图开始计时");
        }else{
            CFTimeInterval elapsed = (_displayLink.timestamp - self.firstTimeStamp);
            kLog(@"执行时长%f",elapsed);
            if (elapsed > 10.0f)
            {
                [self unexpectStopRecord];
            }else{
                @autoreleasepool {
                    UIImage *snapImage;
                    if (_ifscnView) {
                        SCNView *snView = (SCNView *)_scrView;
                        snapImage = [snView snapshot];
                        
                    }else{
                        //        [_scrView.layer renderInContext:_context];
                        //        imgeRef =  CGBitmapContextCreateImage(_context);
                    }
                    
                    if (snapImage) {
                        NSURL *imagePath = [[CMDirectoryHelper getPathCacheScreenshot] URLByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png",_imageCount]];
                        if ([CMBizHelper CGImageWriteToFile:snapImage.CGImage path:imagePath]) {
                            _imageCount ++;
                            kLogInfo(@"单帧图片保存成功 %ld***%f",(long)_imageCount,_displayLink.duration);
                            
                        }
                        else {
                            kLogInfo(@"单帧图片保存失败");
                        }
                        
                        snapImage = nil;
                    }
                }
            }
        }
    });
}

-(void)writeViedoFrameStep{
    //逐帧录制视频
    if (dispatch_semaphore_wait(self.frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    dispatch_async(self.render_queue, ^{
        if (![_videoWriterInput isReadyForMoreMediaData]) return;
        
        if (!self.firstTimeStamp) {
            self.firstTimeStamp = _displayLink.timestamp;
        }
        CFTimeInterval elapsed = (_displayLink.timestamp - self.firstTimeStamp);
        CMTime time = CMTimeMakeWithSeconds(elapsed, 1000);
        kLogInfo(@"单帧写入中...%f",elapsed);
        CGImageRef imgeRef;
        if (_ifscnView) {
            SCNView *snView = (SCNView *)_scrView;
            //            UIImage *newImage = [snView snapshot];
            imgeRef = [snView snapshot].CGImage;
        }else{
            //截屏
            [_scrView.layer renderInContext:_context];
            imgeRef =  CGBitmapContextCreateImage(_context);
        }
        
        CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:imgeRef];
        
        
        
        //        CVPixelBufferRef pixelBuffer = NULL;
        //        CGContextRef bitmapContext = [self createPixelBufferAndBitmapContext:&pixelBuffer];
        //        // draw each window into the context (other windows include UIKeyboard, UIAlert)
        //        // FIX: UIKeyboard is currently only rendered correctly in portrait orientation
        //        dispatch_sync(dispatch_get_main_queue(), ^{
        //            UIGraphicsPushContext(bitmapContext); {
        //                for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        //                    [window drawViewHierarchyInRect:CGRectMake(0, 0, _viewSize.width, _viewSize.height) afterScreenUpdates:NO];
        //                }
        //            } UIGraphicsPopContext();
        //        });
        
        
        // append pixelBuffer on a async dispatch_queue, the next frame is rendered whilst this one appends
        // must not overwhelm the queue with pixelBuffers, therefore:
        // check if _append_pixelBuffer_queue is ready
        // if it’s not ready, release pixelBuffer and bitmapContext
        if (dispatch_semaphore_wait(self.pixelAppendSemaphore, DISPATCH_TIME_NOW) == 0) {
            dispatch_async(self.append_pixelBuffer_queue, ^{
                BOOL success = [_videoWirterAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                if (!success) {
                    kLogInfo(@"⚠️: Unable to write buffer to video");
                }
                //                CGImageRelease(imgeRef);
                //                CGContextRelease(bitmapContext);
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                CVPixelBufferRelease(pixelBuffer);
                
                dispatch_semaphore_signal(self.pixelAppendSemaphore);
            });
        } else {
            //            CGImageRelease(imgeRef);
            
            //            CGContextRelease(bitmapContext);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            CVPixelBufferRelease(pixelBuffer);
        }
        
        dispatch_semaphore_signal(self.frameRenderingSemaphore);
    });
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
//    CVPixelBufferPoolRef pixelBufferPool = [_videoWirterAdaptor pixelBufferPool];
//    CVReturn status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pxbuffer);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,frameWidth,frameHeight,kCVPixelFormatType_32BGRA, nil, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef context =  CGBitmapContextCreate(pxdata,
                                      frameWidth,
                                      frameHeight,
                                      8,
                                      CVPixelBufferGetBytesPerRow(pxbuffer),
                                      rgbColorSpace,
                                      kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Little);

//    CGContextRef context = CGBitmapContextCreate(pxdata, frameWidth, frameHeight, 8,CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0,frameWidth,frameHeight),  image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (CGContextRef)createPixelBufferAndBitmapContext:(CVPixelBufferRef *)pixelBuffer
{
    CVPixelBufferPoolCreatePixelBuffer(NULL, _outputBufferPool, pixelBuffer);
    CVPixelBufferLockBaseAddress(*pixelBuffer, 0);
    
    CGContextRef bitmapContext = NULL;
    bitmapContext = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(*pixelBuffer),
                                          CVPixelBufferGetWidth(*pixelBuffer),
                                          CVPixelBufferGetHeight(*pixelBuffer),
                                          8, CVPixelBufferGetBytesPerRow(*pixelBuffer), _rgbColorSpace,
                                          kCGBitmapByteOrder32Little |  kCGImageAlphaPremultipliedFirst
                                          );
    CGContextScaleCTM(bitmapContext, _scale, _scale);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, _viewSize.height);
    CGContextConcatCTM(bitmapContext, flipVertical);
    return bitmapContext;
}

#pragma mark - getter and setter

-(void)setScrView:(UIView *)scrView{
    _scrView = scrView;
    _viewSize = scrView.frame.size;
    if ([scrView isMemberOfClass:[SCNView class]]) {
        _ifscnView = true;
    }else{
        _ifscnView = false;
    }
}

-(NSURL *)shotTemPath{
    //图片临时存放
    
    if (!_shotTemPath) {
      _shotTemPath = [CMDirectoryHelper getPathCacheScreenshot];
    }
    return _shotTemPath;
}


-(NSURL *)videoPath{
    //视频存储路径
    if (!_videoPath) {
        _videoPath =  [[CMDirectoryHelper getPathCacheScreenshot] URLByAppendingPathComponent:@"AniVideo.mp4"];
    }
    return _videoPath;
}

-(dispatch_queue_t)render_queue{
    if (!_render_queue) {
        _render_queue = dispatch_queue_create("CMScreenRecorder.render.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _render_queue;
}

-(dispatch_queue_t)append_pixelBuffer_queue{
    if (!_append_pixelBuffer_queue) {
        _append_pixelBuffer_queue = dispatch_queue_create("CMScreenRecorder.append.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _append_pixelBuffer_queue;
}

-(dispatch_semaphore_t)frameRenderingSemaphore{
    if (!_frameRenderingSemaphore) {
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
    }
    return _frameRenderingSemaphore;
}

-(dispatch_semaphore_t)pixelAppendSemaphore{
    if (!_pixelAppendSemaphore) {
        _pixelAppendSemaphore = dispatch_semaphore_create(1);
    }
    return _pixelAppendSemaphore;
}

@end




