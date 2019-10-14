//
//  CMTabBar.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMTabBar;
@protocol CMTabBarDelegate <NSObject>

- (void)tabbarDidSlected:(CMTabBar *)tabbar from:(NSInteger)from to:(NSInteger)to;

@end
@interface CMTabBar : UIView
- (void)setupItemWithTitle:(NSString *)title normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage;
@property (nonatomic, weak) id<CMTabBarDelegate> delegate;
@property (nonatomic) BOOL isClickEnable;
- (void)setSelectIndex:(NSInteger)selectIndex;
@end
