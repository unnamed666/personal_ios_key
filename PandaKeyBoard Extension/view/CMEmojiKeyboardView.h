//
//  CMEmojiKeyboardView.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseKeyboardView.h"

@class CMEmojiKeyboardViewModel;
@class CMEmojiKeyboardView;
@class CMKeyModel;

@protocol CMEmojiKeyboardViewDelegate <CMBaseKeyboardViewDelegate>

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard emojiSectionSelected:(NSUInteger)sectionIndex;

@end


@interface CMEmojiKeyboardView : CMBaseKeyboardView
@property (nonatomic, assign)NSUInteger inSource; // 进入此页面的来源

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel deleteModel:(CMKeyModel *)deleteKeyModel returnModel:(CMKeyModel *)returnKeyModel;


@end
