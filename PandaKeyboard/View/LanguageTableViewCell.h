//
//  LanguageTableViewCell.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"
#import "CMBaseViewCell.h"

@interface LanguageTableViewCell : CMBaseViewCell

@property (nonatomic, strong) CheckBox* languageCheckBox;

@property (nonatomic, copy) NSString* titleTop;
@property (nonatomic, copy) NSString* titleBottom;

@end
