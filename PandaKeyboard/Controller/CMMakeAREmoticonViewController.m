//
//  CMMakeAREmoticonViewController.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

@import GoogleMobileVision;

#import "CMMakeAREmoticonViewController.h"
#import <SceneKit/SceneKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DrawingUtility.h"
#import "CMPreviewAREmoticonViewController.h"
#import "CMScreenRecordManager.h"
#import "CMHostInfoc.h"

#define CircleUpdateTimeInterval    0.03

@interface CMAREmoticonStyleCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CMAREmoticonStyleCell

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.selectedImageView];
        [self.contentView addSubview:self.imageView];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectedImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.imageView.frame = CGRectMake(self.bounds.size.width * 0.08, self.bounds.size.height * 0.08, self.bounds.size.width * 0.84, self.bounds.size.height * 0.84);
    }
    return self;
}

#pragma mark - getter/setter
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIImageView *)selectedImageView
{
    if (!_selectedImageView) {
        _selectedImageView = [UIImageView new];
        _selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _selectedImageView;
}

@end

@interface CMMakeAREmoticonViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate, SCNSceneRendererDelegate, CAAnimationDelegate> {

}

@property (nonatomic, strong) UIView *hintView;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) SCNView *scnView;
@property (nonatomic, strong) UICollectionView *styleCollectionView;
@property (nonatomic, strong) UIView *toolBarView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *makeAREmoticonBtn;
@property (nonatomic, strong) UIButton *switchCameraBtn;// 暂时不允许切换前后摄像头

@property (nonatomic, strong)dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong)AVCaptureSession* session;
@property (nonatomic, strong)AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, assign)AVCaptureDevicePosition currentDevicePosition;

@property (nonatomic, strong)SCNNode* mainNode;
@property (nonatomic, strong)SCNNode* neckNode;

@property (nonatomic, strong)CAAnimation* leftEarAnim;
@property (nonatomic, strong)CAAnimation* rightEarAnim;

@property (assign, nonatomic)CGFloat headEulerAngleZBak;
@property (assign, nonatomic)CGFloat headEulerAngleYBak;

// Detector.
@property (nonatomic, strong)GMVDetector *faceDetector;

@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, assign)double addProgressAngle;

@property (nonatomic, assign)NSTimeInterval lastAnimTime;

@property (nonatomic, strong) NSIndexPath *lastSelectedStylePath;

@property (nonatomic, assign) BOOL isRecording;

@end

@implementation CMMakeAREmoticonViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.toolBarView.frame = CGRectMake(0, self.view.bounds.size.height - 160.0f, self.view.bounds.size.width, 160.0f);
    
    self.backBtn.frame = CGRectMake(44.0f, 65.0f, 30.0f, 30.0f);
    self.makeAREmoticonBtn.frame = CGRectMake(( self.view.bounds.size.width - 70.0f ) / 2 , 45.0f, 70.0f, 70.0f);
//    self.switchCameraBtn.frame = CGRectMake(self.view.bounds.size.width - 44.0f - 30.0f, 65.0f, 30.0f, 30.0f);
    
    self.styleCollectionView.frame = CGRectMake(0, self.view.bounds.size.height - self.toolBarView.bounds.size.height - 77.0f, self.view.bounds.size.width, 77.0f);
    CGFloat scnViewSize = self.view.bounds.size.width * 0.65;
    self.scnView.frame = CGRectMake((self.view.bounds.size.width - scnViewSize) / 2, (self.styleCollectionView.frame.origin.y - scnViewSize) / 2, scnViewSize, scnViewSize);
    
    [self.hintView addSubview:self.hintLabel];
    
    [self.view addSubview:self.hintView];
    [self.view addSubview:self.scnView];
    [self.view addSubview:self.styleCollectionView];
    [self.view addSubview:self.toolBarView];
    
    [self.toolBarView addSubview:self.backBtn];
    [self.toolBarView addSubview:self.makeAREmoticonBtn];
