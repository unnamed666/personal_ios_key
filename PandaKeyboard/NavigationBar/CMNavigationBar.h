//
//  CMNavigationBar.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexColors.h"

typedef NS_ENUM(NSInteger, CMNavigationBarType)
{
    CMNavigationBarTypeDefault,
    CMNavigationBarTypeRightItem
};

@protocol CMNavigationBarDelegate <NSObject>

@optional
- (void)navBarBackButtonDidClick;
- (void)navBarRightItemDidClick:(UIButton *)rightItem;

@end

@interface CMNavigationBar : UIView

@property (nonatomic, strong) UIColor * navBarBackgroundColor;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) UIColor * titleColor;
@property (nonatomic, strong) UIFont * titleFont;
@property (nonatomic, copy) NSString * rightItemTitleNormal;
@property (nonatomic, copy) NSString * rightItemTitleSelected;

@property (nonatomic, weak) id<CMNavigationBarDelegate> delegate;

- (CMNavigationBar *)initWithNavigationBarType:(CMNavigationBarType)type centerYOffset:(CGFloat)offset;

- (void)hideBackButton;
- (void)showBackButton;
- (void)hideRightButton;
- (void)showRightButton;
@end
