//
//  CMEmojiKeyboardView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import "CMEmojiKeyboardView.h"
#import "CMKeyButton.h"
#import "HMSegmentedControl.h"
#import "CMEmojiCell.h"
#import "CMBaseKeyboardViewModel.h"
#import "CMEmojiKeyboardViewModel.h"
#import "CMEmojiSectionModel.h"
#import "CMKeyModel.h"
#import "UIView+Util.h"
#import "UIImage+Util.h"
#import "CMPageCollectionViewFlowLayout.h"
#import "CMInfoc.h"
#import "CMSettingManager.h"
#import "CMRowView.h"
#import "CMKeyboardManager.h"
#import "UIDevice+Util.h"
#import "CMNotificationConstants.h"
#import "CMThemeManager.h"

#define ImageViewTage   2000

static float const emojiSectionTopMargin    = 5.0;
static float const emojiCellSize            = 33.0;
static float const minSpace                 = 6.0;
static float const minSpaceBigger           = 9.0f;

@interface CMEmojiKeyboardView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CMEmojiCellDelegate>

@property (nonatomic, strong)UICollectionView* collectionView;
@property (nonatomic, assign)NSInteger lineNum;
@property (nonatomic, assign)NSInteger rowNum;
@property (nonatomic, strong) NSArray<NSNumber *> *emojiGroupPageIndexs;
@property (nonatomic, strong) NSArray<NSNumber *> *emojiGroupPageCounts;
@property (nonatomic, assign) NSInteger emojiGroupTotalPageCount;
@property (nonatomic, assign) NSInteger onePageCount;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat emojiSectionLeftMargin;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong)CMKeyButton* layoutBtn;
@property (nonatomic, strong)CMKeyButton* returnBtn;

@property (nonatomic, strong)HMSegmentedControl* segmentControl;

@property (nonatomic, assign)BOOL isTapped;


// 主题相关
@property (nonatomic, strong)UIColor* iconTintColor;

@end

@implementation CMEmojiKeyboardView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _iconTintColor = kCMKeyboardManager.themeManager.tintColor;
        
        _isTapped = NO;
        [self addSubview:self.pageControl];
        [self addSubview:self.collectionView];
        [self addSubview:self.segmentControl];
        
        _emojiGroupTotalPageCount = -1;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    kLogTrace();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layoutBtn.height = [CMKeyboardManager keyHeight];
    self.returnBtn.height = [CMKeyboardManager keyHeight];
    
    self.layoutBtn.width = [kCMKeyboardManager getRealWidthByRatio:self.layoutBtn.keyModel.keyWidthRatio];
    self.layoutBtn.left = self.boundleft + 4.0f;
    self.layoutBtn.bottom = self.boundBottom;
    
    self.returnBtn.width = [kCMKeyboardManager getRealWidthByRatio:self.returnBtn.keyModel.keyWidthRatio];
    self.returnBtn.right = self.boundRight - 4.0f;
    self.returnBtn.centerY = self.layoutBtn.centerY;
    
    self.segmentControl.width = self.returnBtn.left - 4.0f - self.layoutBtn.right - 4.0f;
    self.segmentControl.left = self.layoutBtn.right + 4.0f;
    self.segmentControl.height = [CMKeyboardManager keyHeight];
    self.segmentControl.centerY = self.layoutBtn.centerY;
    
    self.collectionView.width = self.width;
    self.collectionView.height = self.layoutBtn.top;
    self.collectionView.top = self.boundTop;
    
    self.pageControl.width = self.width;
    self.pageControl.bottom = self.segmentControl.top;
}

- (void)didMoveToWindow {
    if (self.window) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:kNotificationOrientationTransit object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [CMKeyboardManager sharedInstance].lastIsRecentlyEmojiSection = self.segmentControl.selectedSegmentIndex == 0 ? YES : NO;
    }
}

#pragma mark - update constraints
- (void)handleOrientationNotification:(NSNotification *)notify {
    id<UIViewControllerTransitionCoordinator> coordinator = [notify object];
    [self setNeedsLayout];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self layoutIfNeeded];
            [self reloadCollectionView];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        }];
    }
    else {
        [self layoutIfNeeded];
        [self reloadCollectionView];
    }
}