//    [self.toolBarView addSubview:self.switchCameraBtn];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, self.styleCollectionView.frame.size.height - 0.95, self.styleCollectionView.frame.size.width, 0.95);
    layer.backgroundColor = [UIColor colorWithRed:48 / 255.0f green:54 / 255.0f blue:83 / 255.0f alpha:1.0f].CGColor;
    [self.styleCollectionView.layer addSublayer:layer];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.styleCollectionView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    self.addProgressAngle = -90;
    self.isRecording = NO;
    
    [self setupSceneView];

     AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSInteger classType = 0;
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            classType = 1;
            break;
        case AVAuthorizationStatusDenied:
            classType = 2;
            break;
        case AVAuthorizationStatusAuthorized:
            classType = 3;
            break;
        default:
            break;
    }
    [CMHostInfoc reportCheetahkeyboard_ar_show:self.inway classType:classType];
    if (authStatus != AVAuthorizationStatusNotDetermined) {
        [self setupAVCapture];
    }
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [self addOpenCameraGuideView];
                    }
                    [self setupAVCapture];
                });
            }];
        }
            break;

        case AVAuthorizationStatusDenied:
        {
            [self addOpenCameraGuideView];
        }
            break;

        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc {
    kLogTrace();
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.session startRunning];
    if (self.hintView.frame.origin.y == 0) {
        CGSize size = [self.hintLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 52.0f, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.hintLabel.font} context:nil].size;
        self.hintView.frame = CGRectMake(13.0f, 0, self.view.bounds.size.width - 26.0f, size.height + 30.0f);
        self.hintLabel.frame = CGRectMake(13.0f, 0, self.hintView.frame.size.width - 26.0f, size.height + 30.0f);

        [UIView animateWithDuration:0.5f animations:^{
            CGRect rect = self.hintView.frame;
            rect.origin.y = 20.0f;
            self.hintView.frame = rect;
        }];
    }
    
    if (_leftEarAnim) {
        _leftEarAnim.delegate = self;
    }
    
    if (_rightEarAnim) {
        _rightEarAnim.delegate = self;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.session stopRunning];

    
    if (_leftEarAnim) {
        _leftEarAnim.delegate = nil;
    }
    
    if (_rightEarAnim) {
        _rightEarAnim.delegate = nil;
    }
    
    if (self.backBtn.tag != 1000) {
        [CMHostInfoc reportCheetahkeyboard_ar_click:1];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    kLogTrace();
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)_appDidEnterBackgroundNotification {
    kLogTrace();
    if ([CMScreenRecordManager sharedInstance].isRecording) {
        [[CMScreenRecordManager sharedInstance] cancleScreenRecord];
        [self stopRecord:YES];
    }
}

