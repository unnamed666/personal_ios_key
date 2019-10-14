//
//  CMTabBarViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTabBarViewController.h"
#import "CMTabBar.h"
#import "ThemeSettingViewController.h"
#import "CMMainContainerViewController.h"
#import "CMSettingViewController.h"
#import "CMDiscoveryViewController.h"
#import "UIColor+HexColors.h"
#import "CMRouterManager.h"

static CMTabBar *staticTabBar = nil;

@interface UITabBar(Custom)
@end

@implementation UITabBar(Custom)

- (void)setHidden:(BOOL)hidden
{
    if (staticTabBar) {
        [super setHidden:YES];
    }
}

@end

@interface CMTabBarViewController ()<CMTabBarDelegate>
@property (nonatomic, strong) CMTabBar * tab;
@property (nonatomic, strong) ThemeSettingViewController * themeVC;
@property (nonatomic, strong) CMDiscoveryViewController * discoveryVC;
@property (nonatomic, strong) CMSettingViewController * settingVC;
@property (nonatomic, strong) UIButton* showKeyboardButton;
@property (nonatomic, weak)UITextField* textField;
@property (nonatomic, strong)MASConstraint* tabBottomConstraint;

@end

@implementation CMTabBarViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    
    self.tab = [[CMTabBar alloc]init];
    staticTabBar = self.tab;
    //self.tab.frame = self.tabBar.frame;
    self.tab.delegate = self;
    self.isClickEnable = YES;
    [self.tabBar.superview addSubview:self.tab];
    self.tabBar.hidden = YES;
    
    [self.view addSubview:self.showKeyboardButton];

    [self.tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        self.tabBottomConstraint = make.bottom.equalTo(self.view.mas_bottom).offset(0);
        if ([UIDevice isHeight896]) {
            make.height.equalTo(@(69));
        } else {
            make.height.equalTo(@(49));
        }
        
    }];
    
    [self.showKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.width.height.equalTo(@(KScalePt(40)));
         make.right.equalTo(self.view.mas_right).with.offset(-KScalePt(10));
         make.bottom.equalTo(self.tab.mas_top).with.offset(-KScalePt(20));
     }];

    [self setupVC];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self.tab setSelectIndex:selectedIndex];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setupVC
{
    _themeVC = [[ThemeSettingViewController alloc] init];
    [self addChildVCWith:_themeVC title:CMLocalizedString(@"THEME", nil) normalImage:@"tab_theme_normal" selectedImage:@"tab_theme_selected"];
    
    _discoveryVC = [[CMDiscoveryViewController alloc] init];
    [self addChildVCWith:_discoveryVC title:CMLocalizedString(@"Tab_Discovery", nil) normalImage:@"tab_discovery_normal" selectedImage:@"tab_discovery_selected"];
    
    _settingVC = [[CMSettingViewController alloc] init];
    [self addChildVCWith:_settingVC title:CMLocalizedString(@"SETTINGS", nil) normalImage:@"tab_setting_normal" selectedImage:@"tab_setting_selected"];
    
}

- (BOOL)shouldAutorotate {
    if ([UIDevice isIpad]) {
        return YES;
    }
    return NO;
}

- (void)addChildVCWith:(UIViewController *)childVC title:(NSString *)title normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage
{
    childVC.title = title;
    [self.tab setupItemWithTitle:title normalImage:normalImage selectedImage:selectedImage];
    UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self addChildViewController:navVC];
}

- (void)setKeyboardButtonHidden:(BOOL)hidden {
    if (_showKeyboardButton && _showKeyboardButton.superview) {
        self.showKeyboardButton.hidden = hidden;
    }
}

#pragma mark - setter/getter
- (UIButton *)showKeyboardButton
{
    if (!_showKeyboardButton)
    {
        _showKeyboardButton = [[UIButton alloc] init];
        [_showKeyboardButton setImage: [UIImage imageNamed:@"Input_Icon"] forState:UIControlStateNormal];
        [_showKeyboardButton addTarget:self action:@selector(showKeyboardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
#ifdef DEBUG
        [_showKeyboardButton addTarget:self action:@selector(showKeyboardDownRepeatClick:) forControlEvents:UIControlEventTouchDownRepeat];
#endif
    }
    return _showKeyboardButton;
}
#ifdef DEBUG
- (void)showKeyboardDownRepeatClick:(UIButton *)showKeyboardButton{
    [kCMSandboxFileShare showSandboxBrowser:self];
}
#endif
- (void)showKeyboardButtonDidClick:(UIButton *)showKeyboardButton
{
    if (self.textField) {
        [self.textField becomeFirstResponder];
        [CMHostInfoc reportCheetahkeyboard_main_openkeyWithTab:1];
    }
}


#pragma mark - CMTabBarDelegate Method
- (void)tabbarDidSlected:(CMTabBar *)tabbar from:(NSInteger)from to:(NSInteger)to
{
    [super setSelectedIndex:to];
    if (to == 0 && from == to) {
        _themeVC.shouldShowKeyboard = YES;
    }else{
        _themeVC.shouldShowKeyboard = NO;
    }
    
    if (to == 1) {
        _discoveryVC.inwayForReport = 1;
    }
    
    if (to == 2) {
        [CMHostInfoc reportCheetahkeyboard_main_showWithTab:2 inway:2];
    }
}

-(void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    if (hidesBottomBarWhenPushed == YES) {
        self.tabBottomConstraint.offset(self.tabBar.frame.size.height);
        [UIView animateWithDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
//            self.tab.frame = CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height + self.tabBar.frame.size.height, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
        }];
    }else{
        self.tabBottomConstraint.offset(0);
        [UIView animateWithDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
//            self.tab.frame = self.tabBar.frame;
        }];
    }
}

- (void)setIsClickEnable:(BOOL)isClickEnable
{
    self.tab.isClickEnable = isClickEnable;
}

#pragma mark - setter/getter
- (UITextField *)textField {
    _textField = nil;
    UIViewController* topVC = [CMRouterManager sharedInstance].topMostViewController;
    if (topVC) {
        NSArray* array = [self.view allSubviewsWithClass:[UITextField class]];
        if (array && array.count > 0) {
            _textField = [array firstObject];
        }
    }

    return _textField;
}

@end
