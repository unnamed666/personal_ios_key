//
//  CMGifTagDetailView.m
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/11/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMGifTagDetailView.h"
#import "CMKeyModel.h"
#import "CMKeyboardManager.h"
#import "UIView+Util.h"
#import "CMThemeManager.h"
#import "CMKeyButton.h"
#import <YYWebImage/YYWebImage.h>
#import "CMSettingManager.h"
#import "CustomCollectionViewLayout.h"
#import "CMFullAccessTipView.h"
#import "CMInfoc.h"
#import "CMTipView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface CMGifTagDetailCell ()
@property (nonatomic, strong)YYAnimatedImageView * imageView;
@property (nonatomic, strong) CAShapeLayer * shapeLayer;
@property (nonatomic, strong) CAShapeLayer * selectedLayer;
@end


@implementation CMGifTagDetailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.layer.borderColor = [UIColor whiteColor].CGColor;
        //        self.layer.borderWidth = 2;
//        self.layer.cornerRadius = 8;
//        self.layer.masksToBounds = YES;
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        kLog(@"创建了新的 cell %@",self);
        
        
    }
    return self;
}

- (void)dealloc{
    
    kLog(@"dealloc了 cell %@",self);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    
    if (_shapeLayer) {
        UIBezierPath * singletonPath = [UIBezierPath bezierPath];
        [singletonPath moveToPoint:CGPointMake(_imageView.frame.size.width - 15, _imageView.frame.origin.y)];
        [singletonPath addLineToPoint:CGPointMake(_imageView.frame.size.width, _imageView.frame.origin.y)];
        [singletonPath addLineToPoint:CGPointMake(_imageView.frame.size.width, _imageView.frame.origin.y + 15)];
        [singletonPath closePath];
        self.shapeLayer.path = singletonPath.CGPath;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineWidth = 2;
        self.shapeLayer.strokeColor = kCMKeyboardManager.themeManager.dismissBtnTintColor.CGColor;
        self.shapeLayer.fillColor = kCMKeyboardManager.themeManager.dismissBtnTintColor.CGColor;
    }
    if (_selectedLayer) {
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(_imageView.frame.size.width - 8, _imageView.frame.origin.y + 4)];
        [path addLineToPoint:CGPointMake(_imageView.frame.size.width - 5, _imageView.frame.origin.y + 7)];
        [path addLineToPoint:CGPointMake(_imageView.frame.size.width - 1, _imageView.frame.origin.y + 2)];
        self.selectedLayer.path = path.CGPath;
        self.selectedLayer.lineJoin = kCALineJoinRound;
        self.selectedLayer.lineWidth = 1.5;
        if([kCMKeyboardManager isDefaultTheme]){
            self.selectedLayer.strokeColor = [UIColor blackColor].CGColor;
        }else{
            self.selectedLayer.strokeColor = [kCMKeyboardManager.themeManager.dismissBtnTintColor reverseColor].CGColor;
        }
        self.selectedLayer.fillColor = nil;

    }
    
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }
    return _shapeLayer;
}

- (CAShapeLayer *)selectedLayer
{
    if (!_selectedLayer) {
        _selectedLayer = [CAShapeLayer layer];
    }
    return _selectedLayer;
}

-(void)setCellSelected:(BOOL)select
{
    if (select == YES) {
        _imageView.layer.borderColor = kCMKeyboardManager.themeManager.dismissBtnTintColor.CGColor;
        _imageView.layer.borderWidth = 1.0;
        [self.layer addSublayer:self.shapeLayer];
        [self.layer addSublayer:self.selectedLayer];
    }else{
        _imageView.layer.borderColor = [UIColor clearColor].CGColor;
        _imageView.layer.borderWidth = 0;
        if (_shapeLayer) {
            [_shapeLayer removeFromSuperlayer];
        }
        if (_selectedLayer) {
            [_selectedLayer removeFromSuperlayer];
        }
    }
    
}

@end



@interface CMGifTagDetailView()<UICollectionViewDelegate,UICollectionViewDataSource,CustomCollectionViewLayoutDelegate,CMTipsViewDelegate>{
    
    BOOL isRefreshing;
    BOOL isRecent;
}
@property (nonatomic, strong)UILabel * label;
@property (nonatomic, strong)UICollectionView* collectionView;
@property (nonatomic, strong)CMKeyButton * layoutBtn;
@property (nonatomic, strong)CMKeyButton * deleteBtn;
@property (nonatomic, strong)NSMutableArray<CMGiphy*>  *giphyArry;
@property (nonatomic, strong) UIImage *  placeholder;
@property (nonatomic)        int   itemHight;
@property (nonatomic, strong)NSString * searchterm;
@property (nonatomic, strong) UILabel * copiedTipLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong)UIColor * tintColor;
@property (nonatomic, assign) BOOL isShowingFullTip;
@end