#pragma mark -
- (void)addOpenCameraGuideView
{
    [self.toolBarView removeFromSuperview];
    
    UIView *guideView = [[UIView alloc] initWithFrame:self.toolBarView.frame];
    guideView.backgroundColor = [UIColor colorWithRed:13 / 255.0f green:18 / 255.0f blue:43 / 255.0f alpha:1.0f];
    [self.view addSubview:guideView];
    
    UILabel *guideTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15.0f, self.view.frame.size.width, 30.0f)];
    guideTitle.textColor = [UIColor whiteColor];
    guideTitle.textAlignment = NSTextAlignmentCenter;
    guideTitle.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0f];
    guideTitle.text = CMLocalizedString(@"Record Videos with CheetahKey", nil);
    [guideView addSubview:guideTitle];
    
    UILabel *guideMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 46.0f, self.view.frame.size.width, 50.0f)];
    guideMessage.textColor = [UIColor whiteColor];
    guideMessage.textAlignment = NSTextAlignmentCenter;
    guideMessage.numberOfLines = 0;
    guideTitle.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    guideMessage.text = CMLocalizedString(@"Allow access to your camera to start recording videos with CheetahKey.", nil);
    [guideView addSubview:guideMessage];
    
    UIButton *authBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    authBtn.frame = CGRectMake(( self.view.bounds.size.width - 222.0f ) / 2, 100.0f, 222.0f, 40.0f);
    authBtn.backgroundColor = [UIColor colorWithRed:52 / 255.0f green:255 / 255.0f blue:252 / 255.0f alpha:1.0f];
    authBtn.layer.cornerRadius = 20.0f;
    authBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    [authBtn setTitleColor:[UIColor colorWithRed:13 / 255.0f green:18 / 255.0f blue:43 / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [authBtn setTitle:CMLocalizedString(@"Allow Camera Access", nil) forState:UIControlStateNormal];
    [authBtn addTarget:self action:@selector(toAuth:) forControlEvents:UIControlEventTouchUpInside];
    [guideView addSubview:authBtn];
}

#pragma mark - setter/getter
- (SCNView *)scnView
{
    if (!_scnView) {
        // 创建一个用来展示场景的SCNView
        _scnView = [SCNView new];
        // 设置背景
        _scnView.backgroundColor = [UIColor clearColor];
        
        // 允许控制摄像机位置
        _scnView.allowsCameraControl = NO;
        
#ifdef DEBUG
        // 显示数据控制台
        _scnView.showsStatistics = YES;
#endif
    }
    return _scnView;
}

- (UICollectionView *)styleCollectionView
{
    if (!_styleCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _styleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_styleCollectionView registerClass:[CMAREmoticonStyleCell class] forCellWithReuseIdentifier:NSStringFromClass([CMAREmoticonStyleCell class])];
        _styleCollectionView.backgroundColor = [UIColor colorWithRed:13 / 255.0f green:18 / 255.0f blue:43 / 255.0f alpha:1.0f];
        _styleCollectionView.delegate = self;
        _styleCollectionView.dataSource = self;
    }
    return _styleCollectionView;
}

