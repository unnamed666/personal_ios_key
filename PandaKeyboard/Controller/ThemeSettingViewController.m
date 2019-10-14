//
//  ThemeSettingViewController.m
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/22.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import "ThemeSettingViewController.h"
#import "AppDelegate.h"
#import "SetFullAccessViewController.h"
#import "CMBizHelper.h"
#import "AddKeyBoardController.h"
#import "CMGroupDataManager.h"
#import "SwitchKeyboardByMovieViewController.h"
#import "CMAppConfig.h"
#import "ThemeCollectionViewCell.h"
#import "MBProgressHUD+Toast.h"
#import "NSDictionary+Common.h"
#import "CMRouterManager.h"
#import "CMCloudConfig.h"
#import "NSString+Common.h"
#import "CMHostRequestFactory.h"
#import <MJRefresh/MJRefresh.h>
#import "CMThemeModel.h"
#import "CMThemeManager.h"
#import "CMThemeListViewModel.h"
#import "CMError.h"
#import <STPopup/STPopup.h>
#import "ThemeDetailViewController.h"
#import "SwitchKeyboardViewController.h"
#import "CMSandboxFileShare.h"
#import "CMMainContainerViewController.h"
#import "CMRefreshHeader.h"
#import "CMRefreshFooter.h"
#import "CMThemeCollectionViewHeaderView.h"
#import "CMTipView.h"
#import "RateUSView.h"
#import "CMErrorRefreshView.h"
#import "CMKeyboardBackView.h"
#import "AppContainerData.h"
#import "AppContainerData.h"
#import "UIDevice+Util.h"
#import "UIImage+Util.h"
#import "CMRequestLocalNotifyViewController.h"
#import "CMTabBarViewController.h"
#import "CMAllCustomThemeViewController.h"
#import "CMKeyboardManager.h"
#import "CMInappController.h"
#import "CMGroupDataManager.h"

static NSString * defaultThemeCellID = @"defaultThemeCellID";
static NSString * fetchThemeCellID = @"fetchThemeCellID";
static NSString * customThemeCellID = @"customThemeCellID";
static NSString * themeSectionHeader = @"themeSectionHeaderID";
static NSString * kNoMoreDataShowTime = @"_NoMoreDataShowTime_";

@interface ThemeSettingViewController () < UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate, UIScrollViewDelegate, STPopupDelegate, RateUsDelegate, CMErrorRefreshViewDelegate, CMKeyboardBackViewDelegate,CMThemeCollectionViewHeaderViewDelegate,CMAllCustomThemeViewControllerDelegate>
{
    NSArray * _themePlistArray;
}
@property (nonatomic, strong) UITextField* textInput;
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIView* fieldBackImage;
@property (nonatomic, strong) UICollectionView* themeCollectionView;
@property (nonatomic, strong) UIView * titleLineView;

@property (nonatomic) NSArray* collectionArray;

@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor* mainColor;

@property (nonatomic, assign) BOOL isShowedSwitchKeyboard;
@property (nonatomic, assign) BOOL isShowAndHideKeyboard;

@property (nonatomic, assign) int InappControllerCount;


@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat maxScreenForSuit;

@property (nonatomic, strong)MASConstraint * textFiledBottomConstraint;
@property (nonatomic, strong)MASConstraint * keyboardBackViewConstraint;
@property (nonatomic, strong) STPopupController *themeDownPopController;
@property (nonatomic, strong) RateUSView* rateUsView;

@property (nonatomic, strong) CMRefreshHeader * header;
@property (nonatomic, strong) CMRefreshFooter * footer;
@property (nonatomic, assign) BOOL hudIsShow;
@property (nonatomic, strong) CMErrorRefreshView * errorRefreshView;
@property (nonatomic, assign) CGFloat headerViewFrameY;
@property (nonatomic, strong) CMKeyboardBackView* keyboardBackView;
@property (nonatomic, assign) BOOL isFirstLoadNewData;
@property (nonatomic, assign) NSInteger tabForReport;
@property (nonatomic, strong) UIButton * clearButton;
@property (nonatomic, strong) UIVisualEffectView * effectView;

#ifdef SCHEME
@property (nonatomic, strong) UIAlertController* schemeAlertController;
#endif

@property (nonatomic, strong)CMThemeListViewModel* themeViewModel;
@property (nonatomic, strong)CMThemeManager* themeManager;
@property (nonatomic, assign) BOOL isDropDownData;//正在下拉刷新
@property (nonatomic, assign) BOOL isPullUpData;//正在上拉刷新
@property (nonatomic, strong) NSIndexPath* customThemeHeaderIndex;
@property (nonatomic, strong) CMInappController* inappVC;

@end

