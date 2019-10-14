//
//  KeyboardReturnTypeViewController.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "KeyboardReturnTypeViewController.h"

@interface KeyboardReturnTypeViewController () <UIScrollViewDelegate>
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UITextField* defaultTextField;
@property (nonatomic, strong)UITextField* ASCIITextFiled;
@property (nonatomic, strong)UITextField* numberAndPuncationTextFiled;
@property (nonatomic, strong)UITextField* urlTextFiled;
@property (nonatomic, strong)UITextField* numberPadTextFiled;
@property (nonatomic, strong)UITextField* phoneTextFiled;
@property (nonatomic, strong)UITextField* namePhoneTextFiled;
@property (nonatomic, strong)UITextField* emailAddressTextFiled;
@property (nonatomic, strong)UITextField* decimalPadTextFiled;
@property (nonatomic, strong)UITextField* twitterTextFiled;
@property (nonatomic, strong)UITextField* webSearchTextFiled;
@property (nonatomic, strong)UITextField* ASCIINumerPadTextFiled;

@end

@implementation KeyboardReturnTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scrollView];
    UIView* containerView = [UIView new];
    [containerView addSubview:self.defaultTextField];
    [containerView addSubview:self.ASCIITextFiled];
    [containerView addSubview:self.numberAndPuncationTextFiled];
    [containerView addSubview:self.urlTextFiled];
    [containerView addSubview:self.numberPadTextFiled];
    [containerView addSubview:self.phoneTextFiled];
    [containerView addSubview:self.namePhoneTextFiled];
    [containerView addSubview:self.emailAddressTextFiled];
    [containerView addSubview:self.decimalPadTextFiled];
    [containerView addSubview:self.twitterTextFiled];
    [containerView addSubview:self.webSearchTextFiled];
    [containerView addSubview:self.ASCIINumerPadTextFiled];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.scrollView addGestureRecognizer:tap];
    
    [self.scrollView addSubview:containerView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.defaultTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(containerView).offset(20);
    }];
    
    [self.ASCIITextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.defaultTextField.mas_bottom).offset(20);
    }];
    
    [self.numberAndPuncationTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.ASCIITextFiled.mas_bottom).offset(20);
    }];
    
    [self.urlTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.numberAndPuncationTextFiled.mas_bottom).offset(20);
    }];
    
    [self.numberPadTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.urlTextFiled.mas_bottom).offset(20);
    }];
    
    [self.phoneTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.numberPadTextFiled.mas_bottom).offset(20);
    }];
    
    [self.namePhoneTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.phoneTextFiled.mas_bottom).offset(20);
    }];
    
    [self.emailAddressTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.namePhoneTextFiled.mas_bottom).offset(20);
    }];
    
    [self.decimalPadTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.emailAddressTextFiled.mas_bottom).offset(20);
    }];
    
    [self.twitterTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.decimalPadTextFiled.mas_bottom).offset(20);
    }];
    
    [self.webSearchTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.twitterTextFiled.mas_bottom).offset(20);
    }];
    
    [self.ASCIINumerPadTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.webSearchTextFiled.mas_bottom).offset(20);
        make.bottom.equalTo(containerView).offset(-20);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapGesture:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - getter/setter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

/*
 typedef enum {
 UIReturnKeyDefault,
 UIReturnKeyGo,
 UIReturnKeyGoogle,
 UIReturnKeyJoin,
 UIReturnKeyNext,
 UIReturnKeyRoute,
 UIReturnKeySearch,
 UIReturnKeySend,
 UIReturnKeyYahoo,
 UIReturnKeyDone,
 UIReturnKeyEmergencyCall,
 UIReturnKeyContinue NS_ENUM_AVAILABLE_IOS(9_0),
 
 UIReturnKeyDefault, 默认 灰色按钮，标有Return
 UIReturnKeyGo,      标有Go的蓝色按钮
 UIReturnKeyGoogle,标有Google的蓝色按钮，用语搜索
 UIReturnKeyJoin,标有Join的蓝色按钮
 UIReturnKeyNext,标有Next的蓝色按钮
 UIReturnKeyRoute,标有Route的蓝色按钮
 UIReturnKeySearch,标有Search的蓝色按钮
 UIReturnKeySend,标有Send的蓝色按钮
 UIReturnKeyYahoo,标有Yahoo的蓝色按钮
 UIReturnKeyYahoo,标有Yahoo的蓝色按钮
 UIReturnKeyEmergencyCall, 紧急呼叫按钮
 } UIReturnKeyType;
 */

