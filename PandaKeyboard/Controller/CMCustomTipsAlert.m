//
//  CMCustomTipsAlert.m
//  PandaKeyboard
//
//  Created by yu dandan on 2019/5/5.
//  Copyright © 2019 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMCustomTipsAlert.h"



#define buttonWidth         142
#define buttonHeight        42

@implementation CMCustomTipsAlert
{
    UILabel     *titleLabel;
    UILabel     *textLabel;
    UIButton    *confirmButton;
    UIView      *baseView;
    UIImageView *alertView;
    UIView      *baseColorView;
}

- (void)showAlertWithTitle:(NSString *)title confirmText:(NSString *)confirmText buttonText:(NSString *)buttonText {
    
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
    alertView.frame = CGRectMake(KScalePt(21.65), 0, width - KScalePt( 21.65 +  21.85), KScalePt(210));
    alertView.center = CGPointMake(width/2, height/2);
    alertView.userInteractionEnabled = YES;
    [baseView addSubview:alertView];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0, alertView.frame.size.width, KScalePt(50));
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:25];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    [alertView addSubview:titleLabel];
    
    textLabel = [[UILabel alloc] init];
    textLabel.frame = CGRectMake(KScalePt(20), KScalePt(50), alertView.frame.size.width - KScalePt(20) * 2, KScalePt(93));
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = confirmText;
    textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:21];
    textLabel.textColor = [UIColor colorWithHexString:@"#8492A7"];
    textLabel.numberOfLines = 0;
    [alertView addSubview:textLabel];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.layer.borderColor = [UIColor colorWithHexString:@"#54FFFC"].CGColor;
    [confirmButton setTitleColor:[UIColor colorWithHexString:@"#54FFFC"] forState:UIControlStateNormal];
    [confirmButton setTitle:buttonText forState:UIControlStateNormal];
    confirmButton.layer.borderWidth = 1.0;
    confirmButton.layer.cornerRadius = 20;
    confirmButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:21];
    [confirmButton addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [confirmButton addTarget:self action:@selector(confirmBtnDown) forControlEvents:UIControlEventTouchDown];
    [alertView addSubview:confirmButton];

    NSInteger btnHeight = KScalePt(buttonHeight);
    confirmButton.frame = CGRectMake(KScalePt(10), KScalePt(93) + KScalePt(50), alertView.frame.size.width - KScalePt(10) * 2, btnHeight);
    
    [UIView animateWithDuration:0.1 animations:^{
        baseView.alpha =  1.0;
    }];
}


- (void)touchUpOutside:(UIButton *)sender
{
    sender.layer.borderWidth = 1.0;
    [sender setTitleColor:[UIColor colorWithRed:132/255.0 green:146/255.0 blue:167/255.0 alpha:1.0] forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor clearColor];
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


@end

