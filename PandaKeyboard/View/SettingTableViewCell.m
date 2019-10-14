//
//  SettingTableViewCell.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/6/2.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "SettingTableViewCell.h"
#import "UIColor+HexColors.h"
#import "CMBizHelper.h"
//#import "AppDelegate.h"
//#import "Masonry/Masonry.h"

@interface SettingTableViewCell ()
{
    UIImageView * _iconImageView;
    UILabel     * _titleLabel;
    UIImageView * _nextIconImageView;
    UIView * _lineView;
    
    CGFloat screenHeight;
}

@end

@implementation SettingTableViewCell

-(void)setIconName:(NSString *)iconName
{
    _iconName = [iconName copy];
    _iconImageView.image = [UIImage imageNamed:iconName];
}

-(void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.text = title;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        screenHeight = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
        
        self.contentView.backgroundColor = COLOR_WITH_RGBA(14, 17, 41, 1);
    
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).offset(screenHeight/53.36);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(screenHeight/29.84, screenHeight/29.84));
        }];
        
        _nextIconImageView = [[UIImageView alloc] init];
        _nextIconImageView.image = [UIImage imageNamed:@"Setting_Go_Next"];
        [self.contentView addSubview:_nextIconImageView];
        [_nextIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-screenHeight/33.857);
            make.centerY.equalTo(_iconImageView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(screenHeight/98.25, screenHeight/58.25));
        }];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:screenHeight/45.1];
        _titleLabel.textColor = COLOR_WITH_RGBA(255, 255, 255, 1);
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).offset(screenHeight/12.467);
            make.trailing.equalTo(_nextIconImageView.mas_leading).offset(-9);
            make.centerY.equalTo(_iconImageView.mas_centerY);
            make.height.greaterThanOrEqualTo(@0);
        }];
        
        _lineView = [[UIView alloc] init];
//        _lineView.image = [UIImage imageNamed:@"separateLine"];
        _lineView.backgroundColor = COLOR_WITH_RGBA(50, 56, 77, 1);
        [self.contentView addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_titleLabel.mas_leading);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-20);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-1);
            make.height.equalTo(@0.8);
        }];
        
    }
    return self;
}

@end
