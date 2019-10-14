//
//  ViewController.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "KeyboardInputTypeViewController.h"
#import "CMFeedBackViewController.h"
#import "CMHostRequestFactory.h"

@interface KeyboardInputTypeViewController () <UIScrollViewDelegate>
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

@implementation KeyboardInputTypeViewController

/*
 typedef NS_ENUM(NSInteger, UIKeyboardType) {
 UIKeyboardTypeDefault,                // Default type for the current input method.
 UIKeyboardTypeASCIICapable,           // Displays a keyboard which can enter ASCII characters
 UIKeyboardTypeNumbersAndPunctuation,  // Numbers and assorted punctuation.
 UIKeyboardTypeURL,                    // A type optimized for URL entry (shows . / .com prominently).
 UIKeyboardTypeNumberPad,              // A number pad with locale-appropriate digits (0-9, ۰-۹, ०-९, etc.). Suitable for PIN entry.
 UIKeyboardTypePhonePad,               // A phone pad (1-9, *, 0, #, with letters under the numbers).
 UIKeyboardTypeNamePhonePad,           // A type optimized for entering a person's name or phone number.
 UIKeyboardTypeEmailAddress,           // A type optimized for multiple email address entry (shows space @ . prominently).
 UIKeyboardTypeDecimalPad NS_ENUM_AVAILABLE_IOS(4_1),   // A number pad with a decimal point.
 UIKeyboardTypeTwitter NS_ENUM_AVAILABLE_IOS(5_0),      // A type optimized for twitter text entry (easy access to @ #)
 UIKeyboardTypeWebSearch NS_ENUM_AVAILABLE_IOS(7_0),    // A default keyboard type with URL-oriented addition (shows space . prominently).
 UIKeyboardTypeASCIICapableNumberPad NS_ENUM_AVAILABLE_IOS(10_0), // A number pad (0-9) that will always be ASCII digits.
 
 UIKeyboardTypeAlphabet = UIKeyboardTypeASCIICapable, // Deprecated
 
 };
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

- (void)handleTapGesture:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


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
        _defaultTextField.keyboardType = UIKeyboardTypeDefault;
        _defaultTextField.placeholder = @"UIKeyboardTypeDefault";
        _defaultTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        _defaultTextField.returnKeyType = UIReturnKeyGo;
    }
    return _defaultTextField;
}

- (UITextField *)ASCIITextFiled {
    if (!_ASCIITextFiled) {
        _ASCIITextFiled = [UITextField new];
        _ASCIITextFiled.keyboardType = UIKeyboardTypeASCIICapable;
        _ASCIITextFiled.placeholder = @"UIKeyboardTypeASCIICapable";
        _ASCIITextFiled.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _ASCIITextFiled.returnKeyType = UIReturnKeyGoogle;
    }
    return _ASCIITextFiled;
}

- (UITextField *)numberAndPuncationTextFiled {
    if (!_numberAndPuncationTextFiled) {
        _numberAndPuncationTextFiled = [UITextField new];
        _numberAndPuncationTextFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _numberAndPuncationTextFiled.placeholder = @"UIKeyboardTypeNumbersAndPunctuation";
        _numberAndPuncationTextFiled.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _numberAndPuncationTextFiled.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _numberAndPuncationTextFiled.returnKeyType = UIReturnKeyJoin;
    }
    return _numberAndPuncationTextFiled;
}

- (UITextField *)urlTextFiled {
    if (!_urlTextFiled) {
        _urlTextFiled = [UITextField new];
        _urlTextFiled.keyboardType = UIKeyboardTypeURL;
        _urlTextFiled.placeholder = @"UIKeyboardTypeURL";
        _urlTextFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _urlTextFiled.returnKeyType = UIReturnKeyNext;
    }
    return _urlTextFiled;
}

- (UITextField *)numberPadTextFiled {
    if (!_numberPadTextFiled) {
        _numberPadTextFiled = [UITextField new];
        _numberPadTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        _numberPadTextFiled.placeholder = @"UIKeyboardTypeNumberPad";
    }
    return _numberPadTextFiled;
}

- (UITextField *)phoneTextFiled {
    if (!_phoneTextFiled) {
        _phoneTextFiled = [UITextField new];
        _phoneTextFiled.keyboardType = UIKeyboardTypePhonePad;
        _phoneTextFiled.placeholder = @"UIKeyboardTypePhonePad";
    }
    return _phoneTextFiled;
}

- (UITextField *)namePhoneTextFiled {
    if (!_namePhoneTextFiled) {
        _namePhoneTextFiled = [UITextField new];
        _namePhoneTextFiled.keyboardType = UIKeyboardTypeNamePhonePad;
        _namePhoneTextFiled.placeholder = @"UIKeyboardTypeNamePhonePad";
    }
    return _namePhoneTextFiled;
}

- (UITextField *)emailAddressTextFiled {
    if (!_emailAddressTextFiled) {
        _emailAddressTextFiled = [UITextField new];
        _emailAddressTextFiled.keyboardType = UIKeyboardTypeEmailAddress;
        _emailAddressTextFiled.placeholder = @"UIKeyboardTypeEmailAddress";
    }
    return _emailAddressTextFiled;
}

- (UITextField *)decimalPadTextFiled {
    if (!_decimalPadTextFiled) {
        _decimalPadTextFiled = [UITextField new];
        _decimalPadTextFiled.keyboardType = UIKeyboardTypeDecimalPad;
        _decimalPadTextFiled.placeholder = @"UIKeyboardTypeDecimalPad";
    }
    return _decimalPadTextFiled;
}

- (UITextField *)twitterTextFiled {
    if (!_twitterTextFiled) {
        _twitterTextFiled = [UITextField new];
        _twitterTextFiled.keyboardType = UIKeyboardTypeTwitter;
        _twitterTextFiled.placeholder = @"UIKeyboardTypeTwitter";
    }
    return _twitterTextFiled;
}

- (UITextField *)webSearchTextFiled {
    if (!_webSearchTextFiled) {
        _webSearchTextFiled = [UITextField new];
        _webSearchTextFiled.keyboardType = UIKeyboardTypeWebSearch;
        _webSearchTextFiled.placeholder = @"UIKeyboardTypeWebSearch";
    }
    return _webSearchTextFiled;
}

- (UITextField *)ASCIINumerPadTextFiled {
    if (!_ASCIINumerPadTextFiled) {
        _ASCIINumerPadTextFiled = [UITextField new];
        _ASCIINumerPadTextFiled.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
        _ASCIINumerPadTextFiled.placeholder = @"UIKeyboardTypeASCIICapableNumberPad";
    }
    return _ASCIINumerPadTextFiled;
}




#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
