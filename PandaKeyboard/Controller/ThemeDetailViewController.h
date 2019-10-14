//
//  ThemeDetailViewController.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMThemeDetailViewModel.h"
#import "CMBaseViewController.h"

@protocol STPopupDelegate <NSObject>

- (void) dismissPopupView;
- (void)themeDownloadFinish:(CMThemeModel*) theModel indexPath:(NSIndexPath *)indexPath;
- (void)themeApplyTapped:(CMThemeModel *)theModel indexPath:(NSIndexPath *)indexPath; // 点击应用按钮
- (void)themeDiyTapped:(CMThemeModel *)theModel indexPath:(NSIndexPath *)indexPath; // 点击编辑按钮编辑该主题

@end

@class CMThemeManager;

@interface ThemeDetailViewController : CMBaseViewController

@property(nonatomic, copy) NSString * coverImageString;
@property(nonatomic, weak) id<STPopupDelegate> delegate;
@property (nonatomic, strong) CMThemeDetailViewModel *themeDetailViewModel;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (instancetype)initWithThemeDetailModel:(CMThemeDetailViewModel*)theModel themeManager:(CMThemeManager *)themeManager;
- (void)cancleTask;
@end
