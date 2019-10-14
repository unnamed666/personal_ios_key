//
//  CMAnimojiViewController.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/9/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

@import GoogleMobileVision;

#import "CMAnimojiViewController.h"
#import <SceneKit/SceneKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "FaceInTracker.h"
#import "DrawingUtility.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMScreenRecordManager.h"

@interface CMAnimojiViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,SCNSceneRendererDelegate/*,FaceInTrackerDelegate*/> {
    CGFloat _imageOnPreviewScale;
    CGFloat _previewImageWidth;
    CGFloat _previewImageHeight;
}

@property (nonatomic, strong)dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong)AVCaptureSession* session;
@property (nonatomic, strong)AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, assign)UIDeviceOrientation lastKnownDeviceOrientation;

@property (nonatomic, strong)SCNView* scnView;
@property (nonatomic, strong)SCNNode* mainNode;
@property (nonatomic, strong)SCNNode* neckNode;

// Detector.
@property (nonatomic, strong)GMVDetector *faceDetector;
@property (nonatomic, strong)UIView *overlayView;

@end

@implementation CMAnimojiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    [self setupSceneView];
//    [self setupCMFaceDetection];
    [self setupAVCapture];
    
    [self.view addSubview:self.overlayView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    [self cleanupCaptureSession];
}

- (void)setupSceneView {
    // 初始化一个场景
    //    获取资源
//    SCNSceneSource *scneSoure = [SCNSceneSource sceneSourceWithURL:[[NSBundle mainBundle] URLForResource:@"scenekit.scnassets/Horse_NoBlendWithGeo3" withExtension:@"scn"] options:nil]; //马
    SCNSceneSource *scneSoure = [SCNSceneSource sceneSourceWithURL:[[NSBundle mainBundle] URLForResource:@"scenekit.scnassets/Dog_NoBlendWithGeo" withExtension:@"scn"] options:nil]; //狗
    SCNScene *scene = [scneSoure sceneWithOptions:nil error:nil];
    
    // 创建一个摄像机并放入场景中
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // 摆放摄像机位置
    cameraNode.position = SCNVector3Make(0, 15, 40);
    cameraNode.camera.zFar = 300;
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor colorWithRed:0.5F green:0.5F blue:0.5F alpha:1.F];
    [scene.rootNode addChildNode:ambientLightNode];
    
    //马
//    self.mainNode = [scene.rootNode childNodeWithName:@"Horse_base" recursively:YES];
//    SCNNode *leftEyeMesh = [scene.rootNode childNodeWithName:@"Horse_BlinkLMesh" recursively:YES];
//    SCNNode *rightEyeMesh = [scene.rootNode childNodeWithName:@"Horse_BlinkRMesh" recursively:YES];
//    SCNNode *mouthCloseMesh = [scene.rootNode childNodeWithName:@"Horse_MouthCloseMesh" recursively:YES];
//    self.mainNode.morpher = [[SCNMorpher alloc] init];
//    self.mainNode.morpher.targets = [NSArray arrayWithObjects: leftEyeMesh.geometry, rightEyeMesh.geometry, mouthCloseMesh.geometry, nil];
    
    //狗
    self.mainNode = [scene.rootNode childNodeWithName:@"Dog" recursively:YES];
    SCNNode *leftEyeMesh = [scene.rootNode childNodeWithName:@"Dog_BlinkLMesh" recursively:YES];
    SCNNode *rightEyeMesh = [scene.rootNode childNodeWithName:@"Dog_BlinkRMesh" recursively:YES];
    SCNNode *mouthHalfCloseMesh = [scene.rootNode childNodeWithName:@"Dog_MouthHalfCloseMesh" recursively:YES];
    SCNNode *mouthFullCloseMesh = [scene.rootNode childNodeWithName:@"Dog_MouthFullCloseMesh" recursively:YES];
    
    self.neckNode = [scene.rootNode childNodeWithName:@"Neck" recursively:YES];

    self.mainNode.morpher = [[SCNMorpher alloc] init];
    self.mainNode.morpher.targets = [NSArray arrayWithObjects: leftEyeMesh.geometry, rightEyeMesh.geometry, mouthHalfCloseMesh.geometry, mouthFullCloseMesh.geometry, nil];
    
    // 创建一个用来展示场景的SCNView
//    _scnView = [[SCNView alloc] initWithFrame:self.view.bounds];
//    self.scnView.delegate = self;
    [self.view addSubview:self.scnView];
    
    // 设置场景
    self.scnView.scene = scene;
    
    // 设置背景
    self.scnView.backgroundColor = [UIColor purpleColor];
    
    // 允许控制摄像机位置
    self.scnView.allowsCameraControl = NO;
    
#ifdef DEBUG
    // 显示数据控制台
    self.scnView.showsStatistics = YES;
