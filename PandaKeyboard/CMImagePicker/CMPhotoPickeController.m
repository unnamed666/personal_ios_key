//
//  CMPhotoPickeController.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMPhotoPickeController.h"
#import "CMImagePickerController.h"
#import "CMAssetModel.h"
#import "CMImageManger.h"
#import "UIView+Util.h"
#import "CMAssetCollectionCell.h"
#import "CMPhotoPreviewController.h"
#import "CMCommUtil.h"

@interface CMPhotoPickeController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    BOOL _showTakePhotoBtn;
    NSMutableArray *_models;
    CGFloat _offsetItemCount;

}

@property CGRect previousPreheatRect;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) CMPhotoCollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@end

static CGSize AssetGridThumbnailSize;
static CGFloat itemMargin = 5;

@implementation CMPhotoPickeController

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    if (!_models) {
        [self fetchAssetModels];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    kLogWarn(@"内存警告");
}

#pragma mark - private


- (void)fetchAssetModels {
    CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
    if (_isFirstAppear) {
//        [tzImagePickerVc showProgressHUD];
    }
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        
        if (!cmImagePickerVc.sortAscendingByModificationDate && _isFirstAppear) {
            
            [[CMImageManger sharedInstance]getCameraRollAlbumCompletion:^(CMAlbumModel *model) {
                _model = model;
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self refreshCollectionView];
            }];

        } else {
            if (_showTakePhotoBtn || _isFirstAppear) {
                
                [[CMImageManger sharedInstance]getAssetsFromFetchResult:_model.result completionBlock:^(NSArray<CMAssetModel *> *arr) {
                    _models = [NSMutableArray arrayWithArray:arr];
                }];
                [self refreshCollectionView];
          
            } else {
                _models = [NSMutableArray arrayWithArray:_model.models];
                [self refreshCollectionView];
            }
        }
    });
}

-(void)checkSelectedModels {
    for (CMAssetModel *model in _models) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
        for (CMAssetModel *model in cmImagePickerVc.selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        
        if ([selectedAssets containsObject:model.asset]) {
            /// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
            model.isSelected = YES;
        }
    }
}


- (void)refreshCollectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkSelectedModels];
        [self.collectionView reloadData];
        [self scrollCollectionViewToBottom];
    });
    
}

-(void)completeCropIamge:(UIImage *)image asset:(PHAsset *)asset{
    CMImagePickerController *pickerVC = (CMImagePickerController *)self.navigationController;
    
    if (pickerVC.autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:true completion:^{
            if ([pickerVC.pickerDelegate respondsToSelector:NSSelectorFromString(@"cmImagePicker:didFinishCropPhoto:asset:isOriginal:")]) {
                [pickerVC.pickerDelegate cmImagePicker:pickerVC didFinishCropPhoto:image asset:asset isOriginal:_isSelectOriginalPhoto];
            }
        }];
    }else{
        if ([pickerVC.pickerDelegate respondsToSelector:NSSelectorFromString(@"cmImagePicker:didFinishCropPhoto:asset:isOriginal:")]) {
            [pickerVC.pickerDelegate cmImagePicker:pickerVC didFinishCropPhoto:image asset:asset isOriginal:_isSelectOriginalPhoto];
        }
    }
    
   
}

-(void)backToForwardVC{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - setUP View
-(void)setUpView{
    if (_columnNumber < 1) {
        _columnNumber = 4;
    }
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"icon_back_normal"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(14, 6, 14, 22)];
    [backButton addTarget:self action:@selector(backToForwardVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self.view addSubview:self.collectionView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    CMImagePickerController *cmImagePickerController = (CMImagePickerController *)self.navigationController;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cmImagePickerController.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:cmImagePickerController action:NSSelectorFromString(@"cancelButtonClick")];
    _showTakePhotoBtn = (_model.isCameraRoll && cmImagePickerController.allowTakePicture);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.y / (_layout.itemSize.height + _layout.minimumLineSpacing);
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)scrollCollectionViewToBottom{
    if (_models.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_models.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        });
    }
}


#pragma mark - setter and getter

