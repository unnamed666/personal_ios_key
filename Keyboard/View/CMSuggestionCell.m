//
//  CMSuggestionCell.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMSuggestionCell.h"
#import "CMSuggestionCellViewModel.h"
//#import "SwiftTheme-Swift.h"
#import "NSString+Common.h"
#import "NSDictionary+Common.h"
#import "UIView+Util.h"
#import "UIColor+HexColors.h"
#import "UIImage+Util.h"
#import "UIColor+Biz.h"
#import "UIFont+Biz.h"
#import "UIImage+Biz.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"

@interface CMSuggestionCell (){
    BOOL cloudColorChanged;
}
@property (nonatomic, strong)UILabel* titleLabel;
@property (nonatomic, strong)UIImageView* bgImageView;
@property (nonatomic, strong)UIImageView* cloudPredictionImageView;
@property (nonatomic, strong)CMSuggestionCellViewModel* viewModel;

@end

@implementation CMSuggestionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.bgImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.cloudPredictionImageView];

        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(18);
            make.trailing.equalTo(self.contentView).offset(-18).priority(999);
            make.height.equalTo(self.contentView);
        }];
        
        [self.cloudPredictionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.titleLabel.mas_left).offset(-4);
            make.top.mas_equalTo(self.titleLabel.mas_top).offset(3);
            make.width.mas_equalTo(9);
//            make.height.mas_equalTo(8);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width;
    [super layoutSubviews];
}


- (void)bindData:(CMSuggestionCellViewModel *)viewModel {
    if (self.viewModel != viewModel) {
        self.titleLabel.text = viewModel.titleLabelText;
        if (viewModel.isEmphasize) {
            self.cloudPredictionImageView.hidden = YES;
            self.titleLabel.font = kCMKeyboardManager.themeManager.predictCellTextFont;
            self.titleLabel.textColor = kCMKeyboardManager.themeManager.predictCellEmphasizeTextColor;
            self.titleLabel.highlightedTextColor = kCMKeyboardManager.themeManager.predictCellEmphasizeHighlightTextColor;
        }
        else {
            self.titleLabel.font = kCMKeyboardManager.themeManager.predictCellTextFont;
            self.titleLabel.textColor = kCMKeyboardManager.themeManager.predictCellTextColor;
            self.titleLabel.highlightedTextColor = kCMKeyboardManager.themeManager.predictCellHighlightTextColor;
        }
        
        if (viewModel.isCloudWord) {
            self.cloudPredictionImageView.hidden = NO;
            if(cloudColorChanged){
                cloudColorChanged = NO;
                _cloudPredictionImageView.image =  [self cloudPredictionImageWithTintColor:nil];
            }
        }
        else {
            self.cloudPredictionImageView.hidden = YES;
        }

        self.viewModel = viewModel;
        [self.contentView setNeedsLayout];
        [self.contentView layoutIfNeeded];
        viewModel.cachedSize = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    }
}
- (void)cloudPredictionImageViewTintColor:(UIColor*)tintColor{
    
    _cloudPredictionImageView.image = [self cloudPredictionImageWithTintColor:tintColor];
    cloudColorChanged = YES;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleLabel.textColor = titleColor;
}

#pragma mark - setter/getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 1;
        _titleLabel.preferredMaxLayoutWidth = self.bounds.size.width;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        [_titleLabel addBorderWithColor:[UIColor redColor]];
//        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        UIImage* image = kCMKeyboardManager.themeManager.predictCellBgImage;
        if (image == nil) {
            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.predictCellBgColor];
        }
        else {
            [_bgImageView setImage:image];
        }
    }
    return _bgImageView;
}

- (UIImageView *)cloudPredictionImageView{
    if(!_cloudPredictionImageView){
        _cloudPredictionImageView = [[UIImageView alloc] initWithImage:[self cloudPredictionImageWithTintColor:nil]];
        _cloudPredictionImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _cloudPredictionImageView;
}

#pragma mark - private

- (UIImage*)cloudPredictionImageWithTintColor:(UIColor*)TintColor{
    UIImage* iconImage = [UIImage imageNamed:@"cloud_prediction"];
    UIColor * iconTintColor = TintColor;
    if(!iconTintColor){
        iconTintColor = kCMKeyboardManager.themeManager.predictCellTextColor;
    }
    return iconTintColor?[iconImage imageWithTintColor:iconTintColor]:iconImage;
}


@end
