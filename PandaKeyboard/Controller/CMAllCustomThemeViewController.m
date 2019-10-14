//
//  CMAllCustomThemeViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMAllCustomThemeViewController.h"
#import "CMNavigationBar.h"
#import "ThemeCollectionViewCell.h"
#import "CMThemeListViewModel.h"
#import "CMThemeManager.h"
#import "CMDIYThemeViewController.h"
#import "CMKeyboardManager.h"
#import "CMTipView.h"
#import "MBProgressHUD+Toast.h"
#import "CMCustomThemeAlert.h"
#import "ThemeDetailViewController.h"
#import <STPopup/STPopup.h>
#import "CMInappController.h"

static NSString * customThemeCellID = @"customThemeCellID";
//static NSString * selectedCustomIndex = @"selected_custom_index_";

@interface CMAllCustomThemeViewController ()<CMNavigationBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,CMDIVThemeViewControllerDelegate,ThemeCollectionViewCellDelegate,STPopupDelegate>
@property (nonatomic, strong) CMNavigationBar * navigationView;
@property (nonatomic, strong) UICollectionView * themeCollectionView;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat maxScreenForSuit;
@property (nonatomic, strong) NSMutableArray * customThemeArray;

@property (nonatomic, strong) CMThemeManager* themeManager;
@property (nonatomic, assign) BOOL shouldShowDeleteButton;

@property (nonatomic, strong)UITextField* tinyTextField;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) CMCustomThemeAlert * alertView;

@property (nonatomic, strong) STPopupController *themeDownPopController;

@end

@implementation CMAllCustomThemeViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideKeyboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tinyTextField];
    
    self.screenWidth = [CMBizHelper adapterScreenWidth];
    self.screenHeight = [CMBizHelper adapterScreenHeight];
    self.maxScreenForSuit = self.screenHeight > self.screenWidth ? self.screenHeight : self.screenWidth;

    [self.view addSubview:self.themeCollectionView];
    [self.view addSubview:self.navigationView];
    [self.themeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = COLOR_WITH_RGBA(38, 42, 64, 1);
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.navigationView.mas_bottom).offset(-1);
         make.width.equalTo(self.view.mas_width);
         make.height.equalTo(@(0.5));
     }];
    
    [self loadLocalCustomThemeList];
    //[self showKeyBoard];
    //self.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:selectedCustomIndex];
    
    if ([CMKeyboardManager sharedInstance].themeManager.DIYThemes.count == 0) {
        [self.navigationView hideRightButton];
    }
    else if ([CMKeyboardManager sharedInstance].themeManager.DIYThemes.count == 1) {
        CMThemeModel * themeModel = [CMKeyboardManager sharedInstance].themeManager.DIYThemes[0];
        if (![[CMGroupDataManager shareInstance].currentThemeName isEqualToString:themeModel.themeName])
        {
            [self.navigationView showRightButton];
        }else{
            [self.navigationView hideRightButton];
//            if (!self.selectedIndex) {
//                self.selectedIndex = 1;
//                [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:selectedCustomIndex];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
        }
    }
    
}

- (void)loadLocalCustomThemeList {
    @weakify(self)
    [self.themeViewModel loadLocalCustomThemesWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        if (!errorMsg) {
            self.customThemeArray = [NSMutableArray arrayWithArray:[_themeViewModel getLocalTotalCustomArray]];
            [self.themeCollectionView reloadData];
        }
    }];
}

- (BOOL)shouldShowKeyboardBtn {
    return YES;
}

#pragma mark - 导航初始化
- (UIView *)navigationView
{
    if (!_navigationView)
    {
        _navigationView = [[CMNavigationBar alloc] initWithNavigationBarType:CMNavigationBarTypeRightItem centerYOffset:10];
        _navigationView.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
        _navigationView.title = CMLocalizedString(@"See_All", nil);
        _navigationView.rightItemTitleNormal = CMLocalizedString(@"Custom_Theme_Edit", nil);
        _navigationView.rightItemTitleSelected = CMLocalizedString(@"Done", nil);
        _navigationView.delegate = self;
        
        
    }
    
    return _navigationView;
}

#pragma mark - CMNavigationBarDelegate Methods
-(void)navBarBackButtonDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onNavCancelBtnTapped:)]) {
        [self.delegate onNavCancelBtnTapped:self];
    }
}

