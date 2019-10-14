//
//  CMCustomThemeAlert.m
//  KeyboardKit
//
//  Created by Tim on 2017/11/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCustomThemeAlert.h"

#define buttonWidth         142
#define buttonHeight        42

@implementation CMCustomThemeAlert
{
    UILabel     *nameLabel;
    UIButton    *cancelButton;
    UIButton    *confirmButton;
    UIView      *baseView;
    UIImageView *alertView;
    UIView      *baseColorView;
}

- (void)showAlertWithTitle:(NSString *)title confirmTitle:(NSString *)confirmTitle andCancelTitle:(NSString *)cancelTitle {
    
    UIWindow    *keyWindow = [UIApplication sharedApplication].keyWindow;
    NSInteger   width = keyWindow.frame.size.width;
    NSInteger   height = keyWindow.frame.size.height;
    
    baseView = [[UIView alloc] init];
    baseView.frame = keyWindow.bounds;
    baseView.alpha = 0.0;
    [keyWindow addSubview:baseView];
    
    baseColorView = [[UIView alloc] init];
    baseColorView.frame = baseView.bounds;
    baseColorView.backgroundColor = [UIColor colorWithRed:11/255.0 green:17/255.0 blue:43/255.0 alpha:0.85];
    [baseView addSubview:baseColorView];
    
    alertView = [[UIImageView alloc] init];
    alertView.image = [UIImage imageNamed:@"Rectangle 13"];
    alertView.frame = CGRectMake(KScalePt(21.65), 0,width - KScalePt( 21.65 +  21.85), KScalePt(152.8));
    alertView.center = CGPointMake(width/2, height/2);
    alertView.userInteractionEnabled = YES;
    [baseView addSubview:alertView];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(0, 0, alertView.frame.size.width, KScalePt(93));
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = title;
    nameLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.numberOfLines = 0;
    [alertView addSubview:nameLabel];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.layer.borderColor = [UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0].CGColor;
    [cancelButton setTitleColor:[UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancelButton.layer.borderWidth = 1.0;
    cancelButton.layer.cornerRadius = 20;
    cancelButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.5];
    [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [cancelButton addTarget:self action:@selector(cancelBtnDown) forControlEvents:UIControlEventTouchDown];
    [alertView addSubview:cancelButton];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.layer.borderColor = [UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0].CGColor;
    [confirmButton setTitleColor:[UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0] forState:UIControlStateNormal];
    [confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    confirmButton.layer.borderWidth = 1.0;
    confirmButton.layer.cornerRadius = 20;
    confirmButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.5];
    [confirmButton addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [confirmButton addTarget:self action:@selector(confirmBtnDown) forControlEvents:UIControlEventTouchDown];
    [alertView addSubview:confirmButton];
    
    BOOL isShowConfirmBtn = NO;
    
    if (confirmTitle && [confirmTitle isKindOfClass:[NSString class]] && confirmTitle.length > 0) {
        isShowConfirmBtn = YES;
    }
    
    BOOL isShowCancelBtn = NO;
    
    if (cancelTitle && [cancelTitle isKindOfClass:[NSString class]] && cancelTitle.length > 0) {
        isShowCancelBtn = YES;
    }
    
//    NSInteger btnWidth = KScalePt(buttonWidth);
    NSInteger btnHeight = KScalePt(buttonHeight);
    
    if (isShowCancelBtn && isShowConfirmBtn) {
        NSInteger btnWidth = ceil((alertView.frame.size.width - KScalePt(20) - KScalePt(10))/2);
        confirmButton.frame = CGRectMake(alertView.frame.size.width - KScalePt(10) - btnWidth, KScalePt(93), btnWidth, btnHeight);
        cancelButton.frame = CGRectMake(KScalePt(10), KScalePt(93), btnWidth, btnHeight);
    }else if (isShowCancelBtn && !isShowConfirmBtn) {
        NSInteger btnWidth = KScalePt(buttonWidth);
        cancelButton.frame = CGRectMake((alertView.frame.size.width - btnWidth)/2, KScalePt(93), btnWidth, btnHeight);
    }else if (!isShowCancelBtn && isShowConfirmBtn) {
        NSInteger btnWidth = KScalePt(buttonWidth);
        confirmButton.frame = CGRectMake((alertView.frame.size.width - btnWidth)/2, KScalePt(93), btnWidth, btnHeight);
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        baseView.alpha =  1.0;
    }];
    
}

- (void)cancelBtnDown {
    cancelButton.layer.borderWidth = 0.0;
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor colorWithRed:84/255.0 green:243/255.0 blue:238/255.0 alpha:1.0];
}

- (void)touchUpOutside:(UIButton *)sender
{
    sender.layer.borderWidth = 1.0;
    [sender setTitleColor:[UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0] forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor clearColor];
}

- (void)cancelBtnClick {
    [UIView animateWithDuration:0.1 animations:^{
        cancelButton.layer.borderWidth = 0.0;
        [cancelButton setTitleColor:[UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0] forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [baseView removeFromSuperview];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }];
}

- (void)confirmBtnDown {
    confirmButton.layer.borderWidth = 0.0;
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    confirmButton.backgroundColor = [UIColor colorWithRed:84/255.0 green:243/255.0 blue:238/255.0 alpha:1.0];
}

- (void)confirmBtnClick {
    [UIView animateWithDuration:0.1 animations:^{
        confirmButton.layer.borderWidth = 0.0;
        [confirmButton setTitleColor:[UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0] forState:UIControlStateNormal];
        confirmButton.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [baseView removeFromSuperview];
        if (self.confirmBlock) {
            self.confirmBlock();
        }
    }];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

