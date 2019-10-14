//
//  CMEmoticonPasteTip.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/10/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMEmoticonPasteTip.h"
@interface CMEmoticonPasteTip()
@property (nonatomic, strong) UIImageView * fullAccessBgView;
@end
@implementation CMEmoticonPasteTip

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
        self.label.font =  [CMBizHelper getFontWithSize:12];
        self.label.textColor = COLOR_WITH_RGBA(255, 255, 255, 1);
        [_fullAccessBgView addSubview:self.label];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_fullAccessBgView.mas_leading).offset(10);
            make.top.equalTo(_fullAccessBgView.mas_top).offset(7);
            make.trailing.equalTo(_fullAccessBgView.mas_trailing).offset(-8);
            make.bottom.equalTo(_fullAccessBgView.mas_bottom).offset(-8);
        }];
    }
    return self;
}
@end
