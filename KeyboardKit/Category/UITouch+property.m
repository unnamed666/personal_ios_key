//
//  UITouch+property.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UITouch+property.h"

#import <objc/runtime.h>
static const void *kOnScreen = &kOnScreen;

@implementation UITouch (property)

- (BOOL)onScreen{
    return [objc_getAssociatedObject(self, kOnScreen) boolValue];
}

- (void)setOnScreen:(BOOL)onScreen{
    objc_setAssociatedObject(self, kOnScreen, @(onScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
