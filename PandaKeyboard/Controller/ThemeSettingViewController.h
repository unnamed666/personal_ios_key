//
//  ThemeSettingViewController.h
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/22.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeDetailViewController.h"
#include "RateUSView.h"
#import "CMBaseViewController.h"
#import "CMDIYThemeViewController.h"

@interface ThemeSettingViewController : CMBaseViewController <CMDIVThemeViewControllerDelegate>

@property (nonatomic, assign) BOOL shouldShowKeyboard;

- (void) hideKeyboard;

//- (void)scrollToSegmentByIndex:(NSInteger)index;

@end
