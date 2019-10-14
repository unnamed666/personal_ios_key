//
//  CMFullAccessTipView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMFullAccessTipView.h"

@interface CMFullAccessTipView ()

@property (nonatomic, strong) UIImageView * fullAccessBgView;
//@property (nonatomic, strong) UILabel * fullAccessLabel;
@property (nonatomic, strong) UILabel * fullNowLabel;
@property (nonatomic, strong) UIImageView * fullAccessIconView;

@end

@implementation CMFullAccessTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _fullAccessBgView = [[UIImageView alloc] init];
        UIImage * image = [UIImage imageNamed:@"fullAccess_bg"];
        UIImage * newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)];
        _fullAccessBgView.image = newImage;
        
        _fullAccessBgView.layer.shadowOffset = CGSizeMake(0, 2);
        _fullAccessBgView.layer.shadowOpacity = 0.5;
        _fullAccessBgView.layer.shadowColor = [COLOR_WITH_RGBA(0, 0, 0, 0.5) CGColor];
        _fullAccessBgView.layer.shadowRadius = 4.0;
        
        [self addSubview:_fullAccessBgView];
        [_fullAccessBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        self.label = [[UILabel alloc] init];
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
//        _fullAccessLabel.text = CMLocalizedString(@"FullAccess_Tip", nil);
        self.tipsType = CMTipsTypeCloudPrediction;
        self.label.font =  [CMBizHelper getFontWithSize:12];
        self.label.textColor = COLOR_WITH_RGBA(255, 255, 255, 1);
        [_fullAccessBgView addSubview:self.label];
        
        _fullNowLabel = [[UILabel alloc] init];
        _fullNowLabel.text = CMLocalizedString(@"Full_Now", nil);
        _fullNowLabel.font = [CMBizHelper getFontWithSize:12];
        _fullNowLabel.textColor = COLOR_WITH_RGBA(0, 255, 233, 1);
        [_fullNowLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_fullAccessBgView addSubview:_fullNowLabel];

        _fullAccessIconView = [[UIImageView alloc] init];
        _fullAccessIconView.image = [UIImage imageNamed:@"fullAccess_next"];
        _fullAccessIconView.contentMode = UIViewContentModeCenter;
        [_fullAccessBgView addSubview:_fullAccessIconView];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_fullAccessBgView.mas_leading).offset(10);
            make.top.equalTo(_fullAccessBgView.mas_top).offset(7);
            make.trailing.equalTo(_fullNowLabel.mas_leading).offset(-8);
            make.bottom.equalTo(_fullAccessBgView.mas_bottom).offset(-8);
        }];

        [_fullAccessIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_fullAccessBgView.mas_trailing).offset(-8);
            make.centerY.equalTo(_fullAccessBgView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(12, 21));
        }];
        
        [self.fullNowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_fullAccessIconView.mas_leading).offset(-8);
            make.centerY.equalTo(_fullAccessBgView.mas_centerY);
            make.width.greaterThanOrEqualTo(@0);
            make.height.greaterThanOrEqualTo(@0);
        }];

    }
    return self;
}


#pragma mark - getter/setter
- (void)setTipsType:(CMTipsType)tipsType
{
    _tipsType = tipsType;
    switch (_tipsType) {
        case CMTipsTypeCloudPrediction:
            self.label.text = CMLocalizedString(@"FullAccess_Tip", nil);
            break;
        case CMTipsTypeKeyboardSound:
            self.label.text = CMLocalizedString(@"Allow Full Access for Voice Key", nil);
            break;
        case CMTipsTypeCursorMove:
            self.label.text = CMLocalizedString(@"Allow Full Access for cursor", nil);
            break;
        case CMTipsTypeEmoticons:
            self.label.text = CMLocalizedString(@"Full Access to try funny AR-Emoticons feature", nil);
            break;
        case CMTipsTypeGif:
            self.label.text = CMLocalizedString(@"Gif_Full_Access_Tip", nil);
            break;
        default:
            break;
    }
}

@end
