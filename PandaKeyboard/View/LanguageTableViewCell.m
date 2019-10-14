//
//  LanguageTableViewCell.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "LanguageTableViewCell.h"
#import "CMBizHelper.h"

@interface LanguageTableViewCell ()

@property(nonatomic, strong) UIView* labelContainerView;

@property (strong, nonatomic) UILabel* itemTitleLabelTop;
@property (strong, nonatomic) UILabel* itemTitleLabelBottom;

@property (nonatomic) CGFloat screenHeight;

@end

@implementation LanguageTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.screenHeight = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
        if (self)
        {
            [self labelContainerView];
            [self itemTitleLabelTop];
            [self languageCheckBox];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.screenHeight = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
    if (self)
    {
        [self labelContainerView];
        [self itemTitleLabelTop];
        [self languageCheckBox];
    }
    return self;
}

- (UIView *)labelContainerView
{
    if (!_labelContainerView)
    {
        _labelContainerView = [[UIView alloc] init];
        
        [self.contentView addSubview:_labelContainerView];
        [_labelContainerView mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.mas_left).with.offset(self.screenHeight/40.06);
             make.right.equalTo(self.mas_right).with.offset(-self.screenHeight/5.487);
             make.centerY.equalTo(self.contentView);
         }];
    }
    
    return _labelContainerView;
}

- (UILabel *)itemTitleLabelTop
{
    if (!_itemTitleLabelTop)
    {
        _itemTitleLabelTop = [[UILabel alloc] init];
        
        _itemTitleLabelTop.textAlignment = NSTextAlignmentCenter;
        _itemTitleLabelTop.textColor = [UIColor whiteColor];
        _itemTitleLabelTop.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.screenHeight/44.1];
        
        [self.labelContainerView addSubview:_itemTitleLabelTop];
        [_itemTitleLabelTop mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.labelContainerView.mas_left);
             make.top.equalTo(self.labelContainerView.mas_top);
         }];
    }
    
    return _itemTitleLabelTop;
}

- (void)setTitleTop:(NSString *)titleTop
{
    self.itemTitleLabelTop.text = titleTop;
}

- (UILabel *)itemTitleLabelBottom
{
    if (!_itemTitleLabelBottom)
    {
        _itemTitleLabelBottom = [[UILabel alloc] init];
        
        _itemTitleLabelBottom.textAlignment = NSTextAlignmentCenter;
        _itemTitleLabelBottom.textColor = [UIColor colorWithRed:141.0/255.0 green:142.0/255.0 blue:155.0/255.0 alpha:1.0];
        _itemTitleLabelBottom.font =  [UIFont fontWithName:@"Montserrat-Regular" size:self.screenHeight/60.6];
        _itemTitleLabelBottom.lineBreakMode = NSLineBreakByWordWrapping;
        _itemTitleLabelBottom.numberOfLines = 0;
        _itemTitleLabelBottom.textAlignment = NSTextAlignmentLeft;
        
        [self.labelContainerView addSubview:_itemTitleLabelBottom];
        [_itemTitleLabelBottom mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.labelContainerView.mas_left);
             make.right.equalTo(self.labelContainerView.mas_right);
             make.top.equalTo(self.itemTitleLabelTop.mas_bottom);
             make.bottom.equalTo(self.labelContainerView);
         }];
    }
    
    return _itemTitleLabelBottom;
}

- (void)setTitleBottom:(NSString *)titleBottom
{
    self.itemTitleLabelBottom.text = titleBottom;
}

- (CheckBox *)languageCheckBox
{
    if (!_languageCheckBox)
    {
        _languageCheckBox = [[CheckBox alloc] init];
        
        [self.contentView addSubview:_languageCheckBox];
        [_languageCheckBox mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.width.equalTo(@(self.screenHeight/35.57));
            make.height.equalTo(@(self.screenHeight/35.57));
            
            make.right.equalTo(self.mas_right).with.offset(-self.screenHeight/33.857);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
    }
    
    return _languageCheckBox;
}

#pragma mark - hitTest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self.languageCheckBox) {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

@end
