//
//  CMDisCoveryTableViewCell.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/26.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDisCoveryTableViewCell.h"

@interface CMDisCoveryTableViewCell ()
@property (nonatomic, strong) UIImageView * discoveryView;
@end

@implementation CMDisCoveryTableViewCell

-(void)setImageName:(NSString *)imageName
{
    _imageName = [imageName copy];
    _discoveryView.image = [UIImage imageNamed:imageName];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = COLOR_WITH_RGBA(14, 17, 41, 1);
    
        _discoveryView = [[UIImageView alloc] init];
        _discoveryView.userInteractionEnabled = YES;
        _discoveryView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_discoveryView];
        
        [_discoveryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).offset(KScalePt(13));
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-KScalePt(13));
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

@end
