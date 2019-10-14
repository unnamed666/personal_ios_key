//
//  CMBlackThemeTopView.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/8/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMSuggestionViewModel;
@interface CMBlackThemeTopView : UIView

@property (nonatomic, assign)CGFloat toolbarHeight;

- (void)defaultConfig:(CGFloat)toolbarHeight;
- (void)stopWave;

- (void)toucheBeganX:(int)x;
- (void)toucheMoveDistanceX:(int)x;
- (void)toucheEnded;
@end
