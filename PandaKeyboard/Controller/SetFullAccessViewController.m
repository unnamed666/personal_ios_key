//
//  SetFullAccessViewController.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/19.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "SetFullAccessViewController.h"
#import "SwitchKeyboardViewController.h"
//#import "VideoPlayerView.h"
#import "CMGroupDataManager.h"
#import "CMAppConfig.h"
#import "CMBizHelper.h"
#import "UIImage+Util.h"
#import "CMHostInfoc.h"
#import "UIView+Animate.h"
#import "CMPlayerView.h"
#import "UIDevice+Util.h"
#import "CMInappController.h"

static BOOL isScreenLocked = NO;

static NSString* const kFullAccessPageIsFirstShow = @"kFullAccessPageIsFirstShow";

@interface SetFullAccessViewController ()<CMPlayerViewDelegate>

@property (nonatomic, assign)BOOL isFirstShow;
@property (nonatomic, strong) UIColor* mainColor;

@property(nonatomic ,strong) UILabel* titleLabel;
@property(nonatomic ,strong) UIButton *skipButton;

@property (nonatomic, strong) UIView* videoWrapView;
@property(strong , nonatomic) CMPlayerView * videoPlayer;

@property (nonatomic, strong) UIButton* stepOneIconButton;
@property (nonatomic, strong) UILabel* stepOnePartOneLabel;
@property (nonatomic, strong) UILabel* stepOnePartTwoLabel;

@property (nonatomic, strong) UIButton* stepTwoIconButton;
@property (nonatomic, strong) UILabel* stepTwoPartOneLabel;
@property (nonatomic, strong) UILabel* stepTwoPartTwoLabel;

@property (nonatomic, strong) UIButton* openFullAccessButton;

@property (nonatomic, strong) UIImageView* iconImgView;
@property (nonatomic, strong) UILabel* bottomLabel;

//@property (nonatomic) CGFloat maxScreenForSuit;
//@property (nonatomic) CGFloat fStepTextSize;

@property (nonatomic) BOOL isUseABTest;

@end

@implementation SetFullAccessViewController

- (void) registJumpNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    NSString* notif1 = [NSString stringWithFormat:@"co%@a%@pri%@rd.lo%@ete", @"m.", @"pple.s", @"ngboa", @"ckcompl"];
    NSString* notif2 = [NSString stringWithFormat:@"c%@le.%@ngbo%@kst%@", @"om.app", @"spri", @"ard.loc", @"ate"];
    
    CFStringRef str1Ref = (__bridge CFStringRef)notif1;
    CFStringRef str2Ref = (__bridge CFStringRef)notif2;
    
    
    //Screen lock notifications
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    "observer identifier", // observer
                                    displayStatusChanged, // callback
                                    str1Ref, // event name
                                    NULL, // object
                                    4);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    "observer identifier", // observer
                                    displayStatusChanged, // callback
                                    str2Ref, // event name
                                    NULL, // object
                                    4);
    
}


static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *lockState = (__bridge NSString*)name;
    NSString* notif1 = [NSString stringWithFormat:@"co%@a%@pri%@rd.lo%@ete", @"m.", @"pple.s", @"ngboa", @"ckcompl"];
    
    if([lockState isEqualToString:notif1])
    {
        isScreenLocked = YES;
    }
}

- (void)applicationEnteredBackground:(NSNotification *)notification
{
    
}

- (void)applicationEnteredForeground:(NSNotification *)notification
{
    //[self.videoPlayer.player play];
    
    if (!isScreenLocked)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    isScreenLocked = NO;
}

- (void)dealloc
{
    [self.openFullAccessButton removeAllAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFullAccessPageIsFirstShow] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFullAccessPageIsFirstShow];
    }
    
    self.isFirstShow = [[NSUserDefaults standardUserDefaults] boolForKey:kFullAccessPageIsFirstShow];
    [CMHostInfoc reportCheetahkeyboard_activate_show:3 isFirstShow:self.isFirstShow];
    [self registJumpNotify];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFullAccessPageIsFirstShow];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), "observer identifier");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.openFullAccessButton heartBeat];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.openFullAccessButton removeAllAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIDevice isIpad])
    {
        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
    }
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"Splash_Back"].CGImage;
//    self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
    self.mainColor = [UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:255.0];
