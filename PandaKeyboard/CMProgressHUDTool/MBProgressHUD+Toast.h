//
//  MBProgressHUD+Toast.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (Toast)
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view seconds:(CGFloat)seconds;
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view seconds:(CGFloat)seconds completion:(void (^)(BOOL finished))completion;
+ (MBProgressHUD *)showCustomView:(UIView *)customView toView:(UIView *)view seconds:(CGFloat)seconds;
+ (MBProgressHUD *)showCustomView:(UIView *)customView toView:(UIView *)view seconds:(CGFloat)seconds completion:(void (^)(BOOL finished))completion;
@end
