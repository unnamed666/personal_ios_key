//
//  CMServicesPrivacyViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/12.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMServicesPrivacyViewController.h"
#import "CMNavigationBar.h"
#import "CMOReachability.h"
#import "MBProgressHUD+Toast.h"
#import <WebKit/WebKit.h>

//static NSString * servicesPrivacyUrlStr = @"https://www.cmcm.com/protocol/site/tos.html";
//static NSString * servicesPrivacyUrlStr = @"https://www.cmcm.com/protocol/site/tos.html";
static NSString* const kAgreementPageIsFirstShow = @"kAgreementPageIsFirstShow";

@interface CMServicesPrivacyViewController ()<CMNavigationBarDelegate,WKNavigationDelegate>
{
    CMNavigationBar * _navBar;
    WKWebView * _webView;
    MBProgressHUD * _hud;
}

@property (nonatomic, assign)BOOL isFirstShow;

@end

@implementation CMServicesPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _navBar = [[CMNavigationBar alloc] initWithNavigationBarType:CMNavigationBarTypeDefault centerYOffset:10];

    _navBar.title = CMLocalizedString(@"ServicesPrivacy", nil);
    _navBar.delegate = self;
    [self.view addSubview:_navBar];

    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, CMNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - CMNavigationBarHeight)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    if ([CMOReachability status] == kNavNetWorkNotReachable){//无网
        [_hud hideAnimated:YES];
        [_hud removeFromSuperview];
        _hud = [MBProgressHUD showMessage:CMLocalizedString(@"noNet", nil) toView:self.view seconds:1.0];
        return;
    }else{//有网
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_servicesPrivacyUrlStr]]];
    }
}

- (void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAgreementPageIsFirstShow] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAgreementPageIsFirstShow];
    }
    
    self.isFirstShow = [[NSUserDefaults standardUserDefaults] boolForKey:kAgreementPageIsFirstShow];
    [CMHostInfoc reportCheetahkeyboard_activate_show:2 isFirstShow:self.isFirstShow];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAgreementPageIsFirstShow];
}


#pragma mark - CMNavigationBarDelegate method
- (void)navBarBackButtonDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WKNavigationDelegate Methods
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [_hud hideAnimated:YES];
    [_hud removeFromSuperview];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [_hud hideAnimated:YES];
    [_hud removeFromSuperview];

    _hud = [MBProgressHUD showMessage:CMLocalizedString(@"netError", nil) toView:self.view seconds:1.0];
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [_hud hideAnimated:YES];
    [_hud removeFromSuperview];
    
    _hud = [MBProgressHUD showMessage:CMLocalizedString(@"netError", nil) toView:self.view seconds:1.0];

}
@end
