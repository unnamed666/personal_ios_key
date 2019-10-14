//
//  CMGifKeyboardView.m
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/10/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMGifKeyboardView.h"
#import "UIDevice+Util.h"
#import "CMKeyButton.h"
#import "CMKeyModel.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "UIImage+Util.h"
#import "UIView+Toast.h"
#import "MobileCoreServices/UTCoreTypes.h"
#import "CMFullAccessTipView.h"
#import "YYAnimatedImageView.h"
#import "CMEmoticonPasteTip.h"
#import <YYImage/YYImage.h>
#import "CMNotificationConstants.h"
#import "CMInfoc.h"
#import "CMTenorTag.h"
#import <YYWebImage/YYWebImage.h>
#import "CMGifTagDetailView.h"
#import "KeyboardViewController.h"
#import "CMSettingManager.h"
#import "CMFullAccessTipView.h"
#import "CMTipView.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString* const RECETNT  = @"Recent";
static NSInteger const RECETNT_TAG  = 101;
static NSString* const TRENDING  = @"Trending";
static NSInteger const TRENDING_TAG  = 102;

@interface CMGifCell:UICollectionViewCell
@property (nonatomic, strong)UILabel * itemLabel;
@property (nonatomic, strong)UIImageView* cellMarkImageView;
@property (nonatomic, strong)YYAnimatedImageView * imageView;
@property (nonatomic, strong) CALayer* coverLayer;
@end

@implementation CMGifCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.imageView];
        [self.layer addSublayer:self.coverLayer];
        [self addSubview:self.itemLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.coverLayer.frame = self.bounds;
    if(_cellMarkImageView)
    {
        self.itemLabel.frame = CGRectMake(0, _cellMarkImageView.bottom + 5, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/4);
    }
    else
    {
        self.itemLabel.frame = CGRectMake(0, CGRectGetHeight(self.bounds)*2/5, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/4);
    }
}

- (YYAnimatedImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _imageView;
}

- (CALayer *)coverLayer
{
    if (!_coverLayer)
    {
        _coverLayer = [CALayer layer];
        _coverLayer.frame = self.bounds;
        _coverLayer.backgroundColor = rgba(0, 0, 0, 0.3).CGColor;
    }
    
    return _coverLayer;
}

- (void) hideCellMarkImage
{
    [_cellMarkImageView removeFromSuperview];
    _cellMarkImageView = nil;
    self.itemLabel.frame = CGRectMake(0, CGRectGetHeight(self.bounds)*2/5, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/5);
}

- (void) showCellMarkImage:(NSInteger) tag
{
    [self addSubview:self.cellMarkImageView];
    if (tag == RECETNT_TAG)
    {
        self.cellMarkImageView.image = [UIImage imageNamed:@"gif_recent"];
        CGFloat imageWidth = 18.5;
        self.cellMarkImageView.frame = CGRectMake((self.width - imageWidth) / 2, CGRectGetHeight(self.bounds) / 3.68, imageWidth, imageWidth);
    }
    else if (tag == TRENDING_TAG)
    {
        CGFloat imageWidth = 17.5;
        CGFloat imageHeight = 22;
        self.cellMarkImageView.frame = CGRectMake((self.width - imageWidth) / 2, CGRectGetHeight(self.bounds) / 3.68, imageWidth, imageHeight);
        self.cellMarkImageView.image = [UIImage imageNamed:@"gif_trending"];
    }
}

- (UILabel *)itemLabel
{
    if (!_itemLabel)
    {
        _itemLabel = [UILabel new];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.textColor = [UIColor whiteColor];
        _itemLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
    }
    
    return _itemLabel;
}

- (UIImageView *)cellMarkImageView
{
    if (!_cellMarkImageView)
    {
        _cellMarkImageView = [[UIImageView alloc] init];
        _cellMarkImageView.image = [UIImage imageNamed:@"gif_recent"];
    }
    
    return _cellMarkImageView;
}
@end


