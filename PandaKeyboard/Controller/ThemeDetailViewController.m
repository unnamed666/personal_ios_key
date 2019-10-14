//
//  ThemeDetailViewController.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "ThemeDetailViewController.h"
#import "UIImage+Util.h"
#import "UIView+Util.h"
#import <STPopup/STPopup.h>
#import "CMDownProgress.h"
#import "CMHostRequestFactory.h"
#import "CMThemeManager.h"
#import <Lottie/Lottie.h>
#import "CMThemeModel.h"
#import <YYWebImage/YYWebImage.h>
#import "CMError.h"
#import "UIButton+Util.h"
#import "CMBizHelper.h"
#include "UIView+Util.h"

@interface ThemeDetailViewController ()
@property (nonatomic, strong) UIImageView* themeCoverImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton* downloadButton;
@property (nonatomic, strong) UIButton *closeDetailButton;
@property (nonatomic, strong) UILabel *themeSizeLabel;
@property (nonatomic, strong) UIImageView *themeUpdateMarkImageView;
@property (nonatomic, strong) UILabel *themeUpdateAndDateLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIView* downFailedView;
@property (nonatomic, strong) UIImageView* downFailedIconImageView;
@property (nonatomic, strong) UILabel* downFailedTextLabel;
@property (nonatomic, strong) LOTAnimationView * animationView;

@property (nonatomic, strong) CMDownProgress *downThemeProgressView;
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;

@property (nonatomic) CGFloat maxScreenForSuit;

@property (nonatomic, strong)CMThemeManager* themeManager;
@property (nonatomic, strong) UILabel * attributeLabel;
@property (nonatomic, strong) UIButton * fullAccessTipButton;

@property (nonatomic, strong) UIButton *editThemeButton;
@property (nonatomic, strong) UIButton *applyThemeButton;
@end

@implementation ThemeDetailViewController
{
    UILabel *_label;
}

