//
//  CMLaunchViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/9/4.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMLaunchViewController.h"
#import "ZCAnimatedLabel.h"
#import "UIColor+HexColors.h"
#import "CMBizHelper.h"
#import "CMRouterManager.h"
#import "CMCustomTransitioningAnimation.h"
#import "AppDelegate.h"

@interface CMLaunchViewController ()<UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) CMCustomTransitioningAnimation * transitioningAnimation;
@end

@implementation CMLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.transitioningAnimation = [[CMCustomTransitioningAnimation alloc] init];
    self.transitioningDelegate = self;
    [self configLaunchView];
    
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitioningAnimation;
}

- (void)configLaunchView
{
    UIImageView * launchBackGroundView = [[UIImageView alloc] init];
    launchBackGroundView.image = [UIImage imageNamed:@"Launch"];
    //launchBackGroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:launchBackGroundView];
    [launchBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [launchBackGroundView layoutIfNeeded];
    
    UIImageView * iconView = [[UIImageView alloc] init];
    UIImageView * lightView = [[UIImageView alloc] init];
    lightView.image = [UIImage imageNamed:@"Logo_light"];
    [launchBackGroundView addSubview:lightView];
    //iconView.backgroundColor = [UIColor orangeColor];
    iconView.image = [UIImage imageNamed:@"Logo"];
    [launchBackGroundView addSubview:iconView];
    ZCAnimatedLabel * titleLabel = [[ZCAnimatedLabel alloc] init];
    [launchBackGroundView addSubview:titleLabel];
    CGFloat iconSizeWH = [CMBizHelper adapterScreenHeight]>[CMBizHelper adapterScreenWidth]?[CMBizHelper adapterScreenHeight]:[CMBizHelper adapterScreenHeight];
    CGSize iconSizeLast = CGSizeMake(135.5, 135.5);
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(iconSizeWH, iconSizeWH));
        make.centerX.mas_equalTo(launchBackGroundView.mas_centerX);
        make.centerY.mas_equalTo(launchBackGroundView.mas_centerY);
    }];
    [lightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(iconSizeLast);
        make.centerX.mas_equalTo(iconView.mas_centerX);
        make.centerY.mas_equalTo(iconView.mas_centerY);
    }];
    
    [launchBackGroundView layoutIfNeeded];
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [iconView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(iconSizeLast);
            make.centerY.mas_equalTo(launchBackGroundView.mas_centerY).offset(-70);
        }];
        [launchBackGroundView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
            [lightView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(iconSizeLast.width + 50, iconSizeLast.height + 50));
            }];
            [launchBackGroundView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
                [lightView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(iconSizeLast.width - 30, iconSizeLast.height - 30));
                }];
                [launchBackGroundView layoutIfNeeded];
            } completion:nil];
        }];
        
        titleLabel.animationDuration = 0.1;
        titleLabel.animationDelay = 0.02;
        NSMutableParagraphStyle *paramStyle = [[NSMutableParagraphStyle alloc] init];
        paramStyle.alignment = NSTextAlignmentCenter;
        NSAttributedString * attriString = [[NSAttributedString alloc] initWithString:@"Type Less, Say More" attributes:@{NSForegroundColorAttributeName:COLOR_WITH_RGBA(255, 255, 255, 1),NSFontAttributeName:[CMBizHelper getFontWithSize:18],NSParagraphStyleAttributeName:paramStyle}];
        titleLabel.attributedString = attriString;
        CGRect bounds = [attriString boundingRectWithSize:CGSizeMake([CMBizHelper adapterScreenWidth], CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading context:nil];
        //titleLabel.backgroundColor = [UIColor greenColor];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(launchBackGroundView);
            make.centerY.equalTo(launchBackGroundView.mas_centerY).offset(10);
            make.size.mas_equalTo(bounds.size);
        }];
        
        [titleLabel startAppearAnimation];
        
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