@implementation CMGifTagDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *backBtn = [[UIButton alloc] init];
        if([kCMKeyboardManager isDefaultTheme]){
            self.tintColor = rgb(109, 254, 255);
        }else{
            self.tintColor = kCMKeyboardManager.themeManager.dismissBtnTintColor;
        }
        [backBtn setImage:[[UIImage imageNamed:@"left_arrow"] imageWithTintColor:self.tintColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:backBtn];
        int backBtnY = 12;
        int toolbarHeight = [CMKeyboardManager toolbarHeight];
        if(toolbarHeight > 32){
            backBtnY = (toolbarHeight - 32)/2;
        }
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(5);
            make.top.equalTo(self.mas_top).offset(backBtnY);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(32);
        }];
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:15];
        _label.textColor = self.tintColor;
        [self addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(backBtn.mas_centerY);
            make.centerX.equalTo(self);
        }];
        
        UIImageView *view = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"giphylogo"] imageWithTintColor:self.tintColor] ];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(backBtn.mas_centerY);
            make.right.mas_equalTo(self.mas_right).offset(-5);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(14);
        }];
 
        [self addSubview:self.collectionView];
        
        _isShowingFullTip = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layoutSubviews{
    [super layoutSubviews];
    if(CGRectGetWidth(self.bounds)==0 || CGRectGetHeight(self.bounds)==0)return;
    int btnY = self.bounds.size.height - [CMKeyboardManager keyHeight];
    int collectionViewHight = self.bounds.size.height - [CMKeyboardManager keyHeight]-[CMKeyboardManager toolbarHeight];
    int btnWidth = [kCMKeyboardManager getRealWidthByRatio:self.layoutBtn.keyModel.keyWidthRatio];
    _collectionView.frame = CGRectMake(0,  [CMKeyboardManager toolbarHeight], self.bounds.size.width, collectionViewHight);
    _layoutBtn.frame =CGRectMake(4, btnY , btnWidth, [CMKeyboardManager keyHeight]);
    _deleteBtn.frame =CGRectMake(self.bounds.size.width-btnWidth-4, btnY, btnWidth, [CMKeyboardManager keyHeight]);
    if(kScreenWidth<kScreenHeight){
        self.itemHight = (collectionViewHight - 14) /2;
    }else{
        self.itemHight = (collectionViewHight - 14);
    }
    
    _indicator.center =self.center;
    [self.collectionView reloadData];
}

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel  deleteModel:(CMKeyModel *)deleteKeyModel{
    @weakify(self)
    self.layoutBtn = [[CMKeyButton alloc] initWithKeyModel:layoutKeyModel];
    self.layoutBtn.userInteractionEnabled = YES;
    [self.layoutBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        [self removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(abcBtn:)]){
            [(id<CMGifTagDetailViewDelegate>)self.delegate abcBtn:keyButton];
        }
    }];
    [self addSubview:_layoutBtn];
    
    
    self.deleteBtn = [[CMKeyButton alloc] initWithKeyModel:deleteKeyModel];
    self.deleteBtn.userInteractionEnabled = YES;
    [self.deleteBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteBtn:)]){
            [(id<CMGifTagDetailViewDelegate>)self.delegate deleteBtn:keyButton];
        }
    }];
    [self addSubview:_deleteBtn];
}
- (void)showToSuperview:(UIView*)superview title:(NSString*)title{
    
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
    
    isRefreshing = NO;
    self.selectedIndex = -1;
    [superview addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview);
        make.left.mas_equalTo(superview);
        make.width.mas_equalTo(superview);
        make.height.mas_equalTo(superview);
    }];
    self.searchterm = title;
    self.label.text = [title uppercaseString];
    
    self.giphyArry = [NSMutableArray new];
    [self.indicator startAnimating];
    void (^completionBlock)(NSArray<CMGiphy *> *giphyArry, NSError *error) = ^(NSArray<CMGiphy *> *giphyArry, NSError *error){
        
        if(giphyArry.count>0){
            if(!_placeholder){
                if([kCMKeyboardManager isDefaultTheme]){
                    
                    self.placeholder = [UIImage imageWithColor:rgb(34, 39, 64)];
                }else{
                    self.placeholder = [UIImage imageWithColor:self.tintColor];
                }
            }
            [self.giphyArry addObjectsFromArray:giphyArry];
            dispatch_async(dispatch_get_main_queue(),^{
                [_indicator stopAnimating];
                [self.collectionView reloadData];
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
    };
    isRecent = NO;
    if([title isEqualToString:@"Recent"]){
        isRecent = YES;
        completionBlock(kCMSettingManager.recentlyGif,nil);
    }else if([title isEqualToString:@"Trending"]){
        [CMGiphy giphyTrendingRequestWithLimit:20 offset:0 completion:completionBlock];
    }else{
        [CMGiphy giphySearchTagWithQ:title Limit:20 offset:0 completion:completionBlock];
    }
    
}

- (void)dismiss{
    [self removeFromSuperview];
    NSMutableArray * tmpGiphyArry = self.giphyArry;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [tmpGiphyArry class];
    });
    [self.giphyArry removeAllObjects];
    [self.collectionView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismiss)]){
        [(id<CMGifTagDetailViewDelegate>)self.delegate dismiss];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.giphyArry.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CMGifTagDetailCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMGifTagDetailCell class]) forIndexPath:indexPath];
    [cell.imageView yy_setImageWithURL:self.giphyArry[indexPath.row].fixedHeightSmall.url  placeholder:self.placeholder options:YYWebImageOptionProgressive completion:nil];

    if (indexPath.row == self.selectedIndex) {
        [cell setCellSelected:YES];
    }else{
        [cell setCellSelected:NO];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if([cell isKindOfClass:[CMGifTagDetailCell class]]){
        ((CMGifTagDetailCell*)cell).imageView.image= nil;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(!kCMKeyboardManager.isFullAccessAllowed){
        if (_isShowingFullTip == NO) {
            CMFullAccessTipView * fullAccessView = [[CMFullAccessTipView alloc] initWithFrame:CGRectZero];
            fullAccessView.priority = fullAccessTipGif;
            fullAccessView.duration = 7.0f;
            fullAccessView.tipsType = CMTipsTypeGif;
            fullAccessView.tipDelegate = self;
            fullAccessView.layer.zPosition = CGFLOAT_MAX;
            [fullAccessView showInView:self.superview anchorView:nil];
            [fullAccessView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.collectionView);
            }];
        }
        return;
    }
    
    if(self.selectedIndex == indexPath.row)return;
    
    [self sendGifWithIndexPath:indexPath];
    
    if (self.selectedIndex > -1){
        CMGifTagDetailCell * cell = (CMGifTagDetailCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        [cell setCellSelected:NO];
    }
    
    self.selectedIndex = indexPath.row;
    CMGifTagDetailCell * cell = (CMGifTagDetailCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setCellSelected:YES];
    
}