@implementation ThemeSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewData];
    
    //modified by ljd: 左右滑动时可以上下动的问题，和iOS11下MJRefreshUI错乱问题
    if (@available(iOS 11.0, *)) {
        //self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.themeCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        //self.settingTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.themeCollectionView];
    [self.view addSubview:self.fieldBackImage];
    [self.fieldBackImage addSubview:self.textInput];
    [self.fieldBackImage addSubview:self.lineView];
    [self.fieldBackImage addSubview:self.clearButton];
    self.fieldBackImage.hidden = YES;
    
    [self.view addSubview:self.keyboardBackView];
    [self.view addSubview:self.effectView];
    [self.effectView.contentView addSubview:self.titleLabel];
    [self.effectView.contentView addSubview:self.titleLineView];
    
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(@(KScalePt(85)));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self.effectView.mas_centerX);
         make.centerY.equalTo(self.effectView.mas_centerY).offset(KScalePt(10));
         make.width.greaterThanOrEqualTo(@0);
         make.height.greaterThanOrEqualTo(@0);
     }];
    
    [self.themeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    
    [self.fieldBackImage mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.right.equalTo(self.view);
         self.textFiledBottomConstraint = make.bottom.equalTo(self.view.mas_bottom);
         make.height.equalTo(@(self.maxScreenForSuit/15.69));
     }];
    
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.right.equalTo(self.fieldBackImage.mas_right);
         make.centerY.equalTo(self.fieldBackImage.mas_centerY);
         make.size.mas_equalTo(CGSizeMake((self.maxScreenForSuit/15.69), (self.maxScreenForSuit/15.69)));
     }];
    
    [self.textInput mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self.fieldBackImage.mas_left).with.offset(kScreenHeight/51.307);
         make.right.equalTo(self.clearButton.mas_left);
         make.centerY.equalTo(self.fieldBackImage.mas_centerY);
     }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.left.right.equalTo(self.fieldBackImage);
         make.height.equalTo(@(0.5));
     }];
    
    [self.keyboardBackView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.left.right.equalTo(self.view);
         self.keyboardBackViewConstraint = make.bottom.equalTo(self.fieldBackImage.mas_top);
     }];
    
    [self.titleLineView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.bottom.equalTo(self.effectView.mas_bottom);
         make.leading.equalTo(self.view);
         make.trailing.equalTo(self.view);
         make.height.equalTo(@(0.5));
     }];
    
    _hudIsShow = NO;
    _isFirstLoadNewData = YES;
    _tabForReport = 1;
    _isPullUpData = NO;
    _isDropDownData = NO;
    
    [self loadLocalThemeList];
}

- (void)dealloc
{
    kLogTrace();
}

- (void)registerNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidHideInputTextFieldNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidShowInputTextFieldNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCustomThemeRedRoundMark:)  name:@"removeCustomThemeRedRoundMark" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleDidHideInputTextFieldNotification:(NSNotification *) notif
{
    self.fieldBackImage.hidden = YES;
    self.keyboardBackView.hidden = YES;
    
    if ([kCMGroupDataManager keyboardHideTimes] == 2)
    {
        [self showRequestLocalAccessView];
        kCMGroupDataManager.keyboardHideTimes = 10;
    }
}

- (void)handleDidShowInputTextFieldNotification:(NSNotification* ) notif
{
    self.fieldBackImage.hidden = NO;
    self.keyboardBackView.hidden = NO;
    [self detectKeyboardSwitch];
}

- (void) removeCustomThemeRedRoundMark:(NSNotification*) theNotification
{
    if (self.customThemeHeaderIndex)
    {
        [self removeRedRoundMark:self.customThemeHeaderIndex];
    }
}

# pragma mark - 界面生命周期处理
- (void)applicationEnteredForeground:(NSNotification *)notification
{
    if ([[CMRouterManager sharedInstance].topMostViewController isKindOfClass:[ThemeSettingViewController class]]) {
        if (![self detectKeyboardAddAndFullAccess]) {
            if (self.shouldShowKeyboard) {
                [self showKeyBoard:nil];
            }
            if ([self.themeViewModel getFetchedModelArray].count <= 0)
            {
                [self.header beginRefreshing];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];

    if (![UIDevice isIpad])
    {
        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
    }
    
    
    
    _inappVC = [[CMInappController alloc] init];
    
    // 放到子线程来请求数据
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
         [self verifiedReceipt];
    });
   
    BOOL iappEnable = [kCMKeyboardManager.cloundConfig getCloudBoolValue:3 section:@"forced_subscription" key:@"forced_subscription" defValue:NO];
    NSLog(iappEnable ? @"lxm iappEnable Yes" : @"lxm iappEnable No");

    BOOL hasPurchased = [kCMGroupDataManager hasPurchasedIAP];
    
    NSLog(@"lxm kPreviousAppVersion = %@", [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentAppVersion]);
    
    NSString *versionPrevious = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousAppVersion];
    NSString *inappVersion = [CMAppConfig inappVersion];
    if ((versionPrevious == nil || [versionPrevious compare:inappVersion options:NSNumericSearch] == NSOrderedDescending) && iappEnable && !hasPurchased)
    {
        [self.navigationController pushViewController:_inappVC animated:YES];
    }
    
    
}

