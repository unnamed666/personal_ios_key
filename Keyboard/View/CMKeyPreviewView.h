//
//  CMKeyPreviewView.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/3.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMKeyButton;

@interface CMKeyPreviewView : UIView
@property (nonatomic, weak)CMKeyButton *button;
@property (nonatomic, readonly, assign)CGRect containerFrame;

- (instancetype)initWithkeyButton:(CMKeyButton *)button;


- (void)removeWithAnimation:(void (^)(BOOL finished))completion;


@end
