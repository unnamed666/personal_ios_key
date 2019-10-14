//
//  LanguageViewController.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageTableViewCell.h"
#import "CMNavigationBar.h"
#import "CMBizHelper.h"
#import "CMGroupDataManager.h"
#import "SettingData.h"

@interface LanguageViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CMNavigationBarDelegate>

@property (nonatomic, strong) UITableView* laungugeTableView;
@property (strong, nonatomic) UIColor *backColor;
@property (nonatomic, copy) NSArray *languagesTypeArray;
@property (nonatomic, copy) NSArray *titleTopArray;
@property (nonatomic, copy) NSArray *titleBottomArray;

@property (nonatomic, strong) CMNavigationBar* navigationView;

@property(nonatomic) SettingData* mainSettingData;
@property(nonatomic) NSMutableArray* languageArray;

@property(nonatomic) CGFloat screenMaxSize;

@end

@implementation LanguageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    
    self.mainSettingData = [[SettingData alloc] init];
    self.languageArray = [self.mainSettingData.languageArray mutableCopy];
    self.screenMaxSize = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;

    [self navigationView];
    [self laungugeTableView];
    
    self.languagesTypeArray = @[@(CMKeyboardLanguageTypeEnglishUnitedState),
                                @(CMKeyboardLanguageTypeSpanish),
                                @(CMKeyboardLanguageTypeIndonesian),
                                @(CMKeyboardLanguageTypeAzerbaijani),
                                @(CMKeyboardLanguageTypeCatalan),
                                @(CMKeyboardLanguageTypeCzech),
                                @(CMKeyboardLanguageTypeDanish),
                                @(CMKeyboardLanguageTypeGerman),
                                @(CMKeyboardLanguageTypeEstonian),
                                @(CMKeyboardLanguageTypeFinnish),
                                @(CMKeyboardLanguageTypeFrench),
                                @(CMKeyboardLanguageTypeCroatian),
                                @(CMKeyboardLanguageTypeHungarian),
                                @(CMKeyboardLanguageTypePortuguese),
                                @(CMKeyboardLanguageTypeMalay),
                                @(CMKeyboardLanguageTypeFilipino),
                                @(CMKeyboardLanguageTypeTurkish),
                                @(CMKeyboardLanguageTypeItalian),
                                @(CMKeyboardLanguageTypePolish),
                                @(CMKeyboardLanguageTypeRomanian),
                                @(CMKeyboardLanguageTypeDutch),
                                @(CMKeyboardLanguageTypeSlovak),
                                @(CMKeyboardLanguageTypeLatvian),
                                @(CMKeyboardLanguageTypeNorwegianBokmal),
                                @(CMKeyboardLanguageTypeSwedish),
                                @(CMKeyboardLanguageTypeRussian),
                                @(CMKeyboardLanguageTypeBelarusian),
                                @(CMKeyboardLanguageTypeUkrainian),
                                @(CMKeyboardLanguageTypeSerbian),
                                @(CMKeyboardLanguageTypeBulgarian),
                                @(CMKeyboardLanguageTypeMacedonian),
                                @(CMKeyboardLanguageTypeArabic)];
    self.titleTopArray = @[@"English", @"Español", @"Indonesia", @"Azərbaycan",//1
                           @"Català", @"Čeština", @"Dansk", @"Deutsch",//2
                           @"Eesti", @"Suomi", @"Français", @"Hrvatski",//3
                           @"Magyar", @"Português", @"Melayu", @"Tagalog",//4
                           @"Türkçe", @"Italiano", @"Polski", @"Română",//5
                           @"Nederlands", @"Slovenčina", @"Latviešu", @"Norsk bokmål",//6
                           @"Svenska", @"русский", @"Беларуская", @"Українська",//7
                           @"Српски", @"български", @"Македонски",@"العربية"];
    
    self.titleBottomArray = @[@"English", @"Spanish", @"Indonesian", @"Azerbaijani",
                              @"Catalan", @"Czech", @"Danish", @"German",
                              @"Estonian", @"Finnish", @"French", @"Croatian",
                              @"Hungarian", @"Portuguese", @"Malay", @"Filipino",
                              @"Turkish", @"Italian", @"Polish", @"Romanian",
                              @"Dutch", @"Slovak", @"Latvian", @"Norwegian Bokmal",
                              @"Swedish", @"Russian", @"Belarusian", @"Ukrainian",
                              @"Serbian", @"Bulgarian", @"Macedonian",@"Arabic"];
    
    
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
        _navigationView.title = CMLocalizedString(@"Languages", nil);
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
        _laungugeTableView = [[UITableView alloc] init];
        _laungugeTableView.rowHeight = self.screenMaxSize/9.60;
        _laungugeTableView.backgroundColor = self.backColor;
        _laungugeTableView.separatorColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
        _laungugeTableView.delegate = self;
        _laungugeTableView.dataSource = self;
        
        [self.view addSubview:_laungugeTableView];
        
        [_laungugeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_navigationView.mas_bottom);
            make.width.equalTo(self.view.mas_width);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    return _laungugeTableView;
}

- (void)updateSettingData:(BOOL)isChecked languageType:(CMKeyboardLanguageType)languageType
{
    if (isChecked)
    {
        if (![self.languageArray containsObject:@(languageType)])
        {
            [self.languageArray addObject:@(languageType)];
        }
    }
    else
    {
        if ([self.languageArray containsObject:@(languageType)])
        {
            [self.languageArray removeObject:@(languageType)];
        }
    }
    
    self.mainSettingData.languageArray = self.languageArray;
}


#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.languagesTypeArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.screenMaxSize/9.60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    LanguageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[LanguageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
        
    cell.titleTop = self.titleTopArray[indexPath.row];
    cell.titleBottom = CMLocalizedString(self.titleBottomArray[indexPath.row], nil);
    [cell.languageCheckBox setIsChecked:[self.languageArray containsObject:self.languagesTypeArray[indexPath.row]] ? YES : NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMKeyboardLanguageType languageType = (CMKeyboardLanguageType)[self.languagesTypeArray[indexPath.row] integerValue];

    LanguageTableViewCell* theCell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL checkState = !theCell.languageCheckBox.isChecked;
    NSString *language = self.titleBottomArray[indexPath.row];
    if ([self isButtonCanClick:checkState])
    {
        [self updateSettingData:checkState languageType:languageType];
        [theCell.languageCheckBox setIsChecked:checkState];
        [CMHostInfoc reportCheetahkeyboard_set_lang_chanWithValue:checkState ? 1 : 2 selectlanguage:language];
    }
}


- (BOOL) isButtonCanClick : (BOOL) isCheck
{
    if (!isCheck && self.languageArray.count <= 1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