-(void) verifiedReceipt{
     // 验证凭证， 获取到苹果返回的交易数据
    // appStoreReceipturl ios 7.0 增加的， 购买完成后，会将凭据存放在该地址
    NSURL *receiptURL  = [[NSBundle mainBundle] appStoreReceiptURL];
    NSLog(@"lxm receiptURL = %@", receiptURL);
    // 从沙盒种获取到购买凭证
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    /**
     BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     BASE64 是可以编码和解码的
     */
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDate *date = [NSDate date];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger interval = [timeZone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    NSTimeInterval  today = [localeDate timeIntervalSince1970];
    int intervalInt = (int)today;
    
    NSString* pid = [CMAppConfig deviceIdentify];
    NSString* password = [CMAppConfig inappPassword];
    
    NSString* forMd5Str = [NSString stringWithFormat:@"%d%@%@%@", intervalInt, pid, encodeStr,password];
    NSString *md5 = [forMd5Str sha1];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                encodeStr,@"receipt-data",
                                                                pid,@"pid",
                                                                [NSNumber numberWithInt:1],@"version",
                                                                [NSNumber numberWithInt:intervalInt],@"time",
                                                                md5,@"md5",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error: nil
                        ];
    
    NSURL *StoreURL=nil;
    StoreURL= [[NSURL alloc] initWithString: [CMAppConfig inappUrl]];
    
    NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:StoreURL];
    [connectionRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [connectionRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [connectionRequest setHTTPMethod:@"POST"];
    [connectionRequest setTimeoutInterval:50.0];//120.0---50.0zl
    [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [connectionRequest setHTTPBody:jsonData];
    
    //开始请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:connectionRequest returningResponse:nil error:&error];
    if (error) {
        NSLog(@"lxm 验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    
    if(responseData){
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"lxm 请求成功后的数据:%@",dic);
        NSNumber *status=dic[@"status"];
        
        if (status.intValue == 0){
            NSLog(@"lxm 从服务端验证成功");
            
            NSDictionary *verifyResult = dic[@"verify_result"];
            NSNumber *subscribeStatus = verifyResult[@"subscribe_status"];
            
            if(subscribeStatus.intValue == 3 || subscribeStatus.intValue == 2){
                [kCMGroupDataManager setHasPurchasedIAP:YES];
            } else {
                [kCMGroupDataManager setHasPurchasedIAP:NO];
            }
        }
    }
  
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self detectKeyboardAddAndFullAccess]) {
        [self registerNotify];
        if (self.shouldShowKeyboard) {
            [self showKeyBoard:nil];
        }
        if ([self.themeViewModel getFetchedModelArray].count <= 0) {
            [self.header beginRefreshing];
        }
    }
    
    self.shouldShowKeyboard = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDefault];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.themeViewModel cancelTask];
    [self hideKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)fetchThemeList {
    if (_isPullUpData == YES) {
        return;
    }
    _isDropDownData = YES;
    
    @weakify(self)
    [self.themeViewModel fetchNetThemesFirstPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [_header endRefreshing];
        
        _isDropDownData = NO;
        
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil)];
            if ([self.themeViewModel numberOfItemsInSection:2] <= 0) {
                [self hideErrorRefreshView];
                [self showErrorRefreshView];
            }else{
                [self hideErrorRefreshView];
            }
            [CMHostInfoc reportCheetahkeyboard_main_theme_refreshWithAction:2];
        }
        else {
            [self.themeCollectionView reloadData];
            if ([self.themeViewModel numberOfItemsInSection:1] <= 0) {
                [self hideErrorRefreshView];
                [self showErrorRefreshView];
            }else{
                [self hideErrorRefreshView];
            }
            
            if (hasMore == NO) {
                if ([self canShowTipForOneDay] == YES && _isFirstLoadNewData == NO) {
                    [self showErrorTipWithIcon:nil errorMessage:CMLocalizedString(@"LoadNoMoreData_tip", nil)];
                }
                [_footer endRefreshingWithNoMoreData];
            }else{
                [_footer setState:MJRefreshStateIdle];
            }
            
            _isFirstLoadNewData = NO;
            [CMHostInfoc reportCheetahkeyboard_main_theme_refreshWithAction:1];
        }
    }];
}

- (void)loadLocalThemeList {
    @weakify(self)
    [self.themeViewModel loadLocalThemesWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        if (!errorMsg) {
            [self.themeCollectionView reloadData];
        }
    }];
}

- (BOOL)shouldShowKeyboardBtn {
    return YES;
}

- (BOOL)detectKeyboardAddAndFullAccess {
    BOOL needJump = NO;
    if (![CMBizHelper checkIsAddCheetahKeyboard])
    {
        AddKeyBoardController* addKeyboardController = [[AddKeyBoardController alloc] init];
        [self.navigationController pushViewController:addKeyboardController animated:YES];
        needJump = YES;
    }
    else if (![AppContainerData isShowedFullAccess])
    {
        SetFullAccessViewController* fullAccessController = [[SetFullAccessViewController alloc] init];
        [self.navigationController pushViewController:fullAccessController animated:YES];
        [AppContainerData setIsShowedFullAccess:YES];
        needJump = YES;
    }
    return needJump;
}

- (BOOL)detectKeyboardSwitch {
    BOOL needJump = NO;
    if (![CMBizHelper checkIsCheetahKeyboard:self.textInput] && [self.textInput isFirstResponder])
    {
        [self showSwitKeyboardViewController];
        needJump = YES;
    }
    return needJump;
}

- (void) showSwitKeyboardViewController
{
    if (![[CMRouterManager sharedInstance].topMostViewController isKindOfClass:[SwitchKeyboardByMovieViewController class]]) {
        SwitchKeyboardByMovieViewController* switchKeyboardController = [[SwitchKeyboardByMovieViewController alloc] init];
        [self.navigationController pushViewController:switchKeyboardController animated:YES];
    }
}

