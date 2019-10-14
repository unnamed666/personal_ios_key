//
//  AddKeyBoardController.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/19.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "AddKeyBoardController.h"
#import "SetFullAccessViewController.h"
#import "CMGroupDataManager.h"
#import "CMAppConfig.h"
#import "CMServicesPrivacyViewController.h"
#import "UIView+Animate.h"
#import "CMPlayerView.h"

static NSString* const kAddPageIsFirstShow = @"kAddPageIsFirstShow";

@interface AddKeyBoardController ()<CMPlayerViewDelegate>

@property (nonatomic, assign)BOOL isFirstShow;
@property (nonatomic, strong) UIColor* mainColor;

@property (nonatomic, strong) UILabel* titleLable;
@property (nonatomic, strong) UIView* videoWrapView;
@property (nonatomic, strong) CMPlayerView* videoPlayer;

@property (nonatomic, strong) UIButton* stepOneIconButton;
@property (nonatomic, strong) UILabel* stepOnePartOneLabel;
@property (nonatomic, strong) UILabel* stepOnePartTwoLabel;

@property (nonatomic, strong) UIButton* stepTwoIconButton;
@property (nonatomic, strong) UILabel* stepTwoPartOneLabel;
@property (nonatomic, strong) UILabel* stepTwoPartTwoLabel;

@property (nonatomic, strong) UIButton* stepThreeIconButton;
@property (nonatomic, strong) UILabel* stepThreePartOneLabel;
@property (nonatomic, strong) UILabel* stepThreePartTwoLabel;

@property (nonatomic, strong) UIButton* addKeyboardButton;
@property (nonatomic, strong) CALayer* animShadowLayer;

@property (nonatomic, strong) UILabel* bottomLabel;
@property (nonatomic, strong) UILabel* agreenLabel;
@property (nonatomic, strong) UIButton* agreenButton;
@property (nonatomic, strong) UIAlertController* addKeyboardAlertController;

@property (nonatomic) CGFloat maxScreenForSuit;
@property (nonatomic) CGFloat fStepTextSize;
@property (nonatomic) BOOL isUseABTest;

@end

@implementation AddKeyBoardController

static NSString * servicesPrivacyUrlStr = @"https://www.cmcm.com/protocol/cheetah-keyboard/user_agreement.html";


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.addKeyboardButton heartBeat];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.addKeyboardButton removeAllAnimation];
}

- (void) registJumpNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)applicationEnteredForeground:(NSNotification *)notification
{
    if ([CMBizHelper checkIsAddCheetahKeyboard])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self.addKeyboardButton setEnabled:YES];
}

