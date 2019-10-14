//
//  CMBaseViewCell.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/9.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseViewCell.h"
#import "CMBizHelper.h"

@implementation CMBaseViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.selectedBackgroundView.backgroundColor = [CMBizHelper itemSelectedColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.selectedBackgroundView.backgroundColor = [CMBizHelper itemSelectedColor];
    }
    
    return self;
}
@end