- (UIView *)toolBarView
{
    if (!_toolBarView) {
        _toolBarView = [UIView new];
        _toolBarView.backgroundColor = [UIColor colorWithRed:13 / 255.0f green:18 / 255.0f blue:43 / 255.0f alpha:1.0f];
    }
    return _toolBarView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.tag = 0;
        [_backBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)makeAREmoticonBtn
{
    if (!_makeAREmoticonBtn) {
        _makeAREmoticonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_makeAREmoticonBtn setImage:[UIImage imageNamed:@"make_video_icon"] forState:UIControlStateNormal];
        [_makeAREmoticonBtn addTarget:self action:@selector(makeAREmoticon:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _makeAREmoticonBtn;
}

- (UIButton *)switchCameraBtn
{
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchCameraBtn.tag = 0;
        [_switchCameraBtn setImage:[UIImage imageNamed:@"switch_camera_icon"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (UIView *)hintView
{
    if (!_hintView) {
        _hintView = [UIView new];
        _hintView.backgroundColor = [UIColor colorWithRed:48 / 255.0f green:54 / 255.0f blue:83 / 255.0f alpha:1.0f];
        _hintView.layer.cornerRadius = 6.0f;
        
        _hintView.layer.shadowOffset = CGSizeMake(0, 8);
        _hintView.layer.shadowOpacity = 0.2;
    }
    return _hintView;
}

- (UILabel *)hintLabel
{
    if (!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.numberOfLines = 0;
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.font = [UIFont systemFontOfSize:14.0f];
        _hintLabel.text = CMLocalizedString(@"WINK, SMILE or MOVE your head. Whatever you like.", nil);
        _hintLabel.textColor = [UIColor whiteColor];
    }
    return _hintLabel;
}

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
        [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    }
    return _videoDataOutput;
}

- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _session;
}

#pragma mark - Action
- (void)back:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)makeAREmoticon:(UIButton *)sender
{
    self.styleCollectionView.userInteractionEnabled = NO;

    if (self.addProgressAngle == -90) {
        // 开始录制
        [CMHostInfoc reportCheetahkeyboard_ar_click:2];
        [self startRecord];
    }else{
        // 录制过程中 再次点击该按钮 停止录制
        [self stopRecord:NO];
    }
}

- (void)startRecord
{
    if (self.timer) {
        return;
    }
    
    if (self.isRecording) {
        return;
    }
    
    [self.hintView removeFromSuperview];
    
    self.backBtn.hidden = YES;
//    self.switchCameraBtn.hidden = YES;
    [self.makeAREmoticonBtn setImage:[UIImage imageNamed:@"make_video_start_icon"] forState:UIControlStateNormal];
    
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = self.makeAREmoticonBtn.bounds;
    [self.makeAREmoticonBtn.layer addSublayer:backLayer];
    backLayer.fillColor = [UIColor clearColor].CGColor;
    backLayer.strokeColor = [UIColor colorWithRed:58 / 255.0f green:61 / 255.0f blue:95 / 255.0f alpha:1.0f].CGColor;
    backLayer.lineWidth = 5;
    backLayer.lineCap = kCALineCapRound;
    UIBezierPath *backPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.makeAREmoticonBtn.bounds.size.width / 2, self.makeAREmoticonBtn.bounds.size.height / 2) radius:self.makeAREmoticonBtn.bounds.size.width / 2 startAngle:0 endAngle:(M_PI * 2) clockwise:YES];
    backLayer.path = backPath.CGPath;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.makeAREmoticonBtn.bounds;
    [self.makeAREmoticonBtn.layer addSublayer:layer];
    
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor colorWithRed:44 / 255.0f green:255 / 255.0f blue:253 / 255.0f alpha:1.0f].CGColor;
    layer.lineWidth = 5;
    layer.lineCap = kCALineCapRound;
    
    [[CMScreenRecordManager sharedInstance] startScreenRecord:self.scnView channel:ScreenRecordChannleByImage];
//    [[CMScreenRecordManager sharedInstance] startScreenRecord:self.scnView channel:ScreenRecordChannleByVideo];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:CircleUpdateTimeInterval target:self selector:@selector(drawProgressCircle:) userInfo:@{@"backLayer": backLayer, @"layer": layer} repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopRecord:(BOOL)forceCancel
{
    CAShapeLayer *backLayer = self.timer.userInfo[@"backLayer"];
    CAShapeLayer *layer = self.timer.userInfo[@"layer"];
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (forceCancel) {
        self.backBtn.hidden = NO;
        //        self.switchCameraBtn.hidden = NO;
        [self.makeAREmoticonBtn setImage:[UIImage imageNamed:@"make_video_icon"] forState:UIControlStateNormal];
        [layer removeFromSuperlayer];
        [backLayer removeFromSuperlayer];

        self.addProgressAngle = -90;

        [self.scnView makeToast:CMLocalizedString(@"Oops... an error occurred. Please try again.", nil) duration:2.0f position:CSToastPositionTop];
        self.styleCollectionView.userInteractionEnabled = YES;
        
        self.isRecording = NO;
        return;
    }
    
    // loading
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    activityIndicatorView.center = self.scnView.center;
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicatorView.alpha = 0.87;
    activityIndicatorView.backgroundColor = [UIColor blackColor];
    activityIndicatorView.layer.masksToBounds = YES;
    activityIndicatorView.layer.cornerRadius = 6.0f;
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    [[CMScreenRecordManager sharedInstance] stopScreenRecord:^(NSURL * _Nullable gifPath) {
        self.backBtn.hidden = NO;
//        self.switchCameraBtn.hidden = NO;
        [self.makeAREmoticonBtn setImage:[UIImage imageNamed:@"make_video_icon"] forState:UIControlStateNormal];
        [layer removeFromSuperlayer];
        [backLayer removeFromSuperlayer];
        
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        
        // 上报埋点
        NSInteger videtime = round((self.addProgressAngle + 90) / 2 * CircleUpdateTimeInterval);
        [CMHostInfoc reportCheetahkeyboard_ar_done:videtime anim:self.styleCollectionView.indexPathsForSelectedItems.firstObject.row + 1];
        
        self.addProgressAngle = -90;

        if ([[NSFileManager defaultManager] fileExistsAtPath:gifPath.path]) {
            // gif生成成功
            self.backBtn.tag = 1000; // 表示录制完毕进入animoji预览页面

            // 跳到Preview页面
            CMPreviewAREmoticonViewController *previewAREmoticonVC = [[CMPreviewAREmoticonViewController alloc] initWithGifFilePath:gifPath];
            [self.navigationController pushViewController:previewAREmoticonVC animated:YES];
        }else{
            [self.scnView makeToast:CMLocalizedString(@"Oops... an error occurred. Please try again.", nil) duration:2.0f position:CSToastPositionTop];
        }
        
        self.styleCollectionView.userInteractionEnabled = YES;
        
        self.isRecording = NO;
    }];
}

- (void)drawProgressCircle:(NSTimer *)timer
{
    CAShapeLayer *layer = timer.userInfo[@"layer"];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.makeAREmoticonBtn.bounds.size.width / 2, self.makeAREmoticonBtn.bounds.size.height / 2) radius:self.makeAREmoticonBtn.bounds.size.width / 2 startAngle:(M_PI * (-90) / 180.0) endAngle:(M_PI * (self.addProgressAngle) / 180.0) clockwise:YES];
    layer.path = path.CGPath;
    if (self.addProgressAngle == 270) {
        [self stopRecord:NO];
    }else{
        self.addProgressAngle += 2;
    }
}

