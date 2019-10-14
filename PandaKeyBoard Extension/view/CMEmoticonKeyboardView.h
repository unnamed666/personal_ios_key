//
//  CMEmoticonKeyboardView.h
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/10/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseKeyboardView.h"


@protocol CMEmoticonKeyboardViewDelegate <CMBaseKeyboardViewDelegate>

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard openMakeEmoticonVC:(int)row;
- (void)onKeyboard:(CMBaseKeyboardView *)keyboard otherClik:(NSDictionary*)dic;

@end

@interface CMEmoticonKeyboardView : CMBaseKeyboardView
@property (nonatomic, assign) NSUInteger inSource;
- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel;
@end