- (CMBaseKeyboardViewModel *)viewModel {
    if (!_viewModel) {
        NSString *emojiPlistName = nil;
        if (IOS11_1_OR_LATER)
        {
            emojiPlistName = @"EmojiList_11.1";
        }
        else if (IOS11_OR_LATER)
        {
            emojiPlistName = @"EmojiList_11.0";
        }
        else
            if (IOS10_2_OR_LATER) {
            emojiPlistName = @"EmojiList_10.2";
        }else if (IOS10_OR_LATER) {
            emojiPlistName = @"EmojiList_10.0";
        }else if (IOS9_1_OR_LATER) {
            emojiPlistName = @"EmojiList_9.1";
        }else{
            emojiPlistName = @"EmojiList_8.3";
        }
        _viewModel = [CMEmojiKeyboardViewModel viewModelWithPlist:[[NSBundle mainBundle] pathForResource:emojiPlistName ofType:@"plist"]];
    }
    return _viewModel;
}

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel deleteModel:(CMKeyModel *)deleteKeyModel returnModel:(CMKeyModel *)returnKeyModel {
    CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.viewModel;
    
    if (theViewModel.layoutKeyModel == layoutKeyModel && theViewModel.deleteKeyModel == deleteKeyModel && theViewModel.returnKeyModel == returnKeyModel) {
        [self.collectionView reloadData];
        [self setNeedsLayout];
        return;
    }
    
    theViewModel.layoutKeyModel = [layoutKeyModel copy];
    theViewModel.deleteKeyModel = [deleteKeyModel copy];
    theViewModel.returnKeyModel = [returnKeyModel copy];
    
    NSMutableArray* iconArray = [NSMutableArray array];
    NSMutableArray* iconHighlightArray = [NSMutableArray array];
    
    [theViewModel.emojiArray enumerateObjectsUsingBlock:^(CMEmojiSectionModel * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage* iconImage = [UIImage imageNamed:section.sectionNormalIconName];
        UIImage* iconHighlightImage = [UIImage imageNamed:section.sectionHighlightIconName];
        if (iconImage) {
            [iconArray addObject:self.iconTintColor ? [iconImage imageWithTintColor:self.iconTintColor] : iconImage];
        }
        
        if (iconHighlightImage) {
            [iconHighlightArray addObject:self.iconTintColor ? [iconHighlightImage imageWithTintColor:self.iconTintColor] : iconHighlightImage];
        }
    }];
    if (iconArray.count > 0) {
        self.segmentControl.sectionImages = [iconArray copy];
    }
    
    if (iconHighlightArray.count > 0) {
        self.segmentControl.sectionSelectedImages = [iconHighlightArray copy];
    }
    
    if (self.layoutBtn && self.layoutBtn.superview) {
        [self.layoutBtn removeFromSuperview];
        self.layoutBtn = nil;
    }
    theViewModel.layoutKeyModel.key = @"ABC";
    theViewModel.layoutKeyModel.layoutId = @"primary";
    @weakify(self)
    self.layoutBtn = [[CMKeyButton alloc] initWithKeyModel:theViewModel.layoutKeyModel];
    self.layoutBtn.userInteractionEnabled = YES;
    [self.layoutBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        [self hidePreView:NO];
        if (self.delegate) {
            [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
        }
    }];
    [self addSubview:self.layoutBtn];
    
    if (self.returnBtn && self.returnBtn.superview) {
        [self.returnBtn removeFromSuperview];
        self.returnBtn = nil;
    }
    self.returnBtn = [[CMKeyButton alloc] initWithKeyModel:theViewModel.returnKeyModel];
    self.returnBtn.userInteractionEnabled = YES;
    
    [self.returnBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        if (self.delegate) {
            [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
        }
    }];
    
    [self addSubview:self.returnBtn];
    
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
}