#pragma mark - getter/setter
- (CMThemeListViewModel *)themeViewModel {
    if (!_themeViewModel) {
        _themeViewModel = [CMThemeListViewModel new];
    }
    return _themeViewModel;
}

- (CMThemeManager *)themeManager {
    if (!_themeManager) {
        _themeManager = kCMKeyboardManager.themeManager;
    }
    return _themeManager;
}

#pragma mark - 输入框初始化
- (UITextField *)textInput
{
    if (!_textInput)
    {
        _textInput = [[UITextField alloc] init];
        _textInput.textColor = [UIColor whiteColor];
        _textInput.font =  [UIFont fontWithName:@"Montserrat-Regular" size:kScreenHeight/38.44];
        _textInput.delegate = self;
        _textInput.userInteractionEnabled = YES;
                
        NSString * placeholderStr = CMLocalizedString(@"Try_Keyboard", nil);
        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc] initWithString:placeholderStr];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:[UIColor lightGrayColor]
                            range:NSMakeRange(0, placeholderStr.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"Montserrat-Regular" size:kScreenHeight/38.44]
                            range:NSMakeRange(0, placeholderStr.length)];
        _textInput.attributedPlaceholder = placeholder;
        [_textInput addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _textInput;
}


- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:87.0/255.0 green:95.0/255.0 blue:138.0/255.0 alpha:1.0f];
    }
    
    return _lineView;
}

- (UIView *)titleLineView
{
    if (!_titleLineView) {
       _titleLineView = [[UIView alloc] init];
       _titleLineView.backgroundColor = COLOR_WITH_RGBA(38, 42, 64, 1);
    }
    return _titleLineView;
}

- (CMKeyboardBackView *)keyboardBackView
{
    if (!_keyboardBackView)
    {
        _keyboardBackView = [[CMKeyboardBackView alloc] init];
        _keyboardBackView.delegate = self;
    }
    
    return _keyboardBackView;
}

-(UIButton *)clearButton
{
    if (!_clearButton) {
        _clearButton = [[UIButton alloc] init];
        [_clearButton setImage:[UIImage imageNamed:@"textDelete"] forState:UIControlStateNormal];
        [_clearButton setImage:[UIImage imageNamed:@"textDelete"] forState:UIControlStateHighlighted];
        [_clearButton addTarget:self action:@selector(clearButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        _clearButton.hidden = YES;
    }
    return _clearButton;
}

- (void)clearButtonDidClick
{
    self.textInput.text = nil;
    self.clearButton.hidden = YES;
    [CMHostInfoc reportCheetahkeyboard_main_deleteWithTabName:_tabForReport];
}

- (void)keyboardBackViewTouched
{
    kCMGroupDataManager.keyboardHideTimes = ++kCMGroupDataManager.keyboardHideTimes;
    self.keyboardBackView.hidden = YES;
    [self hideKeyboard];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    [self hideKeyboard];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

#pragma mark - TextField Custom Method
-(void)textFieldTextChange:(UITextField *)textField{
    if ([CMGroupDataManager shareInstance].isShowingCloudPredictTip == YES) {
        self.clearButton.hidden = YES;
    }else{
        self.clearButton.hidden = NO;
    }
    if (textField.text.length == 0) {
        self.clearButton.hidden = YES;
    }
}

#pragma mark - 输入框背景初始化
- (UIView *)fieldBackImage
{
    if (!_fieldBackImage)
    {
        _fieldBackImage = [[UIView alloc] init];
        _fieldBackImage.backgroundColor = [UIColor colorWithRed:15.0/255.0 green:19.0/255.0 blue:40.0/255.0 alpha:242.0/255.0];
        _fieldBackImage.userInteractionEnabled = YES;
    }
    
    return _fieldBackImage;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = self.mainColor;
        _titleLabel.text = CMLocalizedString(@"CHEETAH_KEYBOARD", nil);
        _titleLabel.font =  [UIFont fontWithName:@"Montserrat-Regular" size:kScreenHeight/37.7];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        for (UIView *view in _effectView.subviews) {
            kLog(@"UIVisualEffectView subview类型%@", NSStringFromClass([view class]));
            if ([view isMemberOfClass:NSClassFromString(@"_UIVisualEffectFilterView")]|| [view isMemberOfClass:NSClassFromString(@"_UIVisualEffectSubview")] ) {
                // iOS 11 需要 _UIVisualEffectSubview
                view.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:0.91];
                break;
            }
        }
    }
    return _effectView;
}

#pragma mark - SegmentedControl 事件处理
- (void)setApperanceForLabel:(UILabel *)label
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl
{
    kLogInfo(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
}

#pragma mark - 显示隐藏键盘
- (void) showKeyBoard:(id) sender
{
    self.keyboardBackView.hidden = NO;
    self.fieldBackImage.hidden = NO;
    [self.textInput becomeFirstResponder];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.rateUsView)
    {
        [self hideKeyboard];
    }
}

- (void)hideKeyboard
{
    self.fieldBackImage.hidden = YES;
    [self.view endEditing:YES];
}

#pragma mark - 界面数据初始化
- (void) setupViewData
{
    NSString * themePlistPath;
#ifdef SCHEME
    themePlistPath = [[NSBundle mainBundle] pathForResource:@"CMThemeScheme" ofType:@"plist"];
#else
    themePlistPath = [[NSBundle mainBundle] pathForResource:@"CMTheme" ofType:@"plist"];
#endif
    _themePlistArray = [[NSArray alloc] initWithContentsOfFile:themePlistPath];
    
    self.bottom = 0.0f;
    
    self.mainColor = [UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:255.0];
    
    self.backColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    self.view.backgroundColor = self.backColor;
    
    self.view.backgroundColor = self.backColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.screenWidth = [CMBizHelper adapterScreenWidth];
    self.screenHeight = [CMBizHelper adapterScreenHeight];
    self.maxScreenForSuit = self.screenHeight > self.screenWidth ? self.screenHeight : self.screenWidth;
    
    self.isShowAndHideKeyboard = YES;
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
            _themeCollectionView.contentInset = UIEdgeInsetsMake(KScalePt(85), 0, 0, 0);
            
            //layout.itemSize = CGSizeMake(self.maxScreenForSuit/5, self.maxScreenForSuit/6.8);
            layout.minimumLineSpacing = self.maxScreenForSuit/26.66;
            layout.minimumInteritemSpacing = 0;
            layout.sectionInset = UIEdgeInsetsMake(0, self.maxScreenForSuit/26.66, self.maxScreenForSuit/26.66*2, self.maxScreenForSuit/26.66);
            [_themeCollectionView setCollectionViewLayout:layout];
        }
        else
        {
            _themeCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
            _themeCollectionView.contentInset = UIEdgeInsetsMake(KScalePt(85), 0, 0, 0);
            
            //layout.itemSize = CGSizeMake(self.screenHeight/3.8136, self.screenHeight/4.1406);
            //            layout.minimumInteritemSpacing = self.screenHeight/76.66; //横向
            layout.minimumLineSpacing = self.screenHeight/76.66; //竖向
            layout.minimumInteritemSpacing = 0;
            layout.sectionInset = UIEdgeInsetsMake(0, kScreenHeight/76.66, 0, kScreenHeight/76.66);
            [_themeCollectionView setCollectionViewLayout:layout];
        }
        
        _themeCollectionView.backgroundColor = self.backColor;
        _themeCollectionView.clipsToBounds = NO;
        _themeCollectionView.dataSource = self;
        _themeCollectionView.delegate = self;
        _themeCollectionView.allowsMultipleSelection = NO;
        [_themeCollectionView registerClass:[ThemeCollectionViewCell class] forCellWithReuseIdentifier:defaultThemeCellID];
        [_themeCollectionView registerClass:[ThemeCollectionViewCell class] forCellWithReuseIdentifier:fetchThemeCellID];
        [_themeCollectionView registerClass:[ThemeCollectionViewCell class] forCellWithReuseIdentifier:customThemeCellID];
        [_themeCollectionView registerClass:[CMThemeCollectionViewHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:themeSectionHeader];
        _themeCollectionView.mj_header = self.header;
        _themeCollectionView.mj_footer = self.footer;
    }
    
    return _themeCollectionView;
}