- (void)dealloc
{
    [self.addKeyboardButton removeAllAnimation];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect fixframe=self.addKeyboardButton.layer.frame;
    fixframe.size.width=[CMBizHelper adapterScreenWidth]-40;
    self.animShadowLayer.frame=fixframe;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAddPageIsFirstShow] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAddPageIsFirstShow];
    }
    
    self.isFirstShow = [[NSUserDefaults standardUserDefaults] boolForKey:kAddPageIsFirstShow];
    [CMHostInfoc reportCheetahkeyboard_activate_show:1 isFirstShow:self.isFirstShow];
    [self registJumpNotify];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAddPageIsFirstShow];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice isIpad])
    {
        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
    }
    
    self.isUseABTest = [CMBizHelper shouldUseABTestAtInitPage];
    
    [self registJumpNotify];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.layer.contents = (id)[UIImage imageNamed:@"Splash_Back"].CGImage;
    self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
    self.fStepTextSize = self.maxScreenForSuit/51.11;
    self.mainColor = [UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:255.0];
    
    [self.view addSubview:self.titleLable];
    [self.view addSubview:self.videoWrapView];
    [self.view addSubview:self.videoPlayer];
    
    [self.view addSubview:self.stepOneIconButton];
    [self.view addSubview:self.stepOnePartOneLabel];
    [self.view addSubview:self.stepOnePartTwoLabel];
    
    [self.view addSubview:self.stepTwoIconButton];
    [self.view addSubview:self.stepTwoPartOneLabel];
    [self.view addSubview:self.stepTwoPartTwoLabel];
    
    [self.view addSubview:self.stepThreeIconButton];
    [self.view addSubview:self.stepThreePartOneLabel];
    [self.view addSubview:self.stepThreePartTwoLabel];
    
    [self.view addSubview:self.addKeyboardButton];
    [self.view addSubview:self.bottomLabel];
    [self.view addSubview:self.agreenLabel];
    [self.view addSubview:self.agreenButton];

    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.view.mas_top).with.offset(self.maxScreenForSuit/20);
         make.centerX.equalTo(self.view);
     }];

    if (![CMBizHelper isiPhone]) {//ipad
        [self.videoWrapView mas_makeConstraints:^(MASConstraintMaker *make)
         {
//         make.top.equalTo(self.titleLable.mas_bottom).with.offset(self.maxScreenForSuit/23);
             make.top.equalTo(self.titleLable.mas_bottom).offset(KScalePt(29));
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
//         make.top.equalTo(self.titleLable.mas_bottom).with.offset(self.maxScreenForSuit/23);
             make.top.equalTo(self.titleLable.mas_bottom).with.offset(KScalePt(29));
//             make.height.equalTo(@(self.maxScreenForSuit/1.83));
             make.height.equalTo(@(KScalePt(346)));
//             make.left.right.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, self.maxScreenForSuit/10.1, 0, self.maxScreenForSuit/10.1));
             make.left.right.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, KScalePt(66), 0, KScalePt(66)));

             
             
         }];
        
        [self.videoPlayer mas_makeConstraints:^(MASConstraintMaker *make)
         {
//             make.edges.equalTo(self.videoWrapView).with.insets(UIEdgeInsetsMake(self.maxScreenForSuit/12.46, self.maxScreenForSuit/58, 0, self.maxScreenForSuit/58));
             make.edges.equalTo(self.videoWrapView).with.insets(UIEdgeInsetsMake(KScalePt(54), KScalePt(11), 0, KScalePt(11)));

         }];
    }
    
    [self.stepOneIconButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
//         make.width.height.equalTo(@(self.maxScreenForSuit/32));
         make.width.height.equalTo(@(KScalePt(20)));
 make.top.equalTo(self.videoWrapView.mas_bottom).with.offset(self.maxScreenForSuit/42.61);
         make.left.equalTo(self.view).with.offset(self.maxScreenForSuit/15.00);
     }];
    
    [self.stepOnePartOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerY.equalTo(self.stepOneIconButton);
         make.left.equalTo(self.stepOneIconButton.mas_right).with.offset(self.maxScreenForSuit/66.03);
     }];
    
    [self.stepOnePartTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerY.equalTo(self.stepOneIconButton);
         make.left.equalTo(self.stepOnePartOneLabel.mas_right);
         make.right.lessThanOrEqualTo(self.view.mas_right).with.offset(-5);
     }];
    
    [self.stepTwoIconButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(self.stepOneIconButton);
         make.top.equalTo(self.stepOneIconButton.mas_bottom).with.offset(self.maxScreenForSuit/57.25);
         make.left.equalTo(self.stepOneIconButton);
     }];
    
    [self.stepTwoPartOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepTwoIconButton.mas_top);
         make.left.equalTo(_stepTwoIconButton.mas_right).with.offset(self.maxScreenForSuit/66.03);
     }];
    
    [self.stepTwoPartTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepTwoPartOneLabel);
         make.left.equalTo(_stepTwoPartOneLabel.mas_right);
     }];
    
    [self.stepThreeIconButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(self.stepOneIconButton);
         make.top.equalTo(_stepTwoIconButton.mas_bottom).with.offset(self.maxScreenForSuit/57.25);
         make.left.equalTo(_stepTwoIconButton.mas_left);
     }];
    
    [self.stepThreePartOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepThreeIconButton);
         make.left.equalTo(_stepThreeIconButton.mas_right).with.offset(self.maxScreenForSuit/66.03);
     }];
    
    [self.stepThreePartTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_stepThreePartOneLabel);
         make.left.equalTo(_stepThreePartOneLabel.mas_right);
     }];

    [self.addKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
     make.top.equalTo(_stepThreeIconButton.mas_bottom).with.offset(self.maxScreenForSuit/28.0);
         make.height.equalTo(@(self.maxScreenForSuit/13.32));
         make.left.right.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, self.maxScreenForSuit/38.44, 0, self.maxScreenForSuit/38.44));
     }];
    
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_addKeyboardButton.mas_bottom).with.offset(self.maxScreenForSuit/56.90);
         make.centerX.equalTo(self.view);
     }];
    
    [self.agreenLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(_bottomLabel.mas_bottom);
         make.centerX.equalTo(self.view);
     }];
    
    [self.agreenButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.left.right.equalTo(_agreenLabel);
        make.height.equalTo(@(20));
    }];