#pragma mark - getter/setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CMEmojiCell class] forCellWithReuseIdentifier:NSStringFromClass([CMEmojiCell class])];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        _collectionView.decelerationRate = 0.4f;
        if (IOS10_OR_LATER) {
            [_collectionView setPrefetchingEnabled:NO];
        }
    }
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        UIColor *tintColor = self.iconTintColor ? self.iconTintColor : [UIColor colorWithRed:85/255.0 green:189/255.0 blue:179/255.0 alpha:1.0];
        _pageControl.currentPageIndicatorTintColor = tintColor;
        _pageControl.pageIndicatorTintColor = [tintColor colorWithAlphaComponent:0.5];
        _pageControl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    }
    return _pageControl;
}

- (HMSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[HMSegmentedControl alloc] init];
        _segmentControl.backgroundColor = [UIColor clearColor];
        _segmentControl.type = HMSegmentedControlTypeImages;
        _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
        _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
        @weakify(self);
        [_segmentControl setIndexChangeBlock:^(NSInteger index) {
            @stronglize(self);
            self.isTapped = YES;
            
            CGPoint off = self.collectionView.contentOffset;
            off.x = self.emojiGroupPageIndexs[index].integerValue * CGRectGetWidth(self.collectionView.frame);
            [self.collectionView setContentOffset:off animated:NO];
            self.pageControl.numberOfPages = self.emojiGroupPageCounts[index].integerValue;
            self.pageControl.currentPage = 0;
            
            if (self.delegate && [self.delegate conformsToProtocol:@protocol(CMEmojiKeyboardViewDelegate)] && [self.delegate respondsToSelector:@selector(onKeyboard:emojiSectionSelected:)]) {
                [(id<CMEmojiKeyboardViewDelegate>)self.delegate onKeyboard:self emojiSectionSelected:index];
            }
            
            self.isTapped = NO;
            
        }];
    }
    return _segmentControl;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self.collectionView) {
        CGPoint thePt = [self convertPoint:point toView:self];
        CMEmojiCell* cell = (CMEmojiCell *)[self.collectionView findNearestView:thePt class:[CMEmojiCell class]];
        return cell.keyBtn;
    }
    
    return hitTestView;
}

#pragma mark -
- (void)reloadCollectionView
{
    [self removeEmojiImage];
    [self setupLineAndRowNum];
    [self setupSections];
    [self setupEmojiImageView];
    [self.collectionView reloadData];
}

- (void)setupLineAndRowNum
{
    self.minimumInteritemSpacing = minSpace;
    [self calculateLineNum:minSpace];
    
    if (self.lineNum > 4) {
        // 大于4行的情况发生在iPad横屏的情况
        [self calculateLineNum:minSpaceBigger];
        self.minimumInteritemSpacing = minSpaceBigger;
    }
    
    self.minimumLineSpacing = ( CGRectGetHeight(self.collectionView.frame) - emojiSectionTopMargin * 2 - emojiCellSize * self.lineNum ) / (self.lineNum - 1);
    
    self.rowNum = (CGRectGetWidth(self.collectionView.frame) - emojiCellSize) / (emojiCellSize + self.minimumLineSpacing) + 1;
    
    self.onePageCount = self.lineNum * self.rowNum - 1;
    self.emojiSectionLeftMargin = ( CGRectGetWidth(self.collectionView.frame) - emojiCellSize * self.rowNum - self.minimumLineSpacing * (self.rowNum - 1) ) / 2;
}

- (void)calculateLineNum:(float)emojiMinimumInteritemSpacing
{
    self.lineNum = (NSInteger)(CGRectGetHeight(self.collectionView.frame) / emojiCellSize);
    while (CGRectGetHeight(self.collectionView.frame) < emojiCellSize * self.lineNum + emojiMinimumInteritemSpacing * (self.lineNum - 1) + emojiSectionTopMargin * 2) {
        self.lineNum --;
    }
}

