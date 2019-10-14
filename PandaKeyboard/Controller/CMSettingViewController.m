//
//  CMSettingViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMSettingViewController.h"
#import "SettingTableViewCell.h"

#import "UIColor+HexColors.h"
#import "CMAppConfig.h"
#import "CMBizHelper.h"

#import "LanguageViewController.h"
#import "PerferencesViewController.h"
#import "TextCorrectionViewController.h"
#import "CMFeedBackViewController.h"
#import "AboutViewController.h"



@interface CMSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView * settingTableView;
@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * titleLineView;
@property (nonatomic, strong) NSArray * settingSectionOneIconArray;
@property (nonatomic, strong) NSArray * settingSectionTwoIconArray;
@property (nonatomic, strong) NSArray * settingSectionOneTitleArray;
@property (nonatomic, strong) NSArray * settingSectionTwoTitleArray;
@property (nonatomic, assign) CGFloat maxScreenForSuit;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong)UITextField* tinyTextField;

@end

@implementation CMSettingViewController

#pragma mark - life circle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    
    [self.view addSubview:self.tinyTextField];
    
    self.screenWidth = [CMBizHelper adapterScreenWidth];
    self.screenHeight = [CMBizHelper adapterScreenHeight];
    self.maxScreenForSuit = self.screenHeight > self.screenWidth ? self.screenHeight : self.screenWidth;
    
    [self.view addSubview:self.settingTableView];
    [self.view addSubview:self.effectView];
    [self.effectView.contentView addSubview:self.titleLabel];
    [self.effectView.contentView addSubview:self.titleLineView];
    
    [self.settingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.trailing.equalTo(self.view);
        //        make.leading.equalTo(self.themeCollectionView.mas_trailing);
        //        make.width.equalTo(self.themeCollectionView);
    }];
    
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
         //make.top.equalTo(self.view.mas_top).with.offset(kScreenHeight/14.84);
         make.width.greaterThanOrEqualTo(@0);
         make.height.greaterThanOrEqualTo(@0);
     }];
    
    [self.titleLineView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.bottom.equalTo(self.effectView.mas_bottom);
         make.leading.equalTo(self.view);
         make.trailing.equalTo(self.view);
         make.height.equalTo(@(0.5));
     }];
    
    if (@available(iOS 11.0, *)) {
        //self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        //self.themeCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.settingTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (BOOL)shouldShowKeyboardBtn {
    return YES;
}

#pragma mark - getting methods
- (UITableView *)settingTableView
{
    if (!_settingTableView)
    {
        _settingTableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight) style:UITableViewStylePlain];
        _settingTableView.rowHeight = self.maxScreenForSuit/13.925;
        _settingTableView.backgroundColor = [UIColor clearColor];
        _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _settingTableView.delegate = self;
        _settingTableView.dataSource = self;
        _settingTableView.contentInset = UIEdgeInsetsMake(KScalePt(90), 0, 0, 0);
    }
    
    return _settingTableView;
}

- (UITextField *)tinyTextField {
    if (!_tinyTextField) {
        _tinyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.1f, 0.1f)];
    }
    return _tinyTextField;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:255.0];
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

- (UIView *)titleLineView
{
    if (!_titleLineView) {
        _titleLineView = [[UIView alloc] init];
        _titleLineView.backgroundColor = COLOR_WITH_RGBA(38, 42, 64, 1);
    }
    return _titleLineView;
}

- (NSArray *)settingSectionOneIconArray
{
    if (!_settingSectionOneIconArray) {
        _settingSectionOneIconArray = [NSArray arrayWithObjects:@"Setting_Language",@"Setting_Preferences",@"Setting_Sound", nil];
    }
    return _settingSectionOneIconArray;
}

- (NSArray *)settingSectionTwoIconArray
{
    if (!_settingSectionTwoIconArray) {
        _settingSectionTwoIconArray = [NSArray arrayWithObjects:@"Setting_Gesture",@"Setting_Feedback",@"Setting_About", nil];
    }
    return _settingSectionTwoIconArray;
}

- (NSArray *)settingSectionOneTitleArray
{
    if (!_settingSectionOneTitleArray) {
        _settingSectionOneTitleArray = [NSArray arrayWithObjects:CMLocalizedString(@"Language", nil),CMLocalizedString(@"General", nil),CMLocalizedString(@"Text_Correction", nil), nil];
    }
    return _settingSectionOneTitleArray;
}

- (NSArray *)settingSectionTwoTitleArray
{
    if (!_settingSectionTwoTitleArray) {
        _settingSectionTwoTitleArray = [NSArray arrayWithObjects:CMLocalizedString(@"Rate_us", nil),CMLocalizedString(@"Feedback", nil), CMLocalizedString(@"About", nil), nil];
    }
    return _settingSectionTwoTitleArray;
}

#pragma mark - UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.settingSectionOneIconArray.count;
    }else if (section == 1)
    {
        return self.settingSectionTwoIconArray.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"settingCell";
    SettingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.section == 0) {
        cell.iconName = self.settingSectionOneIconArray[indexPath.row];
        cell.title = self.settingSectionOneTitleArray[indexPath.row];
    }else if (indexPath.section == 1)
    {
        cell.iconName = self.settingSectionTwoIconArray[indexPath.row];
        cell.title = self.settingSectionTwoTitleArray[indexPath.row];
    }
    return cell;
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self navigateToLanguageViewController];
                break;
            case 1:
                [self navigateToPerferencesViewController];
                break;
            case 2:
                [self navigateToTextCorrectionViewController];
                break;
            default:
                break;
        }
    }else
    {
        switch (indexPath.row) {
            case 0:
                [self navigateToRateViewController];
                break;
            case 1:
                [self navigateToFeedBackViewController];
                break;
            case 2:
                [self navigateToAboutViewController];
                break;
                
            default:
                break;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView * footerView = [[UIView alloc] init];
        footerView.backgroundColor = [UIColor clearColor];
        return footerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 50;
    }
    return 0;
}

#pragma mark - Navigation Methods
- (void)navigateToLanguageViewController
{
    LanguageViewController * theLanguage = [[LanguageViewController alloc] init];
    [self.navigationController pushViewController:theLanguage animated:YES];
    
    [CMHostInfoc reportCheetahkeyboard_set_lang];
}

- (void)navigateToPerferencesViewController
{
    PerferencesViewController * thePerferences = [[PerferencesViewController alloc] init];
    [self.navigationController pushViewController:thePerferences animated:YES];
    
    [CMHostInfoc reportCheetahkeyboard_set_gene];
}

- (void)navigateToTextCorrectionViewController
{
    TextCorrectionViewController * textCorrection = [[TextCorrectionViewController alloc] init];
    [self.navigationController pushViewController:textCorrection animated:YES];
    
    [CMHostInfoc reportCheetahkeyboard_set_corr];
}

- (void)navigateToFeedBackViewController
{
    CMFeedBackViewController * feedBackVC = [[CMFeedBackViewController alloc] init];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

- (void)navigateToRateViewController
{
    NSString *appStoreUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", [CMAppConfig appleId]];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appStoreUrl]];
}

- (void)navigateToAboutViewController
{
    AboutViewController * theAbout = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:theAbout animated:YES];
}

@end
