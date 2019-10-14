//
//  CMThemeListViewModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMThemeCellViewModel;
@class CMThemeDetailViewModel;
@class CMError;
@class CMThemeModel;
@class CMThemeManager;

typedef void (^CMLoadDataComplete)(CMError* errorMsg, BOOL hasMore);

@interface CMThemeListViewModel : NSObject

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForSection:(NSInteger)section;
- (CMThemeDetailViewModel *)detailViewModelForIndexPath:(NSIndexPath *)indexPath themeManager:(CMThemeManager *)themeManager;

// 加载数据
- (CMThemeModel *)themeModelAtIndexPath:(NSIndexPath *)indexPath;

- (CMThemeModel *)customThemeModelAtIndexPath:(NSIndexPath *)indexPath;

- (void)loadLocalThemesWithBlock:(CMLoadDataComplete)block;

- (void)loadLocalCustomThemesWithBlock:(CMLoadDataComplete)block;

- (void)fetchNetThemesFirstPageWithBlock:(CMLoadDataComplete)block;

- (void)fetchNetThemesNextPageWithBlock:(CMLoadDataComplete)block;

- (void)cancelTask;

- (NSArray *)getFetchedModelArray;
- (NSArray *)getLocalCustomArray;
- (NSArray *)getLocalTotalCustomArray;
- (void)setIndex:(NSInteger)index;
- (NSInteger)getSelectedCustomThemeIndex;
- (void)setupCustomArrayWiththemeModel:(CMThemeModel *)model;
- (void)updateCustomThemesAfterEdit;
- (CMThemeModel *)getSelectedModel;
@end
