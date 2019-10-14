//
//  SwitchKeyboardByMovieViewController.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/20.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "SwitchKeyboardByMovieViewController.h"
#import "ThemeSettingViewController.h"
#import "CMAppConfig.h"
#import "CMBizHelper.h"
#import "UIView+Util.h"
#import "UIDevice+Util.h"
#import "CMPlayerView.h"

static NSString* const kSwitchKeyPageIsFirstShow = @"kSwitchKeyPageIsFirstShow";

@interface SwitchKeyboardByMovieViewController ()<CMPlayerViewDelegate>

@property(nonatomic, strong) UITextField* keyboardTextField;
@property (nonatomic, strong) UIFont* montserFont;

@property (nonatomic, strong) UILabel* middleRowOneLabel;
@property (nonatomic, strong) UIImageView* bottomEarthImageView;
@property (nonatomic, strong) UILabel* middleRowTwoPartOneLabel;


@property (nonatomic, assign)BOOL isFirstShow;
@property (nonatomic) CGFloat maxScreenForSuit;

@property (nonatomic, strong) UILabel* titleLable;
@property (nonatomic, strong) UIColor* mainColor;
@property (nonatomic, strong)UIImageView* swithKeyboardBackImageView;

@property (nonatomic, strong) CMPlayerView* videoPlayer;

@end

@implementation SwitchKeyboardByMovieViewController

-(void)handleDidShowKeyboardNotification:(NSNotification *)notification
{
    if ([CMBizHelper checkIsCheetahKeyboard:self.keyboardTextField])
    {
        [CMHostInfoc reportcheetahkeyboard_activate_click:5 isFirstShow:self.isFirstShow];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSwitchKeyPageIsFirstShow] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSwitchKeyPageIsFirstShow];
    }
    
    self.isFirstShow = [[NSUserDefaults standardUserDefaults] boolForKey:kSwitchKeyPageIsFirstShow];
    [CMHostInfoc reportCheetahkeyboard_activate_show:4 isFirstShow:self.isFirstShow];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidShowKeyboardNotification:)
                                                 name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSwitchKeyPageIsFirstShow];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.keyboardTextField becomeFirstResponder];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldSwipeBack {
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.keyboardTextField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIDevice isIpad])
    {
        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
    }

    [self swithKeyboardBackImageView];
    [self titleLable];
    [self videoPlayer];
    [self middleRowOneLabel];
    [self bottomEarthImageView];
    [self middleRowTwoPartOneLabel];
    [self playButtonDidClick];
    
    self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
    self.view.layer.contents = (id)[UIImage imageNamed:@"Splash_Back"].CGImage;
    self.montserFont =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/45.7];
    self.mainColor = [UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:255.0];
    
    [self.view addSubview:self.swithKeyboardBackImageView];
    [self.view addSubview:self.titleLable];
    [self.view addSubview:self.videoPlayer];
    
    [self.view addSubview:self.middleRowOneLabel];
    [self.view addSubview:self.bottomEarthImageView];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.view.mas_top).with.offset(self.maxScreenForSuit/20);
         make.centerX.equalTo(self.view);
     }];

    [self.videoPlayer mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.view.mas_top).with.offset(self.maxScreenForSuit/7.82);
         make.centerX.equalTo(self.view.mas_centerX);
         make.height.equalTo(@(self.maxScreenForSuit/3.13));
         make.width.equalTo(@(self.maxScreenForSuit/2.47));
     }];
    
    if ([UIDevice isHeight568])
    {
        [self.middleRowOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(self.videoPlayer.mas_centerX);
             make.top.equalTo(self.videoPlayer.mas_bottom).offset(10);
         }];
    }
    else
    {
        [self.middleRowOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(self.videoPlayer.mas_centerX);
             make.top.equalTo(self.videoPlayer.mas_bottom).offset(20);
         }];
    }
    
    [self.bottomEarthImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         CGFloat fImageSize = self.maxScreenForSuit/31.91;
         make.width.equalTo(@(fImageSize));
         make.height.equalTo(@(fImageSize));
         make.left.equalTo(_middleRowOneLabel.mas_right).with.offset(self.maxScreenForSuit/80.36);
         make.centerY.equalTo(_middleRowOneLabel.mas_centerY);
     }];
    
    UIView* middleLineTwoContainerView = UIView.new;
    [self.view addSubview:middleLineTwoContainerView];
    [middleLineTwoContainerView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(_middleRowOneLabel.mas_bottom).with.offset(self.maxScreenForSuit/103.41);
        make.centerX.equalTo(self.view.mas_centerX);
        
        make.width.lessThanOrEqualTo(self.view.mas_width);
    }];
    
    [middleLineTwoContainerView addSubview:self.middleRowTwoPartOneLabel];
    [self.middleRowTwoPartOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(middleLineTwoContainerView.mas_left).offset(20);
         make.top.equalTo(middleLineTwoContainerView.mas_top);
     }];

    UILabel* bottomLabel2Part2= [[UILabel alloc] init];
    bottomLabel2Part2.textColor = [UIColor colorWithRed:137.0/255.0 green:252.0/255.0 blue:251.0/255.0 alpha:1.0];
    bottomLabel2Part2.text = CMLocalizedString(@"Cheetach_Keyboard", nil);
    bottomLabel2Part2.font = self.montserFont;
    bottomLabel2Part2.textAlignment = NSTextAlignmentCenter;;
    bottomLabel2Part2.adjustsFontSizeToFitWidth = YES;
    
    [middleLineTwoContainerView addSubview:bottomLabel2Part2];
    
    [bottomLabel2Part2 mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(_middleRowTwoPartOneLabel.mas_right).with.offset(1);
        make.top.equalTo(_middleRowTwoPartOneLabel.mas_top);
        make.right.equalTo(middleLineTwoContainerView.mas_right).with.offset(-20);
        make.bottom.equalTo(middleLineTwoContainerView.mas_bottom);
    }];
    
    self.keyboardTextField = [UITextField new];
    self.keyboardTextField.delegate = (id)self;
    self.keyboardTextField.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.keyboardTextField];
    [self.keyboardTextField mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.equalTo(@(0.1));
        make.height.equalTo(@(0.1));
    }];
}

