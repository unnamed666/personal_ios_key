//
//  PerferencesViewController.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "PerferencesViewController.h"
#import "PerferencesTableViewCell.h"
#import "CMNavigationBar.h"
#import "CMBizHelper.h"
#import "SettingData.h"
#import "MBProgressHUD+Toast.h"

//static NSInteger AUTO_CORRECTION_INDEX = 0;
//static NSInteger DOUBLE_SPACE_PERIOD = 1;
//static NSInteger OPEN_KEYBOARD_SOUND = 1;

@interface PerferencesViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CMNavigationBarDelegate>

@property (nonatomic, strong) UITableView* laungugeTableView;
@property (strong, nonatomic) UIColor *backColor;
@property(nonatomic) NSArray* collectionArray;

@property (nonatomic, strong) CMNavigationBar* navigationView;

@property(nonatomic) SettingData* settingData;

@end

@implementation PerferencesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    
    self.settingData = [[SettingData alloc] init];
    
    [self navigationView];
    [self laungugeTableView];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)dealloc
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 导航初始化

- (UIView *)navigationView
{
    if (!_navigationView)
    {
        _navigationView = [[CMNavigationBar alloc] initWithNavigationBarType:CMNavigationBarTypeDefault centerYOffset:10];
        _navigationView.backgroundColor = self.backColor;
        _navigationView.title = CMLocalizedString(@"Perferences", nil);
        _navigationView.delegate = self;
        [self.view addSubview:_navigationView];
        
        UIView* theLineView = [[UIView alloc] init];
        theLineView.backgroundColor = COLOR_WITH_RGBA(38, 42, 64, 1);
        [self.view addSubview:theLineView];
        
        [theLineView mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(_navigationView.mas_bottom).with.offset(-1);
             make.width.equalTo(self.view.mas_width);
             make.height.equalTo(@(0.5));
         }];
    }
    
    return _navigationView;
}

-(void)navBarBackButtonDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 列表数据初始化

- (UITableView*) laungugeTableView
{
    if (!_laungugeTableView)
    {
        [self setupTableViewCell];
        
        _laungugeTableView = [[UITableView alloc] init];
        
        _laungugeTableView.rowHeight = kScreenHeight/9.60;
        _laungugeTableView.backgroundColor = self.backColor;
        _laungugeTableView.separatorColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
        _laungugeTableView.delegate = self;
        _laungugeTableView.dataSource = self;
        
        [self.view addSubview:_laungugeTableView];
        
        [_laungugeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_navigationView.mas_bottom);
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_height);
        }];
    }
    
    return _laungugeTableView;
}

- (void) setupTableViewCell
{
    NSMutableArray* mutArray = [NSMutableArray array];
    PerferencesTableViewCell* one = [[PerferencesTableViewCell alloc] init];
    [one.itemSwitch setOn:self.settingData.autoCapital];
    one.titleTop = CMLocalizedString(@"Auto_capitalization", nil);
    one.titleBottom = CMLocalizedString(@"Capitalize_the_first_word_of_each_sentence", nil);
    @weakify(self)
    [one.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         self.settingData.autoCapital = on;
         if (on == YES) {
             [CMHostInfoc reportCheetahkeyboard_set_gene_capWithValue:1];
         }else{
             [CMHostInfoc reportCheetahkeyboard_set_gene_capWithValue:2];
         }
     }];
    [mutArray addObject:one];
    
    PerferencesTableViewCell* two = [[PerferencesTableViewCell alloc] init];
    [two.itemSwitch setOn:self.settingData.doubleSpacePeriod];
    two.titleTop = CMLocalizedString(@"Double_space_Period", nil);
    two.titleBottom = CMLocalizedString(@"Double_tap_on_spacebar_inserts_a_period", nil);
    [two.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         self.settingData.doubleSpacePeriod = on;
         if (on == YES)
         {
             [CMHostInfoc reportCheetahkeyboard_set_gene_doub:1];
         }
         else
         {
             [CMHostInfoc reportCheetahkeyboard_set_gene_doub:2];
         }
     }];
    [mutArray addObject:two];
    
    PerferencesTableViewCell* three = [[PerferencesTableViewCell alloc] init];
    [three.itemSwitch setOn:self.settingData.openKeyboardSound];
    three.titleTop = CMLocalizedString(@"openSound", nil);
    three.titleBottom = CMLocalizedString(@"openKeyboardSound", nil);
    [three.itemSwitch setChangeHandler:^(BOOL on)
    {
        @stronglize(self)
        self.settingData.openKeyboardSound = on;
        if (on == YES) {
            [CMHostInfoc reportCheetahkeyboard_set_gene_sound:1];
        }else{
            [CMHostInfoc reportCheetahkeyboard_set_gene_sound:2];
        }
    }];
    [mutArray addObject:three];
    
    PerferencesTableViewCell* vibration = [[PerferencesTableViewCell alloc] init];
    [vibration.itemSwitch setOn:self.settingData.vibrationEnable];
    vibration.titleTop = CMLocalizedString(@"vibration_enable", nil);
    vibration.titleBottom = CMLocalizedString(@"vibration_enable_description", nil);
    [vibration.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         self.settingData.vibrationEnable = on;
         if (on == YES) {
             [CMHostInfoc reportCheetahkeyboard_set_gene_vibra:1];
         }else{
             [CMHostInfoc reportCheetahkeyboard_set_gene_vibra:2];
         }
     }];
    if (![UIDevice isIpadPro])
    {
        [mutArray addObject:vibration];
    }

    
#ifndef SCHEME
    PerferencesTableViewCell* four = [[PerferencesTableViewCell alloc] init];
    [four.itemSwitch setOn:self.settingData.isSlideInputEnable];
    four.titleTop = CMLocalizedString(@"Swipe Typing", nil);
    four.titleBottom = CMLocalizedString(@"Input a word by sliding through the letters", nil);
    [four.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         self.settingData.slideInputEnable = on;
     }];
    [mutArray addObject:four];
    
#ifdef DEBUG
    PerferencesTableViewCell* five = [[PerferencesTableViewCell alloc] init];
    [five.itemSwitch setOn:self.settingData.isTensorFlowABTestEnable];
    five.titleTop = @"TensorFow ABTest";
    five.titleBottom = @"TensorFow ABTest";
    [five.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         self.settingData.tensorFlowABTestEnable = on;
     }];
    [mutArray addObject:five];
#endif

#endif
    
    self.collectionArray = [mutArray copy];
}


#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:  return self.collectionArray.count;
        default: return 0;
    };
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
            return [self.collectionArray objectAtIndex:indexPath.row];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PerferencesTableViewCell* theCell = [self.collectionArray objectAtIndex:indexPath.row];
    [theCell.itemSwitch setOn:!theCell.itemSwitch.on animated:YES sendActions:YES];
}

@end
