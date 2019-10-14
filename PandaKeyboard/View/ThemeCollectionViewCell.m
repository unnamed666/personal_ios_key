//
//  ThemeCollectionViewCell.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/23.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "ThemeCollectionViewCell.h"
#import "CMBizHelper.h"
#import <YYWebImage/YYWebImage.h>
#import <Lottie/Lottie.h>
#import "UIColor+HexColors.h"
#import "CMGroupDataManager.h"
#import "UIDevice+Util.h"

@interface ThemeCollectionViewCell ()
{
    //UIImageView * _selectedWrapImageView;
    CGFloat screenHeight;
}
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UIImageView * coverImageView;
@property (nonatomic, strong) UIImageView * selectedMarkImageView;
@property (nonatomic, strong) UIImageView * addMarkImage;
@property (nonatomic, strong) UIImageView * operatingMarkIconView;
@property (nonatomic, strong) UILabel     * themeNameLabel;
@property (nonatomic, strong) LOTAnimationView * animationView;
@property (nonatomic, assign) BOOL canSelected;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) UIButton * maskView;
@end

@implementation ThemeCollectionViewCell

- (void)setCanSelected:(BOOL)canSelected
{
    _canSelected = canSelected;
    
    if (canSelected == YES) {
        //_selectedWrapImageView.hidden = NO;
        _selectedMarkImageView.hidden = NO;
        _coverImageView.layer.borderColor = COLOR_WITH_RGBA(44, 255, 253, 1).CGColor;
        _coverImageView.layer.borderWidth = 2.0;
    }else{
        //_selectedWrapImageView.hidden = YES;
        _selectedMarkImageView.hidden = YES;
        _coverImageView.layer.borderColor = COLOR_WITH_RGBA(42, 246, 244, 0.26).CGColor;
        _coverImageView.layer.borderWidth = 1.0;
    }
    
#if defined(SCHEME)
    _addMarkImage.hidden = canSelected;
#endif
}


-(void)setThemeCellViewModel:(CMThemeCellViewModel *)themeCellViewModel indexPath:(NSIndexPath *)indexPath
{
    NSString* currentThemeName = kCMGroupDataManager.currentThemeName;
    if ([themeCellViewModel.themeName isEqualToString:currentThemeName]) {
        kLog(@"themeCellViewModel.themeName = %@   currentThemeName = %@", currentThemeName, currentThemeName);
        self.canSelected = YES;
    }
    else {
        self.canSelected = NO;
    }
    
    [_coverImageView.layer removeAllAnimations];
    
    if (themeCellViewModel.themeStatus == CMThemeStatusLocalDefault) {
        _operatingMarkIconView.hidden = YES;
        _themeNameLabel.hidden = YES;
        _coverImageView.image = [UIImage imageNamed:themeCellViewModel.coverImageUrlString];
        [_animationView pause];
        _animationView.hidden = YES;
        
    }else if (themeCellViewModel.themeStatus == CMThemeStatusCustom)
    {
        _operatingMarkIconView.hidden = YES;
        _themeNameLabel.hidden = YES;
        [_animationView pause];
        _animationView.hidden = YES;
        if (indexPath.row == 0) {
            _coverImageView.contentMode = UIViewContentModeCenter;
            _coverImageView.image = [UIImage imageNamed:themeCellViewModel.coverImageUrlString];
        }else{
            _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
            _coverImageView.image = [UIImage imageNamed:@""];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage * customThemeImage = [UIImage imageWithContentsOfFile:themeCellViewModel.coverImageUrlString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _coverImageView.image = customThemeImage;
                });
            });
            
        }
    }
    else {
        _themeNameLabel.hidden = NO;
//        _themeNameLabel.text = themeCellViewModel.themeTitle;
        @weakify(self)
        [_coverImageView yy_setImageWithURL:[NSURL URLWithString:themeCellViewModel.coverImageUrlString] placeholder:nil options:(YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            @stronglize(self)
            if (!error) {
                [self.animationView pause];
                self.animationView.hidden = YES;
            }else{
                self.animationView.hidden = NO;
                [self.animationView play];
            }
        }];
//        @weakify(self)
//        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:themeCellViewModel.coverImageUrlString] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            @stronglize(self);
//            if (image && cacheType == SDImageCacheTypeNone) {
//                CATransition * transition = [CATransition animation];
//                transition.type = kCATransitionFade;
//                transition.duration = 0.3;
//                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//                [self.coverImageView.layer addAnimation:transition forKey:nil];
//            }
//            if (!error) {
//                [self.animationView pause];
//                self.animationView.hidden = YES;
//            }else{
//                self.animationView.hidden = NO;
//                [self.animationView play];
//            }
//
//        }];

        if (themeCellViewModel.themeStatus == CMThemeStatusLocalDownload) {
            _operatingMarkIconView.hidden = NO;
            _operatingMarkIconView.image = [UIImage imageNamed:@"download"];
        }
        else if (themeCellViewModel.themeStatus == CMThemeStatusUpdateAvaliable) {
            _operatingMarkIconView.hidden = NO;
            _operatingMarkIconView.image = [UIImage imageNamed:@"Update_Available"];
        }
        else if (themeCellViewModel.themeStatus == CMThemeStatusNeedDownload) {
            _operatingMarkIconView.hidden = YES;
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        screenHeight =  SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
        
        _backView = [[UIView alloc] init];
        //_backView.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_backView];
        [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.backgroundColor = COLOR_WITH_RGBA(35, 39, 63, 1);
        _coverImageView.layer.cornerRadius = screenHeight/56.8;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.layer.borderColor = COLOR_WITH_RGBA(42, 246, 244, 0.26).CGColor;
        _coverImageView.layer.borderWidth = 1.0;
        [self.backView addSubview:_coverImageView];
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(KScalePt(4), KScalePt(4), KScalePt(18), KScalePt(4)));
        }];
        _selectedMarkImageView = [[UIImageView alloc] init];
        _selectedMarkImageView.image = [UIImage imageNamed:@"Theme_Item_Mark"];
        _selectedMarkImageView.hidden = YES;
        [self.backView addSubview:_selectedMarkImageView];
        [_selectedMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_coverImageView.mas_top).offset(-1);
            make.trailing.equalTo(_coverImageView.mas_trailing).offset(1);
            make.size.mas_equalTo(CGSizeMake((screenHeight/35.11), (screenHeight/35.11)));
        }];
        
