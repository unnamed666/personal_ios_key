//
//  CMSuggestionView.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMSuggestionStripView.h"
#import "CMSuggestionCell.h"
#import "CMSuggestionViewModel.h"
#import "CMSuggestionCellViewModel.h"
//#import "SwiftTheme-Swift.h"
#import "NSString+Common.h"
#import "NSDictionary+Common.h"
//#import "CMGradientView.h"
#import "UIView+Util.h"
#import "CMPageCollectionViewFlowLayout.h"
#import "CMCollectionView.h"
#import "UIImage+Biz.h"
#import "UIColor+Biz.h"
#import "CMBizHelper.h"
//#import "SuggestedWordInfo.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"

#import "UIView+Util.h"
#import "UIDevice+Util.h"
#import "UIImage+Util.h"
#ifndef HostApp
#import "SuggestedWordInfo.h"
#endif

@interface CMSuggestionStripView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CMCollectionViewDelegate>

@property (nonatomic, strong)NSMutableDictionary<NSString*, CMSuggestionCell*>* cacheCellDic;
@property (nonatomic, strong)UIImageView* bgImageView;

@property (nonatomic, strong)CMSuggestionViewModel* viewModel;

@property (nonatomic, strong)UIButton* emojiBtn;
//@property (nonatomic, strong)CMGradientView* maskView;

@property (nonatomic, assign)CGFloat leftOffset; // 判断滑动位置用
@property (nonatomic, assign)CGFloat rightOffset; // 判断滑动位置用

@property (nonatomic, strong)dispatch_semaphore_t signal;

@property (nonatomic, strong)dispatch_queue_t serialQueue;
@property (nonatomic, strong)dispatch_block_t bindBlock;
@property (nonatomic, strong)dispatch_block_t insertCloudBlock;

@property (nonatomic, strong) UIButton * deleteAllButton;

@end

@implementation CMSuggestionStripView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - getter/setter
- (CMCollectionView *)collectionView {
    if(!_collectionView) {
        CMPageCollectionViewFlowLayout* layout = [CMPageCollectionViewFlowLayout new];

        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        // 是用iOS 8的self-sizing cell，collectionView的contentsize会不对，初步判断为iOS的bug，且在10.x系统仍未修复，故目前仍使用自己autolayout算高，并缓存的思路
//        layout.estimatedItemSize = CGSizeMake(50, toolBarHeightRatio*[CMBizHelper adapterScreenHeight]-2);
        
        _collectionView = [[CMCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CMSuggestionCell class] forCellWithReuseIdentifier:NSStringFromClass([CMSuggestionCell class])];
        CMSuggestionCell* cell = [[CMSuggestionCell alloc] init];
        [self.cacheCellDic setObject:cell forKey:NSStringFromClass([CMSuggestionCell class])];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delaysContentTouches = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.touchDelegate = self;
        cell = nil;
    }
    return _collectionView;
}

- (dispatch_semaphore_t)signal {
    if (!_signal) {
        _signal = dispatch_semaphore_create(0);
    }
    return _signal;
}

- (dispatch_queue_t)serialQueue {
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("stripview_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}

- (NSMutableDictionary<NSString *,CMSuggestionCell *> *)cacheCellDic {
    if (!_cacheCellDic) {
        _cacheCellDic = [NSMutableDictionary dictionary];
    }
    return _cacheCellDic;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        UIImage* image = kCMKeyboardManager.themeManager.predictViewBgImage;
        if (image == nil) {
            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.predictViewBgColor];
        }
        else {
            [_bgImageView setImage:image];
        }
    }
    return _bgImageView;
}

- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = nil;
        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
             image = kCMKeyboardManager.themeManager.emojiImage;
        }else{
            image = [[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
        }
        if (image) {
            [_emojiBtn setImage:image forState:UIControlStateNormal];
            [_emojiBtn setImage:image forState:UIControlStateHighlighted];
        }
        [_emojiBtn addTarget:self action:@selector(handleEmojiBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
#ifdef DEBUG
        [_emojiBtn addTarget:self action:@selector(handleEmojiBtnMoreTapped:) forControlEvents:UIControlEventTouchDownRepeat];
#endif
        [_emojiBtn sizeToFit];
    }
    return _emojiBtn;
}

- (CMSuggestionViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [CMSuggestionViewModel new];
    }
    return _viewModel;
}

-(UIButton *)deleteAllButton
{
    if (!_deleteAllButton) {
        _deleteAllButton = [[UIButton alloc] init];
        [_deleteAllButton setImage:[[UIImage imageNamed:@"deleteAllSuggest"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
        [_deleteAllButton setImage:[[UIImage imageNamed:@"deleteAllSuggest"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateHighlighted];
        _deleteAllButton.hidden = YES;
        [_deleteAllButton addTarget:self action:@selector(handleDeleteAllSuggestTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteAllButton sizeToFit];
    }
    return _deleteAllButton;
}

-(void)setShouldShowDeleteAllButton:(BOOL)shouldShowDeleteAllButton
{
    _shouldShowDeleteAllButton = shouldShowDeleteAllButton;
    if (shouldShowDeleteAllButton == YES) {
        self.emojiBtn.hidden = YES;
        self.deleteAllButton.hidden = NO;
        [self addSubview:self.deleteAllButton];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        dispatch_semaphore_signal(self.signal);
        [self addSubview:self.bgImageView];
        [self addSubview:self.collectionView];
        [self addSubview:self.emojiBtn];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgImageView.frame = self.bounds;
    self.emojiBtn.centerY = self.centerY;
    self.emojiBtn.right = self.boundRight - 16.0f;
    self.deleteAllButton.centerY = self.centerY;
    self.deleteAllButton.right = self.boundRight - 16.0f;
    self.collectionView.width = self.emojiBtn.left - 10.0f;
    self.collectionView.height = self.height;

    self.collectionView.left = self.boundleft;
    self.collectionView.top = self.boundTop;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    kLogTrace();
    _signal = nil;
    if (_bindBlock) {
        dispatch_cancel(_bindBlock);
        _bindBlock = nil;
    }
    
    if (_insertCloudBlock) {
        dispatch_cancel(_insertCloudBlock);
        _insertCloudBlock = nil;
    }
    
    if (_cacheCellDic) {
        [_cacheCellDic removeAllObjects];
        _cacheCellDic = nil;
    }
}
#ifndef HostApp
- (void)bindData:(SuggesteWords *)words completeBlock:(CMCompletionBlock)block {
    if (_bindBlock) {
        dispatch_cancel(self.bindBlock);
        self.bindBlock = nil;
    }
    @weakify(self)
    dispatch_block_t bindBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -8, ^{
        @stronglize(self)
        kLogInfo(@"[LOCK1]bindData signal等待");
        if (_signal) {
            dispatch_semaphore_wait(self.signal, DISPATCH_TIME_FOREVER);
        }
        [self.viewModel updateWithSuggestionWords:words completeBlock:^(CMError *error) {
            @stronglize(self)
            if (_signal) {
                kLogInfo(@"[LOCK1] bindData start");
                [self.collectionView reloadData];
                [self.collectionView layoutIfNeeded];
                [self.collectionView setContentOffset:CGPointZero];
                if (block) {
                    block(error);
                }
                kLogInfo(@"[LOCK1] bindData signal释放");
                dispatch_semaphore_signal(self.signal);
                kLogInfo(@"[LOCK1] bindData end");
            }
        }];
    });
    
    dispatch_async(self.serialQueue, bindBlock);
    self.bindBlock = bindBlock;
}


- (void)insertCloudPrediction:(SuggestedWordInfo *)word completeBlock:(CMCompletionBlock)block {
    if (_insertCloudBlock) {
        dispatch_cancel(self.insertCloudBlock);
        self.insertCloudBlock = nil;
    }
    
    @weakify(self)
    dispatch_block_t insertBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -8, ^{
        @stronglize(self)
        kLogInfo(@"[LOCK1]insertData signal等待");
        if (_signal) {
            dispatch_semaphore_wait(self.signal, DISPATCH_TIME_FOREVER);
        }
        CMSuggestionCellViewModel* cellModel = [CMSuggestionCellViewModel viewModelWithInfo:word];
        if ([self.viewModel containCellViewModel:cellModel]) {
            dispatch_semaphore_signal(self.signal);
            return;
        }
        [self.viewModel insertCellViewModel:cellModel atIndexPath:[NSIndexPath indexPathForItem:3 inSection:0] completeBlock:^(CMError *error) {
            @stronglize(self)
            if(!error){
                [self.collectionView performBatchUpdates:^{
                    @stronglize(self)
                    kLogInfo(@"[LOCK1] insertItemsAtIndexPaths update start");
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:3 inSection:0]]];
                    kLogInfo(@"[LOCK1] insertItemsAtIndexPaths update end");
                } completion:^(BOOL finished) {
                    @stronglize(self)
                    if (_signal) {
                        kLogInfo(@"[LOCK1] insertItemsAtIndexPaths complete start");
                        [self.collectionView reloadData];
                        [self.collectionView layoutIfNeeded];
                        if (block) {
                            block(error);
                        }
                        kLogInfo(@"[LOCK1] insertData signal释放");
                        dispatch_semaphore_signal(self.signal);
                        kLogInfo(@"[LOCK1] insertItemsAtIndexPaths complete end");
                    }
                }];
            } else {
                if (_signal) {
                    kLogInfo(@"[LOCK1] reloadData start");
                    if (block) {
                        block(error);
                    }
                    kLogInfo(@"[LOCK1] reloadData signal释放");
                    dispatch_semaphore_signal(self.signal);
                    kLogInfo(@"[LOCK1] reloadData end");
                }
            }
        }];
    });
    
    dispatch_async(self.serialQueue, insertBlock);
    self.insertCloudBlock = insertBlock;
}
#else
- (void)bindData:(NSArray<NSString*> *)words{
    [self.viewModel updateWithSuggestionWords:words];
    [self.collectionView reloadData];
}
#endif
- (void)switchTheme{
    [self.collectionView reloadData];
   UIImage* image = [[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
    if (image) {
        [_emojiBtn setImage:image forState:UIControlStateNormal];
        [_emojiBtn setImage:image forState:UIControlStateHighlighted];
    }
}
- (void)handleEmojiBtnTapped:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPredictView:emojiBtnTapped:)]) {
        [self.delegate onPredictView:self emojiBtnTapped:nil];
    }
}

- (void)handleEmojiBtnMoreTapped:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPredictView:emojiBtnMoreTapped:)]) {
        [self.delegate onPredictView:self emojiBtnMoreTapped:nil];
    }
}