- (instancetype)initWithThemeDetailModel:(CMThemeDetailViewModel*)theModel themeManager:(CMThemeManager *)themeManager {
    if (self = [super init])
    {
        self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
        if ([UIDevice isHeight568])
        {
            self.contentSizeInPopup = CGSizeMake(self.maxScreenForSuit/1.918, self.maxScreenForSuit/1.72);
        } else if ([UIDevice isHeight896] || [UIDevice isHeight812])
        {
            self.contentSizeInPopup = CGSizeMake(self.maxScreenForSuit/2.318, self.maxScreenForSuit/2.12);
        }
        else
        {
            self.contentSizeInPopup = CGSizeMake(self.maxScreenForSuit/1.918, self.maxScreenForSuit/1.75);
        }
        
        self.landscapeContentSizeInPopup = CGSizeMake(self.maxScreenForSuit/2.318, self.maxScreenForSuit/2.117);
        self.themeDetailViewModel = theModel;
        self.themeManager = themeManager;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.themeCoverImageView];
    [self.containerView addSubview:self.closeDetailButton];
    [self.containerView addSubview:self.themeSizeLabel];
    if (self.themeDetailViewModel.themeType == CMThemeType_Update) {
        [self.containerView addSubview:self.themeUpdateMarkImageView];
    }
    
    if (self.themeDetailViewModel.themeType == CMThemeType_Update || self.themeDetailViewModel.themeType == CMThemeType_Download) {
        [self.containerView addSubview:self.themeUpdateAndDateLabel];
    }
    [self.containerView addSubview:self.downThemeProgressView];
    [self.containerView addSubview:self.progressLabel];
    [self.containerView addSubview:self.downFailedView];
    [self.downFailedView addSubview:self.downFailedIconImageView];
    [self.downFailedView addSubview:self.downFailedTextLabel];
    [self.containerView addSubview:self.attributeLabel];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view);
     }];
    
    [self.themeCoverImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.leading.trailing.equalTo(self.containerView);
         //make.height.equalTo(self.containerView).dividedBy(1.497);
         make.height.equalTo(self.containerView.mas_width).dividedBy(1.497);
         make.top.equalTo(self.containerView.mas_top);
     }];
    
    switch (self.themeDetailViewModel.viewModel.type) {
        case CMThemeModelType_Default:
            {
                [self.containerView addSubview:self.applyThemeButton];
                [self.applyThemeButton mas_makeConstraints:^(MASConstraintMaker *make)
                 {
                     make.height.equalTo(self.containerView.mas_width).dividedBy(7.56);
                     make.width.equalTo(self.containerView).dividedBy(1.153);
                     make.centerX.equalTo(self.containerView);
                     make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(self.maxScreenForSuit/14.83);
                 }];
                [self.attributeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.applyThemeButton.mas_leading);
                    make.trailing.equalTo(self.applyThemeButton.mas_trailing);
                    make.top.equalTo(self.applyThemeButton.mas_bottom).offset(17);
                    make.height.greaterThanOrEqualTo(@0);
                }];
            }
            break;
        case CMThemeModelType_Custom:
        {
            [self.containerView addSubview:self.applyThemeButton];
            [self.containerView addSubview:self.editThemeButton];
            [self.applyThemeButton mas_makeConstraints:^(MASConstraintMaker *make)
             {
                 make.height.equalTo(self.containerView.mas_width).dividedBy(7.56);
                 make.width.equalTo(self.containerView).dividedBy(2.35);
                 make.right.equalTo(self.containerView.mas_centerX).offset(-8);
                 make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(self.maxScreenForSuit/14.83);
             }];
            [self.editThemeButton mas_makeConstraints:^(MASConstraintMaker *make)
             {
                 make.height.equalTo(self.containerView.mas_width).dividedBy(7.56);
                 make.width.equalTo(self.containerView).dividedBy(2.35);
                 make.left.equalTo(self.containerView.mas_centerX).offset(8);
                 make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(self.maxScreenForSuit/14.83);
             }];
            [self.attributeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.applyThemeButton.mas_leading);
                make.trailing.equalTo(self.editThemeButton.mas_trailing);
                make.top.equalTo(self.applyThemeButton.mas_bottom).offset(17);
                make.height.greaterThanOrEqualTo(@0);
            }];
            
        }
            break;
        case CMThemeModelType_Fetched:
        case CMThemeModelType_Cached:
        {
            switch (self.themeDetailViewModel.themeType) {
                case CMThemeType_Download:
                case CMThemeType_Update:
                {
                    [self.containerView addSubview:self.downloadButton];
                    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make)
                     {
                         make.height.equalTo(self.containerView.mas_width).dividedBy(7.56);
                         make.width.equalTo(self.containerView).dividedBy(1.153);
                         make.centerX.equalTo(self.containerView);
                         make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(self.maxScreenForSuit/14.83);
                     }];
                    [self.attributeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(self.downloadButton.mas_leading);
                        make.trailing.equalTo(self.downloadButton.mas_trailing);
                        make.top.equalTo(self.downloadButton.mas_bottom).offset(17);
                        make.height.greaterThanOrEqualTo(@0);
                    }];
                }
                    break;
                case CMThemeType_None:
                {
                    [self.containerView addSubview:self.applyThemeButton];
                    [self.containerView addSubview:self.editThemeButton];
                    [self.applyThemeButton mas_makeConstraints:^(MASConstraintMaker *make)
                     {
                         make.height.equalTo(self.containerView.mas_width).dividedBy(7.56);
                         make.width.equalTo(self.containerView).dividedBy(2.35);
                         make.right.equalTo(self.containerView.mas_centerX).offset(-8);
                         make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(self.maxScreenForSuit/14.83);
                     }];
                    [self.editThemeButton mas_makeConstraints:^(MASConstraintMaker *make)
                     {
                         make.height.equalTo(self.containerView.mas_width).dividedBy(7.56);
                         make.width.equalTo(self.containerView).dividedBy(2.35);
                         make.left.equalTo(self.containerView.mas_centerX).offset(8);
                         make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(self.maxScreenForSuit/14.83);
                     }];
                    [self.attributeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(self.applyThemeButton.mas_leading);
                        make.trailing.equalTo(self.editThemeButton.mas_trailing);
                        make.top.equalTo(self.applyThemeButton.mas_bottom).offset(17);
                        make.height.greaterThanOrEqualTo(@0);
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
    }
    
    [self.closeDetailButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.width.equalTo(self.containerView).dividedBy(11.48);
        make.height.equalTo(self.closeDetailButton.mas_width);
        make.right.equalTo(self.containerView.mas_right).with.offset(-5);
        make.top.equalTo(self.containerView.mas_top).with.offset(7);
    }];
    
    [self.themeSizeLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.right.equalTo(self.containerView.mas_right).with.offset(-7);
        make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(6.5);
    }];

    if (self.themeUpdateMarkImageView.superview) {
        [self.themeUpdateMarkImageView mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.equalTo(self.view).dividedBy(23.30);
             make.height.equalTo(self.themeUpdateMarkImageView.mas_width);
             make.left.equalTo(self.containerView.mas_left).with.offset(10.25);
             make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(9.2);
         }];
    }
    
    if (!self.themeUpdateMarkImageView.superview) {
        [self.themeUpdateAndDateLabel.superview addSubview:self.themeUpdateMarkImageView];
    }
    
    if (self.themeUpdateAndDateLabel.superview) {
        [self.themeUpdateAndDateLabel mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(self.themeCoverImageView.mas_bottom).with.offset(6.5);
             make.left.equalTo(self.themeUpdateMarkImageView.mas_right).with.offset(5);
             make.left.equalTo(self.containerView.mas_left).with.offset(10.25).priority(250);
         }];
    }
    
    if (!self.downloadButton.superview) {
        [self.downThemeProgressView.superview addSubview:self.downloadButton];
    }

    [self.downThemeProgressView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.downloadButton.mas_left);
        make.centerY.equalTo(self.downloadButton);
        make.width.equalTo(self.containerView.mas_width).dividedBy(1.386);
        make.height.equalTo(@(self.maxScreenForSuit/96.6));
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.downThemeProgressView.mas_right).with.offset(self.maxScreenForSuit/62.92);
        make.centerY.equalTo(self.downloadButton);
    }];
    
    [self.downFailedView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.centerX.equalTo(self.containerView);
        make.bottom.equalTo(self.downloadButton.mas_top).with.offset(-5);
    }];
    
    [self.downFailedIconImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.downFailedView);
        make.top.equalTo(self.downFailedView);
        make.bottom.equalTo(self.downFailedView);
        make.width.equalTo(self.containerView.mas_width).dividedBy(23.6);
        make.height.equalTo(self.downFailedIconImageView.mas_width);
    }];
    
    [self.downFailedTextLabel mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.downFailedIconImageView.mas_right).with.offset(5);
        make.top.equalTo(self.downFailedView);
        make.right.equalTo(self.downFailedView);
        make.bottom.equalTo(self.downFailedView);
    }];
    
    kLog(@"self.view = %p", self.view);
    kLog(@"self.containerView = %p", self.containerView);
    kLog(@"self.themeCoverImageView = %p", self.themeCoverImageView);
    kLog(@"self.closeDetailButton = %p", self.closeDetailButton);
    kLog(@"self.themeSizeLabel = %p", self.themeSizeLabel);
    kLog(@"self.themeUpdateMarkImageView = %p", self.themeUpdateMarkImageView);
    kLog(@"self.themeUpdateAndDateLabel = %p", self.themeUpdateAndDateLabel);
    kLog(@"self.downThemeProgressView = %p", self.downThemeProgressView);
    kLog(@"self.progressLabel = %p", self.progressLabel);
    kLog(@"self.downFailedView = %p", self.downFailedView);
    kLog(@"self.downFailedIconImageView = %p", self.downFailedIconImageView);
    kLog(@"self.downFailedTextLabel = %p", self.downFailedTextLabel);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView *)containerView
{
    if (!_containerView)
    {
        _containerView = [[UIView alloc] init];
        self.view.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:47.0/255.0 blue:73.0/255.0 alpha:255.0];
        _containerView.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:47.0/255.0 blue:73.0/255.0 alpha:255.0];
    }
    return _containerView;
}

