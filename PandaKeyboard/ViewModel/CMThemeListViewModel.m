//
//  CMThemeListViewModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMThemeListViewModel.h"
#import "CMThemeModel.h"
#import "CMThemeCellViewModel.h"
#import "CMThemeDetailViewModel.h"
#import "CMHostRequestFactory.h"
#import "NSDictionary+Common.h"
#import "CMThemeManager.h"
#import "CMKeyboardManager.h"

#define kSelectCustomModel @"_selected_custom_model_"

@interface CMThemeListViewModel ()
@property (nonatomic, strong)NSMutableArray<CMThemeModel *>* defaultModelArray;
@property (nonatomic, strong)NSMutableArray<CMThemeModel *>* fetchedModelArray;
@property (nonatomic, strong)NSMutableArray<CMThemeModel *>* localModelArray;
@property (nonatomic, strong)NSMutableArray<CMThemeModel *>* customModelArray;
@property (nonatomic, strong)NSMutableArray<CMThemeModel *>* totalCustomModelArray;


@property (nonatomic, strong)NSURLSessionDataTask* fetchRequestTask;
@property (nonatomic, strong)NSOperationQueue* localQueue;

@property (nonatomic, assign)BOOL isFetched;
@property (nonatomic, assign)NSUInteger currentPageNum;
@property (nonatomic, assign)NSUInteger currentHasCount;
@property (nonatomic, copy)NSString* currentLastModelId;
@property (nonatomic, assign)NSUInteger currentOffset;
@property (nonatomic, assign)NSInteger currentHasMore;

@property (nonatomic, strong)CMThemeModel *selectedModel;


@end

@implementation CMThemeListViewModel


- (void)setIndex:(NSInteger)index
{
    if (index == 0) {
        _selectedModel = nil;
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kSelectCustomModel];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (index < self.totalCustomModelArray.count) {
        _selectedModel = self.totalCustomModelArray[index];
    }
}

- (void)dealloc {
    [self.fetchRequestTask cancel];
}

- (NSInteger)numberOfSections {
    return 3;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.defaultModelArray.count;
    }else if (section == 1){
        if (self.selectedModel) {
            if ([UIDevice isIpad] && self.totalCustomModelArray.count > 2) {
                return 3;
            }
            return 2;
        }else if (self.totalCustomModelArray.count > 1)
        {
            if ([UIDevice isIpad] && self.totalCustomModelArray.count > 2) {
                return 3;
            }
            return 2;
        }
        else{
            return 1;
        }
    }
    else if (section == 2) {
        if (self.fetchedModelArray.count > 0) {
            return self.fetchedModelArray.count;
        }else if (self.localModelArray.count > 0){
            return self.localModelArray.count;
        }else{
            return 0;
        }
    }
    return 0;
}

- (NSString *)titleForSection:(NSInteger)section {
    if (section == 0) {
        return CMLocalizedString(@"Default_Theme", nil);
    }else if (section == 1){
        return CMLocalizedString(@"DIY", nil);
    }
    else if (section == 2) {
        return CMLocalizedString(@"Daily_New_Theme", nil);
    }
    return @"";
}

- (CMThemeModel *)themeModelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0) {
        return nil;
    }
    
    if (indexPath.section == 0 && indexPath.row < self.defaultModelArray.count) {
        return [self.defaultModelArray objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1){
        if (self.totalCustomModelArray.count > 0 && indexPath.row == 0) {
            return [self.totalCustomModelArray objectAtIndex:0];
        }else if(self.totalCustomModelArray.count > 1 && self.selectedModel && indexPath.row == 1){
            return self.selectedModel;
        }else if (self.totalCustomModelArray.count > 1 && !self.selectedModel && indexPath.row == 1){
            return [self.totalCustomModelArray objectAtIndex:1];
        }
        else if ([UIDevice isIpad] && self.totalCustomModelArray.count > 2 && self.selectedModel && indexPath.row == 2)
        {
            if (![[NSUserDefaults standardUserDefaults] integerForKey:@"customThemeClickIndexForPad"]) {
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"customThemeClickIndexForPad"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            CMThemeModel * model = self.totalCustomModelArray[1];
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"customThemeClickIndexForPad"] == 1 || [self.selectedModel.themeName isEqualToString:model.themeName]) {
                return [self.totalCustomModelArray objectAtIndex:2];
            }else{
                return [self.totalCustomModelArray objectAtIndex:1];
            }
        }
        else if ([UIDevice isIpad] && self.totalCustomModelArray.count > 2 && !self.selectedModel && indexPath.row == 2){
            return [self.totalCustomModelArray objectAtIndex:2];
        }
    }
    else if (indexPath.section == 2) {
        if (self.fetchedModelArray.count > 0 && indexPath.row < self.fetchedModelArray.count){
            return [self.fetchedModelArray objectAtIndex:indexPath.row];
        }
        else if (self.localModelArray.count > 0 && indexPath.row < self.localModelArray.count) {
            return [self.localModelArray objectAtIndex:indexPath.row];
        }
    }
    return nil;
}