-(void)navBarRightItemDidClick:(UIButton *)rightItem
{
    rightItem.selected = !rightItem.selected;
    self.shouldShowDeleteButton = rightItem.selected;
    [self.themeCollectionView reloadData];
    
    if (rightItem.selected == YES) {
        self.canSwipRightToPopViewController = NO;
        [self hideKeyboardBtn];
        [self.navigationView hideBackButton];
        [self hideKeyboard];
        [CMHostInfoc reportCheetahkeyboard_diy_all_clic:1 y:[CMKeyboardManager sharedInstance].themeManager.DIYThemes.count];
    }else{
        self.canSwipRightToPopViewController = YES;
        [self showKeyboardBtn];
        [self.navigationView showBackButton];
        if (self.delegate && [self.delegate respondsToSelector:@selector(needReloadAfterEdit)]) {
            [self.delegate needReloadAfterEdit];
        }
        [CMHostInfoc reportCheetahkeyboard_diy_all_clic:2 y:[CMKeyboardManager sharedInstance].themeManager.DIYThemes.count];
    }
}

#pragma mark - getter/setter
//- (CMThemeListViewModel *)themeViewModel {
//    if (!_themeViewModel) {
//        _themeViewModel = [CMThemeListViewModel new];
//    }
//    return _themeViewModel;
//}

- (CMThemeManager *)themeManager {
    if (!_themeManager) {
        _themeManager = kCMKeyboardManager.themeManager;
    }
    return _themeManager;
}

- (NSMutableArray *)customThemeArray
{
    if (!_customThemeArray) {
        _customThemeArray = [NSMutableArray array];
    }
    return _customThemeArray;
}

- (UITextField *)tinyTextField {
    if (!_tinyTextField) {
        _tinyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.1f, 0.1f)];
    }
    return _tinyTextField;
}

- (UICollectionView *)themeCollectionView
{
    if (!_themeCollectionView)
    {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        if ([UIDevice isIpad])
        {
            _themeCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
            _themeCollectionView.contentInset = UIEdgeInsetsMake(CMNavigationBarHeight, 0, 0, 0);
            
            //layout.itemSize = CGSizeMake(self.maxScreenForSuit/5, self.maxScreenForSuit/6.8);
            layout.minimumLineSpacing = self.maxScreenForSuit/26.66;
            layout.minimumInteritemSpacing = 0;
            layout.sectionInset = UIEdgeInsetsMake(0, self.maxScreenForSuit/26.66, self.maxScreenForSuit/26.66*2, self.maxScreenForSuit/26.66);
            [_themeCollectionView setCollectionViewLayout:layout];
        }
        else
        {
            _themeCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
            _themeCollectionView.contentInset = UIEdgeInsetsMake(CMNavigationBarHeight, 0, 0, 0);
            
            //layout.itemSize = CGSizeMake(self.screenHeight/3.8136, self.screenHeight/4.1406);
            //            layout.minimumInteritemSpacing = self.screenHeight/76.66; //横向
            layout.minimumLineSpacing = self.screenHeight/76.66; //竖向
            layout.minimumInteritemSpacing = 0;
            layout.sectionInset = UIEdgeInsetsMake(0, kScreenHeight/76.66, 0, kScreenHeight/76.66);
            [_themeCollectionView setCollectionViewLayout:layout];
        }
        
        _themeCollectionView.backgroundColor = [UIColor clearColor];
        //_themeCollectionView.clipsToBounds = NO;
        _themeCollectionView.dataSource = self;
        _themeCollectionView.delegate = self;
        _themeCollectionView.allowsMultipleSelection = NO;
        _themeCollectionView.alwaysBounceVertical = YES;
        
        [_themeCollectionView registerClass:[ThemeCollectionViewCell class] forCellWithReuseIdentifier:customThemeCellID];
    }
    
    return _themeCollectionView;
}

#pragma mark - UICollectionView DataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionVie
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.customThemeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThemeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:customThemeCellID forIndexPath:indexPath];
    cell.delegate = self;
    
    CMThemeModel * themeModel = [self.themeViewModel customThemeModelAtIndexPath:indexPath];
    CMThemeCellViewModel * cellModel = [[CMThemeCellViewModel alloc] initWithThemeModel:themeModel themeManager:self.themeManager];
    [cell setThemeCellViewModel:cellModel indexPath:indexPath];
    
    if ([[CMGroupDataManager shareInstance].currentThemeName isEqualToString:themeModel.themeName]) {
        self.selectedIndex = indexPath.row;
        [self.themeViewModel setIndex:indexPath.row];
        //[[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:selectedCustomIndex];
    }
    
    if (self.shouldShowDeleteButton == YES) {
        if (indexPath.row == 0 || indexPath.row == self.selectedIndex) {
            [cell setDeleteButtonShouldShow:NO shouldShowMaskView:YES indexPath:indexPath];
        }else{
            [cell setDeleteButtonShouldShow:YES shouldShowMaskView:NO indexPath:indexPath];
        }
    }else{
        [cell setDeleteButtonShouldShow:NO shouldShowMaskView:NO indexPath:indexPath];
    }
    
    
    return cell;
}

