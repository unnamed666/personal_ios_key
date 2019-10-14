//
//  CMImagePickerController.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMImagePickerController.h"
#import "CMImageManger.h"
#import "UIView+Util.h"
#import "CMAssetModel.h"
#import "CMPhotoPickeController.h"
#import "CMCommUtil.h"
#import "CMKeyboardManager.h"
#import "CMCustomThemeAlert.h"

@interface CMImagePickerController (){
    BOOL _didPushPhotoPickerVc;
    BOOL _pushPhotoPickerVc;
    NSTimer *_timer;
}

@property (nonatomic, strong) CMCustomThemeAlert *alertView;

@end

@implementation CMImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[CMBizHelper getFontWithSize:(kScreenHeight/36.63)],NSForegroundColorAttributeName:COLOR_WITH_RGBA(255, 255, 255, 1)}];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    kLogTrace();
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithCropImageColumnNumber:(NSInteger)columnNumber delegate:(id<CMImagePickerControllerDelegate>)delegate pushPhotoPicker:(BOOL)pushPhotoPicker{
    _pushPhotoPickerVc = pushPhotoPicker;
    CMAlbumPickerController *albumPicker = [[CMAlbumPickerController alloc]init];
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        [self confimDefaultSetting];
        self.maxImagesCount = 1;
        self.columnNumber = columnNumber;
        albumPicker.columnNumber = self.columnNumber;
        self.pickerDelegate = delegate;
        //此处需要判断相册权限
        if (![[CMImageManger sharedInstance] authorizationStatusAuthorized]) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:true];
        }else{
            [self pushPhotoPickerVC];
        }
    }
    return self;

}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [super pushViewController:viewController animated:animated];
}

-(void)pushPhotoPickerVC{
    _didPushPhotoPickerVc = false;
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        CMPhotoPickeController *photoPickerVC = [[CMPhotoPickeController alloc]init];
        photoPickerVC.columnNumber = self.columnNumber;
        [[CMImageManger sharedInstance]getCameraRollAlbumCompletion:^(CMAlbumModel *model) {
            photoPickerVC.model = model;
            [self pushViewController:photoPickerVC animated:true];
        }];
    }
    CMAlbumPickerController *albumPickerVC = (CMAlbumPickerController *)self.visibleViewController;
    if ([albumPickerVC isKindOfClass:[CMAlbumPickerController class]]) {
        [albumPickerVC configTableView];
    }
}

#pragma mark - Private
-(void)confimDefaultSetting{
    self.cancelBtnTitleStr = CMLocalizedString(@"Cancel", nil);
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.autoDismiss = YES;
    self.allowPickingOriginalPhoto = true;
    self.sortAscendingByModificationDate = true;
    
//    self.cropRect = CGRectMake(5, (self.view.height - [CMKeyboardManager keyboardHeight])/2, kScreenWidth - 10, [CMKeyboardManager keyboardHeight]);
    
    CGFloat scropW = kScreenWidth - 10;
    CGFloat scropH = scropW * ([CMKeyboardManager keyboardHeight] + [CMKeyboardManager toolbarHeight]) / kScreenWidth ;
    self.cropRect = CGRectMake(5, (self.view.height - scropH)/2, scropW, scropH);

//    CGFloat cropViewWH = MIN(self.view.width, self.view.height) / 3 * 2;
//    self.cropRect = CGRectMake((self.view.width - cropViewWH) / 2, (self.view.height - cropViewWH) / 2, cropViewWH, cropViewWH);
    
}

-(void)observeAuthrizationStatusChange{
    if ([[CMImageManger sharedInstance] authorizationStatusAuthorized]) {
        [_timer invalidate];
        _timer = nil;
        [self pushPhotoPickerVC];
    }
}

-(void)showAlertOfNotAvailableAlbum{
    
    self.alertView = [[CMCustomThemeAlert alloc] init];
    [self.alertView showAlertWithTitle:CMLocalizedString(@"Do you want to save this theme?", nil) confirmTitle:CMLocalizedString(@"OK", nil) andCancelTitle:nil];//CMLocalizedString(@"Cancel", nil)
    @weakify(self);
    self.alertView.confirmBlock = ^{
        @stronglize(self);
        [self cancelButtonClick];
    };
}


#pragma mark - Action

- (void)cancelButtonClick {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

-(void)callDelegateMethod{
    if ([self.pickerDelegate respondsToSelector:NSSelectorFromString(@"cmImagePickerCancle:")]) {
        [self.pickerDelegate cmImagePickerCancle:self];
    }
}

#pragma mark - setter and getter

-(void)setMaxImagesCount:(NSInteger)maxImagesCount{
    _maxImagesCount = maxImagesCount;
    _showSelectBtn = false;
    _allowCrop = true;
//    if (_maxImagesCount > 1) {
//        _showSelectBtn = true;
//        _allowCrop = false;
//    }
}

-(void)setColumnNumber:(NSInteger)columnNumber{
 
    if (columnNumber == 0) {
        _columnNumber = 4;
    }else if ( columnNumber <= 2) {
        _columnNumber = 2;
    }else if (columnNumber >= 6){
        _columnNumber = 6;
    }else{
        _columnNumber = columnNumber;
    }
    
    CMAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [CMImageManger sharedInstance].columnNumber = _columnNumber;
}
-(void)setShowSelectBtn:(BOOL)showSelectBtn{
    _showSelectBtn = showSelectBtn;
}

-(void)setPhotoWidth:(CGFloat)photoWidth{
    _photoWidth = photoWidth;
    [CMImageManger sharedInstance].photoWidth = _photoWidth;
}

-(void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth{
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [CMImageManger sharedInstance].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

-(void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate{
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [CMImageManger sharedInstance].sortAscendingByModificationDate = _sortAscendingByModificationDate;
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

#pragma mark - CMAlbumPickerController

@interface CMAlbumPickerController()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@end

@implementation CMAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    CMImagePickerController *imagePickerVc = (CMImagePickerController *)self.navigationController;
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[CMBizHelper getFontWithSize:(kScreenHeight/36.63)],NSForegroundColorAttributeName:COLOR_WITH_RGBA(255, 255, 255, 1)}];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [imagePickerVc hideProgressHUD];
    [self configTableView];
}

- (void)configTableView {

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CMImagePickerController *imagePickerVc = (CMImagePickerController *)self.navigationController;
        [[CMImageManger sharedInstance]getAllAlbumsCompletion:^(NSArray<CMAlbumModel *> *models) {
            _albumArr = [NSMutableArray arrayWithArray:models];
            for (CMAlbumModel *albumModel in _albumArr) {
                albumModel.selectedModels = imagePickerVc.selectedModels;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_tableView) {
                    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    if (@available(iOS 11.0, *)) {
                        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                    }
                    
                    _tableView.rowHeight = 70;
                    _tableView.tableFooterView = [[UIView alloc] init];
                    _tableView.dataSource = self;
                    _tableView.delegate = self;
                    [_tableView registerClass:[CMAlbumCell class] forCellReuseIdentifier:NSStringFromClass([CMAlbumCell class])];
                    [self.view addSubview:_tableView];
                } else {
                    [_tableView reloadData];
                }
            });
        }];
    });
}

- (void)dealloc {
    kLogTrace();
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat tableViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden){
           top += 20;
        }
        tableViewHeight = self.view.height - top;
    } else {
        tableViewHeight = self.view.height;
    }
    _tableView.frame = CGRectMake(0, top, self.view.width, tableViewHeight);
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CMAlbumCell class])];
//    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPhotoPickeController *photoPickerVc = [[CMPhotoPickeController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    CMAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end


