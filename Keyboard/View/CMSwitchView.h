//
//  CMSwitchView.h
//  PandaKeyboard Extension
//
//  Created by 姚宗超 on 2017/11/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMSwitchCellView : UIView

- (instancetype)initWithFrame:(CGRect)frame icon:(UIImage *)iconImg description:(NSString *)description;

- (void)setHighlight:(BOOL)highlight;

@end

@class CMKeyButton;
@class CMSwitchView;
@class CMKeyModel;

@protocol CMSwitchViewDelegate <NSObject>
- (void)onSwitchView:(CMSwitchView *)switchView selectedIndex:(NSUInteger)index keyModel:(CMKeyModel *)keyModel;

@end

@interface CMSwitchView : UIView
@property (nonatomic, weak)CMKeyButton *button;
@property (nonatomic, assign, readonly)NSInteger selectedInputIndex;
@property (nonatomic, weak)id<CMSwitchViewDelegate> delegate;

- (void)updateSelectedInputIndexForPoint:(CGPoint)point;

@end
