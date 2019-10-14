//
//  CMThemeCollectionViewHeaderView.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMThemeCollectionViewHeaderViewDelegate <NSObject>
@optional
- (void)themeCollectionViewHeaderViewSeeAllButtonClick;
@end

@interface CMThemeCollectionViewHeaderView : UICollectionReusableView
@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) BOOL showAllCustomThemeButton;
@property (nonatomic, weak) id<CMThemeCollectionViewHeaderViewDelegate> delegate;

- (void) removeRedRoundMark;
@end
