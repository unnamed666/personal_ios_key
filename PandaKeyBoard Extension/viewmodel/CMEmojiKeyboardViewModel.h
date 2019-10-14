//
//  CMEmojiKeyboardViewModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMBaseKeyboardViewModel.h"
@class CMEmojiSectionModel;
@class CMKeyModel;

@interface CMEmojiKeyboardViewModel : CMBaseKeyboardViewModel
@property (nonatomic, copy)NSArray<CMEmojiSectionModel *>* emojiArray;
@property (nonatomic, strong)CMKeyModel* layoutKeyModel;
@property (nonatomic, strong)CMKeyModel* deleteKeyModel;
@property (nonatomic, strong)CMKeyModel* returnKeyModel;


- (instancetype)initWithPlist:(NSString *)filePath;

+ (instancetype)viewModelWithPlist:(NSString *)filePath;

@end
