
//
//  CMSourceViewModel.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDiySourceViewModel.h"
#import "CMDiySourceModel.h"
#import "CMHostRequestFactory.h"

@interface CMDiySourceViewModel ()

@property (nonatomic, strong)NSMutableArray<CMDiySourceModel *>* fetchedModelArray;

@property (nonatomic, strong)NSURLSessionDataTask* fetchRequestTask;
@property (nonatomic, strong)NSOperationQueue* localQueue;

@property (nonatomic, assign)NSUInteger currentPageNum;
@property (nonatomic, assign)NSUInteger currentHasCount;
@property (nonatomic, assign)NSUInteger currentOffset;
@property (nonatomic, assign)NSInteger currentHasMore;

@property (nonatomic, assign)BOOL isFetched;

@end

@implementation CMDiySourceViewModel

#pragma mark - init
- (instancetype)init
{
    if (self = [super init]) {
        _fetchStatus = CMDiySourceFetchNone;
    }
    return self;
}

- (instancetype)initWithPlist:(NSString *)plistName
{
    if (self = [self init]) {
        NSArray *plistInfo = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
        [plistInfo enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CMDiySourceModel *sourceModel = [[CMDiySourceModel alloc] initWithPlistInfoDic:obj];
            [self.fetchedModelArray addObject:sourceModel];
        }];
    }
    return self;
}

#pragma mark - dealloc
- (void)dealloc
{
    [self.fetchRequestTask cancel];
}

#pragma mark -
- (NSInteger)numberOfItems
{
    return self.fetchedModelArray.count;
}

- (CMDiySourceModel *)sourceModelAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedModelArray.count > indexPath.row) {
        return self.fetchedModelArray[indexPath.row];
    }
    return nil;
}

- (CMDiySourceModel *)sourceModelAtIndex:(NSInteger)row
{
    if (self.fetchedModelArray.count > row) {
        return self.fetchedModelArray[row];
    }
    return nil;
}

#pragma mark - Fetch DiySources From Network
- (void)fetchNetDiySourcesFirstPageWithBlock:(CMLoadDataComplete)block
{
    self.currentPageNum = 0;
    self.currentHasCount = 0;
    self.currentOffset = 0;
    self.currentHasMore = 1;
    self.fetchStatus = CMDiySourceFetchNew;
    [self fetchNetDiySourcesWithPageNum:self.currentPageNum offset:self.currentOffset fetchCount:50 block:block];
}

- (void)fetchNetDiySourcesNextPageWithBlock:(CMLoadDataComplete)block
{
    self.fetchStatus = CMDiySourceFetchMore;
    [self fetchNetDiySourcesWithPageNum:++self.currentPageNum offset:self.currentOffset fetchCount:50 block:block];
}

- (void)fetchNetDiySourcesWithPageNum:(NSUInteger)pageNum
                           offset:(NSUInteger)offset
                       fetchCount:(NSUInteger)count
                            block:(CMLoadDataComplete)block
{
    [self.localQueue cancelAllOperations];
    self.isFetched = NO;
    @weakify(self)
    self.fetchRequestTask = [CMHostRequestFactory fetchDiySourceWithType:self.diySourceType offset:offset fetchCount:count completeBlock:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        kLogInfo(@"[Thread] current thread = %@", [NSThread currentThread]);
        @stronglize(self)
        if (errorMsg == nil) {
            NSArray* themeInfoArray = [dicOrArray arrayValueForKey:@"data"];
            if (themeInfoArray && themeInfoArray.count > 0) {
                if (pageNum == 0) {
                    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
                    if (self.diySourceType == CMDiySourceTypeBackground) {
                        [userDefault setObject:themeInfoArray forKey:@"cachedDiyBackground"];
                    }
                    else if (self.diySourceType == CMDiySourceTypeButton) {
                        [userDefault setObject:themeInfoArray forKey:@"cachedDiyButton"];
                    }
                    else if (self.diySourceType == CMDiySourceTypeSounds) {
                        [userDefault setObject:themeInfoArray forKey:@"cachedDiySounds"];
                    }
                    else if (self.diySourceType == CMDiySourceTypeFonts) {
                        [userDefault setObject:themeInfoArray forKey:@"cachedDiyFonts"];
                    }
                    [self.fetchedModelArray removeAllObjects];
                }
                
                [themeInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull infoDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    CMDiySourceModel *sourceModel = [CMDiySourceModel modelWithFetchedInfoDic:infoDic];
                    [self.fetchedModelArray addObject:sourceModel];
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
        self.fetchStatus = CMDiySourceFetchNone;
        self.isFetched = YES;
    }];
    [self.fetchRequestTask resume];
}

- (void)loadLocalSourcesWithBlock:(CMLoadDataComplete)block {
    [self.localQueue cancelAllOperations];
    NSBlockOperation* loadThemeTask = [NSBlockOperation blockOperationWithBlock:^{
        kLogInfo(@"[Thread] current thread = %@", [NSThread currentThread]);
        if (!self.isFetched) {
            // 从本地加载缓存主题
            NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
            NSArray* themeInfoArray = nil;
            
            if (self.diySourceType == CMDiySourceTypeBackground) {
                themeInfoArray = [userDefault arrayForKey:@"cachedDiyBackground"];
            }
            else if (self.diySourceType == CMDiySourceTypeButton) {
                themeInfoArray = [userDefault arrayForKey:@"cachedDiyButton"];
            }
            else if (self.diySourceType == CMDiySourceTypeSounds) {
                themeInfoArray = [userDefault arrayForKey:@"cachedDiySounds"];
            }
            else if (self.diySourceType == CMDiySourceTypeFonts) {
                themeInfoArray = [userDefault arrayForKey:@"cachedDiyFonts"];
            }
            if (themeInfoArray && themeInfoArray.count > 0) {
                [self.fetchedModelArray removeAllObjects];
                [themeInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull infoDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    CMDiySourceModel *sourceModel = [CMDiySourceModel modelWithFetchedInfoDic:infoDic];
                    [self.fetchedModelArray addObject:sourceModel];
                }];
            }
        }

        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil, NO);
            });
        }
    }];
    [self.localQueue addOperation:loadThemeTask];
}

- (void)cancelTask
{
    [self.fetchRequestTask cancel];
    [self.localQueue cancelAllOperations];
}

#pragma mark - setter/getter
- (NSMutableArray<CMDiySourceModel *> *)fetchedModelArray {
    if (!_fetchedModelArray) {
        _fetchedModelArray = [NSMutableArray array];
    }
    return _fetchedModelArray;
}

- (NSOperationQueue *)localQueue {
    if (!_localQueue) {
        _localQueue = [NSOperationQueue new];
        _localQueue.maxConcurrentOperationCount = 1;
    }
    return _localQueue;
}

@end