#endif
}

//- (void)setupCMFaceDetection {
//    int nmaxdet = 4;
//
//    CGFloat previewWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat previewHeight = [UIScreen mainScreen].bounds.size.height;
//    CGFloat imageWidth = 720;
//    CGFloat imageHeight = 1280;
//    // Calculate the width, height and scale rate to display the preview image
//    _imageOnPreviewScale = MAX(previewHeight/imageHeight, previewWidth/imageWidth);
//    _previewImageWidth = imageWidth * _imageOnPreviewScale;
//    _previewImageHeight = imageHeight * _imageOnPreviewScale;
//
//    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FaceInModel" ofType:@"bundle"];
//    NSBundle *faceInBundle = [NSBundle bundleWithPath:bundlePath];//[NSBundle mainBundle];
//    BOOL bResult = [[FaceInTracker sharedTracker] trackerInitialWithBundle:faceInBundle andImageSize:CGSizeMake(720, 1280) andPreviewSize:CGSizeMake(_previewImageWidth, _previewImageHeight) andMaxDet:nmaxdet];
//
//    if(bResult){
//        NSLog(@"Init success");
//        [FaceInTracker sharedTracker].delegate = self;
//    } else {
//        NSLog(@"Init failed");
//    }
//}

- (void)cleanupCaptureSession {
    [self.session stopRunning];
    [self cleanupVideoProcessing];
    self.session = nil;
    [self.captureVideoPreviewLayer removeFromSuperlayer];
}

- (void)cleanupVideoProcessing {
    if (self.videoDataOutput) {
        [self.session removeOutput:self.videoDataOutput];
    }
    self.videoDataOutput = nil;
}

- (void)setupCameraPreview {
    // Get the preview frame size.
    if (self.captureVideoPreviewLayer) {
        [self.captureVideoPreviewLayer removeFromSuperlayer];
    }
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.frame = CGRectMake((self.view.bounds.size.width * 2)/3, 0, self.view.bounds.size.width/3, self.view.bounds.size.height/3);
    CGFloat previewWidth = self.captureVideoPreviewLayer.frame.size.width;
    CGFloat previewHeight = self.captureVideoPreviewLayer.frame.size.height;
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    CGFloat imageWidth = 720;
    CGFloat imageHeight = 1280;
    
    // Calculate the width, height and scale rate to display the preview image
    _imageOnPreviewScale = MAX(previewHeight/imageHeight, previewWidth/imageWidth);
    _previewImageWidth = imageWidth * _imageOnPreviewScale;
    _previewImageHeight = imageHeight * _imageOnPreviewScale;
}

- (void)setupAVCapture
{
    self.session = [[AVCaptureSession alloc] init];
    // Set the camera preview size
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    [self updateCameraSelection];
    
    // Setup video processing pipeline.
    [self setupVideoProcessing];
    
    // Setup camera preview.
    [self setupCameraPreview];
    
    // Initialize the face detector.
    NSDictionary *options = @{
                              GMVDetectorFaceMinSize : @(0.3),
                              GMVDetectorFaceTrackingEnabled : @(YES),
                              GMVDetectorFaceClassificationType : @(GMVDetectorFaceClassificationAll),
                              GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll)
                              };
    self.faceDetector = [GMVDetector detectorOfType:GMVDetectorTypeFace options:options];
}

- (void)setupVideoProcessing {
    if (![self.session canAddOutput:self.videoDataOutput]) {
        [self cleanupVideoProcessing];
        kLogError(@"Failed to setup video output");
        return;
    }
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    [self.session addOutput:self.videoDataOutput];
}

- (void)updateCameraSelection {
    [self.session beginConfiguration];
    
    // Remove old inputs
    NSArray *oldInputs = [self.session inputs];
    for (AVCaptureInput *oldInput in oldInputs) {
        [self.session removeInput:oldInput];
    }
    AVCaptureDeviceInput *input = [self cameraForPosition:AVCaptureDevicePositionFront];
    if (!input) {
        // Failed, restore old inputs
        for (AVCaptureInput *oldInput in oldInputs) {
            [self.session addInput:oldInput];
        }
    } else {
        // Succeeded, set input and update connection states
        [self.session addInput:input];
    }
    [self.session commitConfiguration];
}

- (AVCaptureDeviceInput *)cameraForPosition:(AVCaptureDevicePosition)desiredPosition {
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == desiredPosition) {
            NSError *error = nil;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                                error:&error];
            if ([self.session canAddInput:input]) {
                return input;
            }
        }
    }
    return nil;
}

- (CGPoint)scaledPoint:(CGPoint)point
                xScale:(CGFloat)xscale
                yScale:(CGFloat)yscale
                offset:(CGPoint)offset {
    CGPoint resultPoint = CGPointMake(point.x * xscale + offset.x, point.y * yscale + offset.y);
    return resultPoint;
}

