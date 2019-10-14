//
//  AboutViewController.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "AboutViewController.h"
#import "CMServicesPrivacyViewController.h"
#import "KeyboardMainViewController.h"
#import "CMAppConfig.h"
@interface AboutViewController ()  <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CMNavigationBarDelegate>

@property (nonatomic, strong) UITableView* laungugeTableView;
@property (strong, nonatomic) UIColor *backColor;
@property(nonatomic) NSArray* collectionArray;

@property (nonatomic, strong) CMNavigationBar* navigationView;

@end

@implementation AboutViewController

static NSString * servicesPrivacyUrlStr = @"https://www.cmcm.com/protocol/cheetah-keyboard/user_agreement.html";


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:1.0];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


#pragma mark - 导航初始化

- (UIView *)navigationView
{
    if (!_navigationView)
    {
        _navigationView = [[CMNavigationBar alloc] initWithNavigationBarType:CMNavigationBarTypeDefault centerYOffset:10];
        _navigationView.backgroundColor = self.backColor;
        _navigationView.title = CMLocalizedString(@"About", nil);
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
    AboutTableViewCell* one = [[AboutTableViewCell alloc] init];
    one.titleTop = CMLocalizedString(@"E_mail", nil);
    one.titleBottom = @"keyboard@cmcm.com";
    
    AboutTableViewCell* two = [[AboutTableViewCell alloc] init];
    two.titleTop = CMLocalizedString(@"Terms_of_Services_Privacy_Policy", nil);
    
    AboutTableViewCell* three = [[AboutTableViewCell alloc] init];
    three.titleTop = CMLocalizedString(@"Version", nil);
    three.titleBottom = [CMAppConfig appVersion];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    tapGesture.numberOfTapsRequired = 10;
    tapGesture.numberOfTouchesRequired = 1;

    [three addGestureRecognizer:tapGesture];
    
    self.collectionArray = [[NSArray alloc] initWithObjects:one, two, three, nil];
}

-(void)tapView:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    KeyboardMainViewController*  theKeyboardMain = [[KeyboardMainViewController alloc] init];
    [self.navigationController pushViewController:theKeyboardMain animated:YES];
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
    
    if (indexPath.row == 1) {
        CMServicesPrivacyViewController * servicesVC = [[CMServicesPrivacyViewController alloc] init];
        servicesVC.servicesPrivacyUrlStr = servicesPrivacyUrlStr;
        [self.navigationController pushViewController:servicesVC animated:YES];
    }
}


@end
