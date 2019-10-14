//
//  CMToolBarView.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/13.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseToolBarView.h"

@class CMToolBarView;

@protocol CMToolBarViewDelegate <NSObject>

- (void)onToolBarView:(CMToolBarView *)toolBar themeBtnTapped:(NSDictionary *)infoDic;

- (void)onToolBarView:(CMToolBarView *)toolBar settingBtnTapped:(NSDictionary *)infoDic;

- (void)onToolBarView:(CMToolBarView *)toolBar emojiBtnTapped:(NSDictionary *)infoDic;

- (void)onToolBarView:(CMToolBarView *)toolBar cursorMoveBtnTapped:(NSDictionary *)infoDic;

- (void)onToolBarView:(CMToolBarView *)toolBar dismissBtnTapped:(NSDictionary *)infoDic;


- (void)onToolBarView:(CMToolBarView *)toolBar settingBtnDownRepeatTapped:(NSDictionary *)infoDic;

@end

@interface CMToolBarView : CMBaseToolBarView

@property (nonatomic, weak)id<CMToolBarViewDelegate> delegate;

-(void)removeEmojiRedPoint;
@end