- (CMThemeModel *)customThemeModelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0) {
        return nil;
    }
    if (self.totalCustomModelArray.count > 0 && indexPath.row < self.totalCustomModelArray.count) {
        return [self.totalCustomModelArray objectAtIndex:indexPath.row];
    }
    return nil;
}

- (CMThemeDetailViewModel *)detailViewModelForIndexPath:(NSIndexPath *)indexPath themeManager:(CMThemeManager *)themeManager {
    CMThemeModel* themeModel = [self themeModelAtIndexPath:indexPath];
    if (themeModel) {
        return [CMThemeDetailViewModel viewModelWithThemeModel:themeModel indexPath:indexPath themeManager:themeManager];
    }
    return nil;
}

- (void)loadLocalThemesWithBlock:(CMLoadDataComplete)block {
    [self.localQueue cancelAllOperations];
    NSBlockOperation* loadThemeTask = [NSBlockOperation blockOperationWithBlock:^{
        kLogInfo(@"[Thread] current thread = %@", [NSThread currentThread]);
        // 从本地加载默认主题
        NSString * themePlistPath;
#ifdef SCHEME
        themePlistPath = [[NSBundle mainBundle] pathForResource:@"CMThemeScheme" ofType:@"plist"];
#else
        themePlistPath = [[NSBundle mainBundle] pathForResource:@"CMTheme" ofType:@"plist"];
#endif
        NSArray* themeInfoArray = [[NSArray alloc] initWithContentsOfFile:themePlistPath];
        [self.defaultModelArray removeAllObjects];
        [themeInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull infoDic, NSUInteger idx, BOOL * _Nonnull stop) {
            CMThemeModel* model = [CMThemeModel modelWithDefaultInfoDic:infoDic];
            [self.defaultModelArray addObject:model];
        }];
    }];
    
    
    [self loadCustomThemes];
    
    NSInteger selectIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectCustomModel];
    selectIndex = selectIndex ? selectIndex : 1;
    if (selectIndex < self.totalCustomModelArray.count) {
        _selectedModel = self.totalCustomModelArray[selectIndex];
    }
    
    [loadThemeTask addExecutionBlock:^{
        kLogInfo(@"[Thread] current thread = %@", [NSThread currentThread]);
        // 从本地加载缓存主题
        NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
        NSArray* themeInfoArray = [userDefault arrayForKey:@"cachedThemeArray"];
        if (themeInfoArray && themeInfoArray.count > 0 && !self.isFetched) {
            [self.localModelArray removeAllObjects];
            [themeInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull infoDic, NSUInteger idx, BOOL * _Nonnull stop) {
                CMThemeModel* model = [CMThemeModel modelWithCachedInfoDic:infoDic];
                [self.localModelArray addObject:model];
            }];
        }
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil, NO);
            });
            
        }
    }];
    [self.localQueue addOperation:loadThemeTask];
}

- (void)loadLocalCustomThemesWithBlock:(CMLoadDataComplete)block
{
    [self loadCustomThemes];
        
    if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil, NO);
            });
    }
}

- (void)loadCustomThemes
{
    [self.totalCustomModelArray removeAllObjects];
    //默认diy按钮
    CMThemeModel * customModel = [CMThemeModel modelWithCustomInfoDic:@{@"coverurl":@"diyIcon_host"}];
    [self.totalCustomModelArray addObject:customModel];
    
    // 从本地加载diy主题
    self.customModelArray = [NSMutableArray arrayWithArray:[CMKeyboardManager sharedInstance].themeManager.DIYThemes];
    [self.totalCustomModelArray addObjectsFromArray:self.customModelArray];
}

- (void)fetchNetThemesFirstPageWithBlock:(CMLoadDataComplete)block {
    self.currentPageNum = 0;
    self.currentHasCount = 0;
    self.currentOffset = 0;
    self.currentLastModelId = nil;
    self.currentHasMore = 1;
    [self fetchNetThemesWithPageNum:self.currentPageNum hasCount:self.currentHasCount lastModelId:self.currentLastModelId offset:self.currentOffset fetchCount:10 block:block];
}

