//
//  CMRequestLocalNotifyViewController.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/9/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRequestLocalNotifyViewController.h"
#import "UIImage+Util.h"
#import "CMBizHelper.h"
#import "CMAppConfig.h"
#import "UIButton+Util.h"
#import "CMLocalNotify.h"
#import "UIDevice+Util.h"
#import "CMBizHelper.h"
#import "CMHostInfoc.h"

@interface CMRequestLocalNotifyViewController () <UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic) CGFloat maxScreenForSuit;

@property (nonatomic, strong) MASConstraint* topConstraint;
@property (nonatomic, strong) UILabel* lineOneLabel;

@property (nonatomic, strong) UIView* lineTwoContainerView;
@property (nonatomic, strong) UILabel* lineTwoLabel;
@property (nonatomic, strong) UIImageView* lineTwoCheckedImageView;

@property (nonatomic, strong) UIView* lineThreeContainerView;
@property (nonatomic, strong) UILabel* lineThreeLabel;
@property (nonatomic, strong) UIImageView* lineThreeCheckedImageView;

@property (nonatomic) CGFloat topScaleForSuitScreen;
@property (nonatomic) BOOL isSystemLanguageEnglish;

@property (nonatomic) CGFloat bottomScaleForSuitScreen;
@property (nonatomic, strong) MASConstraint* bottomConstraint;
@property (nonatomic, strong) UIImageView* fingerImageView;

@end

@implementation CMRequestLocalNotifyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
    [CMHostInfoc reportCheetahkeyboard_noti_perm_show:1];
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.lineOneLabel];
    
    [self.view addSubview:self.lineTwoContainerView];
    [self.lineTwoContainerView addSubview:self.lineTwoCheckedImageView];
    [self.lineTwoContainerView addSubview:self.lineTwoLabel];
    
    [self.view addSubview:self.lineThreeContainerView];
    [self.lineThreeContainerView addSubview:self.lineThreeCheckedImageView];
    [self.lineThreeContainerView addSubview:self.lineThreeLabel];
    
    [self.view addSubview:self.fingerImageView];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self);
     }];
    
    [self.lineOneLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.leading.equalTo(self).offset(self.maxScreenForSuit/37.67);
         make.trailing.equalTo(self).offset(-self.maxScreenForSuit/37.67);
         self.topConstraint = make.top.equalTo(self).offset(self.maxScreenForSuit/self.topScaleForSuitScreen);
         make.centerX.equalTo(self);
     }];
    
    [self.lineTwoContainerView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.lineOneLabel.mas_bottom).offset(self.maxScreenForSuit/34.55);
         make.centerX.equalTo(self);
         make.width.lessThanOrEqualTo(@(self.maxScreenForSuit/2));
     }];
    
    [self.lineTwoCheckedImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(@(self.maxScreenForSuit/31.55));
         make.leading.centerY.top.equalTo(self.lineTwoContainerView);
     }];
    
    [self.lineTwoLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.leading.equalTo(self.lineTwoCheckedImageView.mas_trailing).offset(self.maxScreenForSuit/96);
         make.top.right.equalTo(self.lineTwoContainerView);
     }];
    
    [self.lineThreeContainerView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.lineTwoLabel.mas_bottom).offset(self.maxScreenForSuit/34.55);
         make.leading.equalTo(self.lineTwoContainerView);
         make.width.lessThanOrEqualTo(self.lineTwoContainerView);
     }];
    
    [self.lineThreeCheckedImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.leading.equalTo(self.lineThreeContainerView);
         make.width.height.equalTo(self.lineTwoCheckedImageView);
     }];
    
    [self.lineThreeLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.leading.equalTo(self.lineThreeCheckedImageView.mas_trailing).offset(self.maxScreenForSuit/96);
         make.top.right.equalTo(self.lineThreeContainerView);
     }];
    
    [self.fingerImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(@(self.maxScreenForSuit/18.4));
         self.bottomConstraint = make.bottom.equalTo(self).offset(-(self.maxScreenForSuit/self.bottomScaleForSuitScreen));
         make.centerX.equalTo(self).offset(self.maxScreenForSuit/18.4*1.5);
     }];
    
    [CMLocalNotify registLocalNotify];
    [self startFingerAnimation];
}

- (void) startFingerAnimation
{
    [UIView animateWithDuration:0.6f delay:0.2f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^
     {
         CGRect theNewRect = CGRectMake(self.fingerImageView.frame.origin.x, self.fingerImageView.frame.origin.y - 60, CGRectGetWidth(self.fingerImageView.frame), CGRectGetHeight(self.fingerImageView.frame));
         self.fingerImageView.frame = theNewRect;
     }
                     completion:^(BOOL finished)
     {
         kLog(@"Animation end！");
     }];
}

- (void) registerNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterUserNotificationSettings:)  name:@"didRegisterUserNotificationSettings" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) didRegisterUserNotificationSettings:(NSNotification*) theNotification
{
    if ([theNotification.name isEqualToString:@"didRegisterUserNotificationSettings"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void) deviceOrientationDidChange
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotify];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         self.topConstraint.valueOffset(@(self.maxScreenForSuit/self.topScaleForSuitScreen));
         self.bottomConstraint.valueOffset(@(-(self.maxScreenForSuit/self.bottomScaleForSuitScreen)));
         
         [self.view setNeedsUpdateConstraints];
         [self.view updateConstraintsIfNeeded];
         
         [UIView animateWithDuration:0.3 animations:^{
             [self.view layoutIfNeeded];
         }];
     }
    completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self.fingerImageView.layer removeAllAnimations];
         [self startFingerAnimation];
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)updateConstraints
{
    [self.view.superview updateConstraints];
}