- (void)setupSections
{
    CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.viewModel;
    
    // 表情组总页数
    NSMutableArray *pageCounts = [NSMutableArray new];
    self.emojiGroupTotalPageCount = 0;
    [theViewModel.emojiArray enumerateObjectsUsingBlock:^(CMEmojiSectionModel * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger pageCount = ( idx == 0 ? 1 : ceil(section.emojiArray.count / (float)self.onePageCount) );
        if (pageCount == 0) pageCount = 1;
        [pageCounts addObject:@(pageCount)];
        _emojiGroupTotalPageCount += pageCount;
    }];
    self.emojiGroupPageCounts = pageCounts;
    
    // 获取各表情组起始页下标数组
    NSMutableArray *indexs = [NSMutableArray new];
    __block NSUInteger index = 0;
    [theViewModel.emojiArray enumerateObjectsUsingBlock:^(CMEmojiSectionModel * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexs addObject:@(index)];
        NSUInteger count = self.emojiGroupPageCounts[idx].unsignedIntegerValue;
        if (count == 0)  count = 1;
        index += count;
    }];
    self.emojiGroupPageIndexs = indexs;
    
    NSInteger selectedSegmentIndex = [CMKeyboardManager sharedInstance].lastIsRecentlyEmojiSection ? 0 : 1;
    
    CGPoint off = CGPointMake(0, 0);
    off.x = self.emojiGroupPageIndexs[selectedSegmentIndex].integerValue * CGRectGetWidth(self.collectionView.frame);
    [self.collectionView setContentOffset:off animated:NO];
    self.segmentControl.selectedSegmentIndex = selectedSegmentIndex;
    self.pageControl.numberOfPages = self.emojiGroupPageCounts[selectedSegmentIndex].integerValue;
    self.pageControl.currentPage = 0;
}

- (void)setupEmojiImageView
{
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    if (kCMKeyboardManager.emojiImages.count > 0 && kCMKeyboardManager.emojiImages.count != self.emojiGroupTotalPageCount) {
        // 容错
        [kCMKeyboardManager.emojiImages removeAllObjects];
    }
    
    if (kCMKeyboardManager.emojiImages.count == 0) {
        for (NSInteger i = 0; i < self.emojiGroupTotalPageCount; i++) {
            [kCMKeyboardManager.emojiImages addObject:[NSNull null]];
        }
    }
    
    for (NSInteger i = 0; i < self.emojiGroupTotalPageCount; i++) {
        UIImageView *emojiImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width , 0, width, CGRectGetHeight(self.collectionView.frame))];
        emojiImageView.tag = ImageViewTage + i;
        [self.collectionView addSubview:emojiImageView];
    }
}

- (void)removeEmojiImage
{
    [self.collectionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImageView class]] && obj.tag >= ImageViewTage) {
            [obj removeFromSuperview];
        }
    }];
    [kCMKeyboardManager.emojiImages removeAllObjects];
}