- (void)handleDeleteAllSuggestTapped:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPredictView:deleteAllSuggestTapped:)]) {
        [self.delegate onPredictView:self deleteAllSuggestTapped:nil];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMSuggestionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMSuggestionCell class]) forIndexPath:indexPath];
    CMSuggestionCellViewModel* cellModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    if (cellModel) {
        [cell bindData:cellModel];
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMSuggestionCell* cell = [self.cacheCellDic objectForKey:NSStringFromClass([CMSuggestionCell class])];
    CMSuggestionCellViewModel* cellModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    if (cell && cellModel && [cellModel isKindOfClass:[CMSuggestionCellViewModel class]]) {
        [cell bindData:cellModel];
        return CGSizeMake(cellModel.cachedSize.width, [CMKeyboardManager toolbarHeight]);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CMSuggestionCellViewModel* cellModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    if (self.delegate && cellModel) {
        [self.delegate onPredictView:self tappedSuggestion:cellModel.suggestInfo];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    kLogInfo(@"velocity:%@", NSStringFromCGPoint(velocity));
    if (velocity.x > 0.5 && self.leftOffset > 0.0f) {
        *targetContentOffset = CGPointMake(self.leftOffset, targetContentOffset->y);
    }
    else if (velocity.x < -0.5 && self.rightOffset > 0.0f) {
        *targetContentOffset = CGPointMake(self.rightOffset, targetContentOffset->y);
    }
    self.leftOffset = 0.0f;
    self.rightOffset = 0.0f;
}

#pragma mark -CMCollectionViewDelegate
- (void)onCollectionView:(UICollectionView *)collectionView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    NSArray<NSIndexPath *>* visibleIndexs = [self.collectionView indexPathsForVisibleItems];
    
    NSArray<NSIndexPath *>* sortedIndexs = [visibleIndexs sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath*  _Nonnull index1, NSIndexPath*  _Nonnull index2) {
        if (index1.row > index2.row) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if (index1.row < index2.row) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    __block UICollectionViewLayoutAttributes* firstScroll = nil;
    __block UICollectionViewLayoutAttributes* lastScroll = nil;
    
    CGRect collectionViewToScreen = [self.collectionView convertRect:self.collectionView.bounds toView:self];
    [sortedIndexs enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:obj];
        CGRect attrsToScreen = [self.collectionView convertRect:attr.frame toView:self];
        if (attrsToScreen.origin.x < collectionViewToScreen.origin.x && attrsToScreen.origin.x + attrsToScreen.size.width >= collectionViewToScreen.origin.x && !firstScroll) {
            firstScroll = attr;
        }
        else if (attrsToScreen.origin.x >= collectionViewToScreen.origin.x && !firstScroll) {
            firstScroll = [self.collectionView layoutAttributesForItemAtIndexPath:[sortedIndexs objectAtIndex:idx> 1 ? idx-1 : 0]];
        }
        else if (attrsToScreen.origin.x < collectionViewToScreen.origin.x+collectionViewToScreen.size.width && attrsToScreen.origin.x + attrsToScreen.size.width >= collectionViewToScreen.origin.x+collectionViewToScreen.size.width) {
            lastScroll = attr;
        }
        else if (attrsToScreen.origin.x > collectionViewToScreen.origin.x && attrsToScreen.origin.x + attrsToScreen.size.width < collectionViewToScreen.origin.x+collectionViewToScreen.size.width) {
            lastScroll = [self.collectionView layoutAttributesForItemAtIndexPath:[sortedIndexs objectAtIndex:idx+1<sortedIndexs.count ? idx+1 : sortedIndexs.count-1]];
        }
    }];
    
    if (firstScroll) {
        CGRect attrsToScreen = [self.collectionView convertRect:firstScroll.frame toView:self];
        CGFloat offset = firstScroll.frame.origin.x - (collectionViewToScreen.origin.x + collectionViewToScreen.size.width - attrsToScreen.origin.x - attrsToScreen.size.width + attrsToScreen.origin.x);
        self.rightOffset = offset;
    }
    
    if (lastScroll) {
        self.leftOffset = lastScroll.frame.origin.x;
    }
}
- (void)onCollectionView:(UICollectionView *)collectionView touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.viewController touchesMoved:touches withEvent:event];

}
- (void)onCollectionView:(UICollectionView *)collectionView touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.viewController touchesEnded:touches withEvent:event];
    
}
- (void)onCollectionView:(UICollectionView *)collectionView touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.viewController touchesCancelled:touches withEvent:event];
}
@end
