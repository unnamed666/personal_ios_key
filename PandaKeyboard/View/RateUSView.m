//
//  RateUSView.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/24.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "RateUSView.h"
#import "UIImage+Util.h"
#import "CMBizHelper.h"
#import "CMAppConfig.h"
#import "UIButton+Util.h"

@interface RateUSView ()

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIButton* rateUsButton;
@property (nonatomic, strong) UIImageView* rateUsBackImageView;

@property (nonatomic) CGFloat maxScreenForSuit;
@property (nonatomic, strong) UILabel* rateUsLabel;
@property (nonatomic, strong) UIButton* closeRateUsButton;

@end

@implementation RateUSView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        self.maxScreenForSuit = kScreenHeight > kScreenWidth ? kScreenHeight : kScreenWidth;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.rateUsBackImageView];
        [self addSubview:self.rateUsButton];
        [self addSubview:self.rateUsLabel];
        [self addSubview:self.closeRateUsImageView];
        
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.edges.equalTo(self);
        }];
        
        [self.rateUsBackImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.width.equalTo(@(self.maxScreenForSuit/2.366));
            make.height.equalTo(@(self.maxScreenForSuit/2.923));
            make.centerX.equalTo(self);
            make.top.equalTo(self).with.offset(self.maxScreenForSuit/6.54);
        }];
        
        [self.rateUsButton mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.equalTo(@(self.maxScreenForSuit/2.97));
             make.height.equalTo(@(self.maxScreenForSuit/17.05));
             make.bottom.equalTo(self.rateUsBackImageView.mas_bottom).with.offset(-self.maxScreenForSuit/26.95);
             make.centerX.equalTo(self.rateUsBackImageView);
         }];
        
        [self.rateUsLabel mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.bottom.equalTo(self.rateUsButton.mas_top).with.offset(-self.maxScreenForSuit/34.95);
            make.left.right.equalTo(self.rateUsBackImageView);
            make.centerX.equalTo(self.rateUsBackImageView);
        }];
        
        [self.closeRateUsImageView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.equalTo(self.rateUsBackImageView.mas_top).with.offset(self.maxScreenForSuit/61.33);
            make.right.equalTo(self.rateUsBackImageView.mas_right).with.offset(-self.maxScreenForSuit/61.33);
            make.width.equalTo(@(self.maxScreenForSuit/48.42));
            make.height.equalTo(self.closeRateUsImageView.mas_width);
        }];
    }
    
    return self;
}

- (UIView *)backgroundView
{
    if (!_backgroundView)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0.0 blue:0.0 alpha:0.5f];
        
        if (NSClassFromString(@"UIBlurEffect"))
        {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        }
        
        UITapGestureRecognizer* backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backgroundView addGestureRecognizer:backGesture];
    }
    
    return _backgroundView;
}

- (void) backgroundTapped:(UITapGestureRecognizer*) theGesture
{
//    [self removeFromSuperview];
//    [self.delegate rateUsViewIsHidden];
    [CMHostInfoc reportCheetahkeyboard_star:1 click:0];
}

-(UIButton *)rateUsButton
{
    if (!_rateUsButton)
    {
        _rateUsButton = [[UIButton alloc] init];
        [_rateUsButton setTitle:@"Rate us" forState:UIControlStateNormal];
        [_rateUsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rateUsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_rateUsButton addTarget:self action:@selector(rateUsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _rateUsButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/38];
        _rateUsButton.backgroundColor = [UIColor blackColor];
        [_rateUsButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:137.0/255.0 green:252.0/255.0 blue:251.0/255.0 alpha:255.0]] forState:UIControlStateNormal];
        [_rateUsButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:70.0/255.0 green:157.0/255.0 blue:161.0/255.0 alpha:255.0]] forState:UIControlStateHighlighted];
        _rateUsButton.layer.cornerRadius = self.maxScreenForSuit/30.88;
        _rateUsButton.layer.masksToBounds = YES;
    }
    
    return _rateUsButton;
}

- (UIImageView *)rateUsBackImageView
{
    if (!_rateUsBackImageView)
    {
        _rateUsBackImageView = [[UIImageView alloc] init];
        _rateUsBackImageView.image = [UIImage imageNamed:@"Rate_Us_Back"];
        _rateUsBackImageView.userInteractionEnabled = YES;
    }
    
    return _rateUsBackImageView;
}

- (UILabel *)rateUsLabel
{
    if (!_rateUsLabel)
    {
        _rateUsLabel = [[UILabel alloc] init];
        _rateUsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _rateUsLabel.numberOfLines = 0;
        _rateUsLabel.textAlignment = NSTextAlignmentCenter;
        _rateUsLabel.text = CMLocalizedString(@"Love_Cheetah_Keyboard", nil);
        _rateUsLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:self.maxScreenForSuit/42];
        _rateUsLabel.textColor = [UIColor whiteColor];
    }
    
    return _rateUsLabel;
}

- (UIButton *)closeRateUsImageView
{
    if (!_closeRateUsButton)
    {
        _closeRateUsButton = [[UIButton alloc] init];
        [_closeRateUsButton setImage:[UIImage imageNamed:@"Rate_Us_Close"] forState:UIControlStateNormal];
        [_closeRateUsButton addTarget:self action:@selector(closeRateUsViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_closeRateUsButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15.0, -15.0, -15.0, -15.0)];
    }
    
    return _closeRateUsButton;
}
- (void) closeRateUsViewTapped:(UITapGestureRecognizer*) theGesture
{
    [self removeFromSuperview];
    [self.delegate rateUsViewIsHidden];
    [CMHostInfoc reportCheetahkeyboard_star:1 click:2];
}

- (void) rateUsButtonTapped:(id) theSender
{
    [self removeFromSuperview];
    NSString *appStoreUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", [CMAppConfig appleId]];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appStoreUrl]];
    [self.delegate rateUsViewIsHidden];
    [CMHostInfoc reportCheetahkeyboard_star:1 click:1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