#pragma mark - 处理屏幕旋转

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        }];
    }
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
    
    if (self.rateUsView)
    {
        [self.rateUsView removeFromSuperview];
    }
    
    self.maxScreenForSuit = self.screenHeight > self.screenWidth ? self.screenHeight : self.screenWidth;
    [self hideKeyboard];
}

#pragma mark - UICollectionView DataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionVie
{
    return [self.themeViewModel numberOfSections];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.themeViewModel numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThemeCollectionViewCell * cell;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:defaultThemeCellID forIndexPath:indexPath];
    }else if (indexPath.section == 1){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:customThemeCellID forIndexPath:indexPath];
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:fetchThemeCellID forIndexPath:indexPath];
    }
    
    CMThemeModel * themeModel = [self.themeViewModel themeModelAtIndexPath:indexPath];
    CMThemeCellViewModel * cellModel = [[CMThemeCellViewModel alloc] initWithThemeModel:themeModel themeManager:self.themeManager];
    [cell setThemeCellViewModel:cellModel indexPath:indexPath];
    
    return cell;
}

#pragma mark - 弹框初始化
#ifdef SCHEME
- (UIAlertController *)schemeAlertController {
    if (!_schemeAlertController) {
        [CMCloudConfigHelper updateLocalCloudConfig];
        NSString* mainTitle = [CMCloudConfigHelper getCloudStringValue:3 section:@"theme_hologram_alert" key:@"mainTitle" defValue:CMLocalizedString(@"Install_Cheetah_Keyboard_for_apply_this_theme", nil)];
        NSString* secondTitle = [CMCloudConfigHelper getCloudStringValue:3 section:@"theme_hologram_alert" key:@"secondTitle" defValue:CMLocalizedString(@"Get_it_now_No_Ads", nil)];
        
        NSString* okButtonTitle = [CMCloudConfigHelper getCloudStringValue:3 section:@"theme_hologram_alert" key:@"okButtonTitle" defValue:CMLocalizedString(@"FREE_INSTALL", nil)];
        NSString* cancleButtonTitle = [CMCloudConfigHelper getCloudStringValue:3 section:@"theme_hologram_alert" key:@"cancleButtonTitle" defValue:CMLocalizedString(@"NOT_NOW", nil)];
        
        _schemeAlertController = [UIAlertController alertControllerWithTitle:mainTitle message:secondTitle preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleCancel handler:^ (UIAlertAction* theAction)
                                       {
                                           NSString *appStoreUrl = @"https://itunes.apple.com/app/apple-store/id1249925656?pt=2036779&ct=theme_default&mt=8";
                                           NSString* currentThemeName = [NSString stringIsEmpty:kCMGroupDataManager.currentThemeName] ? @"default" : kCMGroupDataManager.currentThemeName;
                                           appStoreUrl =  [appStoreUrl stringByReplacingOccurrencesOfString:@"default" withString:currentThemeName];
                                           [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appStoreUrl]];
                                           _schemeAlertController = nil;
                                       }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:cancleButtonTitle style:UIAlertActionStyleDefault handler:^ (UIAlertAction* theAction)
                                   {
                                       kLogInfo(@"");
                                       _schemeAlertController = nil;
                                   }];
        [_schemeAlertController addAction:cancelAction];
        [_schemeAlertController addAction:okAction];
    }
    return _schemeAlertController;
}
#endif