//    [self scaleFrameAnim];
}

- (void) scaleFrameAnim
{
    [UIView animateKeyframesWithDuration:6.8 delay:1.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^
     {
         [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:1.0 / 4 animations:^
          {
              self.addKeyboardButton.transform = CGAffineTransformMakeScale(0.93, 0.93);
              self.videoPlayer.transform = CGAffineTransformMakeScale(0.93, 0.93);
//              self.animShadowLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(0.93, 0.93));
              self.animShadowLayer.transform = CATransform3DScale(CATransform3DIdentity, 0.3, 0.3, 0.3);
        
          }];
         [UIView addKeyframeWithRelativeStartTime:1.0 / 4 relativeDuration:1.0 / 4 animations:^
          {
              self.addKeyboardButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
              self.videoPlayer.transform = CGAffineTransformMakeScale(1.0, 1.0);
//              self.animShadowLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.0, 1.0));
              self.animShadowLayer.transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0);
          }];
         [UIView addKeyframeWithRelativeStartTime:2.0 / 4 relativeDuration:1.0 / 4 animations:^
          {
              self.addKeyboardButton.transform = CGAffineTransformMakeScale(0.93, 0.93);
              self.videoPlayer.transform = CGAffineTransformMakeScale(0.93, 0.93);
//              self.animShadowLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(0.93, 0.93));
              self.animShadowLayer.transform = CATransform3DScale(CATransform3DIdentity, 0.3, 0.3,0.3);
          }];
         [UIView addKeyframeWithRelativeStartTime:3.0 / 4 relativeDuration:1.0 / 4 animations:^
          {
              self.addKeyboardButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
              self.videoPlayer.transform = CGAffineTransformMakeScale(1.0, 1.0);
//              self.animShadowLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.0, 1.0));
              self.animShadowLayer.transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0);
          }];
     }completion:^(BOOL finished)
     {
         [self scaleFrameAnim];
     }];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldSwipeBack {
    return NO;
}

- (UILabel *)titleLable
{
    if (!_titleLable)
    {
        _titleLable = [[UILabel alloc] init];
        _titleLable.textColor = self.mainColor;
        _titleLable.text = CMLocalizedString(@"Add_Cheetah_Keyboard", nil);
        _titleLable.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/37.7];
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLable;
}

- (UIView *)videoWrapView
{
    if (!_videoWrapView)
    {
        _videoWrapView = [[UIView alloc] init];
        UIImage* imagePhone = [UIImage imageNamed:@"Phone_Model"];
        _videoWrapView.layer.contents = (id)imagePhone.CGImage;
    }
    
    return _videoWrapView;
}

- (UIAlertController *)addKeyboardAlertController
{
    if (!_addKeyboardAlertController)
    {
        _addKeyboardAlertController = [UIAlertController alertControllerWithTitle:CMLocalizedString(@"Before_you_go", nil) message:CMLocalizedString(@"Come_back_this_app_after_you", nil) preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
//                                       {
//                                           NSLog(@"");
//                                       }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:CMLocalizedString(@"Got_it", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
                                   {
                                       [self.addKeyboardButton removeAllAnimation];
                                       [self.videoPlayer pause];
                                       [self callAddKeyboardSetting];
                                       [CMHostInfoc reportcheetahkeyboard_activate_click:8 isFirstShow:self.isFirstShow];
                                   }];
//        [_addKeyboardAlertController addAction:cancelAction];
        [_addKeyboardAlertController addAction:okAction];
    }
    
    return _addKeyboardAlertController;
}

- (CMPlayerView *)videoPlayer
{
    if (!_videoPlayer)
    {
        _videoPlayer = [[CMPlayerView alloc] init];
        _videoPlayer.delegate = self;
        _videoPlayer.backgroundColor = [UIColor whiteColor];
        _videoPlayer.coverImageString = @"Add_Keyboard_New_cover";
    }
    
    return _videoPlayer;
}

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
        _stepOnePartOneLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.fStepTextSize];
        _stepOnePartOneLabel.text = CMLocalizedString(@"Go_to", nil);
        _stepOnePartOneLabel.textAlignment = NSTextAlignmentLeft;
        [_stepOnePartOneLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    return  _stepOnePartOneLabel;
}