#pragma mark - private

- (void)sendGifWithIndexPath:(NSIndexPath *)indexPath{
    CMGiphy* giphy =  self.giphyArry[indexPath.row];
//    NSString *tmpDir =  [NSTemporaryDirectory() stringByAppendingPathComponent:@"giftem"];
    NSString *tmpDir =  [kCMGroupDataManager.tmp.path stringByAppendingPathComponent:@"giftem"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:tmpDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:giphy.fixedWidthImageDownsampled.url];
    NSString *ext = [key pathExtension];
    NSString *keyid = giphy.gifID;
    NSString *gifPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",keyid,ext]];
    if([[NSFileManager defaultManager] fileExistsAtPath:gifPath]){
        [CMBizHelper sendGifPath:gifPath];
        [self showCopiedTip];
        [self recentlyGifItem:giphy];
    }else{
        [self.indicator startAnimating];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = giphy.fixedWidthImageDownsampled.url;
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        NSURLSessionTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [_indicator stopAnimating];
                                                if(!error){
                                                    [CMBizHelper sendGifData:data];
                                                    [self showCopiedTip];
                                                }
                                            });
                                            if (!error) {
                                                [data writeToFile:gifPath atomically:YES];
                                                [self recentlyGifItem:giphy];
                                            }
                                        }];
        
        // 启动任务
        [task resume];
    }
    
    [CMInfoc reportEmojiTapped:self.inSource emoji:@"GIF"];
}

- (void)recentlyGifItem:(CMGiphy*)giphy{
    
    NSMutableArray<CMGiphy*> *recentlyGifArray = [NSMutableArray arrayWithArray:kCMSettingManager.recentlyGif];
    __block BOOL change = NO;
    [recentlyGifArray enumerateObjectsUsingBlock:^(CMGiphy * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.gifID isEqualToString:giphy.gifID]){
            *stop = YES;change= YES;
            [recentlyGifArray exchangeObjectAtIndex:idx withObjectAtIndex:0];
        }
    }];
    if(!change){
        [recentlyGifArray insertObject:giphy atIndex:0];
        if (recentlyGifArray.count > 30 ) {
            [recentlyGifArray removeLastObject];
        }
    }
    kCMSettingManager.recentlyGif = recentlyGifArray;
}

