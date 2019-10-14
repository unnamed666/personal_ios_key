//
//  CMInputOptionView.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/9/9.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMKeyButton.h"

@class CMKeyModel;

@interface CMInputOptionCellView : UIView

- (instancetype)initWithFrame:(CGRect)frame option:(NSString *)option isSpaceType:(BOOL)isSpace;

- (void)setHighlight:(BOOL)highlight font:(UIFont *)font;

@end

@interface CMInputOptionView : UIView

@property (nonatomic, readonly, assign)NSInteger selectedInputIndex;
@property (nonatomic, readonly, assign)CMKeyBtnPosition keyPosition;

@property (nonatomic, weak)CMKeyButton *button;

- (instancetype)initWithkeyButton:(CMKeyButton *)button;

- (void)updateSelectedInputIndexForPoint:(CGPoint)point;

@end