- (void)switchCamera:(UIButton *)sender
{
    [CMHostInfoc reportCheetahkeyboard_ar_click:3];
    
    if (self.switchCameraBtn.tag == 0) {
        self.switchCameraBtn.tag = 1000;
        [self updateCameraSelection:AVCaptureDevicePositionBack];
    }else{
        self.switchCameraBtn.tag = 0;
        [self updateCameraSelection:AVCaptureDevicePositionFront];
    }
}

- (void)toAuth:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark -
- (void)setupSceneView
{
    // 初始化一个场景
    //    获取资源
    NSString *scneSoureName = nil;
    NSString *extension = @"scn";
    NSInteger selectedIndex = self.styleCollectionView.indexPathsForSelectedItems.firstObject.row;
    switch (selectedIndex) {
        case 0:
            // 狗
            scneSoureName = @"Dog";
            extension = @"dae";
            break;
        case 1:
            // 马
            scneSoureName = @"Horse_NoBlendWithGeo3";
            break;
        case 2:
            break;
        default:
            break;
    }
    
    SCNSceneSource *scneSoure = [SCNSceneSource sceneSourceWithURL:[[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"scenekit.scnassets/%@", scneSoureName] withExtension:extension] options:nil];
    SCNScene *scene = [scneSoure sceneWithOptions:nil error:nil];
    scene.background.contents = [UIColor clearColor];
    
    // 创建一个摄像机并放入场景中
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // 摆放摄像机位置
    switch (selectedIndex) {
        case 0:
            cameraNode.position = SCNVector3Make(0, 13, 30);
            break;
        case 1:
            cameraNode.position = SCNVector3Make(0, 13, 25);
            break;
            
        default:
            break;
    }
//
    cameraNode.camera.zFar = 300;
    
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor colorWithRed:0.5F green:0.5F blue:0.5F alpha:1.F];
    [scene.rootNode addChildNode:ambientLightNode];
    
    switch (selectedIndex) {
        case 0:
            {
                // 狗
                self.mainNode = [scene.rootNode childNodeWithName:@"Dog" recursively:YES];
                UIImage* skin = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dog_skin_2bit_rgba" ofType:@"pvr"]];
                if (!skin) {
                    skin = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dog_skin@2x" ofType:@"png"]];
                }
                self.mainNode.geometry.firstMaterial.diffuse.contents = skin;
                
                SCNNode *leftEyeMesh = [scene.rootNode childNodeWithName:@"Dog_BlinkLShapeMesh" recursively:YES];
                SCNNode *rightEyeMesh = [scene.rootNode childNodeWithName:@"Dog_BlinkRShapeMesh" recursively:YES];
                SCNNode *mouthHalfCloseMesh = [scene.rootNode childNodeWithName:@"Dog_MouthHalfCloseShapeMesh" recursively:YES];
                SCNNode *mouthFullCloseMesh = [scene.rootNode childNodeWithName:@"Dog_MouthFullCloseShapeMesh" recursively:YES];
                
                self.mainNode.morpher = [[SCNMorpher alloc] init];
                self.mainNode.morpher.targets = [NSArray arrayWithObjects: leftEyeMesh.geometry, rightEyeMesh.geometry, mouthHalfCloseMesh.geometry, mouthFullCloseMesh.geometry, nil];
                
                self.neckNode = [scene.rootNode childNodeWithName:@"Neck" recursively:YES];
                
                self.headEulerAngleZBak = self.neckNode.eulerAngles.x;
                self.headEulerAngleYBak = self.neckNode.eulerAngles.y;
                
                self.leftEarAnim = [self loadAnimationFromSceneNamed:@"Dog@DogLEar_Fix"];
                self.rightEarAnim = [self loadAnimationFromSceneNamed:@"Dog@DogREar_Fix"];
                if (self.leftEarAnim) {
                    self.leftEarAnim.repeatCount = 1;
                    self.leftEarAnim.delegate = self;
                }
                
                if (self.rightEarAnim) {
                    self.rightEarAnim.repeatCount = 1;
                    self.rightEarAnim.delegate = self;
                }
            }
            break;
            
        case 1:
        {
            // 马
            self.mainNode = [scene.rootNode childNodeWithName:@"Horse_base" recursively:YES];
            
            UIImage* skin = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"horse_skin_2bit_rgba" ofType:@"pvr"]];
            if (!skin) {
                skin = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"horse_skin@2x" ofType:@"png"]];
            }

            self.mainNode.geometry.firstMaterial.diffuse.contents = skin;

            SCNNode *leftEyeMesh = [scene.rootNode childNodeWithName:@"Horse_BlinkLMesh" recursively:YES];
            SCNNode *rightEyeMesh = [scene.rootNode childNodeWithName:@"Horse_BlinkRMesh" recursively:YES];
            SCNNode *mouthCloseMesh = [scene.rootNode childNodeWithName:@"Horse_MouthCloseMesh" recursively:YES];
            self.mainNode.morpher = [[SCNMorpher alloc] init];
            self.mainNode.morpher.targets = [NSArray arrayWithObjects: leftEyeMesh.geometry, rightEyeMesh.geometry, mouthCloseMesh.geometry, nil];

            self.neckNode = [scene.rootNode childNodeWithName:@"Neck" recursively:YES];
            
            self.leftEarAnim = nil;
            self.rightEarAnim = nil;
        }
            break;
            
        default:
            break;
    }
    
    // 设置场景
    _scnView.scene = scene;
    _scnView.delegate = self;
    self.lastAnimTime = 0.0f;
    
    if ([UIDevice systemMajorVersion] < 10 || ([UIDevice systemMajorVersion] == 10 && [UIDevice systemMinorVersion] < 2)) {
        AVAudioEngine *audioEngine = [self.scnView audioEngine]; // https://stackoverflow.com/questions/39543083/avfaudio-playback-crash-on-ios-10
//        [self.scnView audioEngine]; // https://stackoverflow.com/questions/39543083/avfaudio-playback-crash-on-ios-10
    }
}