#pragma mark - UICollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    
    if (indexPath.row == 0) {
        if ([UIDevice isIpad])
        {
            [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
        }
        CMDIYThemeViewController *diyThemeVC = [CMDIYThemeViewController new];
        diyThemeVC.delegate = self;
        diyThemeVC.inway = 2;
        [self.navigationController pushViewController:diyThemeVC animated:YES];
        
    }else{
        [self popThemeDetailController:indexPath];
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(allCustomThemeViewControllerThemeClick:)]) {
        [self.delegate allCustomThemeViewControllerThemeClick:indexPath.row];
    }
    
    if (indexPath.row != 0) {
       self.selectedIndex = indexPath.row;
    }
//    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:selectedCustomIndex];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    if ([UIDevice isIpad]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(customThemeDidClick:)]) {
            [self.delegate customThemeDidClick:indexPath.row];
        }
    }    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideKeyboard];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice isIpad])
    {
        return CGSizeMake(self.maxScreenForSuit/5, self.maxScreenForSuit/6.8);
    }else{
        return CGSizeMake(KScalePt(168), KScalePt(168)*142/168.0);
    }
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if ([UIDevice isIpad]) {
        return UIEdgeInsetsMake(KScalePt(8), KScalePt(30), 0, KScalePt(30));
    }else{
        return UIEdgeInsetsMake(KScalePt(8), KScalePt(12), 0, KScalePt(12));
    }
    
}

#pragma mark - ThemeCollectionViewCellDelegate Method
- (void)themeCollectionViewCellDeleteButtonClickWithCell:(UICollectionViewCell *)cell
{
    NSIndexPath * indexPath = [self.themeCollectionView indexPathForCell:cell];
    self.alertView = [[CMCustomThemeAlert alloc] init];
    [self.alertView showAlertWithTitle:CMLocalizedString(@"Delete_this_theme", nil) confirmTitle:CMLocalizedString(@"OK", nil) andCancelTitle:CMLocalizedString(@"Cancel", nil)];
    @weakify(self)
    self.alertView.confirmBlock = ^{
        @stronglize(self);
        
        //if ([UIDevice isIpad]) {
            CMThemeModel * selectedModel = [self.themeViewModel getSelectedModel];
            CMThemeModel * model = self.customThemeArray[indexPath.row];
            if (selectedModel) {
                if ([selectedModel.themeName isEqualToString:model.themeName]) {
                    [self.themeViewModel setIndex:0];
                }
            }
        //}
        
        [self.themeCollectionView performBatchUpdates:^{
            [[CMKeyboardManager sharedInstance].themeManager deleteThemeModel:self.customThemeArray[indexPath.row]];
            [self.customThemeArray removeObjectAtIndex:indexPath.row];
            [self.themeCollectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.themeViewModel updateCustomThemesAfterEdit];
            
            if ([CMKeyboardManager sharedInstance].themeManager.DIYThemes.count == 0) {
                [self.themeViewModel setIndex:0];
            }
            
            NSInteger index = [self.themeViewModel getSelectedCustomThemeIndex];
            if (index > 1) {
                [self.themeViewModel setIndex:index - 1];
            }
        } completion:^(BOOL finished) {
            //[self.themeCollectionView reloadData];
        }];
        
        
        
        
        if (self.selectedIndex != 1) {
            self.selectedIndex = self.selectedIndex - 1;
        }
//        [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:selectedCustomIndex];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    };
}

-(void)doneButtonClickWith:(CMThemeModel *)model
{
    [self.themeViewModel setIndex:1];
    [self.themeViewModel setupCustomArrayWiththemeModel:[CMKeyboardManager sharedInstance].themeManager.latestDIYTheme];
    kCMGroupDataManager.currentThemeName = [CMKeyboardManager sharedInstance].themeManager.latestDIYTheme.themeName;
    [self loadLocalCustomThemeList];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(needReloadSeletedCustomTheme)]) {
        [self.delegate needReloadSeletedCustomTheme];
    }
    if ([UIDevice isIpad]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"customThemeClickIndexForPad"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self showKeyBoard];
    
    self.selectedIndex = 1;