@interface CMGifKeyboardView()<UICollectionViewDelegate,UICollectionViewDataSource,CMGifTagDetailViewDelegate,CMTipsViewDelegate>
@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)UIView * bottomView;
@property (nonatomic)        CGSize   itemSize;
@property (nonatomic, strong)CMKeyButton * layoutBtn;
@property (nonatomic, strong)CMKeyButton * deleteBtn;
@property (nonatomic, strong)CMEmoticonPasteTip * pasteTip;
@property (nonatomic, strong)NSMutableArray<CMTenorTag*>* modelArray;
@property (nonatomic, strong) UIImage *  placeholder;
@property (nonatomic, strong)CMGifTagDetailView* gifTagDeatilView;
@property (nonatomic, strong)CMKeyModel *layoutKeyModel;
//@property (nonatomic, strong)CMKeyModel *deleteKeyModel;

@property (nonatomic, assign) CGFloat gifSectionLeftRightMargin;
@property (nonatomic, assign) CGFloat gifSectionTopBottomMargin;
@property (nonatomic, assign) CGFloat minumLineSpacing;
@property (nonatomic, assign) CGFloat minumInteritSpacing;
@property (nonatomic, assign) CGFloat itemScale;
@property (nonatomic, assign) CGFloat itemHeightScale;
@property (nonatomic, assign) NSInteger countPerSection;
@property (nonatomic, assign) BOOL isSettedCollectionMargin;
@property (nonatomic, assign) int nTotalPageCount;
@property (nonatomic, strong) UIPageControl* pageControl;

@property (nonatomic, assign) int nRowCount;
@property (nonatomic, assign) int nColumnCount;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL isShowingFullTip;
@end

@implementation CMGifKeyboardView

