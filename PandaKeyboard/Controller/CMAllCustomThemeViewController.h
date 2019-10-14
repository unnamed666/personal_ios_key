//
//  CMAllCustomThemeViewController.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseViewController.h"
#import "CMThemeModel.h"
#import "CMThemeListViewModel.h"

@protocol CMAllCustomThemeViewControllerDelegate <NSObject>
@optional
- (void)allCustomThemeViewControllerThemeClick:(NSInteger)themeIndex;
- (void)needReloadSeletedCustomTheme;
- (void)customThemeDidClick:(NSInteger)index;
- (void)needReloadAfterEdit;
- (void)onNavCancelBtnTapped:(CMBaseViewController *)vc;
@end

@interface CMAllCustomThemeViewController : CMBaseViewController
@property (nonatomic, strong) CMThemeListViewModel* themeViewModel;
@property (nonatomic, weak) id<CMAllCustomThemeViewControllerDelegate>delegate;
@end
