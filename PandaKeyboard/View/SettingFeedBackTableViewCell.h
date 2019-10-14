//
//  SettingFeedBackTableViewCell.h
//  KeyboardSplash
//
//  Created by Alchemist on 2017/6/3.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseViewCell.h"

@interface SettingFeedBackTableViewCell : CMBaseViewCell

@property (strong, nonatomic) UIImageView* itemIconImage;
@property (strong, nonatomic) UIImageView* itemGoNextImage;
@property (strong, nonatomic) UILabel* itemTitleLabel;
@property (strong, nonatomic) UIImageView* theLineView;

@end
