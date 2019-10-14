//
//  KeyboardCorrectionTypeViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/14.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "KeyboardCorrectionTypeViewController.h"

@interface KeyboardCorrectionTypeViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UITextField* autocorrectionDefaultTextField;
@property (nonatomic, strong)UITextField* autocorrectionTypeNoTextField;
@property (nonatomic, strong)UITextField* autocorrectionTypeYesTextFiled;

@property (nonatomic, strong)UITextField* autocapitalizationNoneTextFiled;
@property (nonatomic, strong)UITextField* autocapitalizationWordsTextFiled;
@property (nonatomic, strong)UITextField* autocapitalizationSentencesTextFiled;
@property (nonatomic, strong)UITextField* autocapitalizationAllCharactersTextFiled;
@end

@implementation KeyboardCorrectionTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.scrollView];
    UIView* containerView = [UIView new];
    [containerView addSubview:self.autocorrectionDefaultTextField];
    [containerView addSubview:self.autocorrectionTypeNoTextField];
    [containerView addSubview:self.autocorrectionTypeYesTextFiled];
    [containerView addSubview:self.autocapitalizationNoneTextFiled];
    [containerView addSubview:self.autocapitalizationWordsTextFiled];
    [containerView addSubview:self.autocapitalizationSentencesTextFiled];
    [containerView addSubview:self.autocapitalizationAllCharactersTextFiled];
    
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
    
    [self.autocorrectionDefaultTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(containerView).offset(20);
    }];
    
    [self.autocorrectionTypeNoTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.autocorrectionDefaultTextField.mas_bottom).offset(20);
    }];
    
    [self.autocorrectionTypeYesTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.autocorrectionTypeNoTextField.mas_bottom).offset(20);
    }];
    
    [self.autocapitalizationNoneTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.autocorrectionTypeYesTextFiled.mas_bottom).offset(20);
    }];
    
    [self.autocapitalizationWordsTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.autocapitalizationNoneTextFiled.mas_bottom).offset(20);
    }];
    
    [self.autocapitalizationSentencesTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.autocapitalizationWordsTextFiled.mas_bottom).offset(20);
    }];
    
    [self.autocapitalizationAllCharactersTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(containerView).offset(20);
        make.trailing.equalTo(containerView).offset(-20);
        make.top.equalTo(self.autocapitalizationSentencesTextFiled.mas_bottom).offset(20);
        make.bottom.equalTo(containerView).offset(-20);
    }];
    
}
- (void)handleTapGesture:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
    }
    return _scrollView;
}
- (UITextField *)autocorrectionDefaultTextField {
    if (!_autocorrectionDefaultTextField) {
        _autocorrectionDefaultTextField = [UITextField new];
        _autocorrectionDefaultTextField.returnKeyType = UIReturnKeyDefault;
        _autocorrectionDefaultTextField.placeholder = @"UITextAutocorrectionTypeDefault";
        _autocorrectionDefaultTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
    }
    return _autocorrectionDefaultTextField;
}

- (UITextField *)autocorrectionTypeNoTextField {
    if (!_autocorrectionTypeNoTextField) {
        _autocorrectionTypeNoTextField = [UITextField new];
        _autocorrectionTypeNoTextField.returnKeyType = UIReturnKeyDefault;
        _autocorrectionTypeNoTextField.placeholder = @"UITextAutocorrectionTypeNo";
        _autocorrectionTypeNoTextField.autocorrectionType = UITextAutocorrectionTypeNo;

    }
    return _autocorrectionTypeNoTextField;
}

- (UITextField *)autocorrectionTypeYesTextFiled {
    if (!_autocorrectionTypeYesTextFiled) {
        _autocorrectionTypeYesTextFiled = [UITextField new];
        _autocorrectionTypeYesTextFiled.returnKeyType = UIReturnKeyDefault;
        _autocorrectionTypeYesTextFiled.placeholder = @"UITextAutocorrectionTypeYes";
        _autocorrectionTypeYesTextFiled.autocorrectionType = UITextAutocorrectionTypeYes;

    }
    return _autocorrectionTypeYesTextFiled;
}

- (UITextField *)autocapitalizationNoneTextFiled {
    if (!_autocapitalizationNoneTextFiled) {
        _autocapitalizationNoneTextFiled = [UITextField new];
        _autocapitalizationNoneTextFiled.returnKeyType = UIReturnKeyDefault;
        _autocapitalizationNoneTextFiled.placeholder = @"UITextAutocapitalizationTypeNone";
        _autocapitalizationNoneTextFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _autocapitalizationNoneTextFiled;
}

- (UITextField *)autocapitalizationWordsTextFiled {
    if (!_autocapitalizationWordsTextFiled) {
        _autocapitalizationWordsTextFiled = [UITextField new];
        _autocapitalizationWordsTextFiled.returnKeyType = UIReturnKeyDefault;
        _autocapitalizationWordsTextFiled.placeholder = @"UITextAutocapitalizationTypeWords";
        _autocapitalizationWordsTextFiled.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    return _autocapitalizationWordsTextFiled;
}

- (UITextField *)autocapitalizationSentencesTextFiled {
    if (!_autocapitalizationSentencesTextFiled) {
        _autocapitalizationSentencesTextFiled = [UITextField new];
        _autocapitalizationSentencesTextFiled.returnKeyType = UIReturnKeyDefault;
        _autocapitalizationSentencesTextFiled.placeholder = @"UITextAutocapitalizationTypeSentences";
        _autocapitalizationSentencesTextFiled.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
    return _autocapitalizationSentencesTextFiled;
}

- (UITextField *)autocapitalizationAllCharactersTextFiled {
    if (!_autocapitalizationAllCharactersTextFiled) {
        _autocapitalizationAllCharactersTextFiled = [UITextField new];
        _autocapitalizationAllCharactersTextFiled.returnKeyType = UIReturnKeyDefault;
        _autocapitalizationAllCharactersTextFiled.placeholder = @"UITextAutocapitalizationTypeAllCharacters";
        _autocapitalizationAllCharactersTextFiled.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
    return _autocapitalizationAllCharactersTextFiled;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
@end