- (void)setupAVCapture
{
    [self updateCameraSelection:AVCaptureDevicePositionFront];
    
    // Setup video processing pipeline.
    [self setupVideoProcessing];
    
    // Initialize the face detector.
    NSDictionary *options = @{
                              GMVDetectorFaceMinSize : @(0.3),
                              GMVDetectorFaceMode : @(GMVDetectorFaceFastMode),
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
    [self.session addOutput:self.videoDataOutput];
}

- (void)updateCameraSelection:(AVCaptureDevicePosition)desiredPosition {
    [self.session beginConfiguration];
    
    self.currentDevicePosition = desiredPosition;
    
    // Remove old inputs
    NSArray *oldInputs = [self.session inputs];
    for (AVCaptureInput *oldInput in oldInputs) {
        [self.session removeInput:oldInput];
    }
    AVCaptureDeviceInput *input = [self cameraForPosition:desiredPosition];
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

- (void)cleanupVideoProcessing {
    if (self.videoDataOutput) {
        [self.session removeOutput:self.videoDataOutput];
    }
    self.videoDataOutput = nil;
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    UIImage *image = [GMVUtility sampleBufferTo32RGBA:sampleBuffer];
    
    // Establish the image orientation.
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:self.currentDevicePosition
                                       defaultDeviceOrientation:UIDeviceOrientationPortrait];
    NSDictionary *options = @{
                              GMVDetectorImageOrientation : @(orientation)
                              };
    // Detect features using GMVDetector.
    NSArray<GMVFaceFeature *> *faces = [self.faceDetector featuresInImage:image options:options];

    dispatch_sync(dispatch_get_main_queue(), ^{
        for (GMVFaceFeature *face in faces) {
            if (face.hasSmilingProbability) {
                if (self.mainNode) {
                    NSInteger selectedIndex = self.styleCollectionView.indexPathsForSelectedItems.firstObject.row;
                    switch (selectedIndex) {
                        case 0:
                            // 狗
                        {
                            CGFloat halfOpen = 1.0f - fabs(((1.0f - face.smilingProbability) - 0.5f)/0.5f);
                            CGFloat raw = (1.0f - face.smilingProbability - 0.5f)/0.5f;
                            CGFloat close = raw<0.0f ? 0.0f : raw;
                            close = close>1.0f ? 1.0f : close;
                            
                            [self.mainNode.morpher setWeight:(halfOpen) forTargetAtIndex:2];
                            [self.mainNode.morpher setWeight:(close) forTargetAtIndex:3];
                        }
                            break;
                        
                        case 1:
                        {
                            [self.mainNode.morpher setWeight:(1.0f - face.smilingProbability) forTargetAtIndex:2];
                            break;
                        }
                            
                        default:
                            break;
                    }
                }
            }
            
            if (face.hasLeftEyeOpenProbability) {
                if (self.mainNode) {
                    [self.mainNode.morpher setWeight:(1.0 - face.leftEyeOpenProbability) forTargetAtIndex:0];
                }
            }
            
            if (face.hasRightEyeOpenProbability) {
                if (self.mainNode) {
                    [self.mainNode.morpher setWeight:(1.0 - face.rightEyeOpenProbability) forTargetAtIndex:1];
                }
            }
            
            if (face.hasHeadEulerAngleZ || face.hasHeadEulerAngleY) {
                if (self.neckNode) {
                    CGFloat threshold = 0.03f;
                    CGFloat eulerX = self.headEulerAngleZBak;
                    CGFloat eulerY = self.headEulerAngleYBak;
                    if (fabs((face.headEulerAngleZ * M_PI)/180.0f - self.headEulerAngleZBak) >= threshold) {
                        eulerX = (face.headEulerAngleZ * M_PI)/180.0f;
                        self.headEulerAngleZBak = eulerX;
                    }
                    
                    if (fabs((face.headEulerAngleY * M_PI)/180.0f - self.headEulerAngleYBak) >= threshold) {
                        eulerY = (face.headEulerAngleY * M_PI)/180.0f;
                        self.headEulerAngleYBak = eulerY;
                    }

                    self.neckNode.eulerAngles = SCNVector3Make(eulerX, eulerY, self.neckNode.eulerAngles.z);
                }
            }
        }
    });
}

- (CAAnimation *)loadAnimationFromSceneNamed:(NSString *)sceneName {
    SCNSceneSource *scneSoure = [SCNSceneSource sceneSourceWithURL:[[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"scenekit.scnassets/%@", sceneName] withExtension:@"dae"] options:nil];
    SCNScene *scene = [scneSoure sceneWithOptions:nil error:nil];
    
    // find top level animation
    __block CAAnimation *animation = nil;
    [scene.rootNode enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
        if (child.animationKeys.count > 0) {
            animation = [child animationForKey:child.animationKeys[0]];
            *stop = YES;
        }
    }];
    
    return animation;
}