//    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:selectedCustomIndex];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)changeKeyboardTheme:(CMThemeModel*) theModel index:(NSInteger)index
{
        [[CMGroupDataManager shareInstance] setCurrentThemeName:theModel.themeName];
        [self.themeCollectionView reloadData];
        CMTipView * tipView = [[CMTipView alloc] initWithIcon:nil message:CMLocalizedString(@"Change_Theme", nil)];
        MBProgressHUD * hud = [MBProgressHUD showCustomView:tipView toView:self.view seconds:0.5 completion:^(BOOL finished){
            
            [self showKeyBoard];

        }];
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = COLOR_WITH_RGBA(48, 54, 83, 1);
        hud.bezelView.layer.cornerRadius = 20;
        hud.userInteractionEnabled = NO;
}

#pragma mark -
- (void)popThemeDetailController:(NSIndexPath*) indexPath
{
    
//    CMThemeModel * themeModel = [self.themeViewModel customThemeModelAtIndexPath:indexPath];
//    CMThemeCellViewModel * cellModel = [[CMThemeCellViewModel alloc] initWithThemeModel:themeModel themeManager:self.themeManager];
    
    CMThemeModel * themeModel = [self.themeViewModel customThemeModelAtIndexPath:indexPath];
    CMThemeDetailViewModel* themeDetailModel = [CMThemeDetailViewModel viewModelWithThemeModel:themeModel indexPath:indexPath themeManager:self.themeManager];
    ThemeDetailViewController* rootController = [[ThemeDetailViewController alloc] initWithThemeDetailModel:themeDetailModel themeManager:self.themeManager];
    rootController.indexPath = indexPath;
    rootController.delegate = self;
    
    self.themeDownPopController = [[STPopupController alloc] initWithRootViewController:rootController];
    self.themeDownPopController.containerView.layer.cornerRadius = 6;
    self.themeDownPopController.navigationBarHidden = YES;
    self.themeDownPopController.transitionStyle = STPopupTransitionStyleFade;
    
    [self.themeDownPopController presentInViewController:self.navigationController];
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.themeDownPopController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    self.themeDownPopController.backgroundView.tag = indexPath.row;
    [self.themeDownPopController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
    
    [self.themeDownPopController.navigationBar removeFromSuperview];
    self.themeDownPopController.navigationBar.hidden = YES;
}

- (void) backgroundViewDidTap
{
    ThemeDetailViewController* theTopController = (ThemeDetailViewController*)self.themeDownPopController.topViewController;
    
    if (theTopController)
    {
        [theTopController cancleTask];
    }
    
    [self.themeDownPopController dismiss];
}

#pragma mark - STPopupDelegate
- (void) dismissPopupView
{
    [self.themeDownPopController dismiss];
}

- (void)themeDownloadFinish:(CMThemeModel*) theModel indexPath:(NSIndexPath *)indexPath
{
    
}

- (void)themeApplyTapped:(CMThemeModel *)theModel indexPath:(NSIndexPath *)indexPath
{
    if (![theModel.themeName isEqualToString:kCMGroupDataManager.currentThemeName]) {
        [self changeKeyboardTheme:theModel index:indexPath.row];
        [CMHostInfoc reportCheetahkeyboard_main_theme_clickWithThemeName:theModel.themeName xy:indexPath.row+1 value:2];
    }
}

- (void)themeDiyTapped:(CMThemeModel *)theModel indexPath:(NSIndexPath *)indexPath
{
    CMDIYThemeViewController *diyThemeVC = [[CMDIYThemeViewController alloc] initWithDiyThemeName:theModel.themeName diyType:CMDiyTypeDiy];
    diyThemeVC.delegate = self;
    diyThemeVC.inway = 2;
    [self.navigationController pushViewController:diyThemeVC animated:YES];

}

#pragma mark - 显示隐藏键盘
- (void)showKeyBoard
{
    [self.tinyTextField becomeFirstResponder];
}

- (void)hideKeyboard
{
    [self.tinyTextField endEditing:YES];
}

#pragma mark - 处理屏幕旋转
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (size.width < size.height)
    {
        self.screenWidth = size.width;
        self.screenHeight = size.height;
    }
    else
    {
        self.screenWidth = size.width;
        self.screenHeight = size.height;
    }
    

    self.maxScreenForSuit = self.screenHeight > self.screenWidth ? self.screenHeight : self.screenWidth;
    [self hideKeyboard];
}
@end