- (UIImage *)drawOnePageEmojiImage:(NSInteger)pageIndex
{
    if (kCMKeyboardManager.emojiImages.count < pageIndex) {
        return nil;
    }
    
    UIImage *emojiImage = kCMKeyboardManager.emojiImages[pageIndex];
    if (pageIndex != 0 && [emojiImage isKindOfClass:[UIImage class]]) {
        return emojiImage;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.collectionView.frame.size, NO, 0.0f);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextDrawingMode(contextRef, kCGTextStroke);
    CGContextSetRGBFillColor(contextRef, 1, 1, 1, 0);
    
    CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.viewModel;
    CMEmojiSectionModel *group = nil;
    NSUInteger page = 0;
    for (NSInteger i = self.emojiGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *sectionPageIndex = self.emojiGroupPageIndexs[i];
        if (pageIndex >= sectionPageIndex.unsignedIntegerValue) {
            group = theViewModel.emojiArray[i];
            page = pageIndex - sectionPageIndex.unsignedIntegerValue;
            break;
        }
    }
    
    CGFloat realInteritemSpacing = ( CGRectGetHeight(self.collectionView.frame) - emojiSectionTopMargin * 2 - emojiCellSize * self.lineNum ) / (self.lineNum - 1);
    for (NSInteger i = 0; i < self.onePageCount; i++) {
        NSInteger lineIndex = i / self.rowNum;
        NSInteger rowIndex = i % self.rowNum;
        NSInteger index = page * self.onePageCount + i;
        if (group.emojiArray.count > index) {
            NSString *emojiStr = group.emojiArray[index].key;
            [emojiStr drawAtPoint:CGPointMake(self.emojiSectionLeftMargin + rowIndex * (emojiCellSize + self.minimumLineSpacing), emojiSectionTopMargin + lineIndex * (emojiCellSize + realInteritemSpacing)) withAttributes:@{NSFontAttributeName: kCMKeyboardManager.themeManager.emojiKeyFont}];
        }else{
            break;
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [kCMKeyboardManager.emojiImages replaceObjectAtIndex:pageIndex withObject:image];
    
    return image;
}

- (CMKeyModel *)emojiModelForIndexPath:(NSIndexPath *)indexPath
{
    CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.viewModel;
    
    NSUInteger section = indexPath.section;
    for (NSInteger i = self.emojiGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = self.emojiGroupPageIndexs[i];
        if (section >= pageIndex.unsignedIntegerValue) {
            CMEmojiSectionModel *group = theViewModel.emojiArray[i];
            NSUInteger page = section - pageIndex.unsignedIntegerValue;
            NSUInteger index = page * self.onePageCount + indexPath.row;
            
            // transpose line/row
            NSUInteger ip = index / self.onePageCount;
            NSUInteger ii = index % self.onePageCount;
            NSUInteger reIndex = (ii % self.lineNum) * self.rowNum + (ii / self.lineNum);
            index = reIndex + ip * self.onePageCount;
            
            if (index < group.emojiArray.count) {
                return group.emojiArray[index];
            }else{
                return nil;
            }
            break;
        }
    }
    return nil;
}

- (BOOL)shouldUseBatchInpupt {
    return NO;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSAssert([self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]], @"[numberOfSectionsInCollectionView]: viewModel invalid");
    if (![self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]]) {
        return 0;
    }
    
    if (self.emojiGroupTotalPageCount == -1) {
        if (kCMKeyboardManager.emojiImages.count > 0) {
//            kCMKeyboardManager.emojiImages.count > 1代表不是第一次展示emoji页面
            UIImage *lastDrawEmojiImage = kCMKeyboardManager.emojiImages[0];
            if (![lastDrawEmojiImage isKindOfClass:[UIImage class]] && kCMKeyboardManager.emojiImages.count > 1) {
                lastDrawEmojiImage = kCMKeyboardManager.emojiImages[1];
            }
            if (![lastDrawEmojiImage isKindOfClass:[UIImage class]] || lastDrawEmojiImage.size.width != [CMBizHelper adapterScreenWidth]) {
                // ![lastDrawEmojiImage isKindOfClass:[UIImage class]]为容错  由于某种原因 emoji图片绘制完add到kCMKeyboardManager.emojiImages数组（或绘制）失败
                // 本次键盘弹起横竖屏与上次横竖屏方向不同 emoji图片需重新绘制
                [kCMKeyboardManager.emojiImages removeAllObjects];
            }
        }
        [self setupLineAndRowNum];
        [self setupSections];
        [self setupEmojiImageView];
    }
    return _emojiGroupTotalPageCount;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert([self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]], @"[numberOfItemsInSection]: viewModel invalid");
    if (![self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]]) {
        return 0;
    }
    CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.viewModel;
    
    if (theViewModel == nil || theViewModel.emojiArray == nil || theViewModel.emojiArray.count <= 0) {
        return 0;
    }
    return self.onePageCount + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert([self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]], @"[cellForItemAtIndexPath]: viewModel invalid");
    
    UIImageView *imageView = [self.collectionView viewWithTag:ImageViewTage + indexPath.section];
    if (imageView.image == nil) {
        imageView.image = [self drawOnePageEmojiImage:indexPath.section];
    }
    
    CMEmojiCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMEmojiCell class]) forIndexPath:indexPath];
    if (indexPath.row == self.onePageCount) {
        CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.viewModel;
        [cell bindKeyModel:theViewModel.deleteKeyModel delegate:self];
    }else{
        CMKeyModel *model = [self emojiModelForIndexPath:indexPath];
        [cell bindKeyModel:model delegate:self];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(emojiCellSize, emojiCellSize);
//    return CGSizeMake(KScalePt(emojiCellSize), KScalePt(emojiCellSize));
//    return CGSizeMake(KScalePt(emojiCellSize), KScalePt(emojiCellSize));

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSAssert([self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]], @"[insetForSectionAtIndex]: viewModel invalid");
    if (![self.viewModel isKindOfClass:[CMEmojiKeyboardViewModel class]]) {
        return UIEdgeInsetsZero;
    }
    
    return UIEdgeInsetsMake(emojiSectionTopMargin, self.emojiSectionLeftMargin, emojiSectionTopMargin, self.emojiSectionLeftMargin);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.minimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.minimumLineSpacing;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = round(scrollView.contentOffset.x / scrollView.width);
    if (page < 0) page = 0;
    else if (page >= self.emojiGroupTotalPageCount) page = self.emojiGroupTotalPageCount - 1;
    
    for (NSInteger i = 0; i < self.emojiGroupPageCounts.count; i++) {
        NSInteger pageCount = self.emojiGroupPageCounts[i].integerValue;
        if (page + 1 <= self.emojiGroupPageIndexs[i].unsignedIntegerValue + pageCount) {
            self.pageControl.numberOfPages = self.emojiGroupPageCounts[i].integerValue;
            self.pageControl.currentPage = self.pageControl.numberOfPages - (self.emojiGroupPageIndexs[i].unsignedIntegerValue + pageCount - page);
            
            if (i != self.segmentControl.selectedSegmentIndex) {
                [self.segmentControl setSelectedSegmentIndex:i];
            }
            break;
        }
    }
}


