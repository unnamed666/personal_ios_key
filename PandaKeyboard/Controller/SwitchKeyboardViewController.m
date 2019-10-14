//
//  SwitchKeyboardViewController.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/20.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "SwitchKeyboardViewController.h"
#import "ThemeSettingViewController.h"
#import "CMAppConfig.h"
#import "CMBizHelper.h"
#import "UIView+Util.h"
#import "UIDevice+Util.h"

static NSString* const kSwitchKeyPageIsFirstShow = @"kSwitchKeyPageIsFirstShow";

@interface SwitchKeyboardViewController ()

@property(nonatomic, strong) UITextField* keyboardTextField;
@property (nonatomic, strong) UIFont* montserFont;

@property (nonatomic, strong) UILabel* rowOneLabel;
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UILabel* rowTwoLabel;
@property (nonatomic, strong) UILabel* rowThreeLabel;
@property (nonatomic, strong) UIImageView* fingerImageView;

@property (nonatomic, strong) UILabel* middleRowOneLabel;
@property (nonatomic, strong) UIImageView* bottomEarthImageView;
@property (nonatomic, strong) UILabel* middleRowTwoPartOneLabel;


@property (nonatomic, assign)BOOL isFirstShow;
@property (nonatomic) CGFloat maxScreenForSuit;

@property (nonatomic, strong)UIImageView* swithKeyboardBackImageView;

@end

@implementation SwitchKeyboardViewController

-(void)changeInputMode:(NSNotification *)notification
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
                                             selector:@selector(changeInputMode:)
                                                 name:UITextInputCurrentInputModeDidChangeNotification object:nil];
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

    self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
    self.view.layer.contents = (id)[UIImage imageNamed:@"Splash_Back"].CGImage;
    self.montserFont =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/45.7];

    [self.view addSubview:self.swithKeyboardBackImageView];
    
    [self.view addSubview:self.rowOneLabel];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.rowTwoLabel];
    [self.view addSubview:self.rowThreeLabel];
    [self.view addSubview:self.fingerImageView];
    
    [self.view addSubview:self.middleRowOneLabel];
    [self.view addSubview:self.bottomEarthImageView];
    
    [self.swithKeyboardBackImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(self.view.mas_top).with.offset(self.maxScreenForSuit/7.82);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(@(self.maxScreenForSuit/3.955));
        make.width.equalTo(@(self.maxScreenForSuit/2.47));
    }];

    [self.rowOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.swithKeyboardBackImageView).offset(self.maxScreenForSuit/9.875);
        make.top.equalTo(self.swithKeyboardBackImageView.mas_top).with.offset(self.maxScreenForSuit/52);
    }];
    
    [self.rowTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.rowOneLabel.mas_centerX);
         make.top.equalTo(self.swithKeyboardBackImageView.mas_top).with.offset(self.maxScreenForSuit/12);
     }];
    
    [self.rowThreeLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.rowOneLabel);
         make.bottom.equalTo(self.swithKeyboardBackImageView).offset(-self.maxScreenForSuit/11.6);
     }];
    
    [self.fingerImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.equalTo(@(self.maxScreenForSuit/12.98));
        make.height.equalTo(@(self.maxScreenForSuit/11.75));
        make.top.equalTo(self.swithKeyboardBackImageView.mas_bottom).offset(-self.maxScreenForSuit/62);
        make.leading.equalTo(self.swithKeyboardBackImageView.mas_leading).with.offset(self.maxScreenForSuit/14.62);
    }];
    
    if ([UIDevice isHeight568])
    {
        [self.middleRowOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(_swithKeyboardBackImageView.mas_centerX);
             make.top.equalTo(_fingerImageView.mas_bottom). with.offset(self.maxScreenForSuit/39.82);
         }];
    }
    else
    {
        [self.middleRowOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.centerX.equalTo(_swithKeyboardBackImageView.mas_centerX);
             make.top.equalTo(_fingerImageView.mas_bottom). with.offset(self.maxScreenForSuit/23.82);
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

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldSwipeBack {
    return NO;
}

- (UIImageView *)swithKeyboardBackImageView
{
    if (!_swithKeyboardBackImageView)
    {
        _swithKeyboardBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Switch_Keyboard_Back"]];
    }
    return _swithKeyboardBackImageView;
}

 -(UILabel *)rowOneLabel
{
    if (!_rowOneLabel)
    {
        _rowOneLabel = [[UILabel alloc] init];
        _rowOneLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _rowOneLabel.text = CMLocalizedString(@"English_US", nil);
        _rowOneLabel.font = self.montserFont;
        _rowOneLabel.textAlignment = NSTextAlignmentCenter;;
    }
    
    return _rowOneLabel;
}

 -(UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:168.0/255.0 green:168.0/255.0 blue:168.0/255.0 alpha:0.5];
    }
    
    return _lineView;
}

- (UILabel *)rowTwoLabel
{
    if (!_rowTwoLabel)
    {
        _rowTwoLabel = [[UILabel alloc] init];
        _rowTwoLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _rowTwoLabel.text = CMLocalizedString(@"Emoji", nil);
        _rowTwoLabel.font = self.montserFont;
        _rowTwoLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _rowTwoLabel;
}

- (UILabel *)rowThreeLabel
{
    if (!_rowThreeLabel)
    {
        _rowThreeLabel = [[UILabel alloc] init];
        _rowThreeLabel.textColor = [UIColor whiteColor];
        _rowThreeLabel.text = CMLocalizedString(@"Cheetach_Keyboard", nil);
        _rowThreeLabel.font = self.montserFont;
        _rowThreeLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _rowThreeLabel;
}

- (UIImageView *)fingerImageView
{
    if (!_fingerImageView)
    {
        _fingerImageView = [[UIImageView alloc] init];
        _fingerImageView.image = [UIImage imageNamed:@"Finger_Icon"];
    }
    
    return _fingerImageView;
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