#pragma mark - CustomCollectionViewLayoutDelegate

- (int)flowLayoutStartSection{
    return 0;
}

- (int)fixedCount{
    if(kScreenWidth<kScreenHeight){
        return 2;
    }else{
        return 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView collectionViewLayout:(CustomCollectionViewLayout *)collectionViewLayout sizeOfItemAtIndexPath:(NSIndexPath *)indexPath {
        int width = self.giphyArry[indexPath.row].fixedHeightSmall.width / self.giphyArry[indexPath.row].fixedHeightSmall.height *  self.itemHight;
        return CGSizeMake(width, self.itemHight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(isRefreshing || isRecent)return;
    if (scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width + scrollView.contentInset.right ){
        isRefreshing = YES;
//        kLog(@"开始刷新啦!!!!!");
        void (^completionBlock)(NSArray<CMGiphy *> *giphyArry, NSError *error) = ^(NSArray<CMGiphy *> *giphyArry, NSError *error){
            
            if(giphyArry.count>0){
                
                [self.giphyArry addObjectsFromArray:giphyArry];
                dispatch_async(dispatch_get_main_queue(),^{
                    [UIView animateWithDuration:0 animations:^{
                        [self.collectionView reloadData];
                    } completion:^(BOOL finished) {
                        isRefreshing = NO;
                    }];
                });
            }
        };
        if([self.searchterm isEqualToString:@"Trending"]){
            [CMGiphy giphyTrendingRequestWithLimit:20 offset:self.giphyArry.count completion:completionBlock];
        }else{
            [CMGiphy giphySearchTagWithQ:self.searchterm Limit:20 offset:self.giphyArry.count completion:completionBlock];
        }
    }
}

#pragma mark - get

- (UIActivityIndicatorView *)indicator{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center =self.center;
        _indicator.color = kCMKeyboardManager.themeManager.dismissBtnTintColor;
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CustomCollectionViewLayout *layout = [CustomCollectionViewLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.layoutDelegate = self;
        layout.lineSpacing = 4;
        layout.interitemSpacing = 4;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CMGifTagDetailCell class] forCellWithReuseIdentifier:NSStringFromClass([CMGifTagDetailCell class])];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.decelerationRate = 0.4f;
        if (IOS10_OR_LATER) {
            [_collectionView setPrefetchingEnabled:NO];
        }
    }
    return _collectionView;
}

#pragma mark - CopiedTip Methods
- (void)showCopiedTip
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCopiedTip) object:nil];
    
    [self addSubview:self.copiedTipLabel];
    self.copiedTipLabel.frame = CGRectMake(0, -42, self.frame.size.width, 0);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.copiedTipLabel.frame = CGRectMake(0, 0, self.frame.size.width, 42);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideCopiedTip) withObject:nil afterDelay:3.0];
    }];
    
}

- (void)hideCopiedTip
{
    [UIView animateWithDuration:0.25 animations:^{
        self.copiedTipLabel.frame = CGRectMake(0, -42, self.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [self.copiedTipLabel removeFromSuperview];
        self.copiedTipLabel = nil;
    }];
}

- (UILabel *)copiedTipLabel
{
    if (!_copiedTipLabel) {
        _copiedTipLabel = [[UILabel alloc] init];
        _copiedTipLabel.backgroundColor = COLOR_WITH_RGBA(109, 254, 255, 1);
        _copiedTipLabel.textAlignment = NSTextAlignmentCenter;
        _copiedTipLabel.text = CMLocalizedString(@"Copy_Gif_Tip", nil);
        _copiedTipLabel.font = [CMBizHelper getFontWithSize:15];
        _copiedTipLabel.textColor = COLOR_WITH_RGBA(14, 17, 43, 1);
        _copiedTipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _copiedTipLabel;
}

#pragma mark - CMTipsViewDelegate
- (void)tipsView:(id<CMTipsViewProtocol>)view onShowed:(NSDictionary *)infoDic{
    _isShowingFullTip = YES;
}

- (void)tipsView:(id<CMTipsViewProtocol>)view onTapped:(NSDictionary *)infoDic{
    
    if (view.priority == fullAccessTipGif) {
        [self gotoFullAccess];
    }
    _isShowingFullTip = NO;
}
- (void)tipsView:(id<CMTipsViewProtocol>)view onSwiped:(NSDictionary *)infoDic{
    _isShowingFullTip = NO;
}
-(void)tipsView:(id<CMTipsViewProtocol>)view onRemoved:(NSDictionary *)infoDic {
    _isShowingFullTip = NO;
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
