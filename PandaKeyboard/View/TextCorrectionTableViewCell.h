//
//  TextCorrectionTableViewCell.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMUISwitch.h"
#import "CMBaseViewCell.h"

@interface TextCorrectionTableViewCell : CMBaseViewCell

@property (nonatomic, strong) CMUISwitch *itemSwitch;

@property (nonatomic, copy) NSString* titleTop;
@property (nonatomic, copy) NSString* titleBottom;

@end