- (BOOL)isSystemLanguageEnglish
{
    NSString* systemLanguage = [[CMBizHelper getPreferredLanguage] substringToIndex:2];
    if ([systemLanguage isEqualToString:@"en"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (UIView *)backgroundView
{
    if (!_backgroundView)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:16.0/255.0 blue:42.0/255.0 alpha:1.0f];
        
        UITapGestureRecognizer* backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backgroundView addGestureRecognizer:backGesture];
    }
    
    return _backgroundView;
}

- (void) backgroundTapped:(UITapGestureRecognizer*) theGesture
{
    [self.navigationController popViewControllerAnimated:YES];   
}

- (UILabel *)lineOneLabel
{
    if (!_lineOneLabel)
    {
        _lineOneLabel = [[UILabel alloc] init];
        _lineOneLabel.textColor = [UIColor whiteColor];
        _lineOneLabel.textAlignment = NSTextAlignmentCenter;
        _lineOneLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/44.20];
        _lineOneLabel.text = CMLocalizedString(@"Allow_notifycation_you_will_get_this_function", nil);
        _lineOneLabel.lineBreakMode = NSTextAlignmentLeft;
        _lineOneLabel.numberOfLines = 0;
    }
    
    return _lineOneLabel;
}

- (UIView *)lineTwoContainerView
{
    if (!_lineTwoContainerView)
    {
        _lineTwoContainerView = [[UIView alloc] init];
    }
    
    return _lineTwoContainerView;
}

- (UILabel *)lineTwoLabel
{
    if (!_lineTwoLabel)
    {
        _lineTwoLabel = [[UILabel alloc] init];
        _lineTwoLabel = [[UILabel alloc] init];
        _lineTwoLabel.textColor = [UIColor whiteColor];
        _lineTwoLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/44.20];
        _lineTwoLabel.text = CMLocalizedString(@"Customized_themes_just_for_you", nil);
        _lineTwoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _lineTwoLabel.numberOfLines = 0;
        _lineTwoLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _lineTwoLabel;
}

- (UIImageView *)lineTwoCheckedImageView
{
    if (!_lineTwoCheckedImageView)
    {
        _lineTwoCheckedImageView = [[UIImageView alloc] init];
        _lineTwoCheckedImageView.image = [UIImage imageNamed:@"Checked"];
    }
    
    return _lineTwoCheckedImageView;
}

- (UIView *)lineThreeContainerView
{
    if (!_lineThreeContainerView)
    {
        _lineThreeContainerView = [[UIView alloc] init];
    }
    
    return _lineThreeContainerView;
}

- (UILabel *)lineThreeLabel
{
    if (!_lineThreeLabel)
    {
        _lineThreeLabel = [[UILabel alloc] init];
        _lineThreeLabel = [[UILabel alloc] init];
        _lineThreeLabel.textColor = [UIColor whiteColor];
        _lineThreeLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/44.20];
        _lineThreeLabel.text = CMLocalizedString(@"Cool_funciton_teaching", nil);
        _lineThreeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _lineThreeLabel.numberOfLines = 0;
        _lineThreeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _lineThreeLabel;
}

- (UIImageView *)lineThreeCheckedImageView
{
    if (!_lineThreeCheckedImageView)
    {
        _lineThreeCheckedImageView = [[UIImageView alloc] init];
        _lineThreeCheckedImageView.image = [UIImage imageNamed:@"Checked"];
    }
    
    return _lineThreeCheckedImageView;
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

- (CGFloat)topScaleForSuitScreen
{
    if ([UIDevice isHeight667])
    {
        if ([self isSystemLanguageEnglish])
        {
            _topScaleForSuitScreen = 5.61;
        }
        else
        {
            _topScaleForSuitScreen = 9.21;
        }
    }
    else if ([UIDevice isHeight736])
    {
        if ([self isSystemLanguageEnglish])
        {
            _topScaleForSuitScreen = 5.11;
        }
        else
        {
            _topScaleForSuitScreen = 8.11;
        }
    }
    else if ([UIDevice isHeight568])
    {
        if ([self isSystemLanguageEnglish])
        {
            _topScaleForSuitScreen = 6.31;
        }
        else
        {
            _topScaleForSuitScreen = 12.91;
        }
    }
    else if ([UIDevice isHeight1024])
    {
        if ([[UIDevice currentDevice] isScreenPortrait])
        {
            _topScaleForSuitScreen = 6.61;
        }
        else
        {
            _topScaleForSuitScreen = 12.61;
        }
    }
    else
    {
        _topScaleForSuitScreen = 4.61;
    }
    
    return _topScaleForSuitScreen;
}

- (CGFloat)bottomScaleForSuitScreen
{
    if ([UIDevice isHeight667])
    {
        if ([self isSystemLanguageEnglish])
        {
            _bottomScaleForSuitScreen = 3.466;
        }
        else
        {
            _bottomScaleForSuitScreen = 4.466;
        }
    }
    else if ([UIDevice isHeight736])
    {
        if ([self isSystemLanguageEnglish])
        {
            _bottomScaleForSuitScreen = 3.466;
        }
        else
        {
            _bottomScaleForSuitScreen = 3.466;
        }
    }
    else if ([UIDevice isHeight1024])
    {
        if ([[UIDevice currentDevice] isScreenPortrait])
        {
            _bottomScaleForSuitScreen = 3.466;
        }
        else
        {
            _bottomScaleForSuitScreen = 5.61;
        }
    }
    else
    {
        _bottomScaleForSuitScreen = 4.61;
    }
    
    return _bottomScaleForSuitScreen;
}

@end