- (CGRect)scaledRect:(CGRect)rect
              xScale:(CGFloat)xscale
              yScale:(CGFloat)yscale
              offset:(CGPoint)offset {
    CGRect resultRect = CGRectMake(rect.origin.x * xscale,
                                   rect.origin.y * yscale,
                                   rect.size.width * xscale,
                                   rect.size.height * yscale);
    resultRect = CGRectOffset(resultRect, offset.x, offset.y);
    return resultRect;
}

- (void)setLastKnownDeviceOrientation:(UIDeviceOrientation)orientation {
    if (orientation != UIDeviceOrientationUnknown &&
        orientation != UIDeviceOrientationFaceUp &&
        orientation != UIDeviceOrientationFaceDown) {
        _lastKnownDeviceOrientation = orientation;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    UIImage *image = [GMVUtility sampleBufferTo32RGBA:sampleBuffer];
    AVCaptureDevicePosition devicePosition = AVCaptureDevicePositionFront;
    
    // Establish the image orientation.
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:devicePosition
                                       defaultDeviceOrientation:self.lastKnownDeviceOrientation];
    NSDictionary *options = @{
                              GMVDetectorImageOrientation : @(orientation)
                              };
    // Detect features using GMVDetector.
    NSArray<GMVFaceFeature *> *faces = [self.faceDetector featuresInImage:image options:options];
//    NSLog(@"Detected %lu face(s).", (unsigned long)[faces count]);
    // The video frames captured by the camera are a different size than the video preview.
    // Calculates the scale factors and offset to properly display the features.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
    CGSize parentFrameSize = self.captureVideoPreviewLayer.frame.size;
    
    // Assume AVLayerVideoGravityResizeAspect
    CGFloat cameraRatio = clap.size.height / clap.size.width;
    CGFloat viewRatio = parentFrameSize.width / parentFrameSize.height;
    CGFloat xScale = 1;
    CGFloat yScale = 1;
    CGRect videoBox = CGRectZero;
    if (viewRatio > cameraRatio) {
        videoBox.size.width = parentFrameSize.height * clap.size.width / clap.size.height;
        videoBox.size.height = parentFrameSize.height;
        videoBox.origin.x = (parentFrameSize.width - videoBox.size.width) / 2;
        videoBox.origin.y = (videoBox.size.height - parentFrameSize.height) / 2;
        
        xScale = videoBox.size.width / clap.size.width;
        yScale = videoBox.size.height / clap.size.height;
    } else {
        videoBox.size.width = parentFrameSize.width;
        videoBox.size.height = clap.size.width * (parentFrameSize.width / clap.size.height);
        videoBox.origin.x = (videoBox.size.width - parentFrameSize.width) / 2;
        videoBox.origin.y = (parentFrameSize.height - videoBox.size.height) / 2;
        
        xScale = videoBox.size.width / clap.size.height;
        yScale = videoBox.size.height / clap.size.width;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Remove previously added feature views.
        for (UIView *featureView in self.overlayView.subviews) {
            [featureView removeFromSuperview];
        }
        
        // Display detected features in overlay.
        for (GMVFaceFeature *face in faces) {
            
            // Mouth
            if (face.hasBottomMouthPosition) {
                CGPoint point = [self scaledPoint:face.bottomMouthPosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor greenColor]
                                      withRadius:5];
            }
            if (face.hasMouthPosition) {
                CGPoint point = [self scaledPoint:face.mouthPosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor greenColor]
                                      withRadius:10];
            }
            if (face.hasRightMouthPosition) {
                CGPoint point = [self scaledPoint:face.rightMouthPosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor greenColor]
                                      withRadius:5];
            }
            if (face.hasLeftMouthPosition) {
                CGPoint point = [self scaledPoint:face.leftMouthPosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor greenColor]
                                      withRadius:5];
            }
            
            // Nose
            if (face.hasNoseBasePosition) {
                CGPoint point = [self scaledPoint:face.noseBasePosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor darkGrayColor]
                                      withRadius:10];
            }
            
            // Eyes
            if (face.hasLeftEyePosition) {
                CGPoint point = [self scaledPoint:face.leftEyePosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor blueColor]
                                      withRadius:10];
            }
            
            if (face.hasRightEyePosition) {
                CGPoint point = [self scaledPoint:face.rightEyePosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor blueColor]
                                      withRadius:10];
            }
            
            // Ears
            if (face.hasLeftEarPosition) {
                CGPoint point = [self scaledPoint:face.leftEarPosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor purpleColor]
                                      withRadius:10];
            }
            if (face.hasRightEarPosition) {
                CGPoint point = [self scaledPoint:face.rightEarPosition
                                           xScale:xScale
                                           yScale:yScale
                                           offset:videoBox.origin];
                [DrawingUtility addCircleAtPoint:point
                                          toView:self.overlayView
                                       withColor:[UIColor purpleColor]
                                      withRadius:10];
            }
            
            if (face.hasSmilingProbability) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(videoBox.origin.x, videoBox.origin.y, 200, 20)];
                label.text = [NSString stringWithFormat:@"微笑: %.2f", face.smilingProbability];
                label.textColor = [UIColor redColor];
                [self.overlayView addSubview:label];
                if (self.mainNode) {
                    // 狗
                    CGFloat halfOpen = 1.0f - fabs(((1.0f - face.smilingProbability) - 0.5f)/0.5f);
                    CGFloat raw = (1.0f - face.smilingProbability - 0.5f)/0.5f;
                    CGFloat close = raw<0.0f ? 0.0f : raw;
                    close = close>1.0f ? 1.0f : close;
//                    [SCNTransaction begin];
//                    [SCNTransaction setAnimationDuration:0.05];

                    [self.mainNode.morpher setWeight:(halfOpen) forTargetAtIndex:2];
                    [self.mainNode.morpher setWeight:(close) forTargetAtIndex:3];
                    
                    // 马
//                    [self.mainNode.morpher setWeight:(1.0f - face.smilingProbability) forTargetAtIndex:2];
//                    [SCNTransaction commit];
                }
            }
            
            if (face.hasLeftEyeOpenProbability) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(videoBox.origin.x, videoBox.origin.y + 20, 200, 20)];
                label.text = [NSString stringWithFormat:@"左眼睁: %.2f", face.leftEyeOpenProbability];
                label.textColor = [UIColor redColor];
                [self.overlayView addSubview:label];
                
                if (self.mainNode) {
//                    [SCNTransaction begin];
//                    [SCNTransaction setAnimationDuration:0.05];
                    [self.mainNode.morpher setWeight:(1.0 - face.leftEyeOpenProbability) forTargetAtIndex:0];
//                    [SCNTransaction commit];
                }
            }
            
            if (face.hasRightEyeOpenProbability) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(videoBox.origin.x, videoBox.origin.y + 40, 200, 20)];
                label.text = [NSString stringWithFormat:@"右眼睁: %.2f", face.rightEyeOpenProbability];
                label.textColor = [UIColor redColor];
                [self.overlayView addSubview:label];
                if (self.mainNode) {
//                    [SCNTransaction begin];
//                    [SCNTransaction setAnimationDuration:0.05];
                    [self.mainNode.morpher setWeight:(1.0 - face.rightEyeOpenProbability) forTargetAtIndex:1];
//                    [SCNTransaction commit];
                }
            }
            
            if (face.hasHeadEulerAngleZ || face.hasHeadEulerAngleY) {
                if (self.neckNode) {
                    // Dog的模型定义x轴和z轴搞反了
                    self.neckNode.eulerAngles = SCNVector3Make((face.headEulerAngleZ * M_PI)/180.0f, (face.headEulerAngleY * M_PI)/180.0f, self.neckNode.eulerAngles.z);
                }
            }
        }
    });
}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//
//    BOOL isFront = self.device.position == AVCaptureDevicePositionFront;
//
//    [[FaceInTracker sharedTracker] trackingFaceWithSampleBuffer:sampleBuffer andIsFront:isFront];
//}