//    self.fStepTextSize = self.maxScreenForSuit/46.11;
//    self.fStepTextSize = KScalePt(14);
    
    self.isUseABTest = [CMBizHelper shouldUseABTestAtInitPage];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.skipButton];
    
    [self.view addSubview:self.videoWrapView];
    [self.view addSubview:self.videoPlayer];
    
    [self.view addSubview:self.stepOneIconButton];
    [self.view addSubview:self.stepOnePartOneLabel];
    [self.view addSubview:self.stepOnePartTwoLabel];
    
    [self.view addSubview:self.stepTwoIconButton];
    [self.view addSubview:self.stepTwoPartOneLabel];
    [self.view addSubview:self.stepTwoPartTwoLabel];
    
    [self.view addSubview:self.openFullAccessButton];
    
    UIView* bottomView = [UIView new];
    [bottomView addSubview:self.iconImgView];
    [bottomView addSubview:self.bottomLabel];
    
    [self.view addSubview:bottomView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
//         make.top.equalTo(self.view).with.offset(self.maxScreenForSuit/20);
         make.top.equalTo(self.view).with.offset(KScalePt(33));
         make.centerX.equalTo(self.view);
     }];
    
    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
//         make.top.equalTo(self.titleLabel).with.offset(self.maxScreenForSuit/45);
         make.top.equalTo(self.titleLabel).with.offset(KScalePt(14));
//         make.right.equalTo(self.view).with.offset(-self.maxScreenForSuit/38.11);
         make.right.equalTo(self.view).with.offset(-KScalePt(18));
     }];
    
    if (![CMBizHelper isiPhone]) {//ipad
        [self.videoWrapView mas_makeConstraints:^(MASConstraintMaker *make)
         {
//             make.top.equalTo(self.titleLabel.mas_bottom).with.offset(self.maxScreenForSuit/23);
             make.top.equalTo(self.titleLabel.mas_bottom).with.offset(KScalePt(29));
//             make.height.equalTo(@(self.maxScreenForSuit/1.93));
             make.height.equalTo(@(KScalePt(346)));
             make.centerX.equalTo(self.view);
         }];
        
        [self.videoPlayer mas_makeConstraints:^(MASConstraintMaker *make)
         {
//             make.edges.equalTo(self.videoWrapView).with.insets(UIEdgeInsetsMake(self.maxScreenForSuit/12.46, self.maxScreenForSuit/58, 0, self.maxScreenForSuit/58));
             make.edges.equalTo(self.videoWrapView).with.insets(UIEdgeInsetsMake(KScalePt(54), KScalePt(11), 0, KScalePt(11)));
         }];
    }else{
        [self.videoWrapView mas_makeConstraints:^(MASConstraintMaker *make)
         {
//             make.top.equalTo(self.titleLabel.mas_bottom).with.offset(self.maxScreenForSuit/23);
             make.top.equalTo(self.titleLabel.mas_bottom).with.offset(KScalePt(29));
//             make.height.equalTo(@(self.maxScreenForSuit/1.83));
             make.height.equalTo(@(KScalePt(365)));
//             make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, self.maxScreenForSuit/10.1, 0, self.maxScreenForSuit/10.1));
             make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, KScalePt(66), 0, KScalePt(66)));
         }];
        
        [self.videoPlayer mas_makeConstraints:^(MASConstraintMaker *make)
         {
//             make.left.right.bottom.equalTo(self.videoWrapView).insets(UIEdgeInsetsMake(0, self.maxScreenForSuit/58, 0, self.maxScreenForSuit/58));
             make.left.right.bottom.equalTo(self.videoWrapView).insets(UIEdgeInsetsMake(0, KScalePt(11), 0, KScalePt(11)));
//             make.height.equalTo(@(self.maxScreenForSuit/2.155));
             make.height.equalTo(@(KScalePt(310)));
         }];
        
    }
    
    [self.stepOneIconButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
//         make.width.height.equalTo(@(self.maxScreenForSuit/32));
         make.width.height.equalTo(@(KScalePt(20)));
//         make.top.equalTo(self.videoWrapView.mas_bottom).with.offset(self.maxScreenForSuit/18.2);
         make.top.equalTo(self.videoWrapView.mas_bottom).with.offset(KScalePt(37));
//         make.left.equalTo(self.view.mas_left).with.offset(self.maxScreenForSuit/15.00);
         make.left.equalTo(self.view.mas_left).with.offset(KScalePt(44));
     }];
    
    [self.stepOnePartOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.stepOneIconButton);