-(UIImagePickerController *)imagePickerVc{
    if (!_imagePickerVc) {
        _imagePickerVc = [[UIImagePickerController alloc]init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem * cmBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[CMImagePickerController class]]];
        UIBarButtonItem *BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        NSDictionary *titleTextAttributes = [cmBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

-(CMPhotoCollectionView *)collectionView{
    if (!_collectionView) {
        
        CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
        _collectionView = [[CMPhotoCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
        if (_showTakePhotoBtn && cmImagePickerVc.allowTakePicture ) {
            _collectionView.contentSize = CGSizeMake(self.view.width, ((_model.count + self.columnNumber) / self.columnNumber) * self.view.height);
        } else {
            _collectionView.contentSize = CGSizeMake(self.view.width, ((_model.count + self.columnNumber - 1) / self.columnNumber) * self.view.height);
        }
        [_collectionView registerClass:[CMAssetCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([CMAssetCollectionCell class])];
        [_collectionView registerClass:[CMAssetCameraCell class] forCellWithReuseIdentifier:NSStringFromClass([CMAssetCameraCell class])];
    }
    return _collectionView;
}

-(UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWH = (self.view.width - (self.columnNumber + 1) * itemMargin) / self.columnNumber;
        _layout.itemSize = CGSizeMake(itemWH, itemWH);
        _layout.minimumInteritemSpacing = itemMargin;
        _layout.minimumLineSpacing = itemMargin;
    }
    return _layout;
}



#pragma mark - UICollectionViewDataSource && Delegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_showTakePhotoBtn) {
        CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
        if (cmImagePickerVc.allowTakePicture) {
            return _models.count + 1;
        }
    }
    
    return _models.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // the cell lead to take a picture / 去拍照的cell
    CMImagePickerController *cmImagePickerVc = (CMImagePickerController *)self.navigationController;
//    if (((cmImagePickerVc.sortAscendingByModificationDate && indexPath.row >= _models.count) || (!cmImagePickerVc.sortAscendingByModificationDate && indexPath.row == 0)) && _showTakePhotoBtn) {
//        CMAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMAssetCameraCell class]) forIndexPath:indexPath];
////        cell.imageView.image = [UIImage imageNamedFromMyBundle:tzImagePickerVc.takePictureImageName];
//        return cell;
//    }
    // the cell dipaly photo or video / 展示照片或视频的cell
    CMAssetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMAssetCollectionCell class]) forIndexPath:indexPath];
    cell.photoDefImageName = cmImagePickerVc.photoDefImageName;
    cell.photoSelImageName = cmImagePickerVc.photoSelImageName;
    CMAssetModel *model;
    if (cmImagePickerVc.sortAscendingByModificationDate || !_showTakePhotoBtn) {
        model = _models[indexPath.row];
    } else {
        model = _models[indexPath.row - 1];
    }
    cell.model = model;
//    __weak typeof(self) weakSelf = self;
//    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
//        CMImagePickerController *tzImagePickerVc = (CMImagePickerController *)weakSelf.navigationController;
//        if (isSelected) {
//            model.isSelected = NO;
//            NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
//            for (CMAssetModel *model_item in selectedModels) {
//                if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
//                    [tzImagePickerVc.selectedModels removeObject:model_item];
//                    break;
//                }
//            }
//        } else {
//            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个
//        }
//    };
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CMPhotoPreviewController *photoPreviewVc = [[CMPhotoPreviewController alloc] init];
    photoPreviewVc.currentIndex = indexPath.item;
    photoPreviewVc.models = _models;
    photoPreviewVc.isCropImage = true;
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)pushPhotoPrevireViewController:(CMPhotoPreviewController *)photoPreviewVc {
    
    @weakify(self);
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        kLog(@"preview 返回");
//        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
//        [weakSelf.collectionView reloadData];
//        [weakSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
//        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
//        [weakSelf doneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, PHAsset * asset) {
        @stronglize(self);
        [self completeCropIamge:cropedImage asset:asset];
        kLog(@"preview 剪裁完成");
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

-(void)dealloc{
    kLogTrace();
}

#pragma mark - UIScrollViewDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

#pragma mark - collection View


@implementation CMPhotoCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