- (void)setCoverImageString:(NSString *)coverImageString
{
    _coverImageString = [coverImageString copy];
    self.themeCoverImageView.image = [UIImage imageNamed:coverImageString];
}

- (UIView *)themeCoverImageView
{
    if (!_themeCoverImageView)
    {
        _themeCoverImageView = [[UIImageView alloc] init];
        
        if (self.themeDetailViewModel.viewModel.type == CMThemeModelType_Default)
        {
            _themeCoverImageView.image = [UIImage imageNamed:self.themeDetailViewModel.coverUrlString];
        }else if (self.themeDetailViewModel.viewModel.type == CMThemeModelType_Custom) {
            _themeCoverImageView.image = [UIImage imageWithContentsOfFile:self.themeDetailViewModel.coverUrlString];
        }else
        {
            @weakify(self)
            [self.themeCoverImageView yy_setImageWithURL:[NSURL URLWithString:self.themeDetailViewModel.coverUrlString] placeholder:nil options:(YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                @stronglize(self)
                [self.animationView pause];
                [self.animationView removeFromSuperview];
            }];
        }
    }
    return _themeCoverImageView;
}

- (void) reportDownloadError:(CMError*) error
{
    NSInteger classType;
    if (error.code == NSURLErrorNotConnectedToInternet)
    {
        if (self.themeDetailViewModel.themeType == CMThemeType_Download)
        {
            classType = 5;
        }
        else
        {
            classType = 7;
        }
    }
    else
    {
        if (self.themeDetailViewModel.themeType == CMThemeType_Download)
        {
            classType = 6;
        }
        else
        {
            classType = 8;
        }
    }
    
    [CMHostInfoc reportCheetahkeyboard_main_theme_downWithThemeName:self.themeDetailViewModel.themeName xy:(self.themeDetailViewModel.themeIndex + 1) action:self.themeDetailViewModel.themeType classType:classType];
}

