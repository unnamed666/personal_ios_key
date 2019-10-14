//
//  CMFeedBackViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/5/30.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMFeedBackViewController.h"
#import "CMPlaceholderTextView.h"
#import "UIColor+HexColors.h"
#import "CMHostRequestFactory.h"
#import <Photos/Photos.h>
#import "CMNavigationBar.h"
#import "CMBizHelper.h"
#import "MBProgressHUD+Toast.h"
#import "CMOReachability.h"

//@implementation CMCustomLabel
//- (void)drawTextInRect:(CGRect)rect {
//    UIEdgeInsets insets = {0, 15, 0, 5};
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
//}
//@end
@implementation CMCustomBgView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint p = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, p)) {
                view = subView;
            }
        }
    }
    return view;
}
@end

@interface CMFeedBackViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UIScrollViewDelegate,CMNavigationBarDelegate>
{
    CMNavigationBar * _navBar;
    
    UIScrollView * _bgView;
    UIView * _containerView;//适应ipad,为UIScrollView加的
    UIButton * _backButton;
    CMPlaceholderTextView * _textView;
    UIButton * _addPicBtn;
    UIImageView * _pickImageView;
    UITextField * _connectTextField;    
    UIButton * _sendButton;
    
    
    NSMutableArray * _uploadImageViewArray;
    NSMutableArray * _imageArray;
    NSMutableArray * _picBgViewArray;
    NSMutableArray<UIButton*> * _deletePicButtonArray;
    
    NSURLSessionDataTask* _task;
    
    MBProgressHUD * _hud;
    
    //UILabel * _connectLabel;
    //CMCustomLabel * _connectMethodLabel;
    //UIButton * _chooseMethodBtn;
    //UITableView * _methodTableView;
    //NSArray * _contactMethodDataArray;
    
}

@end

@implementation CMFeedBackViewController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR_WITH_RGBA(27, 31, 55, 1);
    
    [self setupUI];
    
//    if (!_contactMethodDataArray) {
//        _contactMethodDataArray = [NSArray arrayWithObjects:@"Email",@"Phone",@"Blog", nil];
//    }

    if (!_uploadImageViewArray) {
        _uploadImageViewArray = [NSMutableArray array];
    }
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    
    if (!_picBgViewArray) {
        _picBgViewArray = [NSMutableArray array];
    }
    if (!_deletePicButtonArray) {
        _deletePicButtonArray = [NSMutableArray array];
    }
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_inSource == 2) {
        // 特殊处理 2代表点击键盘的Feedback按钮跳到的反馈页，此时需要强制重载下键盘，否则键盘显示的是设置页而非字符键盘
        [_textView becomeFirstResponder];
        [_textView resignFirstResponder];
        [_textView becomeFirstResponder];
    }else{
        [_textView becomeFirstResponder];
    }
}