- (void)dealloc{
    YYImageCache *imageCache = [YYWebImageManager sharedManager].cache;
    [imageCache.memoryCache removeAllObjects];
    kLog(@"释放啦 %@",self);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        YYImageCache *imageCache = [YYWebImageManager sharedManager].cache;
        imageCache.memoryCache.countLimit = 10;
        
        [self setupModel];
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        _isShowingFullTip = NO;

        if(!kCMKeyboardManager.isFullAccessAllowed){
            if (_isShowingFullTip == NO) {
               CMFullAccessTipView * fullAccessView = [[CMFullAccessTipView alloc] initWithFrame:CGRectZero];
                fullAccessView.priority = fullAccessTipGif;
                fullAccessView.duration = 10.0f;
                fullAccessView.tipsType = CMTipsTypeGif;
                fullAccessView.tipDelegate = self;
                fullAccessView.layer.zPosition = CGFLOAT_MAX;
                [fullAccessView showInView:self anchorView:nil];
                [fullAccessView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.collectionView);
                }];
            }
        }
    }
    
    return self;
}
- (void)setupModel{
    _modelArray = [NSMutableArray new];

    
    [self.indicator startAnimating];
    [CMTenorTag TenorTagList:^(NSArray<CMTenorTag *> *arr) {
        if(arr){
            if([kCMKeyboardManager isDefaultTheme]){
                
                self.placeholder = [UIImage imageWithColor:rgb(34, 39, 64)];
            }else{
                self.placeholder = [UIImage imageWithColor:kCMKeyboardManager.themeManager.dismissBtnTintColor];
            }
            NSArray * recentlyArr = kCMSettingManager.recentlyGif;
            if(recentlyArr.count>0){
                CMTenorTag * trending = [CMTenorTag new];
                trending.name = RECETNT;
                trending.searchterm = RECETNT;
                trending.imageUrlStr = ((CMGiphy*)recentlyArr.firstObject).fixedWidthSmall.url.absoluteString;
                [_modelArray addObject:trending];
            }

            CMTenorTag * trending = [CMTenorTag new];
            trending.name = TRENDING;
            trending.searchterm = TRENDING;
            [_modelArray addObject:trending];
        
            [_modelArray addObjectsFromArray:arr];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.indicator stopAnimating];
                [self.indicator removeFromSuperview];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_indicator stopAnimating];
                [self.indicator removeFromSuperview];
                CMTipView * tipView = [[CMTipView alloc] initWithIcon:@"icon_warning" message:CMLocalizedString(@"Net_Error", nil)];
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = tipView;
                [hud hideAnimated:YES afterDelay:3.0];
                hud.removeFromSuperViewOnHide = YES;
                hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                hud.bezelView.backgroundColor = COLOR_WITH_RGBA(48, 54, 83, 1);
                hud.bezelView.layer.cornerRadius = 20;
                hud.userInteractionEnabled = NO;
                [hud mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.collectionView);
                    make.centerY.equalTo(self.collectionView);
                }];
            });
        }

    }];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel  deleteModel:(CMKeyModel *)deleteKeyModel
{
    if(!layoutKeyModel)return;
    CMKeyModel * btnModel = [layoutKeyModel copy];
    btnModel.key = @"ABC";
    btnModel.layoutId = @"primary";
    self.layoutKeyModel = btnModel;
    self.deleteKeyModel = deleteKeyModel;
    [self.layoutBtn removeFromSuperview];
    @weakify(self)
    self.layoutBtn = [[CMKeyButton alloc] initWithKeyModel:btnModel];
    self.layoutBtn.userInteractionEnabled = YES;
    [self.layoutBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt)
     {
         @stronglize(self);
         [self hidePreView:NO];
         if (self.delegate) {
             [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
         }
     }];
    [self addSubview:self.layoutBtn];
    
    //    iconImageView
    
    [self.deleteBtn removeFromSuperview];
    
    self.deleteBtn = [[CMKeyButton alloc] initWithKeyModel:deleteKeyModel];
    self.deleteBtn.userInteractionEnabled = YES;
    [self.deleteBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        [self hidePreView:NO];
        if (self.delegate) {
            [self.delegate onKeyboard:self touchDownKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
        }
    }];
    
    [self addSubview:self.deleteBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.minumLineSpacing = 3;
    self.minumInteritSpacing = 3;
    self.gifSectionTopBottomMargin = 4;
    
    if(CGRectGetWidth(self.bounds)==0 || CGRectGetHeight(self.bounds)==0)return;
    int btnY = self.bounds.size.height - [CMKeyboardManager keyHeight];
    int btnWidth = [kCMKeyboardManager getRealWidthByRatio:self.layoutBtn.keyModel.keyWidthRatio];
    _bottomView.frame = CGRectMake(0, btnY , self.bounds.size.width, 40);
    _collectionView.frame = CGRectMake(0,  0, self.bounds.size.width, btnY);
    _layoutBtn.frame =CGRectMake(4, btnY , btnWidth, [CMKeyboardManager keyHeight]);
    _deleteBtn.frame =CGRectMake(self.bounds.size.width-btnWidth-4, btnY , btnWidth, [CMKeyboardManager keyHeight]);
    self.indicator.frame = self.collectionView.frame;
    self.pageControl.width = self.width;
    self.pageControl.centerY = self.deleteBtn.centerY;

    if (YES)
    {
        if(kScreenWidth<kScreenHeight)
        {
            self.nColumnCount = 3;
            if ([UIDevice isHeight1024] || [UIDevice isHeight1112] || [UIDevice isHeight1366])
            {
                self.nColumnCount = 5;
            }
            
            self.nRowCount = 2;
            int itemWidth = (self.bounds.size.width - ((self.nColumnCount + 1) * self.minumLineSpacing))/self.nColumnCount;
            int itemHeight = itemWidth * 0.68;
            if(itemHeight * self.nRowCount + (self.minumInteritSpacing * self.nRowCount - 1) + self.gifSectionTopBottomMargin * 2 < CGRectGetHeight(self.collectionView.bounds))
            {
                self.itemSize = CGSizeMake(itemWidth, (int)(itemWidth*0.68));
                self.minumLineSpacing = (self.bounds.size.width - (self.nColumnCount * itemWidth)) / (self.nColumnCount + 1);
                self.minumInteritSpacing = (self.collectionView.bounds.size.height - itemHeight * self.nRowCount);
            }
            else
            {
                itemHeight = (self.collectionView.bounds.size.height - (self.minumInteritSpacing * self.nRowCount - 1) - self.gifSectionTopBottomMargin * 2) / self.nRowCount;
                itemWidth = itemHeight * self.itemScale;
                self.itemSize = CGSizeMake(itemWidth, itemHeight);
                self.minumLineSpacing = (self.bounds.size.width - (self.nColumnCount * itemWidth)) / (self.nColumnCount + 1);
                self.minumInteritSpacing = (self.collectionView.bounds.size.height - itemHeight * self.nRowCount - self.gifSectionTopBottomMargin * 2);
            }
            
            self.gifSectionLeftRightMargin = (self.bounds.size.width - (self.nColumnCount * itemWidth) - ((self.nColumnCount - 1) * self.minumLineSpacing)) / 2;
            if ([UIDevice isHeight568] || [UIDevice isHeight1112])
            {
                self.minumInteritSpacing = (self.collectionView.bounds.size.height - itemHeight * self.nRowCount) / 3;
                self.gifSectionTopBottomMargin = self.minumInteritSpacing - 1;
            }
            else
            {
                self.gifSectionTopBottomMargin = (self.collectionView.bounds.size.height - self.nRowCount * itemHeight - (self.nRowCount - 1) * self.minumInteritSpacing) / 2 - 1;
            }
            self.countPerSection = self.nColumnCount * self.nRowCount;
        }
        else
        {
            if ([UIDevice isHeight568])
            {
                self.gifSectionTopBottomMargin = 10;
            }
            self.nRowCount = 1;
            int itemHeight = (self.collectionView.bounds.size.height - (self.nRowCount - 1) * self.minumInteritSpacing - self.gifSectionTopBottomMargin * 2) / self.nRowCount;
            int itemWidth = itemHeight * self.itemScale;
            self.itemSize = CGSizeMake(itemWidth, itemHeight);
            
            self.nColumnCount = self.collectionView.bounds.size.width / itemWidth;
            
            self.minumLineSpacing = (self.bounds.size.width - (self.nColumnCount * itemWidth)) / (self.nColumnCount + 1);
            self.minumInteritSpacing = (self.collectionView.bounds.size.height - itemHeight * self.nRowCount - self.gifSectionTopBottomMargin * 2);
            self.gifSectionLeftRightMargin = (self.bounds.size.width - (self.nColumnCount * itemWidth) - ((self.nColumnCount - 1) * self.minumLineSpacing)) / 2;
            self.gifSectionTopBottomMargin = (self.collectionView.bounds.size.height - (self.nRowCount - 1) * self.minumInteritSpacing - itemHeight * self.nRowCount) / 2 - 1;
            self.countPerSection = self.nRowCount * self.nColumnCount;
        }
        
        [self.collectionView reloadData];
        
        self.isSettedCollectionMargin = YES;
    }
}

- (CGFloat)itemScale
{
    if ([UIDevice isHeight736])
    {
        return 1.563;
    }
    else
    {
        return 1.463;
    }
}

- (void)didMoveToWindow {
    if (self.window) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:kNotificationOrientationTransit object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
- (void)handleMemoryWarning{
    if(_gifTagDeatilView && !_gifTagDeatilView.superview){
        self.gifTagDeatilView = nil;
    }
}

#pragma mark - update constraints
- (void)handleOrientationNotification:(NSNotification *)notify {
    self.isSettedCollectionMargin = NO;
    id<UIViewControllerTransitionCoordinator> coordinator = [notify object];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self layoutIfNeeded];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        }];
    }
    else {
        [self layoutIfNeeded];
    }
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger nDataIndex = [self transposeCellIndexToDataIndex:indexPath];
    if (nDataIndex >= self.modelArray.count)
    {
        return ;
    }

    CMTenorTag * tag = _modelArray[nDataIndex];
    [self.gifTagDeatilView showToSuperview:self.superview title:tag.searchterm];
    self.hidden = YES;
    kCMKeyboardManager.keyboardViewController.currentToolBar.hidden = YES;
    
    [CMInfoc reportEmojiTapped:self.inSource emoji:tag.searchterm];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.countPerSection;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.countPerSection == 0)
    {
        return 0;
    }
    self.nTotalPageCount = (self.modelArray.count / self.countPerSection);
    if ((self.modelArray.count % self.countPerSection) > 0)
    {
        ++self.nTotalPageCount;
    }
    self.pageControl.numberOfPages = self.nTotalPageCount;
    self.pageControl.currentPage = 0;
    return self.nTotalPageCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CMGifCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMGifCell class]) forIndexPath:indexPath];
    
    NSInteger nDataIndex = [self transposeCellIndexToDataIndex:indexPath];
    if (nDataIndex >= self.modelArray.count)
    {
         cell.coverLayer.hidden = YES;
        return cell;
    }
    cell.coverLayer.hidden = NO;
    
    CMTenorTag* tag = self.modelArray[nDataIndex];
    if ([tag.name isEqualToString:RECETNT])
    {
        [cell showCellMarkImage:RECETNT_TAG];
    }
    else if ([tag.name isEqualToString:TRENDING])
    {
        [cell showCellMarkImage:TRENDING_TAG];
    }
    else
    {
        [cell hideCellMarkImage];
    }
    
    if(tag.imageUrlStr)
    {
        [cell.imageView yy_setImageWithURL:[NSURL URLWithString:tag.imageUrlStr]  placeholder:nil options:YYWebImageOptionProgressive completion:nil];
        cell.itemLabel.text = tag.name;
    }
    else
    {
        void (^completionBlock)(NSArray<CMGiphy *> *giphyArry, NSError *error) = ^(NSArray<CMGiphy *> *giphyArry, NSError *error)
        {
            CMGiphy *giphy= [giphyArry firstObject];
            if(giphy)
            {
                tag.imageUrlStr = giphy.fixedWidthSmall.url.absoluteString;
                dispatch_async(dispatch_get_main_queue(), ^{
                     CMGifCell * cell1 = (CMGifCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                    __weak typeof(cell1) weakCell = cell1;
                    [cell1.imageView yy_setImageWithURL:giphy.fixedWidthSmall.url placeholder:_placeholder options:YYWebImageOptionProgressive completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                        weakCell.itemLabel.text = tag.name;
                    }];
                });
            }
        };
        
        if([tag.searchterm isEqualToString:TRENDING]){
            [CMGiphy giphyTrendingRequestWithLimit:1 offset:0 completion:completionBlock];
        }
        else
        {
            [CMGiphy giphySearchTagWithQ:tag.searchterm Limit:1 offset:0 completion:completionBlock];
        }
    }
    return cell;
}