- (UIButton *)closeDetailButton
{
    if (!_closeDetailButton)
    {
        _closeDetailButton = [[UIButton alloc] init];
        [_closeDetailButton setBackgroundImage:[UIImage imageNamed:@"Close_Theme_Detail"] forState:UIControlStateNormal];
        [_closeDetailButton setBackgroundImage:[UIImage imageNamed:@"Close_Theme_Detail_Press"] forState:UIControlStateHighlighted];
        [_closeDetailButton addTarget:self action:@selector(dismissPopUpController) forControlEvents:UIControlEventTouchUpInside];
        [_closeDetailButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15.0, -15.0, -15.0, -15.0)];
    }
    
    return _closeDetailButton;
}

- (UILabel *)themeSizeLabel
{
    if (!_themeSizeLabel)
    {
        _themeSizeLabel = [[UILabel alloc] init];
        _themeSizeLabel.textAlignment = NSTextAlignmentCenter;
        _themeSizeLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:146.0/255.0 blue:165.0/255.0 alpha:255.0];
        _themeSizeLabel.font =  [UIFont  fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/56.30];
        _themeSizeLabel.text = self.themeDetailViewModel.zipSizeString;
        [_themeSizeLabel sizeToFit];
    }
    
    return _themeSizeLabel;
}

- (UIImageView *)themeUpdateMarkImageView
{
    if (!_themeUpdateMarkImageView)
    {
        _themeUpdateMarkImageView = [[UIImageView alloc] init];
        _themeUpdateMarkImageView.image = [UIImage imageNamed:@"Update_Available"];
    }
    
    return _themeUpdateMarkImageView;
}

