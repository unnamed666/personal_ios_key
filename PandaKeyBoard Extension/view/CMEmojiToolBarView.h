//
//  CMEmojiToolBarView.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/22.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseToolBarView.h"

@class CMEmojiToolBarView;

@protocol CMEmojiToolBarViewDelegate <NSObject>

- (void)onEmojiViewToolBarView:(CMEmojiToolBarView *)toolBar emojiBtnTapped:(NSDictionary *)infoDic;

@end

@interface CMEmojiToolBarView : CMBaseToolBarView

@property (nonatomic, weak)id<CMEmojiToolBarViewDelegate> delegate;

@end
