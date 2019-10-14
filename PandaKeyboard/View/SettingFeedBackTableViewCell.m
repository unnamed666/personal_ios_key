//
//  SettingFeedBackTableViewCell.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/6/3.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "SettingFeedBackTableViewCell.h"
#import "AppDelegate.h"
#import "CMBizHelper.h"

@implementation SettingFeedBackTableViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.itemIconImage = [[UIImageView alloc] init];
        
        [self.contentView addSubview:self.itemIconImage];
        
        [self.itemIconImage mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.equalTo(@(kScreenHeight/29.84));
             make.height.equalTo(@(kScreenHeight/29.84));
             
             make.left.equalTo(self.mas_left).with.offset(kScreenHeight/53.36);
             make.bottom.equalTo(self.mas_bottom).with.offset(-kScreenHeight/59.29);
         }];
        
        self.itemTitleLabel = [[UILabel alloc] init];
        
        self.itemTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.itemTitleLabel.textColor = [UIColor whiteColor];
        self.itemTitleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:kScreenHeight/45.1];
        
        [self.contentView addSubview:self.itemTitleLabel];
        [self.itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.mas_left).with.offset(kScreenHeight/12.467);
             make.bottom.equalTo(self.mas_bottom).with.offset(-kScreenHeight/43.74);
         }];
    }
    
    self.theLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
    self.theLineView.tintColor = [UIColor redColor];
    
    [self.contentView addSubview:self.theLineView];
    
    [self.theLineView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.bottom.equalTo(self.contentView.mas_bottom);
         make.left.equalTo(self.itemTitleLabel.mas_left);
         make.right.equalTo(self.contentView.mas_right);
         
         make.height.equalTo(@(1));
     }];
    
    [self.contentView sendSubviewToBack:self.theLineView];
    
    self.itemGoNextImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Setting_Go_Next"]];
    
    [self.contentView addSubview:self.itemGoNextImage];
    
    [self.itemGoNextImage mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.equalTo(@(kScreenHeight/98.25));
         make.height.equalTo(@(kScreenHeight/58.25));
         
         make.right.equalTo(self.mas_right).with.offset(-kScreenHeight/33.857);
         make.centerY.equalTo(self.itemTitleLabel.mas_centerY);
     }];
    
    
    return self;
}

@end