-(UILabel *)stepOnePartTwoLabel
{
    if (!_stepOnePartTwoLabel)
    {
        _stepOnePartTwoLabel = [[UILabel alloc] init];
        
        _stepOnePartTwoLabel.textColor = self.mainColor;
        _stepOnePartTwoLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.fStepTextSize];
        if (self.isUseABTest)
        {
            _stepOnePartTwoLabel.text = CMLocalizedString(@"Setting_CheetahKey", nil);
        }
        else
        {
            _stepOnePartTwoLabel.text = CMLocalizedString(@"Settings_General_Keyboard", nil);
        }
        _stepOnePartTwoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _stepOnePartTwoLabel.adjustsFontSizeToFitWidth = YES;
        _stepOnePartTwoLabel.baselineAdjustment = UIBaselineAdjustmentNone;
        _stepOnePartTwoLabel.textAlignment = NSTextAlignmentLeft;
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
        _stepTwoPartOneLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.fStepTextSize];
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
        _stepTwoPartTwoLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.fStepTextSize];
        if (self.isUseABTest)
        {
            _stepTwoPartTwoLabel.text = CMLocalizedString(@"Keyboards", nil);
        }
        else
        {
            _stepTwoPartTwoLabel.text = CMLocalizedString(@"Add_New_Keyboard", nil);
        }
        _stepTwoPartTwoLabel.textAlignment = NSTextAlignmentLeft;
        _stepTwoPartTwoLabel.numberOfLines = 0;
        _stepTwoPartTwoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return _stepTwoPartTwoLabel;
}

- (UIButton *)stepThreeIconButton
{
    if (!_stepThreeIconButton)
    {
        _stepThreeIconButton = [[UIButton alloc] init];
        [_stepThreeIconButton setBackgroundImage:[UIImage imageNamed:@"Add_Full_Setp_Icon_3"] forState:UIControlStateNormal];
    }
    
    return _stepThreeIconButton;
}

- (UILabel *)stepThreePartOneLabel
{
    if (!_stepThreePartOneLabel)
    {
        _stepThreePartOneLabel = [[UILabel alloc] init];
        _stepThreePartOneLabel.textColor = [UIColor colorWithRed:140.0/255.0 green:141.0/255.0 blue:154.0/254.0 alpha:1];
        _stepThreePartOneLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.fStepTextSize];
        _stepThreePartOneLabel.text = CMLocalizedString(@"Tap", nil);
        _stepThreePartOneLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _stepThreePartOneLabel;
}