- (void) backgroundViewDidTap
{
    ThemeDetailViewController* theTopController = (ThemeDetailViewController*)self.themeDownPopController.topViewController;
    
    if (theTopController)
    {
        [CMHostInfoc reportCheetahkeyboard_main_theme_downWithThemeName:theTopController.themeDetailViewModel.themeName xy:(theTopController.themeDetailViewModel.themeIndex + 1) action:theTopController.themeDetailViewModel.themeType classType:4];
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
    [self changeKeyboardTheme:theModel index:indexPath.row];
    [CMHostInfoc reportCheetahkeyboard_main_theme_clickWithThemeName:theModel.themeName xy:indexPath.row+3 value:1];
}

- (void)themeApplyTapped:(CMThemeModel *)theModel indexPath:(NSIndexPath *)indexPath
{
    self.shouldShowKeyboard = YES;
    if (![theModel.themeName isEqualToString:kCMGroupDataManager.currentThemeName]) {
        [self changeKeyboardTheme:theModel index:indexPath.row];
        if (theModel.type == CMThemeModelType_Default) {
            [CMHostInfoc reportCheetahkeyboard_main_theme_clickWithThemeName:theModel.themeName xy:indexPath.row+1 value:1];
        }else if (theModel.type == CMThemeModelType_Custom){
            [CMHostInfoc reportCheetahkeyboard_main_theme_clickWithThemeName:theModel.themeName xy:0 value:1];
        }else{
            [CMHostInfoc reportCheetahkeyboard_main_theme_clickWithThemeName:theModel.themeName xy:indexPath.row+5 value:1];
        }
    }
}

- (void)themeDiyTapped:(CMThemeModel *)theModel indexPath:(NSIndexPath *)indexPath
{
    CMDiyType diyType = indexPath.section == 1 ? CMDiyTypeDiy :CMDiyTypeOfficial;
    CMDIYThemeViewController *diyThemeVC = [[CMDIYThemeViewController alloc] initWithDiyThemeName:theModel.themeName diyType:diyType];
    diyThemeVC.delegate = self;
    diyThemeVC.inway = 1;
    [self.navigationController pushViewController:diyThemeVC animated:YES];
    
}

#pragma mark -
- (void) popThemeDetailController:(NSIndexPath*) indexPath
{
    self.shouldShowKeyboard = NO;
    
    CMThemeDetailViewModel* themeDetailModel = [self.themeViewModel detailViewModelForIndexPath:indexPath themeManager:self.themeManager];
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

- (void)rateUsViewIsHidden
{
    self.rateUsView = nil;
}

- (void) showRateUsView
{
    self.rateUsView = [[RateUSView alloc] init];
    self.rateUsView.delegate = self;
    [self.view addSubview:self.rateUsView];
    [self.rateUsView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self.view);
     }];
    
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.2];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.rateUsView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [self.rateUsView becomeFirstResponder];
    [AppContainerData setIsShowedRateUsView:YES];
}

- (void) showRequestLocalAccessView
{
    UIViewController* theRoot =  [CMRouterManager sharedInstance].rootController;
    if (theRoot && [theRoot isKindOfClass:[CMTabBarViewController class]])
    {
        ((CMTabBarViewController*) theRoot).isClickEnable = NO;
    }
    CMRequestLocalNotifyViewController* switchKeyboardController = [[CMRequestLocalNotifyViewController alloc] init];
    [self.navigationController pushViewController:switchKeyboardController animated:YES];
    [self performSelector:@selector(enableTabBarClick) withObject:nil afterDelay:3];
}

- (void) enableTabBarClick
{
    UIViewController* theRoot =  [CMRouterManager sharedInstance].rootController;
    if (theRoot && [theRoot isKindOfClass:[CMTabBarViewController class]])
    {
        ((CMTabBarViewController*) theRoot).isClickEnable = YES;
    }
}