- (UIImageView *)swithKeyboardBackImageView
{
    if (!_swithKeyboardBackImageView)
    {
        _swithKeyboardBackImageView = [[UIImageView alloc] init];
        _swithKeyboardBackImageView.image = [UIImage imageNamed:@"Switch_Keyboard_Back"];
    }
    return _swithKeyboardBackImageView;
}

- (UILabel *)titleLable
{
    if (!_titleLable)
    {
        _titleLable = [[UILabel alloc] init];
        _titleLable.textColor = self.mainColor;
        _titleLable.text = CMLocalizedString(@"Switch_to_Cheetah_Keyboard", nil);
        _titleLable.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/37.7];
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLable;
}

- (CMPlayerView *)videoPlayer
{
    if (!_videoPlayer)
    {
        _videoPlayer = [[CMPlayerView alloc] init];
        _videoPlayer.delegate = self;
        _videoPlayer.backgroundColor = [UIColor whiteColor];
        _videoPlayer.coverImageString = @"Switch_Home";
        self.videoPlayer.backgroundColor = [UIColor clearColor];
    }
    
    return _videoPlayer;
}

- (void)playButtonDidClick
{
    NSString * sourceString= [[NSBundle mainBundle]pathForResource:@"Switch_Keyboard" ofType:@"mp4"];
    [_videoPlayer setupPlayerWithSourceString:sourceString];
    [_videoPlayer play];
    [CMHostInfoc reportcheetahkeyboard_activate_click:6 isFirstShow:self.isFirstShow];
}


- (UILabel *)middleRowOneLabel
{
    if (!_middleRowOneLabel)
    {
        _middleRowOneLabel = [[UILabel alloc] init];
        _middleRowOneLabel.textColor = [UIColor whiteColor];
        _middleRowOneLabel.text = CMLocalizedString(@"Long_press_and_hold", nil);
        _middleRowOneLabel.font = self.montserFont;
        _middleRowOneLabel.textAlignment = NSTextAlignmentCenter;;
    }
    
    return _middleRowOneLabel;
}

- (UIImageView *)bottomEarthImageView
{
    if (!_bottomEarthImageView)
    {
        _bottomEarthImageView = [[UIImageView alloc] init];
        _bottomEarthImageView.image = [UIImage imageNamed:@"Earth_Icon"];
    }
    
    return _bottomEarthImageView;
}

- (UILabel *)middleRowTwoPartOneLabel
{
    if (!_middleRowTwoPartOneLabel)
    {
        _middleRowTwoPartOneLabel= [[UILabel alloc] init];
        _middleRowTwoPartOneLabel.textColor = [UIColor whiteColor];
        _middleRowTwoPartOneLabel.text = CMLocalizedString(@"to_switch_to", nil);
        _middleRowTwoPartOneLabel.font = self.montserFont;
        _middleRowTwoPartOneLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return _middleRowTwoPartOneLabel;
}


@end
