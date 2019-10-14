//
//  TextCorrectionViewController.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "TextCorrectionViewController.h"
#import "TextCorrectionTableViewCell.h"
#import "CMNavigationBar.h"
#import "CMBizHelper.h"
#import "SettingData.h"

static NSInteger SHOW_CORRECTION_SUGGESTIONS = 0;
static NSInteger AUTO_CORRECTION_SUGGESTIONS = 1;
static NSInteger NEXT_WORD_SUGGESTIONS = 2;
static NSInteger HISTORY_SUGGESTIONS = 3;

@interface TextCorrectionViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CMNavigationBarDelegate>

@property (nonatomic, strong) UITableView* laungugeTableView;
@property (strong, nonatomic) UIColor *backColor;
@property(nonatomic) NSArray* collectionArray;

@property (nonatomic, strong) CMNavigationBar* navigationView;

@property(nonatomic) SettingData* settingData;

@end

@implementation TextCorrectionViewController

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
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
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
        _navigationView.title = CMLocalizedString(@"Text_Correction", nil);
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
    TextCorrectionTableViewCell* one = [[TextCorrectionTableViewCell alloc] init];
    [one.itemSwitch setOn:self.settingData.showCorrectionSuggestions];
    one.titleTop = CMLocalizedString(@"Show_correction_suggestions", nil);
    one.titleBottom = CMLocalizedString(@"Display_suggested_word_while_typing", nil);
    @weakify(self)
    [one.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         [self updateSettingData:on byIndex:SHOW_CORRECTION_SUGGESTIONS];

     }];
    
    TextCorrectionTableViewCell* two = [[TextCorrectionTableViewCell alloc] init];
    [two.itemSwitch setOn:self.settingData.autoCorrectionSuggestions];
    two.titleTop = CMLocalizedString(@"Auto_correction_suggestions", nil);
    two.titleBottom = CMLocalizedString(@"Spacebar_and_punctuation_automatically", nil);
    [self updateAutoCorrectionSwitchState:two.itemSwitch];
    
    [two.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         [self updateSettingData:on byIndex:AUTO_CORRECTION_SUGGESTIONS];

     }];
    
    TextCorrectionTableViewCell* three = [[TextCorrectionTableViewCell alloc] init];
    [three.itemSwitch setOn:self.settingData.nextWordSuggestions];
    three.titleTop = CMLocalizedString(@"Next_word_Suggestions", nil);
    three.titleBottom = CMLocalizedString(@"Use_the_previous_word", nil);
    [three.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         [self updateSettingData:on byIndex:NEXT_WORD_SUGGESTIONS];


     }];
    
    
    TextCorrectionTableViewCell* four = [[TextCorrectionTableViewCell alloc] init];
    [four.itemSwitch setOn:self.settingData.historySuggestions];
    four.titleTop = CMLocalizedString(@"History_Suggestions", nil);
    four.titleBottom = CMLocalizedString(@"Use_the_History_word", nil);
    [four.itemSwitch setChangeHandler:^(BOOL on)
     {
         @stronglize(self)
         [self updateSettingData:on byIndex:HISTORY_SUGGESTIONS];
         
     }];
    
    
    self.collectionArray = @[one,two,three,four];
}

- (void) updateSettingData : (BOOL)isChecked byIndex:(NSInteger) theIndex
{
    if (theIndex == SHOW_CORRECTION_SUGGESTIONS)
    {
        self.settingData.showCorrectionSuggestions = isChecked;
        TextCorrectionTableViewCell* autoCorrectionCell = [self.collectionArray objectAtIndex:AUTO_CORRECTION_SUGGESTIONS];
        [self updateAutoCorrectionSwitchState:autoCorrectionCell.itemSwitch];
        
        if (isChecked == YES) {
            [CMHostInfoc reportCheetahkeyboard_set_corr_showcorrWithValue:1];
        }else{
            [CMHostInfoc reportCheetahkeyboard_set_corr_showcorrWithValue:2];
        }
    }else if (theIndex == AUTO_CORRECTION_SUGGESTIONS)
    {
        self.settingData.autoCorrectionSuggestions = isChecked;
        if (isChecked == YES) {
            [CMHostInfoc reportCheetahkeyboard_set_corr_autocorrWithValue:1];
        }else{
            [CMHostInfoc reportCheetahkeyboard_set_corr_autocorrWithValue:2];
        }
    }else if (theIndex == NEXT_WORD_SUGGESTIONS)
    {
        self.settingData.nextWordSuggestions = isChecked;
        if (isChecked == YES) {
            [CMHostInfoc reportCheetahkeyboard_set_corr_nextsuggWithValue:1];
        }else{
            [CMHostInfoc reportCheetahkeyboard_set_corr_nextsuggWithValue:2];
        }
    }else if(theIndex == HISTORY_SUGGESTIONS){
        self.settingData.historySuggestions = isChecked;
        [CMHostInfoc reportCheetahkeyboard_set_corr_history:isChecked];
    }
}

- (void) updateAutoCorrectionSwitchState:(CMUISwitch*) autoCorrectionSwitch
{
    if (self.settingData.showCorrectionSuggestions)
    {
        autoCorrectionSwitch.thumbImage = [UIImage imageNamed:@"Switch_Toggle_On"];
        autoCorrectionSwitch.thumbHighlightImage = [UIImage imageNamed:@"Switch_Toggle_Off"];
        autoCorrectionSwitch.trackMaskImage = [UIImage imageNamed:@"Switch_Back_Off"];
        autoCorrectionSwitch.trackImageOn = [UIImage imageNamed:@"Switch_Back_On"];
        autoCorrectionSwitch.trackImageOff = [UIImage imageNamed:@"Switch_Back_Off"];
        autoCorrectionSwitch.isSwitchClickable = YES;
    }
    else
    {
        autoCorrectionSwitch.thumbImage = [UIImage imageNamed:@"Switch_Toggle_Off"];
        autoCorrectionSwitch.thumbHighlightImage = [UIImage imageNamed:@"Switch_Toggle_Off"];
        autoCorrectionSwitch.trackMaskImage = [UIImage imageNamed:@"Switch_Back_Off"];
        autoCorrectionSwitch.trackImageOn = [UIImage imageNamed:@"Switch_Back_Off"];
        autoCorrectionSwitch.trackImageOff = [UIImage imageNamed:@"Switch_Back_Off"];
        autoCorrectionSwitch.isSwitchClickable = NO;
    }
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
    
    TextCorrectionTableViewCell* theCell = [self.collectionArray objectAtIndex:indexPath.row];
    if (!self.settingData.showCorrectionSuggestions && indexPath.row == AUTO_CORRECTION_SUGGESTIONS)
    {
        return;
    }
    [theCell.itemSwitch setOn:!theCell.itemSwitch.on animated:YES ];
    [self updateSettingData:theCell.itemSwitch.on byIndex:indexPath.row];
}


@end