- (void) changeKeyboardTheme:(CMThemeModel*) theModel index:(NSInteger)index
{
    if (![self detectKeyboardSwitch]) {
        [[CMGroupDataManager shareInstance] setCurrentThemeName:theModel.themeName];
        [self.themeCollectionView reloadData];
        CMTipView * tipView = [[CMTipView alloc] initWithIcon:nil message:CMLocalizedString(@"Change_Theme", nil)];
        MBProgressHUD * hud = [MBProgressHUD showCustomView:tipView toView:self.view seconds:0.5 completion:^(BOOL finished)
                               {
                                   [self showKeyBoard:nil];
                                   id date = [AppContainerData appFirstInstallTime];
                                   if (date && [date isKindOfClass:[NSDate class]])
                                   {
                                       NSDate* lastDate = (NSDate *)date;
                                       NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:lastDate];
                                       BOOL valid = (delta >= 60*60*24 || delta < 0);
#if DEBUG
                                       valid = (delta >= 5*60 || delta < 0);
#endif
                                       if (![AppContainerData isShowedRateUsView] && valid) {
                                           // [self performSelector:@selector(showRateUsView) withObject:nil afterDelay:0.5];
                                       }
                                   }
                               }];
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = COLOR_WITH_RGBA(48, 54, 83, 1);
        hud.bezelView.layer.cornerRadius = 20;
        hud.userInteractionEnabled = NO;
        
    }
}

#pragma mark - UICollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        if ([UIDevice isIpad])
        {
            [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
        }
        
        [self removeRedRoundMark:indexPath];
        
        CMDIYThemeViewController *diyThemeVC = [CMDIYThemeViewController new];
        diyThemeVC.delegate = self;
        diyThemeVC.inway = 1;
        [self.navigationController pushViewController:diyThemeVC animated:YES];
        return;
    }
    NSInteger theIndex = indexPath.row;
    kCMGroupDataManager.keyboardThemeChangeTimes = ++kCMGroupDataManager.keyboardThemeChangeTimes;
    if ([kCMGroupDataManager keyboardThemeChangeTimes] >= 5)
    {
        if (![AppContainerData isShowedRateUsView] && [[UIDevice currentDevice] isScreenPortrait])
        {
            [self performSelector:@selector(showRateUsView) withObject:nil afterDelay:0.5];
        }
    }
    kLog(@"indexPath.row = %ld   index.section = %ld", (long)theIndex, (long) indexPath.section);
    
    if (![self detectKeyboardSwitch]) {
        [self popThemeDetailController:indexPath];
        
#if defined(SCHEME)
        if (indexPath.item != 0)
        {
            [self hideKeyboard];
            [self presentViewController:self.schemeAlertController animated:YES completion:nil];
            [self.themeCollectionView reloadData];
            return;
        }
#endif
    }
}

- (void) removeRedRoundMark:(NSIndexPath*) theIndex
{
    UICollectionReusableView* headerView = [self.themeCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:theIndex];
    if (headerView && [headerView isKindOfClass:[CMThemeCollectionViewHeaderView class]])
    {
        [((CMThemeCollectionViewHeaderView*) headerView) removeRedRoundMark];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsShowCustomThemeRedRoundMarkOnContainerApp];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH, 33);
    }
    return CGSizeMake(SCREEN_WIDTH, 28);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *supplementaryView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        CMThemeCollectionViewHeaderView * headerView = (CMThemeCollectionViewHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:themeSectionHeader forIndexPath:indexPath];
        headerView.delegate = self;
        
        if (indexPath.section == 1) {
            self.customThemeHeaderIndex = indexPath;
            headerView.showAllCustomThemeButton = YES;
        }else{
            headerView.showAllCustomThemeButton = NO;
        }
        
        if (indexPath.section == 2) {
            if (headerView.frame.origin.y > 0)
            {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    _headerViewFrameY = headerView.frame.origin.y;
                });
            }
            //kLogInfo(@"%@",NSStringFromCGRect(headerView.frame));
        }
        headerView.title = [self.themeViewModel titleForSection:indexPath.section];
        
        supplementaryView = headerView;
        
    }
    return supplementaryView;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice isIpad])
    {
        return CGSizeMake(self.maxScreenForSuit/5, self.maxScreenForSuit/6.8);
    }else{
        return CGSizeMake(KScalePt(170), KScalePt(170)*142/170.0);
    }
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if ([UIDevice isIpad]) {
        return UIEdgeInsetsMake(KScalePt(4), KScalePt(30), 0, KScalePt(30));
    }else{
        return UIEdgeInsetsMake(KScalePt(4), KScalePt(12), 0, KScalePt(12));
    }
    
}

#pragma mark - CMThemeCollectionViewHeaderViewDelegate Method
- (void)themeCollectionViewHeaderViewSeeAllButtonClick
{
    CMAllCustomThemeViewController * allCustomThemeVC = [[CMAllCustomThemeViewController alloc] init];
    allCustomThemeVC.themeViewModel = self.themeViewModel;
    allCustomThemeVC.delegate = self;
    [CMHostInfoc reportCheetahkeyboard_diy_all:[CMKeyboardManager sharedInstance].themeManager.DIYThemes.count];
    [self.navigationController pushViewController:allCustomThemeVC animated:YES];
}

#pragma mark - RefreshHeaderAndFooter Methods
- (CMRefreshHeader *)header {
    if (!_header) {
        _header = [CMRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewThemes)];
    }
    return _header;
}

- (CMRefreshFooter *)footer {
    if (!_footer) {
        _footer = [CMRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreThemes)];
    }
    return _footer;
}