- (NSInteger) transposeCellIndexToDataIndex:(NSIndexPath*) thePathIndex
{
    int nSection = thePathIndex.section;
    int nIndexInPage = thePathIndex.row;
    NSInteger nRowInSection = nIndexInPage % self.nRowCount;
    NSInteger nColumnInSection = nIndexInPage / self.nRowCount;
    NSInteger nDataIndex = nRowInSection * self.nColumnCount + nColumnInSection + nSection *self.countPerSection;
    
    return nDataIndex;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[CMGifCell class]])
    {
        ((CMGifCell*)cell).imageView.image= nil;
        ((CMGifCell*)cell).itemLabel.text = nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemSize;
}

#pragma mark - CMGifTagDetailViewManagerDelegate
- (void)dismiss{
    self.hidden = NO;
    kCMKeyboardManager.keyboardViewController.currentToolBar.hidden = NO;
}
- (void)abcBtn:(CMKeyButton*)keyButton{
    if (self.delegate) {
        [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:CGPointZero fromeRepeate:NO];
    }
}
- (void)deleteBtn:(CMKeyButton*)keyButton{
    if (self.delegate) {
        [self.delegate onKeyboard:self touchDownKeyModel:keyButton.keyModel touchPt:CGPointZero fromeRepeate:NO];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(self.gifSectionTopBottomMargin, self.gifSectionLeftRightMargin, self.gifSectionTopBottomMargin, self.gifSectionLeftRightMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.minumInteritSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.minumLineSpacing;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSIndexPath *centerCellIndexPath = [self.collectionView indexPathForItemAtPoint:[self convertPoint:[self center] toView:self.collectionView]];
//    self.pageControl.currentPage = centerCellIndexPath.section;
    
    for (UICollectionViewCell *cell in [self.collectionView visibleCells])
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        self.pageControl.currentPage = indexPath.section;
        break;
    }
}

#pragma mark - get\set

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CMGifCell class] forCellWithReuseIdentifier:NSStringFromClass([CMGifCell class])];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.decelerationRate = 0.4f;
        if (IOS10_OR_LATER)
        {
            [_collectionView setPrefetchingEnabled:NO];
        }
    }
    
    return _collectionView;
}

