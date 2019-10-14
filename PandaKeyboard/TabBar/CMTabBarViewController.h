//
//  CMTabBarViewController.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTabBarViewController : UITabBarController
@property (nonatomic) BOOL isClickEnable;

- (void)setKeyboardButtonHidden:(BOOL)hidden;

@end
    