- (UITextField *)defaultTextField {
    if (!_defaultTextField) {
        _defaultTextField = [UITextField new];
        _defaultTextField.returnKeyType = UIReturnKeyDefault;
        _defaultTextField.placeholder = @"Default/UITextAutocapitalizationTypeAllCharacters";
        _defaultTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
    return _defaultTextField;
}

- (UITextField *)ASCIITextFiled {
    if (!_ASCIITextFiled) {
        _ASCIITextFiled = [UITextField new];
        _ASCIITextFiled.returnKeyType = UIReturnKeyGo;
        _ASCIITextFiled.placeholder = @"Go/UITextAutocapitalizationTypeSentences";
        _ASCIITextFiled.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
    return _ASCIITextFiled;
}

- (UITextField *)numberAndPuncationTextFiled {
    if (!_numberAndPuncationTextFiled) {
        _numberAndPuncationTextFiled = [UITextField new];
        _numberAndPuncationTextFiled.returnKeyType = UIReturnKeyGoogle;
        _numberAndPuncationTextFiled.placeholder = @"Google/UITextAutocapitalizationTypeWords";
        _numberAndPuncationTextFiled.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    return _numberAndPuncationTextFiled;
}

- (UITextField *)urlTextFiled {
    if (!_urlTextFiled) {
        _urlTextFiled = [UITextField new];
        _urlTextFiled.returnKeyType = UIReturnKeyJoin;
        _urlTextFiled.placeholder = @"Join/UITextAutocapitalizationTypeNone";
        _urlTextFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _urlTextFiled;
}

- (UITextField *)numberPadTextFiled {
    if (!_numberPadTextFiled) {
        _numberPadTextFiled = [UITextField new];
        _numberPadTextFiled.returnKeyType = UIReturnKeyNext;
        _numberPadTextFiled.placeholder = @"UIReturnKeyNext";
    }
    return _numberPadTextFiled;
}

- (UITextField *)phoneTextFiled {
    if (!_phoneTextFiled) {
        _phoneTextFiled = [UITextField new];
        _phoneTextFiled.returnKeyType = UIReturnKeyRoute;
        _phoneTextFiled.placeholder = @"UIReturnKeyRoute";
    }
    return _phoneTextFiled;
}

- (UITextField *)namePhoneTextFiled {
    if (!_namePhoneTextFiled) {
        _namePhoneTextFiled = [UITextField new];
        _namePhoneTextFiled.returnKeyType = UIReturnKeySearch;
        _namePhoneTextFiled.placeholder = @"UIReturnKeySearch";
    }
    return _namePhoneTextFiled;
}

- (UITextField *)emailAddressTextFiled {
    if (!_emailAddressTextFiled) {
        _emailAddressTextFiled = [UITextField new];
        _emailAddressTextFiled.returnKeyType = UIReturnKeySend;
        _emailAddressTextFiled.placeholder = @"UIReturnKeySend";
    }
    return _emailAddressTextFiled;
}

- (UITextField *)decimalPadTextFiled {
    if (!_decimalPadTextFiled) {
        _decimalPadTextFiled = [UITextField new];
        _decimalPadTextFiled.returnKeyType = UIReturnKeyYahoo;
        _decimalPadTextFiled.placeholder = @"UIReturnKeyYahoo";
    }
    return _decimalPadTextFiled;
}

- (UITextField *)twitterTextFiled {
    if (!_twitterTextFiled) {
        _twitterTextFiled = [UITextField new];
        _twitterTextFiled.returnKeyType = UIReturnKeyDone;
        _twitterTextFiled.placeholder = @"UIReturnKeyDone";
    }
    return _twitterTextFiled;
}

- (UITextField *)webSearchTextFiled {
    if (!_webSearchTextFiled) {
        _webSearchTextFiled = [UITextField new];
        _webSearchTextFiled.returnKeyType = UIReturnKeyEmergencyCall;
        _webSearchTextFiled.placeholder = @"UIReturnKeyEmergencyCall";
    }
    return _webSearchTextFiled;
}

- (UITextField *)ASCIINumerPadTextFiled {
    if (!_ASCIINumerPadTextFiled) {
        _ASCIINumerPadTextFiled = [UITextField new];
        _ASCIINumerPadTextFiled.returnKeyType = UIReturnKeyContinue;
        _ASCIINumerPadTextFiled.placeholder = @"UIReturnKeyContinue";
    }
    return _ASCIINumerPadTextFiled;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
