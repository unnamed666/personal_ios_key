//
//  PerferencesTableViewCell.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "PerferencesTableViewCell.h"
#import "CMBizHelper.h"

@interface PerferencesTableViewCell ()

@property (strong, nonatomic) UILabel* itemTitleLabelTop;
@property (strong, nonatomic) UILabel* itemTitleLabelBottom;

@property (nonatomic) CGFloat screenHeight;

@end

@implementation PerferencesTableViewCell

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
    
    self.screenHeight = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
    
    if (self)
    {
        [self itemTitleLabelTop];
        [self itemSwitch];
    }
    return self;
}


- (UILabel *)itemTitleLabelTop
{
    UIView* theContainer = [[UIView alloc] init];
    
    [self.contentView addSubview:theContainer];
    [theContainer mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.mas_left).with.offset(self.screenHeight/40.06);
        make.right.equalTo(self.mas_right).with.offset(-self.screenHeight/5.487);
        make.centerY.equalTo(self);
    }];
    
    if (!_itemTitleLabelTop || !_itemTitleLabelBottom)
    {
        _itemTitleLabelTop = [[UILabel alloc] init];
        
        _itemTitleLabelTop.textAlignment = NSTextAlignmentCenter;
        _itemTitleLabelTop.textColor = [UIColor whiteColor];
        _itemTitleLabelTop.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.screenHeight/44.1];
        
        [theContainer addSubview:_itemTitleLabelTop];
        [_itemTitleLabelTop mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(theContainer.mas_left);
             make.top.equalTo(theContainer.mas_top);
         }];
        
        _itemTitleLabelBottom = [[UILabel alloc] init];
        
        _itemTitleLabelBottom.textAlignment = NSTextAlignmentCenter;
        _itemTitleLabelBottom.textColor = [UIColor colorWithRed:141.0/255.0 green:142.0/255.0 blue:155.0/255.0 alpha:1.0];
        _itemTitleLabelBottom.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.screenHeight/60.6];
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

- (CMUISwitch *)itemSwitch
{
    if (!_itemSwitch)
    {
        _itemSwitch = [[CMUISwitch alloc] initWithFrame:(CGRect){ CGPointZero, { self.screenHeight/20.43, self.screenHeight/37.68 } }];
        _itemSwitch.thumbImage = [UIImage imageNamed:@"Switch_Toggle_On"];
        _itemSwitch.thumbHighlightImage = [UIImage imageNamed:@"Switch_Toggle_Off"];
        _itemSwitch.trackMaskImage = [UIImage imageNamed:@"Switch_Back_Off"];
        _itemSwitch.trackImageOn = [UIImage imageNamed:@"Switch_Back_On"];
        _itemSwitch.trackImageOff = [UIImage imageNamed:@"Switch_Back_Off"];
    }
    
    [self.contentView addSubview:_itemSwitch];
    
    [_itemSwitch mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.right.equalTo(self.mas_right).with.offset(-self.screenHeight/33.857);
         make.centerY.equalTo(self.mas_centerY);
     }];
    
    return _itemSwitch;
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
