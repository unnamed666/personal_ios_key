//
//  CMPhotoPreviewController.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMPhotoPreviewController.h"
#import "CMImagePickerController.h"
#import "UIView+Util.h"
#import "CMAssetModel.h"
#import "CMAssetPreviewCell.h"
#import "CMImageCropHelper.h"
#import "CMImageManger.h"

@interface CMPhotoPreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    NSArray *_photosTemp;
    NSArray *_assetsTemp;
    CGFloat _offsetItemCount;
}

@property (nonatomic, assign) BOOL isHideNaviBar;
@property (nonatomic, strong) UIView *cropBgView;
@property (nonatomic, strong) UIView *cropView;

@property (nonatomic, assign) double progress;
@property (strong, nonatomic) id alertView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIView *naviBar;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation CMPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    kLogInfo(@"index %d",_currentIndex);
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    CMImagePickerController *_cmImagePickerVc = (CMImagePickerController *)weakSelf.navigationController;
    if (!self.models.count) {
        self.models = [NSMutableArray arrayWithArray:_cmImagePickerVc.selectedModels];
        _assetsTemp = [NSMutableArray arrayWithArray:_cmImagePickerVc.selectedAssets];
        self.isSelectOriginalPhoto = _cmImagePickerVc.isSelectOriginalPhoto;
    }
    
    [self setUpView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc {
    kLogTrace();
}


-(void)setUpView{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.naviBar];
    [self.view addSubview:self.toolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    _photosTemp = [NSArray arrayWithArray:photos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentIndex > 0) {
       [self.collectionView setContentOffset:CGPointMake((self.view.width + 20) * self.currentIndex, 0) animated:NO];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;

    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
    
    if (_offsetItemCount > 0) {
        CGFloat offsetX = _offsetItemCount * _layout.itemSize.width;
        [_collectionView setContentOffset:CGPointMake(offsetX, 0)];
    }
    if (cmImagePickerVc.allowCrop) {
        [_collectionView reloadData];
    }

    if (_isCropImage) {
        [self.view addSubview:self.cropBgView];
        [self.view addSubview:self.cropView];
        
        if (cmImagePickerVc.cropViewSettingBlock) {
            cmImagePickerVc.cropViewSettingBlock(_cropView);
        }
    }
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
}

#pragma mark - Click Event

- (void)select:(UIButton *)selectButton {
    CMImagePickerController *_tzImagePickerVc = (CMImagePickerController *)self.navigationController;
    CMAssetModel *model = _models[_currentIndex];
    if (!selectButton.isSelected) {
        // 1. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
        if (_tzImagePickerVc.selectedModels.count >= _tzImagePickerVc.maxImagesCount) {
//            NSString *title = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a maximum of %zd photos"], _tzImagePickerVc.maxImagesCount];
//            [_tzImagePickerVc showAlertWithTitle:title];
            return;
            // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
        } else {
            [_tzImagePickerVc.selectedModels addObject:model];
            if (self.photos) {
                [_tzImagePickerVc.selectedAssets addObject:_assetsTemp[_currentIndex]];
                [self.photos addObject:_photosTemp[_currentIndex]];
            }
//            if (model.type == TZAssetModelMediaTypeVideo && !_tzImagePickerVc.allowPickingMultipleVideo) {
//                [_tzImagePickerVc showAlertWithTitle:[NSBundle tz_localizedStringForKey:@"Select the video when in multi state, we will handle the video as a photo"]];
//            }
        }
    } else {
        NSArray *selectedModels = [NSArray arrayWithArray:_tzImagePickerVc.selectedModels];
        for (CMAssetModel *model_item in selectedModels) {
            
            if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                // 1.6.7版本更新:防止有多个一样的model,一次性被移除了
                NSArray *selectedModelsTmp = [NSArray arrayWithArray:_tzImagePickerVc.selectedModels];
                for (NSInteger i = 0; i < selectedModelsTmp.count; i++) {
                    CMAssetModel *model = selectedModelsTmp[i];
                    if ([model isEqual:model_item]) {
                        [_tzImagePickerVc.selectedModels removeObjectAtIndex:i];
                        break;
                    }
                }
                // [_tzImagePickerVc.selectedModels removeObject:model_item];
                if (self.photos) {
                    // 1.6.7版本更新:防止有多个一样的asset,一次性被移除了
                    NSArray *selectedAssetsTmp = [NSArray arrayWithArray:_tzImagePickerVc.selectedAssets];
                    for (NSInteger i = 0; i < selectedAssetsTmp.count; i++) {
                        id asset = selectedAssetsTmp[i];
                        if ([asset isEqual:_assetsTemp[_currentIndex]]) {
                            [_tzImagePickerVc.selectedAssets removeObjectAtIndex:i];
                            break;
                        }
                    }
                    // [_tzImagePickerVc.selectedAssets removeObject:_assetsTemp[_currentIndex]];
                    [self.photos removeObject:_photosTemp[_currentIndex]];
                }
                break;
            }
        }
    }
    model.isSelected = !selectButton.isSelected;
    [self refreshNaviBarAndBottomBarState];
//    if (model.isSelected) {
//        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:TZOscillatoryAnimationToBigger];
//    }
//    [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:TZOscillatoryAnimationToSmaller];
}

- (void)backButtonClick {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(_isSelectOriginalPhoto);
    }
}