- (UILabel *)themeUpdateAndDateLabel
{
    if (!_themeUpdateAndDateLabel)
    {
        _themeUpdateAndDateLabel = [[UILabel alloc] init];
        _themeUpdateAndDateLabel.textAlignment = NSTextAlignmentCenter;
        _themeUpdateAndDateLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:146.0/255.0 blue:165.0/255.0 alpha:255.0];
        _themeUpdateAndDateLabel.font =  [UIFont  fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/56.30];
        if (self.themeDetailViewModel.themeType == CMThemeType_Download)
        {
            _themeUpdateAndDateLabel.text = self.themeDetailViewModel.themeTitle;
        }
        else
        {
            _themeUpdateAndDateLabel.text = CMLocalizedString(@"Update_Available", nil);
        }
        
        [_themeUpdateAndDateLabel sizeToFit];
    }
    
    return _themeUpdateAndDateLabel;
}

- (CMDownProgress *)downThemeProgressView
{
    if (!_downThemeProgressView)
    {
        _downThemeProgressView = [[CMDownProgress alloc] init];
        _downThemeProgressView.backColor = [UIColor colorWithRed:30.0/255.0 green:35.0/255.0 blue:53.0/255.0 alpha:1.0f];
        _downThemeProgressView.progressColor = [UIColor colorWithRed:137.0/255.0 green:251.0/255.0 blue:250.0/255.0 alpha:1.0f];
        _downThemeProgressView.hidden = YES;
    }
    
    return _downThemeProgressView;
}

- (UILabel *)progressLabel
{
    if (!_progressLabel)
    {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/48.1];
        _progressLabel.text = @"0%";
        [_progressLabel sizeToFit];
        _progressLabel.hidden = YES;
    }
    
    return _progressLabel;
}

- (UIView *)downFailedView
{
    if (!_downFailedView)
    {
        _downFailedView = [[UIView alloc] init];
        _downFailedView.hidden = YES;
    }
    
    return _downFailedView;
}

- (UIImageView *)downFailedIconImageView
{
    if (!_downFailedIconImageView)
    {
        _downFailedIconImageView = [[UIImageView alloc] init];
        _downFailedIconImageView.image = [UIImage imageNamed:@"icon_warning"];
    }
    
    return _downFailedIconImageView;
}

- (UILabel *)downFailedTextLabel
{
    if (!_downFailedTextLabel)
    {
        _downFailedTextLabel = [[UILabel alloc] init];
        _downFailedTextLabel.textAlignment = NSTextAlignmentCenter;
        _downFailedTextLabel.textColor = [UIColor colorWithRed:132.0/255.0 green:146.0/255.0 blue:167.0/255.0 alpha:1.0];
        _downFailedTextLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/87];
        _downFailedTextLabel.text = CMLocalizedString(@"Download_failed_please_check_your_network", nil);;
        [_downFailedTextLabel sizeToFit];
    }
    
    return _downFailedTextLabel;
}

- (UILabel *)attributeLabel
{
    if (!_attributeLabel) {
        _attributeLabel = [[UILabel alloc] init];
        _attributeLabel.userInteractionEnabled = YES;
        _attributeLabel.numberOfLines = 0;
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] init];
        NSString * str1 = CMLocalizedString(@"DownLoadTheme_FullAccess_tip", nil);
        NSString * str2 = CMLocalizedString(@"Full_Access_Now", nil);
        [attriStr.mutableString appendString:str1];
        [attriStr.mutableString appendString:str2];
        [attriStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_RGBA(132, 146, 167, 1) range:NSMakeRange(0, [str1 length])];
        [attriStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_RGBA(44, 255, 253, 1) range:NSMakeRange([str1 length], [str2 length])];
        [attriStr addAttribute:NSFontAttributeName value:[CMBizHelper getFontWithSize:9] range:NSMakeRange(0, [attriStr.mutableString length])];
        
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
         paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 2;
        [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attriStr.mutableString length])];
        _attributeLabel.attributedText = attriStr;
        
        [_attributeLabel addSubview:self.fullAccessTipButton];
        [self.fullAccessTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_attributeLabel);
        }];
        
    }
    return _attributeLabel;
}

