//
//  CMCustomTipsAlert.h
//  PandaKeyboard
//
//  Created by yu dandan on 2019/5/5.
//  Copyright © 2019 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^confirmBlock)();
typedef void (^cancelBlock)();

@interface CMCustomTipsAlert : UIView

@property (nonatomic, copy) confirmBlock confirmBlock;
@property (nonatomic, copy) cancelBlock cancelBlock;

- (void)showAlertWithTitle:(NSString *)title confirmText:(NSString *)confirmtext buttonText:(NSString *)buttonText;

@end