- (UILabel *)stepThreePartTwoLabel
{
    if (!_stepThreePartTwoLabel)
    {
        _stepThreePartTwoLabel = [[UILabel alloc] init];
        
        _stepThreePartTwoLabel.textColor = self.mainColor;
        _stepThreePartTwoLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.fStepTextSize];
        _stepThreePartTwoLabel.text = CMLocalizedString(@"Cheetah_Keyboard", nil);
        _stepThreePartTwoLabel.textAlignment = NSTextAlignmentLeft;
        _stepThreePartTwoLabel.numberOfLines = 0;
        _stepThreePartTwoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return _stepThreePartTwoLabel;
}

 -(UIButton *)addKeyboardButton
{
    if (!_addKeyboardButton)
    {
        UIColor* btnColor = [UIColor colorWithRed:17.0/255.0 green:0.0/255.0 blue:8.0/255.0 alpha:255.0];
        UIColor* btnColorSelected = [UIColor colorWithRed:70.0/255.0 green:157.0/255.0 blue:161.0/255.0 alpha:255.0];
        CGFloat fBtnHeight = self.maxScreenForSuit/13.32;
        _addKeyboardButton = [[UIButton alloc] init];
        
        [_addKeyboardButton setTitleColor:btnColor forState:UIControlStateNormal];
        [_addKeyboardButton setTitleColor:btnColorSelected forState:UIControlStateSelected];
        _addKeyboardButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/40.76];
        _addKeyboardButton.titleLabel.textColor = btnColor;
        [_addKeyboardButton setTitle:CMLocalizedString(@"Add_Now", nil) forState:UIControlStateNormal];
        [_addKeyboardButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:137.0/255.0 green:252.0/255.0 blue:251.0/255.0 alpha:255.0]] forState:UIControlStateNormal];
        [_addKeyboardButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:70.0/255.0 green:157.0/255.0 blue:161.0/255.0 alpha:255.0]] forState:UIControlStateHighlighted];
        
        _addKeyboardButton.layer.cornerRadius = fBtnHeight/2;
        _addKeyboardButton.layer.masksToBounds = YES;
        [_addKeyboardButton addTarget:self action:@selector(AddOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addKeyboardButton;
}

- (CALayer *)animShadowLayer
{
    if (_animShadowLayer)
    {
        _animShadowLayer = [CALayer layer];
        _animShadowLayer.cornerRadius = 8;
        _animShadowLayer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        _animShadowLayer.masksToBounds=NO;
        _animShadowLayer.shadowColor=[UIColor redColor].CGColor;
        _animShadowLayer.shadowOffset=CGSizeMake(10,10);
        _animShadowLayer.shadowOpacity=0.5;
        _animShadowLayer.shadowRadius=8;
        
        [self.view.layer insertSublayer:_animShadowLayer below:self.addKeyboardButton.layer];
    }
    
    return _animShadowLayer;
}

- (void) AddOnClick:(id) sender
{
	[CMHostInfoc reportcheetahkeyboard_activate_click:1 isFirstShow:self.isFirstShow];
    [self presentViewController:self.addKeyboardAlertController animated:YES completion:nil];
    self.isFirstShow = [[NSUserDefaults standardUserDefaults] boolForKey:kAddPageIsFirstShow];
    [CMHostInfoc reportCheetahkeyboard_activate_show:5 isFirstShow:self.isFirstShow];
    [self.addKeyboardButton setEnabled:NO];
}

- (void) callAddKeyboardSetting
{
    self.isUseABTest = [CMBizHelper shouldUseABTestAtInitPage];
    
    if (self.isUseABTest)
    {
        NSString*  urlString = [@"App-Prefs:" stringByAppendingString:[CMAppConfig hostAppbundleId]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else
    {
        NSString* str1 = @"A";
        NSString* str2 = @"pp-Pr";
        NSString* str3 = @"efs";
        NSString* str4 = @":r";
        NSString* str5 = @"oot=G";
        NSString* str6 = @"eneral&p";
        NSString* str7 = @"ath=Keyboard/KEYBOARDS";
        NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",str1,str2,str3,str4,str5,str6,str7];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
    }
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel)
    {
        _bottomLabel = [[UILabel alloc] init];
        
        _bottomLabel.textColor = [UIColor colorWithRed:130.0/255.0 green:151.0/255.0 blue:160.0/255.0 alpha:1];
        UIFont* bottomFont = [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/62];
        _bottomLabel.font =  bottomFont;
        _bottomLabel.text = CMLocalizedString(@"Tap_the_button_means_you_agree_to_our", nil);
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return _bottomLabel;
}

- (UILabel *)agreenLabel
{
    if (!_agreenLabel)
    {
        _agreenLabel = [[UILabel alloc] init];
        _agreenLabel.textColor = [UIColor colorWithRed:130.0/255.0 green:151.0/255.0 blue:160.0/255.0 alpha:1];
        UIFont* bottomFont = [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/62];
        _agreenLabel.font =  bottomFont;
        _agreenLabel.textAlignment = NSTextAlignmentLeft;
        [_agreenLabel setLineBreakMode:NSLineBreakByWordWrapping];
        _agreenLabel.numberOfLines =3;
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:CMLocalizedString(@"User_Agreement", nil)]];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        _agreenLabel.attributedText = content;
    }
    
    return _agreenLabel;
}

 -(UIButton *)agreenButton
{
    if (!_agreenButton)
    {
        _agreenButton = [[UIButton alloc] init];
        [_agreenButton addTarget:self action:@selector(showUserAgreement:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _agreenButton;
}

- (void) showUserAgreement:(id) sender
{
    [CMHostInfoc reportcheetahkeyboard_activate_click:2 isFirstShow:self.isFirstShow];
    CMServicesPrivacyViewController * servicesVC = [[CMServicesPrivacyViewController alloc] init];
    servicesVC.servicesPrivacyUrlStr = servicesPrivacyUrlStr;
    [self.navigationController pushViewController:servicesVC animated:YES];
}

- (void) callFullAccessSetting
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

#pragma mark - CMPlayerViewDelegate Method
- (void)playButtonDidClick
{
    NSString * sourceString;
    if (self.isUseABTest)
    {
        sourceString = [[NSBundle mainBundle]pathForResource:@"Add_Keyboard_New_New_new_later" ofType:@"mp4"];
    }
    else
    {
        sourceString = [[NSBundle mainBundle]pathForResource:@"Add_Keyboard_New_new" ofType:@"mp4"];
    }
    
    [_videoPlayer setupPlayerWithSourceString:sourceString];
    [_videoPlayer play];
    [CMHostInfoc reportcheetahkeyboard_activate_click:6 isFirstShow:self.isFirstShow];
}

@end