- (void)loadNewThemes
{
    [self fetchThemeList];
    
}

- (void)loadMoreThemes
{
    if (_isDropDownData == YES) {
        return;
    }
    _isPullUpData = YES;
    @weakify(self)
    [self.themeViewModel fetchNetThemesNextPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        
        [_footer endRefreshing];
        _isPullUpData = NO;
        
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil)];
            [CMHostInfoc reportCheetahkeyboard_main_theme_refreshWithAction:4];
        }
        else {
            if (hasMore == NO) {
                [_footer endRefreshingWithNoMoreData];
            }
            
            [self.themeCollectionView reloadData];
            [CMHostInfoc reportCheetahkeyboard_main_theme_refreshWithAction:3];
        }
    }];
}

#pragma mark - ErrorTip Method
- (void)showErrorTipWithIcon:(NSString *)iconString errorMessage:(NSString *)errorMessage
{
    if (_hudIsShow == NO) {
        _hudIsShow = YES;
        CMTipView * tipView = [[CMTipView alloc] initWithIcon:iconString message:errorMessage];
        MBProgressHUD * hud = [MBProgressHUD showCustomView:tipView toView:self.view seconds:3.0 completion:^(BOOL finished) {
            _hudIsShow = NO;
        }] ;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = COLOR_WITH_RGBA(48, 54, 83, 1);
        hud.bezelView.layer.cornerRadius = 20;
        hud.userInteractionEnabled = NO;
        
        [_footer endRefreshingWithNoMoreData];
    }
}

- (BOOL)canShowTipForOneDay
{
    NSDate * date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSTimeInterval preTime = [[NSUserDefaults standardUserDefaults] doubleForKey:kNoMoreDataShowTime];
    if (time - preTime >= 24 * 60 * 60 - 60) {
        [[NSUserDefaults standardUserDefaults] setDouble:time forKey:kNoMoreDataShowTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

- (void)showErrorRefreshView
{
    _errorRefreshView = [[CMErrorRefreshView alloc] init];
    _errorRefreshView.delegate = self;
    [self.themeCollectionView addSubview:_errorRefreshView];
    CGFloat offsetY = self.maxScreenForSuit - (self.maxScreenForSuit - _headerViewFrameY - 49) * 0.5 - 50 - KScalePt(85);
    [_errorRefreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.themeCollectionView.mas_top).offset(offsetY);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 100));
    }];
}

- (void)hideErrorRefreshView
{
    if (_errorRefreshView) {
        _errorRefreshView.hidden = YES;
        [_errorRefreshView removeFromSuperview];
    }
}

#pragma mark - CMErrorRefreshViewDelegate Method
-(void)refreshDidClick
{
    [self hideErrorRefreshView];
    [_header beginRefreshing];
}

- (void)handleKeyboardWillShow:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = [UIDevice isHeight812] ? -keyboardRect.size.height+75+8 : -keyboardRect.size.height + 49;
    height = [UIDevice isHeight896] ? -keyboardRect.size.height + 85 : height;
    self.textFiledBottomConstraint.offset(height);
//    if ([UIDevice isHeight812]) {
//        self.textFiledBottomConstraint.offset(-([CMKeyboardManager keyboardHeight] + [CMKeyboardManager toolbarHeight] - (83 - 75))); //tabbar高 - 系统白边高（量出的高度）
//    }
//    else {
//        self.textFiledBottomConstraint.offset(-([CMKeyboardManager keyboardHeight] + [CMKeyboardManager toolbarHeight] - 49));
//    }
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)handleKeyboardWillHidden:(NSNotification *)notif
{
    self.textFiledBottomConstraint.offset(0);
    NSDictionary *userInfo = [notif userInfo];
    //键盘的动画时间,设定与其完全一致
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    //键盘的动画是变速的,设定与其完全保持一致
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - CMAllCustomThemeViewControllerDelegate Method
-(void)allCustomThemeViewControllerThemeClick:(NSInteger)themeIndex
{
    [self.themeViewModel setIndex:themeIndex];
    [self.themeCollectionView reloadData];
}

- (void)needReloadSeletedCustomTheme
{
    [self.themeViewModel updateCustomThemesAfterEdit];
    [self.themeCollectionView reloadData];
}

- (void)needReloadAfterEdit
{
    [self.themeViewModel updateCustomThemesAfterEdit];
    [self.themeCollectionView reloadData];
}

- (void)onNavCancelBtnTapped:(CMBaseViewController *)vc {
    self.shouldShowKeyboard = NO;
}

#pragma mark - CMDIVThemeViewControllerDelegate Method
-(void)doneButtonClickWith:(CMThemeModel *)model
{
    [self.themeViewModel setupCustomArrayWiththemeModel:[CMKeyboardManager sharedInstance].themeManager.latestDIYTheme];
    kCMGroupDataManager.currentThemeName = [CMKeyboardManager sharedInstance].themeManager.latestDIYTheme.themeName;
    //[CMThemeModel modifyModelWithModel:model];
    
    if ([UIDevice isIpad]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"customThemeClickIndexForPad"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.themeCollectionView reloadData];
    
    self.shouldShowKeyboard = YES;
}

- (void)customThemeDidClick:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"customThemeClickIndexForPad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.themeCollectionView reloadData];
}
@end