//         make.left.equalTo(self.stepOneIconButton.mas_right).with.offset(self.maxScreenForSuit/66.03);
         make.left.equalTo(self.stepOneIconButton.mas_right).with.offset(KScalePt(10));
     }];
    
    [self.stepOnePartTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepOnePartOneLabel);
         make.left.equalTo(_stepOnePartOneLabel.mas_right);
         make.right.lessThanOrEqualTo(self.view).with.offset(-KScalePt(40));
     }];
    
    [self.stepTwoIconButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(self.stepOneIconButton);
//         make.top.equalTo(_stepOneIconButton.mas_bottom).with.offset(self.maxScreenForSuit/44.46);
         make.top.equalTo(_stepOneIconButton.mas_bottom).with.offset(KScalePt(15));
         make.left.equalTo(_stepOneIconButton);
     }];
    
    [self.stepTwoPartOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepTwoIconButton);
//         make.left.equalTo(_stepTwoIconButton.mas_right).with.offset(self.maxScreenForSuit/66.03);
         make.left.equalTo(_stepTwoIconButton.mas_right).with.offset(KScalePt(10));
     }];
    
    [self.stepTwoPartTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepTwoPartOneLabel);
         make.left.equalTo(_stepTwoPartOneLabel.mas_right);
     }];
    
    [self.openFullAccessButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
//         make.top.equalTo(self.stepTwoIconButton.mas_bottom).with.offset(self.maxScreenForSuit/20.87);
         make.top.lessThanOrEqualTo(self.stepTwoIconButton.mas_bottom).with.offset(KScalePt(28));
//         make.height.equalTo(@(self.maxScreenForSuit/13.32));
         make.height.equalTo(@(KScalePt(50)));
//         make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, self.maxScreenForSuit/38.44, 0, self.maxScreenForSuit/38.44));
         make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, KScalePt(18), 0, KScalePt(18)));
     }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.greaterThanOrEqualTo(self.view.mas_leading).with.offset(self.maxScreenForSuit/23.69);
        make.leading.equalTo(self.view.mas_leading).with.offset(KScalePt(44));
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-KScalePt(18));
//        make.top.lessThanOrEqualTo(self.openFullAccessButton.mas_bottom).offset(self.maxScreenForSuit/60.09);
        make.top.lessThanOrEqualTo(self.openFullAccessButton.mas_bottom).offset(KScalePt(11));
        make.bottom.lessThanOrEqualTo(self.view.mas_bottom).offset(-KScalePt(10));
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make)
     {
//         make.width.equalTo(@(self.maxScreenForSuit/44.46));
         make.top.equalTo(bottomView);
         make.width.equalTo(@(KScalePt(15)));
//         make.height.equalTo(@(self.maxScreenForSuit/37.00));
         make.height.equalTo(@(KScalePt(18)));
         make.leading.equalTo(bottomView);
         make.bottom.lessThanOrEqualTo(bottomView.mas_bottom);
         
         //         make.top.equalTo(_openFullAccessButton.mas_bottom).with.offset(self.maxScreenForSuit/60.09);
         //         make.left.equalTo(self.view).with.offset(self.maxScreenForSuit/23.69);
     }];
    
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.iconImgView);
//         make.leading.equalTo(self.iconImgView.mas_trailing).with.offset(self.maxScreenForSuit/86.43);
         make.leading.equalTo(self.iconImgView.mas_trailing).with.offset(KScalePt(8));
         make.trailing.bottom.equalTo(bottomView);
//         make.right.lessThanOrEqualTo(self.view.mas_right).with.offset(-30);
     }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldSwipeBack {
    return NO;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = self.mainColor;
        _titleLabel.text = CMLocalizedString(@"Allow_Full_Access", nil);
//        _titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/37.7];
        _titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(18)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;;
    }
    
    return _titleLabel;
}