- (CMGifTagDetailView *)gifTagDeatilView{
    if(!_gifTagDeatilView){
        _gifTagDeatilView = [[CMGifTagDetailView alloc] init];
        _gifTagDeatilView.delegate = self;
        _gifTagDeatilView.inSource = self.inSource;
        [_gifTagDeatilView setupWithLayoutModel:self.layoutKeyModel deleteModel:self.deleteKeyModel];
    }
    return _gifTagDeatilView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        UIColor *tintColor = kCMKeyboardManager.themeManager.dismissBtnTintColor ? kCMKeyboardManager.themeManager.dismissBtnTintColor : [UIColor colorWithRed:85/255.0 green:189/255.0 blue:179/255.0 alpha:1.0];
        _pageControl.currentPageIndicatorTintColor = tintColor;
        _pageControl.pageIndicatorTintColor = [tintColor colorWithAlphaComponent:0.5];
        _pageControl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        _pageControl.numberOfPages = 10;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

- (UIActivityIndicatorView *)indicator{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center =self.center;
        _indicator.color = kCMKeyboardManager.themeManager.dismissBtnTintColor;
        [self addSubview:_indicator];
    }
    return _indicator;
}

#pragma mark - CMTipsViewDelegate
- (void)tipsView:(id<CMTipsViewProtocol>)view onShowed:(NSDictionary *)infoDic{
    _isShowingFullTip = YES;
    if(view.priority == fullAccessTipGif){
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:8];
    }
}

