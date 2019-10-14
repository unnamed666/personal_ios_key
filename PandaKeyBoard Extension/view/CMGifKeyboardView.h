//
//  CMEmoticonKeyboardView.h
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/10/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseKeyboardView.h"

@protocol CMGifKeyboardViewDelegate <CMBaseKeyboardViewDelegate>

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard otherClik:(NSDictionary*)dic;

@end

@interface CMGifKeyboardView : CMBaseKeyboardView
@property (nonatomic, assign) NSUInteger inSource;
- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel  deleteModel:(CMKeyModel *)deleteKeyModel ;
@end