- (UIButton *)skipButton
{
    if (!_skipButton)
    {
        UIColor* normalColor = [UIColor colorWithRed:141.0/255.0 green:142.0/255.0 blue:155.0/255.0 alpha:1];
        UIColor* selectColor = [UIColor colorWithRed:70.0/255.0 green:71.0/255.0 blue:88.0/255.0 alpha:1];
        
        _skipButton = [[UIButton alloc] init];
        [_skipButton setTitleColor:normalColor forState:UIControlStateNormal];
        [_skipButton setTitleColor:selectColor forState:UIControlStateSelected];
        [_skipButton setTitleColor:selectColor forState:UIControlStateHighlighted];
//        _skipButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/46.11];
        _skipButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(15)];
        _skipButton.titleLabel.textColor = normalColor;
        [_skipButton setTitle:CMLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipCurrentController:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _skipButton;
}

- (void) skipCurrentController:(id) sender
{
    [CMHostInfoc reportcheetahkeyboard_activate_click:4 isFirstShow:self.isFirstShow];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)videoWrapView
{
    if (!_videoWrapView)
    {
        _videoWrapView = [[UIView alloc] init];
        _videoWrapView.layer.contents = (id)[UIImage imageNamed:@"Phone_Model"].CGImage;
    }
    
    return _videoWrapView;
}

- (CMPlayerView *)videoPlayer
{
    if (!_videoPlayer)
    {
        _videoPlayer = [[CMPlayerView alloc] init];
        _videoPlayer.delegate = self;
        _videoPlayer.backgroundColor = [UIColor whiteColor];
        _videoPlayer.coverImageString = @"Allow_Full_Access_cover";
    }
    
    return _videoPlayer;
}

//- (void)runLoopTheMovie:(NSNotification *)theNotify
//{
//    AVPlayerItem* thePlayer = [theNotify object];
//    [thePlayer seekToTime:kCMTimeZero];
//    [self.videoPlayer.player play];
//_playButton.hidden = NO;
//}

- (UIButton *)stepOneIconButton
{
    if (!_stepOneIconButton)
    {
        _stepOneIconButton = [[UIButton alloc] init];
        [_stepOneIconButton setBackgroundImage:[UIImage imageNamed:@"Add_Full_Setp_Icon_1"] forState:UIControlStateNormal];
    }
    
    return _stepOneIconButton;
}

- (UILabel *)stepOnePartOneLabel
{
    if (!_stepOnePartOneLabel)
    {
        _stepOnePartOneLabel = [[UILabel alloc] init];
        
        _stepOnePartOneLabel.textColor = [UIColor colorWithRed:140.0/255.0 green:141.0/255.0 blue:154.0/254.0 alpha:1];
        _stepOnePartOneLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(14)];
        _stepOnePartOneLabel.text = CMLocalizedString(@"Tap", nil);
        _stepOnePartOneLabel.textAlignment = NSTextAlignmentLeft;
        [_stepOnePartOneLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    return _stepOnePartOneLabel;
}

- (UILabel *)stepOnePartTwoLabel
{
    if (!_stepOnePartTwoLabel)
    {
        _stepOnePartTwoLabel = [[UILabel alloc] init];
        
        _stepOnePartTwoLabel.textColor = self.mainColor;
        _stepOnePartTwoLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(14)];
        if (self.isUseABTest)
        {
            _stepOnePartTwoLabel.text = CMLocalizedString(@"Keyboards", nil);
        }
        else
        {
            _stepOnePartTwoLabel.text = CMLocalizedString(@"Allow_Full_Access", nil);
        }
        _stepOnePartTwoLabel.textAlignment = NSTextAlignmentLeft;
        _stepOnePartTwoLabel.numberOfLines = 0;
        _stepOnePartTwoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return _stepOnePartTwoLabel;
}

- (UIButton *)stepTwoIconButton
{
    if (!_stepTwoIconButton)
    {
        _stepTwoIconButton = [[UIButton alloc] init];
        [_stepTwoIconButton setBackgroundImage:[UIImage imageNamed:@"Add_Full_Setp_Icon_2"] forState:UIControlStateNormal];
    }
    
    return _stepTwoIconButton;
}

- (UILabel *)stepTwoPartOneLabel
{
    if (!_stepTwoPartOneLabel)
    {
        _stepTwoPartOneLabel = [[UILabel alloc] init];
        
        _stepTwoPartOneLabel.textColor = [UIColor colorWithRed:140.0/255.0 green:141.0/255.0 blue:154.0/254.0 alpha:1];
        _stepTwoPartOneLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(14)];
        _stepTwoPartOneLabel.text = CMLocalizedString(@"Tap", nil);
        _stepTwoPartOneLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _stepTwoPartOneLabel;
}

- (UILabel *)stepTwoPartTwoLabel
{
    if (!_stepTwoPartTwoLabel)
    {
        _stepTwoPartTwoLabel = [[UILabel alloc] init];
        
        _stepTwoPartTwoLabel.textColor = self.mainColor;
        _stepTwoPartTwoLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(14)];
        if (self.isUseABTest)
        {
            _stepTwoPartTwoLabel.text = CMLocalizedString(@"Allow_Full_Access", nil);
        }
        else
        {
            _stepTwoPartTwoLabel.text = CMLocalizedString(@"Allow", nil);
        }
        _stepTwoPartTwoLabel.textAlignment = NSTextAlignmentLeft;
        _stepTwoPartTwoLabel.numberOfLines = 0;
        _stepTwoPartTwoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return _stepTwoPartTwoLabel;
}

- (UIButton *)openFullAccessButton
{
    if (!_openFullAccessButton)
    {
        UIColor* btnColor = [UIColor colorWithRed:17.0/255.0 green:0.0/255.0 blue:8.0/255.0 alpha:255.0];
//        CGFloat fBtnHeight = self.maxScreenForSuit/13.32;
        CGFloat fBtnHeight = KScalePt(50);

        _openFullAccessButton = [[UIButton alloc] init];
        
        [_openFullAccessButton setTitleColor:btnColor forState:UIControlStateNormal];
        [_openFullAccessButton setTitleColor:btnColor forState:UIControlStateSelected];
//        _openFullAccessButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/40.76];
        _openFullAccessButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(16)];
        _openFullAccessButton.titleLabel.textColor = btnColor;
        [_openFullAccessButton setTitle:CMLocalizedString(@"Allow_Now", nil) forState:UIControlStateNormal];
        
        [_openFullAccessButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:137.0/255.0 green:252.0/255.0 blue:251.0/255.0 alpha:255.0]] forState:UIControlStateNormal];
        [_openFullAccessButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:70.0/255.0 green:157.0/255.0 blue:161.0/255.0 alpha:255.0]] forState:UIControlStateHighlighted];
        
        _openFullAccessButton.layer.cornerRadius = fBtnHeight/2;
        _openFullAccessButton.layer.masksToBounds = YES;
        [_openFullAccessButton addTarget:self action:@selector(fullAccessButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _openFullAccessButton;
}

- (void) fullAccessButtonTapped:(id) sender
{
    [CMHostInfoc reportcheetahkeyboard_activate_click:3 isFirstShow:self.isFirstShow];
    [self.videoPlayer pause];
    [self.openFullAccessButton removeAllAnimation];
    NSString* strUrl = [CMBizHelper fullAccessUrlFromUpperCase];
    strUrl = [CMBizHelper fullAccessUrlFromLowerCase];
    strUrl = [CMBizHelper fullAccessUrlFromExtension];
    if (self.isUseABTest)
    {
        NSString*  urlString = [@"App-Prefs:" stringByAppendingString:[CMAppConfig hostAppbundleId]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[CMBizHelper fullAccessUrlFromUpperCase]]])
        {
            if (IOS10_OR_LATER)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[CMBizHelper fullAccessUrlFromUpperCase]] options:@{} completionHandler:nil];
            }
            else if (IOS8_OR_LATER)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[CMBizHelper fullAccessUrlFromUpperCase]]];
            }
        }
        else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[CMBizHelper fullAccessUrlFromLowerCase]]])
        {
            if (IOS10_OR_LATER)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[CMBizHelper fullAccessUrlFromLowerCase]] options:@{} completionHandler:nil];
            }
            else if (IOS8_OR_LATER)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[CMBizHelper fullAccessUrlFromLowerCase]]];
            }
        }
    }
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Add_Full_Setp_Icon_4"]];
    }
    return _iconImgView;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel)
    {
        _bottomLabel = [[UILabel alloc] init];
        
        _bottomLabel.textColor = [UIColor colorWithRed:116.0/255.0 green:232.0/255.0 blue:151.0/254.0 alpha:1];
//        _bottomLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/57];
        _bottomLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(11)];
        _bottomLabel.text = CMLocalizedString(@"Cheetah_Keyboard_will_not_collect_any_private_data", nil);
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.numberOfLines = 0;
    }
    
    return _bottomLabel;
}

#pragma mark - CMPlayerViewDelegate Method
- (void)playButtonDidClick
{
    NSString * sourceString;
    if (self.isUseABTest)
    {
        sourceString = [[NSBundle mainBundle]pathForResource:@"Allow_Full_Access_New_New_new_later" ofType:@"mp4"];
    }
    else
    {
        sourceString = [[NSBundle mainBundle]pathForResource:@"Allow_Full_Access_New_new" ofType:@"mp4"];
    }
    [_videoPlayer setupPlayerWithSourceString:sourceString];
    [_videoPlayer play];
    [CMHostInfoc reportcheetahkeyboard_activate_click:7 isFirstShow:self.isFirstShow];
}

@end
