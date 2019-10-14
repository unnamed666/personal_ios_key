//
//  CMBaseViewModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMKeyboardModel;
@interface CMBaseKeyboardViewModel : NSObject<NSCopying>
@property (nonatomic, readonly, copy)CMKeyboardModel* keyboadModel;


- (instancetype)initWithKeyboardModel:(CMKeyboardModel *)keyboardModel;
@end
