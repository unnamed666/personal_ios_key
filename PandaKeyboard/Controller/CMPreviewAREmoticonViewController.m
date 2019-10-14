//
//  CMPreviewAREmoticonViewController.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/10/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMPreviewAREmoticonViewController.h"
#import <YYImage/YYImage.h>
#import "CMHostInfoc.h"

@interface CMPreviewAREmoticonViewController ()

@property (nonatomic, strong) NSURL *gifFilePath;

@property (nonatomic, strong) UIImageView *previewAREmoticonView;
@property (nonatomic, strong) UIView *toolBarView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *makeAREmoticonDoneBtn;

@end

@implementation CMPreviewAREmoticonViewController

#pragma mark - init
- (instancetype)initWithGifFilePath:(NSURL *)gifFilePath
{
    if (self = [self init]) {
        self.gifFilePath = gifFilePath;
    }
    return self;
}
   
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSData *data = [NSData dataWithContentsOfURL:self.gifFilePath];
    UIImage *image = [YYImage imageWithData:data];;
    CGSize imageSize = image ? image.size : CGSizeMake(1, 1);
    
    self.toolBarView.frame = CGRectMake(0, self.view.bounds.size.height - 160.0f, self.view.bounds.size.width, 160.0f);
    self.backBtn.frame = CGRectMake(44.0f, 65.0f, 30.0f, 30.0f);
    self.makeAREmoticonBtn.frame = CGRectMake(( self.view.bounds.size.width - 70.0f ) / 2 , 45.0f, 70.0f, 70.0f);
    CGFloat previewAREmoticonViewWidth = self.view.bounds.size.width * 0.6;
    CGFloat previewAREmoticonViewHeight = previewAREmoticonViewWidth / imageSize.width * imageSize.height;
    self.previewAREmoticonView.frame = CGRectMake((self.view.bounds.size.width - previewAREmoticonViewWidth ) / 2, (self.toolBarView.frame.origin.y - previewAREmoticonViewHeight) / 2, previewAREmoticonViewWidth, previewAREmoticonViewWidth / imageSize.width * imageSize.height);
    
    [self.view addSubview:self.previewAREmoticonView];
    [self.view addSubview:self.toolBarView];

    [self.toolBarView addSubview:self.backBtn];
    [self.toolBarView addSubview:self.makeAREmoticonDoneBtn];
    
    if (image) {
        self.previewAREmoticonView.image = image;
//        NSString *htmlStr = [NSString stringWithFormat:@"<img src=%@ width = \"%f\" height = \"%f\" style=\"position:absolute; left:0px; top:0px; \">", self.gifFilePath.absoluteString, self.previewAREmoticonView.frame.size.width, self.previewAREmoticonView.frame.size.height];
//        [self.previewAREmoticonView loadHTMLString:htmlStr baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.makeAREmoticonDoneBtn.tag != 1000) {
        [[NSFileManager defaultManager] removeItemAtURL:self.gifFilePath error:nil];
        [CMHostInfoc reportCheetahkeyboard_ar_done_clic:1];
        [CMHostInfoc reportCheetahkeyboard_ar_show:3 classType:3];
    }else{
        [CMHostInfoc reportCheetahkeyboard_ar_done_clic:2];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - setter/getter
- (UIImageView *)previewAREmoticonView
{
    if (!_previewAREmoticonView) {
        _previewAREmoticonView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _previewAREmoticonView.userInteractionEnabled = NO;
        _previewAREmoticonView.opaque = NO;
        _previewAREmoticonView.backgroundColor = [UIColor whiteColor];
    }
    return _previewAREmoticonView;
}

- (UIView *)toolBarView
{
    if (!_toolBarView) {
        _toolBarView = [UIView new];
        _toolBarView.backgroundColor = [UIColor colorWithRed:13 / 255.0f green:18 / 255.0f blue:43 / 255.0f alpha:1.0f];
    }
    return _toolBarView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)makeAREmoticonBtn
{
    if (!_makeAREmoticonDoneBtn) {
        _makeAREmoticonDoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_makeAREmoticonDoneBtn setImage:[UIImage imageNamed:@"make_ar_emoticon_done"] forState:UIControlStateNormal];
        [_makeAREmoticonDoneBtn addTarget:self action:@selector(makeAREmoticonDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _makeAREmoticonDoneBtn;
}

#pragma mark - Action
- (void)back:(UIButton *)sender
{
    [[NSFileManager defaultManager] removeItemAtURL:self.gifFilePath error:nil];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)makeAREmoticonDone:(UIButton *)sender
{
    self.makeAREmoticonDoneBtn.tag = 1000;// 用来标识点击了制作完成按钮
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CMLocalizedString(@"You can use the AR-Emoticons in your Cheetah Keyboard NOW!", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:CMLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CMHostInfoc reportCheetahkeyboard_ar_show:6 classType:3];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:NO completion:nil];
}

#pragma mark - Autorotate
- (BOOL) shouldAutorotate
{
    return NO;
}

@end
