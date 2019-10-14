//
//  CMEmojiKeyboardSwitcher.h
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMEmojiKeyboardView.h"
#import "CMEmojiKeyboardViewModel.h"
@interface CMEmojiKeyboardSwitcher : NSObject
@property (nonatomic, assign)NSUInteger inSource; // 进入此页面的来源
@property (nonatomic, assign)int keyboardIndex;
@property (nonatomic, strong)CMBaseKeyboardView * emojiKeyboard;
@property (nonatomic, strong)CMBaseKeyboardViewModel  * viewModel;

- (instancetype)initWithDelegate:(id)delegate;

- (void)showToParentVeiw:(UIView*)view;
- (void)removeFromSuperview;
- (void)didReceiveMemoryWarning;
- (BOOL)isShowEmojiKeyboard;


- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel deleteModel:(CMKeyModel *)deleteKeyModel returnModel:(CMKeyModel *)returnKeyModel;
@end
