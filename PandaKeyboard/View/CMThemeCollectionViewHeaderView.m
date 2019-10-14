//
//  CMThemeCollectionViewHeaderView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMThemeCollectionViewHeaderView.h"
#import "UIColor+HexColors.h"
#import "CMBizHelper.h"

@interface CMThemeCollectionViewHeaderView ()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * allCustomThemeButton;
@property (nonatomic, strong) UIView * customThemeRedRoundMark;
@end

@implementation CMThemeCollectionViewHeaderView

-(void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.text = title;
}

- (void)setShowAllCustomThemeButton:(BOOL)showAllCustomThemeButton
{
    _showAllCustomThemeButton = showAllCustomThemeButton;
    _allCustomThemeButton.hidden = !showAllCustomThemeButton;
 
    if (showAllCustomThemeButton && [[NSUserDefaults standardUserDefaults] boolForKey:kIsShowCustomThemeRedRoundMarkOnContainerApp])
    {
        self.customThemeRedRoundMark.hidden = !showAllCustomThemeButton;
    }
    else
    {
        self.customThemeRedRoundMark.hidden = YES;
    }
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.allCustomThemeButton];
        [self addSubview:self.customThemeRedRoundMark];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.mas_leading).offset(13);
            make.centerY.equalTo(self.mas_centerY);
            make.width.greaterThanOrEqualTo(@0);
            make.height.greaterThanOrEqualTo(@0);
        }];
                
        [self.allCustomThemeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.mas_trailing).offset(-20);
            make.centerY.equalTo(self.mas_centerY);
            make.width.greaterThanOrEqualTo(@0);
            make.height.greaterThanOrEqualTo(@0);
        }];
        
        [self.customThemeRedRoundMark mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(self.titleLabel);
             make.left.equalTo(self.titleLabel.mas_right);
             make.width.height.equalTo(@(KScalePt(6)));
         }];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = COLOR_WITH_RGBA(132, 146, 167, 1);
        _titleLabel.font = [CMBizHelper getFontWithSize:13];
    }
    return _titleLabel;
}

- (UIButton *)allCustomThemeButton
{
    if (!_allCustomThemeButton) {
        _allCustomThemeButton = [[UIButton alloc] init];
        [_allCustomThemeButton setTitle:CMLocalizedString(@"See_All", nil) forState:UIControlStateNormal];
        _allCustomThemeButton.titleLabel.font = [CMBizHelper getFontWithSize:13];
        [_allCustomThemeButton setTitleColor:COLOR_WITH_RGBA(132, 146, 167, 1) forState:UIControlStateNormal];
        [_allCustomThemeButton addTarget:self action:@selector(allCustomThemeButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _allCustomThemeButton.hidden = YES;
    }
    return _allCustomThemeButton;
}

- (void)allCustomThemeButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeCollectionViewHeaderViewSeeAllButtonClick)]) {
        [self.delegate themeCollectionViewHeaderViewSeeAllButtonClick];
    }
}

- (UIView *)customThemeRedRoundMark
{
    if (!_customThemeRedRoundMark)
    {
        _customThemeRedRoundMark = [[UIView alloc] init];
        _customThemeRedRoundMark.tag = 100;
        _customThemeRedRoundMark.backgroundColor = [UIColor redColor];
        _customThemeRedRoundMark.layer.cornerRadius = 3;
    }
    
    return _customThemeRedRoundMark;
}

- (void) removeRedRoundMark
{
    self.customThemeRedRoundMark.hidden = YES;
}
@end
