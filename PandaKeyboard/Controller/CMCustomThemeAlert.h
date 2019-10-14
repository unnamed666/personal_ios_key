//
//  CMCustomThemeAlert.h
//  KeyboardKit
//
//  Created by Tim on 2017/11/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^confirmBlock)();
typedef void (^cancelBlock)();

@interface CMCustomThemeAlert : UIView

@property (nonatomic, copy) confirmBlock confirmBlock;
@property (nonatomic, copy) cancelBlock cancelBlock;

- (void)showAlertWithTitle:(NSString *)title confirmTitle:(NSString *)confirmTitle andCancelTitle:(NSString *)cancelTitle;

@end