- (void)doneButtonClick {
    CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
    // 如果图片正在从iCloud同步中,提醒用户
//    if (_progress > 0 && _progress < 1 && (_selectButton.isSelected || !_tzImagePickerVc.selectedModels.count )) {
//        _alertView = [_tzImagePickerVc showAlertWithTitle:[NSBundle tz_localizedStringForKey:@"Synchronizing photos from iCloud"]];
//        return;
//    }
    
    // 如果没有选中过照片 点击确定时选中当前预览的照片
    if (cmImagePickerVc.selectedModels.count == 0 && cmImagePickerVc.minImagesCount <= 0) {
        CMAssetModel *model = _models[_currentIndex];
        [cmImagePickerVc.selectedModels addObject:model];
    }
    if (cmImagePickerVc.allowCrop) { // 裁剪状态
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        CMPhotoPreviewCell *cell = (CMPhotoPreviewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        UIImage *cropedImage = [CMImageCropHelper cropImageView:cell.previewView.imageView toRect:cmImagePickerVc.cropRect zoomScale:cell.previewView.scrollView.zoomScale containerView:self.view];
        
        NSData *cropImageData = UIImageJPEGRepresentation(cropedImage, 1);
        
        kLogInfo(@"剪裁图片大小: %.2fkb", cropImageData.length/1024.0);
        
//        UIImage * newImage = [UIImage imageWithData:imageData];
        
        if (self.doneButtonClickBlockCropMode) {
            CMAssetModel *model = _models[_currentIndex];
            self.doneButtonClickBlockCropMode(cropedImage,model.asset);
        }
    } else if (self.doneButtonClickBlock) { // 非裁剪状态
        self.doneButtonClickBlock(_isSelectOriginalPhoto);
    }
//    if (self.doneButtonClickBlockWithPreviewType) {
//        self.doneButtonClickBlockWithPreviewType(self.photos,_tzImagePickerVc.selectedAssets,self.isSelectOriginalPhoto);
//    }
}


- (void)didTapPreviewCell {
    self.isHideNaviBar = !self.isHideNaviBar;
    self.naviBar.hidden = self.isHideNaviBar;
    self.toolBar.hidden = self.isHideNaviBar;
    kLog(@"隐藏显示 tool bar");
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.width + 20);
    
    if (currentIndex < _models.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewCollectionViewDidScroll" object:nil];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMImagePickerController *_tzImagePickerVc = (CMImagePickerController *)self.navigationController;
    CMAssetModel *model = _models[indexPath.row];
    
    CMAssetPreviewCell *cell;
    __weak typeof(self) weakSelf = self;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMPhotoPreviewCell class]) forIndexPath:indexPath];
    CMPhotoPreviewCell *photoPreviewCell = (CMPhotoPreviewCell *)cell;
    photoPreviewCell.cropRect = _tzImagePickerVc.cropRect;
    photoPreviewCell.allowCrop = _tzImagePickerVc.allowCrop;
    __weak typeof(_tzImagePickerVc) weakTzImagePickerVc = _tzImagePickerVc;
    __weak typeof(_collectionView) weakCollectionView = _collectionView;
    __weak typeof(photoPreviewCell) weakCell = photoPreviewCell;
    [photoPreviewCell setImageProgressUpdateBlock:^(double progress) {
        weakSelf.progress = progress;
        if (progress >= 1) {
            if (weakSelf.isSelectOriginalPhoto) [weakSelf showPhotoBytes];
            if (weakSelf.alertView && [weakCollectionView.visibleCells containsObject:weakCell]) {
//                [weakTzImagePickerVc hideAlertView:weakSelf.alertView];
                weakSelf.alertView = nil;
                [weakSelf doneButtonClick];
            }
        }
    }];
    
    cell.model = model;
    [cell setSingleTapGestureBlock:^{
        [weakSelf didTapPreviewCell];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CMPhotoPreviewCell class]]) {
        [(CMPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CMPhotoPreviewCell class]]) {
        [(CMPhotoPreviewCell *)cell recoverSubviews];
    } else {
    }
}

#pragma mark - Private Method


- (void)refreshNaviBarAndBottomBarState {

}

- (void)showPhotoBytes {

}


#pragma mark - setter and getter

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(0, 0);
        _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.width + 20), 0);
        [_collectionView registerClass:[CMPhotoPreviewCell class] forCellWithReuseIdentifier:NSStringFromClass([CMPhotoPreviewCell class])];
    }
    return _collectionView;
}

-(UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
    }
    return _layout;
}

-(UIView *)naviBar{
    if (!_naviBar) {
        _naviBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 44, 44)];
        [backButton setImage:[UIImage imageNamed:@"icon_back_normal"] forState:UIControlStateNormal];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(14, 6, 14, 22)];
        [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_naviBar addSubview:backButton];
        
    }
    return _naviBar;
}

-(UIView *)toolBar{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
        static CGFloat rgb = 34 / 255.0;
        _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
        [_toolBar addSubview:self.doneBtn];
    }
    return _toolBar;
}

-(UIView *)cropView{
    if (!_cropView) {
        _cropView = [[UIView alloc]init];
        _cropView.userInteractionEnabled = NO;
        CMImagePickerController *pickVC = (CMImagePickerController *)self.navigationController;
        _cropView.frame = pickVC.cropRect;
        _cropView.userInteractionEnabled = false;
        _cropView.backgroundColor = [UIColor clearColor];
        _cropView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropView.layer.borderWidth = 1.0;
    }
    return _cropView;
}

-(UIView *)cropBgView{
    if (!_cropBgView) {
        _cropBgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _cropBgView.backgroundColor = [UIColor clearColor];
        _cropBgView.userInteractionEnabled = false;
        CMImagePickerController *pickVC = (CMImagePickerController *)self.navigationController;
        [CMImageCropHelper overlayClippingWithView:_cropBgView cropRect:pickVC.cropRect containerView:self.view needCircleCrop:false];
    }
    return _cropBgView;
}

-(UIButton *)doneBtn{
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 44 -12, 0, 44, 44)];
        _doneBtn.titleLabel.font = [CMBizHelper getFontWithSize:KScalePt(14)];
        [_doneBtn setTitle:CMLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