#pragma mark FaceInTrackerDelegate
- (void)trackerGetLandmarksWithFaces:(NSArray *)faces andScore:(CGFloat)score andRoll:(CGFloat)roll andYaw:(CGFloat)yaw andPitch:(CGFloat)pitch{
    if (!faces || faces.count == 0) {
        return;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMAREmoticonStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMAREmoticonStyleCell class]) forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ar_emoticon_icon_%ld", (long)indexPath.row]];
    if (!self.lastSelectedStylePath && indexPath.row == 0) {
        cell.selectedImageView.image = [UIImage imageNamed:@"ar_emoticon_selected_icon"];
        self.lastSelectedStylePath = indexPath;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(67.0f, 67.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.lastSelectedStylePath.row) {
        return;
    }
    
    switch (indexPath.row) {
        case 0:
            [CMHostInfoc reportCheetahkeyboard_ar_click:4];
            break;
        case 1:
            [CMHostInfoc reportCheetahkeyboard_ar_click:5];
            break;
            
        default:
            break;
    }
    
    self.makeAREmoticonBtn.userInteractionEnabled = NO;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    activityIndicatorView.center = self.view.center;
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicatorView.alpha = 0.87;
    activityIndicatorView.backgroundColor = [UIColor blackColor];
    activityIndicatorView.layer.masksToBounds = YES;
    activityIndicatorView.layer.cornerRadius = 6.0f;
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupSceneView];
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        
        self.makeAREmoticonBtn.userInteractionEnabled = YES;

        CMAREmoticonStyleCell *lastSelectedCell = (CMAREmoticonStyleCell *)[self.styleCollectionView cellForItemAtIndexPath:self.lastSelectedStylePath];
        lastSelectedCell.selectedImageView.image = nil;
        
        CMAREmoticonStyleCell *cell = (CMAREmoticonStyleCell *)[self.styleCollectionView cellForItemAtIndexPath:indexPath];
        cell.selectedImageView.image = [UIImage imageNamed:@"ar_emoticon_selected_icon"];
        
        self.lastSelectedStylePath = indexPath;
    });
}

#pragma mark - SCNSceneRendererDelegate
- (void)renderer:(id <SCNSceneRenderer>)renderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    if (!self.leftEarAnim || !self.rightEarAnim || !self.neckNode) {
        return;
    }
    
    if (self.lastAnimTime <= 0.0f) {
        self.lastAnimTime = time;
    }
    
    if ((time - self.lastAnimTime) >= 5) {
        [self.neckNode addAnimation:self.leftEarAnim forKey:@"LeftEar"];
        [self.neckNode addAnimation:self.rightEarAnim forKey:@"RightEar"];
        self.lastAnimTime = time;
    }
}

#pragma mark - applicationEnterBackground


#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }
    if (anim == self.leftEarAnim) {
        [self.neckNode removeAnimationForKey:@"LeftEar"];
    }
    else if (anim == self.rightEarAnim) {
        [self.neckNode removeAnimationForKey:@"RightEar"];
    }
}

#pragma mark - Autorotate
- (BOOL) shouldAutorotate
{
    return NO;
}

@end