- (void)fetchNetThemesNextPageWithBlock:(CMLoadDataComplete)block {
    [self fetchNetThemesWithPageNum:++self.currentPageNum hasCount:self.currentHasCount lastModelId:self.currentLastModelId offset:self.currentOffset fetchCount:10 block:block];
}

- (void)fetchNetThemesWithPageNum:(NSUInteger)pageNum
                         hasCount:(NSUInteger)hasCount
                      lastModelId:(NSString *)lastModelId
                           offset:(NSUInteger)offset
                       fetchCount:(NSUInteger)count
                        block:(CMLoadDataComplete)block {
    self.isFetched = NO;
    @weakify(self)
    self.fetchRequestTask = [CMHostRequestFactory fetchThemeListWithPageNum:pageNum hasCount:hasCount lastModelId:lastModelId offset:offset fetchCount:count completeBlock:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        kLogInfo(@"[Thread] current thread = %@", [NSThread currentThread]);
        @stronglize(self)
        if (errorMsg == nil) {
            NSArray* themeInfoArray = [dicOrArray arrayValueForKey:@"data"];
            if (themeInfoArray && themeInfoArray.count > 0) {
                if (pageNum == 0) {
                    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:themeInfoArray forKey:@"cachedThemeArray"];
                    [self.fetchedModelArray removeAllObjects];
                    [self.localModelArray removeAllObjects];
                }
                
                [themeInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull infoDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    CMThemeModel* theme = [CMThemeModel modelWithFetchedInfoDic:infoDic];
                    [self.fetchedModelArray addObject:theme];
                    if (idx == themeInfoArray.count - 1) {
                        self.currentLastModelId = theme.themeId;
                    }
                }];
            }
            NSDictionary* pageInfo = [dicOrArray dictionaryValueForKey:@"pagination"];
            self.currentOffset = [pageInfo integerValueForKey:@"offset" defaultValue:self.currentOffset];
            self.currentHasCount = self.currentHasCount + [pageInfo integerValueForKey:@"count" defaultValue:0];
            self.currentHasMore = [pageInfo integerValueForKey:@"hasMore" defaultValue:self.currentHasMore];
            if (block) {
                block(nil, self.currentHasMore > 0 ? YES : NO);
            }
        }
        else if (block) {
            block(errorMsg, self.currentHasMore > 0 ? YES : NO);
        }
        self.isFetched = YES;
    }];
    [self.fetchRequestTask resume];
}

- (void)cancelTask {
    [self.fetchRequestTask cancel];
    [self.localQueue cancelAllOperations];
}

#pragma mark - setter/getter
- (NSMutableArray<CMThemeModel *> *)defaultModelArray {
    if (!_defaultModelArray) {
        _defaultModelArray = [NSMutableArray array];
    }
    return _defaultModelArray;
}

- (NSMutableArray<CMThemeModel *> *)fetchedModelArray {
    if (!_fetchedModelArray) {
        _fetchedModelArray = [NSMutableArray array];
    }
    return _fetchedModelArray;
}

-(NSMutableArray<CMThemeModel *> *)localModelArray
{
    if (!_localModelArray) {
        _localModelArray = [NSMutableArray array];
    }
    return _localModelArray;
}

- (NSMutableArray<CMThemeModel *> *)customModelArray
{
    if (!_customModelArray) {
        _customModelArray = [NSMutableArray array];
    }
    return _customModelArray;
}

-(NSMutableArray<CMThemeModel *> *)totalCustomModelArray
{
    if (!_totalCustomModelArray) {
        _totalCustomModelArray = [NSMutableArray array];
    }
    return _totalCustomModelArray;
}

- (NSOperationQueue *)localQueue {
    if (!_localQueue) {
        _localQueue = [NSOperationQueue new];
        _localQueue.maxConcurrentOperationCount = 1;
    }
    return _localQueue;
}

- (NSArray *)getFetchedModelArray {
    return [self.fetchedModelArray copy];
}

- (NSArray *)getLocalCustomArray
{
    return [self.customModelArray copy];
}

- (NSArray *)getLocalTotalCustomArray
{
    return [self.totalCustomModelArray copy];
}

- (void)setupCustomArrayWiththemeModel:(CMThemeModel *)model
{
    _selectedModel = model;
    [self.totalCustomModelArray insertObject:_selectedModel atIndex:1];
}

- (void)updateCustomThemesAfterEdit
{
    [self loadCustomThemes];
}

- (NSInteger)getSelectedCustomThemeIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSelectCustomModel];
}

- (CMThemeModel *)getSelectedModel
{
    if (self.selectedModel) {
        return self.selectedModel;
    }
    return nil;
}
@end