#pragma mark -

-(void)renderer:(id<SCNSceneRenderer>)renderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time{
    
//    [scene.scene snapshot];
//    SCNView *scnView = [[SCNView alloc] initWithFrame:self.view.bounds];
//
//    [_gifArr addObject:[self.scnView snapshot]];
   

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    });
}


#pragma mark -
#pragma mark FaceInTrackerDelegate
//- (void)trackerGetLandmarksWithFaces:(NSArray *)faces andScore:(CGFloat)score andRoll:(CGFloat)roll andYaw:(CGFloat)yaw andPitch:(CGFloat)pitch{
//    if (!faces || faces.count == 0) {
//        return;
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - getter/setter
- (dispatch_queue_t)videoDataOutputQueue {
    if (!_videoDataOutputQueue) {
        _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _videoDataOutputQueue;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        NSDictionary *rgbOutputSettings = @{
                                            (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
                                            };
        [_videoDataOutput setVideoSettings:rgbOutputSettings];
    }
    return _videoDataOutput;
}

- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [UIView new];
        _overlayView.frame = self.captureVideoPreviewLayer.frame;
    }
    return _overlayView;
}

-(SCNView *)scnView{
    if (!_scnView) {
        _scnView = [[SCNView alloc]initWithFrame:self.view.bounds];
        _scnView.delegate = self;
    }
    return _scnView;
}


@end