- (void)tipsView:(id<CMTipsViewProtocol>)view onTapped:(NSDictionary *)infoDic{
    
    if (view.priority == fullAccessTipGif) {
        [self gotoFullAccess];
        [CMInfoc reportCheetahkeyboard_tip_clickWithValue:10];
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:8 closeType:4];
    }
    _isShowingFullTip = NO;
}
- (void)tipsView:(id<CMTipsViewProtocol>)view onSwiped:(NSDictionary *)infoDic{
    _isShowingFullTip = NO;
    if(view.priority == fullAccessTipGif){
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:8 closeType:2];
    }
}
-(void)tipsView:(id<CMTipsViewProtocol>)view onRemoved:(NSDictionary *)infoDic {
    _isShowingFullTip = NO;
    if(view.priority == fullAccessTipGif){
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:8 closeType:1];
    }
}

- (void)gotoFullAccess{
    
    NSURL *url = [NSURL URLWithString:[CMBizHelper fullAccessUrlFromExtension]];
    UIResponder *responder = self;
    while (responder !=nil) {
        if([responder respondsToSelector:@selector(openURL:)]){
            [NSThread detachNewThreadSelector:@selector(openURL:) toTarget:responder withObject:url];
        }
        responder = responder.nextResponder;
    }
}

@end