#pragma mark - CMEmojiCellDelegate
- (void)onEmojiCellTouchDown:(CMEmojiCell *)cell keyButton:(CMKeyButton *)keyButton touchPt:(CGPoint)touchPt
{
    [self hidePreView:NO];
    [self showPreview:keyButton];
    if (self.delegate) {
        [self.delegate onKeyboard:self touchDownKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
    }
}

- (void)onEmojiCellTapped:(CMEmojiCell *)cell keyButton:(CMKeyButton *)keyButton touchPt:(CGPoint)touchPt {
    [self hidePreView:YES];
    [CMInfoc reportEmojiTapped:self.inSource emoji:keyButton.keyModel.key];
    NSMutableArray *recentlyEmojiMArray = [NSMutableArray arrayWithArray:kCMSettingManager.recentlyEmoji];
    [recentlyEmojiMArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:keyButton.keyModel.key]) {
            [recentlyEmojiMArray removeObject:obj];
            [recentlyEmojiMArray addObject:@""];
            *stop = YES;
        }
    }];
    [recentlyEmojiMArray insertObject:keyButton.keyModel.key atIndex:0];
    if (recentlyEmojiMArray.count > self.onePageCount || [[recentlyEmojiMArray lastObject] isEqualToString:@""]) {
        [recentlyEmojiMArray removeLastObject];
    }
    kCMSettingManager.recentlyEmoji = recentlyEmojiMArray;
}

- (void)onEmojiCellCancel:(CMEmojiCell *)cell keyButton:(CMKeyButton *)keyButton touchPt:(CGPoint)touchPt {
    [self hidePreView:YES];
}

- (void)onDelCellTapped:(CMKeyButton *)keyButton
{
    self.isDeleteButtonDown = NO;
    [self startDeleteRepeate:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeNormal]];
    [self cancleDeleteRepeate:self deleteButton:keyButton];
}

- (void)onDelCellTouchDown:(CMKeyButton *)keyButton touchPt:(CGPoint)touchPt
{
    self.deleteTouchPoint = touchPt;
    self.isDeleteButtonDown = YES;
    self.deleteKeyModel = keyButton.keyModel;
    [self performSelector:@selector(startDeleteRepeate:) withObject:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeShort] afterDelay:0.6];
}

- (void)onDelCellCancel:(CMKeyButton *)keyButton
{
    [self cancleDeleteRepeate:self deleteButton:keyButton];
}
@end

