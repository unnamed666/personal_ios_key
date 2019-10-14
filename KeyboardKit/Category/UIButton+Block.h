//
//  UIButton+Block.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^ActionBlock)(void);

@interface UIButton(Block)

@property (readonly) NSMutableDictionary *event;

- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end
