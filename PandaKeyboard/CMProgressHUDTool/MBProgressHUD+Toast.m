//
//  MBProgressHUD+Toast.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "MBProgressHUD+Toast.h"

@implementation MBProgressHUD (Toast)
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view seconds:(CGFloat)seconds
{
    if (view == nil)
    {
        view = [UIApplication sharedApplication].windows.lastObject;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.label.lineBreakMode = NSLineBreakByTruncatingTail;
    hud.label.numberOfLines = 0;
    [hud hideAnimated:YES afterDelay:seconds];
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view seconds:(CGFloat)seconds completion:(void (^)(BOOL finished))completion
{
    MBProgressHUD * hud = [self showMessage:message toView:view seconds:seconds];
    if (completion) {
        hud.completionBlock = ^(){
            completion(YES);
        };
    }
    
    return hud;
}

+ (MBProgressHUD *)showCustomView:(UIView *)customView toView:(UIView *)view seconds:(CGFloat)seconds
{
    if (view == nil)
    {
        view = [UIApplication sharedApplication].windows.lastObject;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = customView;
    [hud hideAnimated:YES afterDelay:seconds];
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

+ (MBProgressHUD *)showCustomView:(UIView *)customView toView:(UIView *)view seconds:(CGFloat)seconds completion:(void (^)(BOOL finished))completion
{
    MBProgressHUD * hud = [self showCustomView:customView toView:view seconds:seconds];
    if (completion) {
        hud.completionBlock = ^(){
            completion(YES);
        };
    }
    
    return hud;
}

@end
