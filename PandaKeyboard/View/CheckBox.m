//
//  CheckBox.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setBackgroundImage:[UIImage imageNamed:@"Not_Checked"]
                        forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"Checked"]
                        forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageNamed:@"Checked"]
                        forState:UIControlStateHighlighted];
    self.adjustsImageWhenHighlighted=YES;
//    [self addTarget:self action:@selector(AddOnClick:) forControlEvents:UIControlEventTouchUpInside];
    _isChecked = false;
    return self;
}

//- (void) AddOnClick:(id) sender
//{
//    _isChecked = !_isChecked;
//    [self setSelected:_isChecked];
//}

- (void)setIsChecked:(BOOL)mark
{
    _isChecked = mark;
    [self setSelected:_isChecked];
}

@end