#if defined(SCHEME)
        _addMarkImage = [[UIImageView alloc] init];
        _addMarkImage.image = [UIImage imageNamed:@"Add_Mark"];
        [self.contentView addSubview:_addMarkImage];
        [_addMarkImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_coverImageView.mas_bottom).offset(1);
            make.trailing.equalTo(_coverImageView.mas_trailing).offset(1);
            make.size.mas_equalTo(CGSizeMake((screenHeight/17.11), (screenHeight/35.11)));
        }];
#endif
        
        UIStackView* stackView = [UIStackView new];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFill;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.spacing = 6.0f;

        _operatingMarkIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KScalePt(7), KScalePt(7))];
        _operatingMarkIconView.hidden = YES;
        [_operatingMarkIconView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        _themeNameLabel = [[UILabel alloc] init];
        _themeNameLabel.textColor = COLOR_WITH_RGBA(132, 146, 167, 1);
        _themeNameLabel.font = [CMBizHelper getFontWithSize:11];
        _themeNameLabel.textAlignment = NSTextAlignmentLeft;
        _themeNameLabel.hidden = YES;
        
        [stackView addArrangedSubview:_operatingMarkIconView];
        [stackView addArrangedSubview:_themeNameLabel];
        
        [self.backView addSubview:stackView];
//        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.equalTo(self.contentView).offset(2);
//            make.trailing.equalTo(self.contentView.mas_trailing).offset(-6);
//            make.top.equalTo(_coverImageView.mas_bottom).offset(7);
//        }];
        
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(2);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-6);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];

        
        _animationView = [LOTAnimationView animationNamed:@"LoadingDotsLoop"];
        _animationView.contentMode = UIViewContentModeScaleAspectFill;
        _animationView.loopAnimation = YES;
        _animationView.hidden = NO;
        [_coverImageView addSubview:_animationView];
        
        [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_coverImageView);
            make.size.mas_equalTo(CGSizeMake((screenHeight/4.02) * 0.5, (screenHeight/5.464) * 0.5));
        }];
        
        [_animationView play];
        
        
        
        _maskView = [[UIButton alloc] init];
        _maskView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _maskView.hidden = YES;
        _maskView.layer.cornerRadius = screenHeight/56.8;
        _maskView.clipsToBounds = YES;
        [self.backView addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        _deleteButton = [[UIButton alloc] init];
       // _deleteButton.backgroundColor = [UIColor orangeColor];
        [_deleteButton setImage:[UIImage imageNamed:@"delete_diy"] forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 26, 26, 0)];
        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:_deleteButton];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.backView.mas_trailing);
            make.top.equalTo(self.backView.mas_top);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        
    }
    
    return self;
}

- (void)setDeleteButtonShouldShow:(BOOL)shouldShowDeleteButton shouldShowMaskView:(BOOL)shouldShowMaskView indexPath:(NSIndexPath *)indexPath
{
    self.deleteButton.hidden = !shouldShowDeleteButton;
    self.indexPath = indexPath;
    
    if (shouldShowDeleteButton == YES) {
        if (shouldShowMaskView == YES) {
            self.maskView.hidden = NO;
            self.maskView.backgroundColor = COLOR_WITH_RGBA(11, 16, 43, 0.65);
        }else{
            self.maskView.hidden = NO;
            self.maskView.backgroundColor = [UIColor clearColor];
        }
    }else{
        if (shouldShowMaskView == YES) {
            self.maskView.hidden = NO;
            self.maskView.backgroundColor = COLOR_WITH_RGBA(11, 16, 43, 0.65);
        }else{
            self.maskView.hidden = YES;
        }        
    }
}

- (void)deleteButtonClick:(UIButton *)deleteButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeCollectionViewCellDeleteButtonClickWithCell:)]) {
        [self.delegate themeCollectionViewCellDeleteButtonClickWithCell:self];
    }
}

@end