-(void)dealloc
{
    if (_task) {
        [_task cancel];
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

#pragma mark - CMNavigationBarDelegate method
- (void)navBarBackButtonDidClick
{
    [_textView resignFirstResponder];
    [_connectTextField resignFirstResponder];

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)setupUI
{
    _navBar = [[CMNavigationBar alloc] initWithNavigationBarType:CMNavigationBarTypeDefault centerYOffset:10];
    _navBar.title = CMLocalizedString(@"Feedback", nil);
    _navBar.delegate = self;
    [self.view addSubview:_navBar];
    
    _bgView = [[UIScrollView alloc] init];
    _bgView.delegate = self;
    _bgView.scrollEnabled = YES;
    _bgView.alwaysBounceVertical = YES;
    _bgView.showsVerticalScrollIndicator = NO;
    _bgView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_bgView];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(_navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    _containerView = [[UIView alloc] init];
    [_bgView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_bgView);
        make.width.equalTo(_bgView);
    }];
    
    _textView = [[CMPlaceholderTextView alloc] init];
    _textView.backgroundColor = COLOR_WITH_RGBA(27, 31, 55, 1);
    _textView.font = [CMBizHelper getFontWithSize:13];
    _textView.textColor = COLOR_WITH_RGBA(141, 142, 156, 1);
    _textView.placeholder = CMLocalizedString(@"FeedbackPlaceholder", nil);
    _textView.layer.borderColor = COLOR_WITH_RGBA(64, 68, 93, 1).CGColor;
    _textView.layer.borderWidth = 1.0;
    _textView.layer.cornerRadius = 7.0;
    _textView.delegate = self;
//    [_textView becomeFirstResponder];
    [_containerView addSubview:_textView];
    
    if (self.view.frame.size.width > self.view.frame.size.height) {
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_containerView.mas_leading).offset(15);
            make.trailing.equalTo(_containerView.mas_trailing).offset(-15);
            make.top.equalTo(_containerView.mas_top).offset(15);
            make.height.equalTo(@(SCREEN_HEIGHT * 0.15));
        }];
    }else{
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_containerView.mas_leading).offset(15);
            make.trailing.equalTo(_containerView.mas_trailing).offset(-15);
            make.top.equalTo(_containerView.mas_top).offset(15);
            make.height.equalTo(@(SCREEN_HEIGHT * 0.26));
        }];
    }
    
    _addPicBtn = [[UIButton alloc] init];
    [_addPicBtn setBackgroundImage:[UIImage imageNamed:@"addPicBackGround"] forState:UIControlStateNormal];
    [_addPicBtn addTarget:self action:@selector(addPicBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_addPicBtn];
    
    [_addPicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_leading).offset(14);
        make.top.equalTo(_textView.mas_bottom).offset(SCREEN_HEIGHT * 0.02);
        make.size.mas_equalTo(CGSizeMake(SCREEN_HEIGHT * 0.09, SCREEN_HEIGHT * 0.09));
    }];
    
//    _connectLabel = [[UILabel alloc] init];
//    _connectLabel.text = @"Please select your preferred contact method";
//    _connectLabel.textColor = [UIColor whiteColor];
//    [_bgView addSubview:_connectLabel];
//    
//    [_connectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(_textView.mas_leading);
//        make.trailing.equalTo(_textView.mas_trailing);
//        make.height.greaterThanOrEqualTo(@0);
//        make.top.equalTo(_addPicBtn.mas_bottom).offset(25);
//    }];
    
//    _connectMethodLabel = [[CMCustomLabel alloc] init];
//    _connectMethodLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
//    _connectMethodLabel.text = @"Email";
//    _connectMethodLabel.textColor = [UIColor whiteColor];
//    _connectMethodLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _connectMethodLabel.layer.borderWidth = 1.0;
//    _connectMethodLabel.layer.cornerRadius = 5.0;
//    _connectMethodLabel.clipsToBounds = YES;
//    _connectMethodLabel.userInteractionEnabled = YES;
//    [_bgView addSubview:_connectMethodLabel];
//    
//    [_connectMethodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(_textView.mas_leading);
//        make.trailing.equalTo(_textView.mas_trailing);
//        make.top.equalTo(_connectLabel.mas_bottom).offset(15);
//        make.height.equalTo(@40);
//    }];
    
