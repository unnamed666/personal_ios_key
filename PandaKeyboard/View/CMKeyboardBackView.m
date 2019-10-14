//
//  CMKeyboardBackView.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMKeyboardBackView.h"

@implementation CMKeyboardBackView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self removeFromSuperview];
    [self.delegate keyboardBackViewTouched];
}

@end
