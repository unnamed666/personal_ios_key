//
//  CMDiscoveryViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDiscoveryViewController.h"
#import "CMAnimojiViewController.h"
#import "CMBizHelper.h"
#import "CMMakeAREmoticonViewController.h"
#import "CMDisCoveryTableViewCell.h"
#import "CMAnimojiViewController.h"
#import <MessageUI/MessageUI.h>
#import "CMHostInfoc.h"
#import "UIImage+Util.h"
//#import "InappController.h"

@interface CMDiscoveryViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView * listTableView;
@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * emoticonButton;
@property (nonatomic, strong) UIButton * iMessageButton;
@property (nonatomic, strong) UIView * titleLineView;

@property (nonatomic, strong)UITextField* tinyTextField;
@end

@implementation CMDiscoveryViewController

#pragma mark - life circle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [CMHostInfoc reportCheetahkeyboard_main_disc_showWithInway:_inwayForReport];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tinyTextField];
    
    [self.view addSubview:self.listTableView];
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
    
    [self.titleLineView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.bottom.equalTo(self.effectView.mas_bottom);
         make.leading.equalTo(self.view);
         make.trailing.equalTo(self.view);
         make.height.equalTo(@(0.5));
     }];
    
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (BOOL)shouldShowKeyboardBtn {
    return YES;
}

#pragma mark - getting methods
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

- (UITextField *)tinyTextField {
    if (!_tinyTextField) {
        _tinyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.1f, 0.1f)];
    }
    return _tinyTextField;
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

-(UITableView *)listTableView
{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] init];
        _listTableView.backgroundColor = [UIColor clearColor];
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTableView.dataSource = self;
        _listTableView.delegate = self;
        _listTableView.tableFooterView = [[UIView alloc] init];
        _listTableView.contentInset = UIEdgeInsetsMake(KScalePt(95), 0, 0, 0);
        _listTableView.rowHeight = KScalePt(160);
    }
    return _listTableView;
}

- (UIView *)titleLineView
{
    if (!_titleLineView) {
        _titleLineView = [[UIView alloc] init];
        _titleLineView.backgroundColor = COLOR_WITH_RGBA(38, 42, 64, 1);
    }
    return _titleLineView;
}

#pragma mark - UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cellID";
    CMDisCoveryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[CMDisCoveryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.section == 0) {
        cell.imageName = @"animoji";
    }else if (indexPath.section == 1){
        cell.imageName = @"scanner";
    }else if (indexPath.section == 2){
        cell.imageName = @"fitness";
    }
    return cell;
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        _inwayForReport = 2;
        //        CMAnimojiViewController* makeAREmoticonVC = [CMAnimojiViewController new];
        if ([UIDevice isIpad])
        {
            [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
        }
        CMMakeAREmoticonViewController *makeAREmoticonVC = [CMMakeAREmoticonViewController new];
        makeAREmoticonVC.inway = 1;
        [self.navigationController pushViewController:makeAREmoticonVC animated:YES];
        [CMHostInfoc reportCheetahkeyboard_main_disc_clickWithName:1];
    }else if (indexPath.section == 1){
        NSString *appStoreUrl = @"https://itunes.apple.com/app/apple-store/id1447479721?pt=119544074&ct=kb_discovery&mt=8";
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appStoreUrl]];
    }else if (indexPath.section == 2){
        NSString *appStoreUrl = @"https://itunes.apple.com/app/apple-store/id1450145142?pt=119544074&ct=kb_discovery&mt=8";
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appStoreUrl]];
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
        return KScalePt(1);
    }
    return 0;
}
@end