//    _chooseMethodBtn = [[UIButton alloc] init];
//    _chooseMethodBtn.backgroundColor = [UIColor orangeColor];
//    [_chooseMethodBtn addTarget:self action:@selector(chooseMethodBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_connectMethodLabel addSubview:_chooseMethodBtn];
//    
//    [_chooseMethodBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_connectMethodLabel.mas_centerY);
//        make.trailing.equalTo(_connectMethodLabel.mas_trailing).offset(-5);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//    }];
    
    _connectTextField = [[UITextField alloc] init];
    _connectTextField.backgroundColor = COLOR_WITH_RGBA(27, 31, 55, 1);
    _connectTextField.textColor = COLOR_WITH_RGBA(255, 255, 255, 1);
    _connectTextField.font = [CMBizHelper getFontWithSize:11];
    _connectTextField.placeholder = CMLocalizedString(@"E-Mail_Address", nil);
    [_connectTextField setValue:COLOR_WITH_RGBA(141, 142, 156, 1) forKeyPath:@"_placeholderLabel.textColor"];
    _connectTextField.layer.borderColor = COLOR_WITH_RGBA(64, 68, 93, 1).CGColor;
    _connectTextField.layer.borderWidth = 1.0;
    _connectTextField.layer.cornerRadius = 5.0;
    _connectTextField.clipsToBounds = YES;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, SCREEN_HEIGHT * 0.06)];
    _connectTextField.leftView = paddingView;
    _connectTextField.leftViewMode = UITextFieldViewModeAlways;
    [_containerView addSubview:_connectTextField];
    
    if (self.view.frame.size.width > self.view.frame.size.height) {
        [_connectTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_containerView.mas_leading).offset(15);
            make.trailing.equalTo(_containerView.mas_trailing).offset(-15);
            make.top.equalTo(_addPicBtn.mas_bottom).offset(SCREEN_HEIGHT * 0.02);
            make.height.equalTo(@(SCREEN_HEIGHT * 0.03));
        }];
    }else{
        [_connectTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_containerView.mas_leading).offset(15);
            make.trailing.equalTo(_containerView.mas_trailing).offset(-15);
            make.top.equalTo(_addPicBtn.mas_bottom).offset(SCREEN_HEIGHT * 0.02);
            make.height.equalTo(@(SCREEN_HEIGHT * 0.06));
        }];
    }
    
    _sendButton = [[UIButton alloc] init];
    UIImage * sendNormalImage = [UIImage imageNamed:@"sendNormal"];
    UIImage * sendHighlighted = [UIImage imageNamed:@"sendBtnHighlighted"];
    
    [_sendButton setBackgroundImage:[sendNormalImage stretchableImageWithLeftCapWidth:sendNormalImage.size.width * 0.5 topCapHeight:sendNormalImage.size.height * 0.5] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[sendHighlighted stretchableImageWithLeftCapWidth:sendHighlighted.size.width * 0.5 topCapHeight:sendHighlighted.size.height * 0.5] forState:UIControlStateHighlighted];
    [_sendButton setTitle:CMLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [_sendButton setTitleColor:COLOR_WITH_RGBA(9, 17, 43, 1) forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [CMBizHelper getFontWithSize:17];
    //_sendButton.enabled = NO;
    [_sendButton addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_sendButton];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_containerView.mas_leading).offset(15);
        make.trailing.equalTo(_containerView.mas_trailing).offset(-15);
        make.top.equalTo(_connectTextField.mas_bottom).offset(SCREEN_HEIGHT * 0.04);
        make.bottom.equalTo(_bgView.mas_bottom);
        //make.height.equalTo(@(SCREEN_HEIGHT * 0.09));
    }];
    
}


- (void)sendBtnClick:(UIButton *)sendBtn
{
    if ([CMOReachability status] == kNavNetWorkNotReachable){//无网
        _hud = [MBProgressHUD showMessage:CMLocalizedString(@"noNet", nil) toView:self.view seconds:1.0];
            return;
    }else{//有网
        if ([self isEmytp:_textView.text] == NO || [self isEmytp:_connectTextField.text] == NO || _imageArray.count > 0) {
            [self requestFeedback];
        }else{
            
        }

    }
}

