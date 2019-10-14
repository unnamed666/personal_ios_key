//
//  CMBaseViewModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseKeyboardViewModel.h"
#import "CMKeyboardModel.h"
@interface CMBaseKeyboardViewModel ()
@property (nonatomic, readwrite, copy)CMKeyboardModel* keyboadModel;
@end
@implementation CMBaseKeyboardViewModel


- (instancetype)initWithKeyboardModel:(CMKeyboardModel *)keyboardModel{
    if(self = [super init]){
        self.keyboadModel = keyboardModel;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CMBaseKeyboardViewModel* model = [[[self class] allocWithZone:zone] init];
    model.keyboadModel = [_keyboadModel copy];
    return model;
}

@end
