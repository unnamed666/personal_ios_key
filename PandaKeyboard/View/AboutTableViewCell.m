//
//  AboutTableViewCell.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "AboutTableViewCell.h"
#import "CMBizHelper.h"

@interface AboutTableViewCell ()

@property (strong, nonatomic) UILabel* itemTitleLabelTop;
@property (strong, nonatomic) UILabel* itemTitleLabelBottom;

@end


@implementation AboutTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self itemTitleLabelTop];
    }
    return self;
}


- (UILabel *)itemTitleLabelTop
{
    UIView* theContainer = [[UIView alloc] init];
    [self.contentView addSubview:theContainer];
    [theContainer mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.mas_left).with.offset(kScreenHeight/40.06);
         make.right.equalTo(self.mas_right).with.offset(-KScalePt(10));
         make.centerY.equalTo(self);
     }];
    
    if (!_itemTitleLabelTop || !_itemTitleLabelBottom)
    {
        _itemTitleLabelTop = [[UILabel alloc] init];
        _itemTitleLabelTop.numberOfLines = 0;
        _itemTitleLabelTop.lineBreakMode = NSLineBreakByWordWrapping;
        _itemTitleLabelTop.textAlignment = NSTextAlignmentLeft;
        _itemTitleLabelTop.textColor = [UIColor whiteColor];
        _itemTitleLabelTop.font =  [UIFont fontWithName:@"Montserrat-Regular" size:kScreenHeight/44.1];
        
        [theContainer addSubview:_itemTitleLabelTop];
        [_itemTitleLabelTop mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(theContainer.mas_left);
             make.top.equalTo(theContainer.mas_top);
             make.right.equalTo(theContainer.mas_right);
         }];
        
        _itemTitleLabelBottom = [[UILabel alloc] init];
        
        _itemTitleLabelBottom.textAlignment = NSTextAlignmentCenter;
        _itemTitleLabelBottom.textColor = [UIColor colorWithRed:141.0/255.0 green:142.0/255.0 blue:155.0/255.0 alpha:1.0];
        _itemTitleLabelBottom.font =  [UIFont fontWithName:@"Montserrat-Regular" size:kScreenHeight/60.6];
        _itemTitleLabelBottom.lineBreakMode = NSLineBreakByWordWrapping;
        _itemTitleLabelBottom.numberOfLines = 0;
        _itemTitleLabelBottom.textAlignment = NSTextAlignmentLeft;
        
        [theContainer addSubview:_itemTitleLabelBottom];
        [_itemTitleLabelBottom mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(theContainer.mas_left);
             make.right.equalTo(theContainer.mas_right);
             make.top.equalTo(_itemTitleLabelTop.mas_bottom);
             make.bottom.equalTo(theContainer);
         }];
    }
    
    return _itemTitleLabelTop;
}

- (UILabel *)itemTitleLabelBottom
{
    if (!_itemTitleLabelBottom)
    {
        
    }
    
    return _itemTitleLabelBottom;
}

- (void)setTitleTop:(NSString *)titleTop
{
    self.itemTitleLabelTop.text = titleTop;
}

- (void)setTitleBottom:(NSString *)titleBottom
{
    self.itemTitleLabelBottom.text = titleBottom;
}


@end