- (void)requestFeedback
{
    if (_task) {
        [_task cancel];
    }
    __weak typeof(self) weakSelf = self;
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString * contact = _connectTextField.text ? _connectTextField.text : @"";
    NSString * content = _textView.text ? _textView.text : @"";
    
    _task = [CMHostRequestFactory feedbackRequestWithContact:contact content:content imageArray:_imageArray ? _imageArray :nil completeBlock:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        
        [_hud hideAnimated:YES];
        [_hud removeFromSuperview];
        
        if (errorMsg) {
            kLogError(@"%@", errorMsg);
            _hud = [MBProgressHUD showMessage:CMLocalizedString(@"FeedbackFail", nil) toView:self.view seconds:1.0 completion:^(BOOL finished) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }] ;
        }
        else {
            kLogInfo(@"%@", dicOrArray);
            NSDictionary * responseDic = dicOrArray;
            if ([responseDic.allKeys containsObject:@"code"]) {
                NSString *code = [NSString stringWithFormat:@"%@",responseDic[@"code"]];
                
                if ([code isEqualToString:@"0"]) {
                    _hud = [MBProgressHUD showMessage:CMLocalizedString(@"FeedbackSuccess", nil) toView:self.view seconds:1.0 completion:^(BOOL finished) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }] ;
                    
                }else{
                    _hud = [MBProgressHUD showMessage:CMLocalizedString(@"FeedbackFail", nil) toView:self.view seconds:1.0 completion:^(BOOL finished) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }] ;
                }
            }
        }
        
    }];
    
    [_task resume];

}

- (void)addPicBtnDidClick:(UIButton *)addPicBtn
{
    [_textView resignFirstResponder];
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction * takePhotoAction = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UIImagePickerController * pickVC = [[UIImagePickerController alloc] init];
//        pickVC.delegate = self;
//        pickVC.allowsEditing = NO;
//        pickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentViewController:pickVC animated:YES completion:nil];
//    }];
    UIAlertAction * libraryAction = [UIAlertAction actionWithTitle:CMLocalizedString(@"Choose_from_library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateUIWithStatus:status];
                        
                    });
                }];
                
            });
        }
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:CMLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [alertVC addAction:takePhotoAction];
//        [alertVC addAction:libraryAction];
//    }else{
        [alertVC addAction:libraryAction];
    //}
    
    [alertVC addAction:cancelAction];
    
    if (![CMBizHelper isiPhone]) {//ipad
        UIPopoverPresentationController * popPresenterVC = alertVC.popoverPresentationController;
        popPresenterVC.sourceView = addPicBtn;
        popPresenterVC.sourceRect = addPicBtn.bounds;
        
    }

    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void)updateUIWithStatus:(PHAuthorizationStatus)status
{
    if (status == PHAuthorizationStatusDenied) {
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:CMLocalizedString(@"No_access", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:CMLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }else if (status == PHAuthorizationStatusAuthorized){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self showImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showImage:(UIImage *)image
{
    if (image) {
        
    [_imageArray addObject:image];
        
    CMCustomBgView * picBgView = [[CMCustomBgView alloc] init];
    //picBgView.backgroundColor = [UIColor redColor];
    [_bgView addSubview:picBgView];
    [_picBgViewArray addObject:picBgView];
        
    
    UIImageView * picImageView = [[UIImageView alloc] init];
    picImageView.contentMode = UIViewContentModeScaleToFill;
    //picImageView.backgroundColor = [UIColor redColor];
    picImageView.userInteractionEnabled = YES;
    picImageView.layer.cornerRadius = 7.0;
    picImageView.clipsToBounds = YES;
    [picBgView addSubview:picImageView];
    [_uploadImageViewArray addObject:picImageView];
        
    [picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(picBgView.mas_leading);
        make.top.equalTo(picBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(SCREEN_HEIGHT * 0.09, SCREEN_HEIGHT * 0.09));
    }];
    
    UIButton * deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_HEIGHT * 0.09 - 25, -10, 44, 44)];
    //deleteBtn.backgroundColor = [UIColor redColor];
    [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 18, 25, 10)];
    [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [picBgView addSubview:deleteBtn];
    [_deletePicButtonArray addObject:deleteBtn];
        
    [self updatePicFrame];
        
    }
}