- (UIButton *)fullAccessTipButton
{
    if (!_fullAccessTipButton) {
        _fullAccessTipButton = [[UIButton alloc] init];
        _fullAccessTipButton.backgroundColor = [UIColor clearColor];
        [_fullAccessTipButton addTarget:self action:@selector(fullAccessTipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullAccessTipButton;
}

- (LOTAnimationView *)animationView
{
    if (!_animationView)
    {
        _animationView = [LOTAnimationView animationNamed:@"LoadingDotsLoop"];
        _animationView.contentMode = UIViewContentModeScaleAspectFill;
        _animationView.loopAnimation = YES;
        [_animationView play];
    }
    
    return _animationView;
}

- (void) dismissPopUpController
{
    [CMHostInfoc reportCheetahkeyboard_main_theme_downWithThemeName:self.themeDetailViewModel.themeName xy:(self.themeDetailViewModel.themeIndex + 1) action:self.themeDetailViewModel.themeType classType:3];
    [self.delegate dismissPopupView];
    [self cancleTask];
}

- (void) dismissPopUpControllerWhileDownSuccess
{
    [CMHostInfoc reportCheetahkeyboard_main_theme_downWithThemeName:self.themeDetailViewModel.themeName xy:(self.themeDetailViewModel.themeIndex + 1) action:self.themeDetailViewModel.themeType classType:4];
    [self.delegate dismissPopupView];
    [self cancleTask];
}

- (void) cancleTask
{
    if (self.downloadTask)
    {
        [self.downloadTask cancel];
        self.downloadTask = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    kLogInfo(@"self.view frame(%@), self.containerView frame(%@), self.imageView frame:(%@)", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.containerView.frame), NSStringFromCGRect(self.themeCoverImageView.frame));
}

- (void)fullAccessTipButtonClick
{
    if ([CMBizHelper shouldUseABTestAtInitPage])
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

#pragma mark - Action
- (void)downloadBtnTapped:(UIButton *)sender
{
    self.downloadButton.hidden = YES;
    self.downThemeProgressView.hidden = NO;
    self.progressLabel.hidden = NO;
    self.downThemeProgressView.progress = 0;
    if (![self.downFailedView isHidden])
    {
        self.downFailedView.hidden = YES;
    }
    
    [CMHostInfoc reportCheetahkeyboard_main_theme_downWithThemeName:self.themeDetailViewModel.themeName xy:(self.themeDetailViewModel.themeIndex + 1) action:self.themeDetailViewModel.themeType classType:self.themeDetailViewModel.themeType];
    
    @weakify(self)
    self.downloadTask = [self.themeManager downloadTheme:self.themeDetailViewModel.viewModel progressBlock:^(NSProgress *downloadProgress)
                         {
                             @stronglize(self)
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 float fPress = ((float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount);
                                 if (fPress < 0)
                                 {
                                     fPress = 0;
                                 }
                                 int nPress = (int)(fPress * 100);
                                 
                                 self.progressLabel.text = [NSString stringWithFormat:@"%d%%", nPress];
                                 [self.downThemeProgressView setProgress:((float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount)];
                             });
                         } completeBlock:^(NSURLResponse *response, NSURL *filePath, CMError *error)
                         {
                             @stronglize(self)
                             if (!error)
                             {
                                 [self dismissPopUpControllerWhileDownSuccess];
                                 [self.delegate themeDownloadFinish:self.themeDetailViewModel.viewModel indexPath:self.indexPath];
                             }
                             else
                             {
                                 self.downFailedView.hidden = NO;
                                 self.downloadButton.hidden = NO;
                                 self.downThemeProgressView.hidden = YES;
                                 self.progressLabel.hidden = YES;
                                 self.downloadButton.hidden = NO;
                                 
                                 [self reportDownloadError:error];
                             }
                             self.downloadTask = nil;
                         }];
    [self.downloadTask resume];
}

- (void)editTheme:(UIButton *)sender
{
    [self.delegate dismissPopupView];
    [self.delegate themeDiyTapped:self.themeDetailViewModel.viewModel indexPath:self.indexPath];
}

- (void)applyTheme:(UIButton *)sender
{
    [self.delegate dismissPopupView];
    [self.delegate themeApplyTapped:self.themeDetailViewModel.viewModel indexPath:self.indexPath];
}

#pragma mark - setter/getter
- (UIButton *)downloadButton
{
    if (!_downloadButton)
    {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton setBackgroundImage:[UIImage imageWithColor:rgb(74, 255, 252)] forState:UIControlStateNormal];
        [_downloadButton setBackgroundImage:[UIImage imageWithColor:rgb(72, 157, 161)] forState:UIControlStateHighlighted];
        int corner;
        if([UIDevice isHeight896] || [UIDevice isHeight812]){
            corner = 38;
        } else {
            corner = 28;
        }
        _downloadButton.layer.cornerRadius = self.maxScreenForSuit/corner;
        _downloadButton.layer.masksToBounds = YES;
        [_downloadButton setTitleColor:rgb(11, 16, 41) forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = [CMBizHelper getFontWithSize:self.maxScreenForSuit/44.1];
        if (self.themeDetailViewModel.themeType == CMThemeType_Download)
        {
            [_downloadButton setImage:[UIImage imageNamed:@"Theme_Download"] forState:UIControlStateNormal];
            [_downloadButton setTitle:CMLocalizedString(@"DOWNLOAD", nil) forState:UIControlStateNormal];
        }
        else
        {
            [_downloadButton setImage:[UIImage imageNamed:@"Theme_Update"] forState:UIControlStateNormal];
            [_downloadButton setTitle:CMLocalizedString(@"UPDATE", nil) forState:UIControlStateNormal];
        }

        [_downloadButton addTarget:self action:@selector(downloadBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (UIButton *)editThemeButton
{
    if (!_editThemeButton) {
        _editThemeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editThemeButton setBackgroundImage:[UIImage imageWithColor:rgb(74, 255, 252)] forState:UIControlStateNormal];
        [_editThemeButton setBackgroundImage:[UIImage imageWithColor:rgb(72, 157, 161)] forState:UIControlStateHighlighted];
        _editThemeButton.layer.cornerRadius = self.maxScreenForSuit/28;
        _editThemeButton.layer.masksToBounds = YES;
        [_editThemeButton setTitle:CMLocalizedString(@"EDIT", nil) forState:UIControlStateNormal];
        [_editThemeButton setTitleColor:rgb(11, 16, 41) forState:UIControlStateNormal];
        _editThemeButton.titleLabel.font = [CMBizHelper getFontWithSize:self.maxScreenForSuit/44.1];
        [_editThemeButton addTarget:self action:@selector(editTheme:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editThemeButton;
}

- (UIButton *)applyThemeButton
{
    if (!_applyThemeButton) {
        _applyThemeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_applyThemeButton setBackgroundImage:[UIImage imageWithColor:rgb(74, 255, 252)] forState:UIControlStateNormal];
        [_applyThemeButton setBackgroundImage:[UIImage imageWithColor:rgb(72, 157, 161)] forState:UIControlStateHighlighted];
        _applyThemeButton.layer.cornerRadius = self.maxScreenForSuit/28;
        _applyThemeButton.layer.masksToBounds = YES;
        [_applyThemeButton setTitle:CMLocalizedString(@"APPLY", nil) forState:UIControlStateNormal];
        [_applyThemeButton setTitleColor:rgb(11, 16, 41) forState:UIControlStateNormal];
        _applyThemeButton.titleLabel.font = [CMBizHelper getFontWithSize:self.maxScreenForSuit/44.1];
        [_applyThemeButton addTarget:self action:@selector(applyTheme:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyThemeButton;
}
@end