- (void)updatePicFrame
{
    if (_uploadImageViewArray.count > 0) {
        
    for (int i = 0; i < _uploadImageViewArray.count; i++) {
       
        CMCustomBgView * picBgView = _picBgViewArray[i];
        UIImageView * picImageView = _uploadImageViewArray[i];
        
        CGFloat picBgViewWidth = SCREEN_HEIGHT * 0.09;
        CGFloat picBgViewHeight = SCREEN_HEIGHT * 0.09;
        CGFloat picBgViewX = 15 + i * (picBgViewWidth + 20);
    
        [picBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_containerView.mas_leading).offset(picBgViewX);
            make.top.equalTo(_textView.mas_bottom).offset(SCREEN_HEIGHT * 0.02);
            make.size.mas_equalTo(CGSizeMake(picBgViewWidth, picBgViewHeight));
        }];
        picImageView.image = _imageArray[i];
        [_addPicBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(picBgView.mas_trailing).offset(20);
            make.top.equalTo(_textView.mas_bottom).offset(SCREEN_HEIGHT * 0.02);
            make.size.mas_equalTo(CGSizeMake(SCREEN_HEIGHT * 0.09, SCREEN_HEIGHT * 0.09));
        }];
        
        if (i == 2) {
            _addPicBtn.hidden = YES;
        }else{
            _addPicBtn.hidden = NO;
        }
        _deletePicButtonArray[i].tag = i;
    }
    }else{
        [_addPicBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_containerView.mas_leading).offset(14);
            make.top.equalTo(_textView.mas_bottom).offset(SCREEN_HEIGHT * 0.02);
            make.size.mas_equalTo(CGSizeMake(SCREEN_HEIGHT * 0.09, SCREEN_HEIGHT * 0.09));
        }];
    }
    
}
- (void)deleteBtnClick:(UIButton *)deleteBtn
{
    NSInteger index = deleteBtn.tag;

    UIImageView * imageView = _uploadImageViewArray[index];
    CMCustomBgView * picBgView = _picBgViewArray[index];
    picBgView.hidden = YES;
    imageView.hidden = YES;
    
    [_imageArray removeObjectAtIndex:index];
    [_picBgViewArray removeObjectAtIndex:index];
    [_uploadImageViewArray removeObjectAtIndex:index];
    [_deletePicButtonArray removeObjectAtIndex:index];
    [picBgView removeFromSuperview];
    //[imageView removeFromSuperview];
    [self updatePicFrame];
}

- (BOOL)isEmytp:(NSString *)string
{
    if (!string) {
        return YES;
    }else{
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [string stringByTrimmingCharactersInSet:set];
        if (trimedString.length == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}


#pragma mark - UITextView Delegate Methods

//- (void)textViewDidChange:(UITextView *)textView {
//    if(textView.text.length > 0){
//        _sendButton.enabled = YES;
//    }else {
//        _sendButton.enabled = NO;
//    }
//}

#pragma mark - UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_textView resignFirstResponder];
    [_connectTextField resignFirstResponder];
}

#pragma mark - choose contact method
//- (void)chooseMethodBtnClick:(UIButton *)chooseBtn
//{
//    chooseBtn.selected = !chooseBtn.selected;
//    if (_methodTableView) {
//        [_methodTableView removeFromSuperview];
//    }
//    _methodTableView = [[UITableView alloc] init];
//    _methodTableView.dataSource = self;
//    _methodTableView.delegate = self;
//    _methodTableView.tableFooterView = [[UIView alloc] init];
//    _methodTableView.hidden = YES;
//    [self.view addSubview:_methodTableView];
//
//    [_methodTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(_connectMethodLabel.mas_leading);
//        make.trailing.equalTo(_connectMethodLabel.mas_trailing);
//        make.top.equalTo(_connectMethodLabel.mas_bottom).offset(5);
//        make.height.equalTo(@120);
//    }];
//
//    _methodTableView.hidden = !chooseBtn.selected;
//
//}

#pragma mark - UITableView DataSource Methods
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return _contactMethodDataArray.count;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString * ID = @"cellID";
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//    }
//    cell.textLabel.text = _contactMethodDataArray[indexPath.row];
//    return cell;
//}

#pragma mark - UITableView Delegate Methods

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    _connectMethodLabel.text = _contactMethodDataArray[indexPath.row];
//    _methodTableView.hidden = YES;
//    _chooseMethodBtn.selected = NO;
//    
//}

@end
