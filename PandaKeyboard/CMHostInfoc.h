//
//  CMHostInfoc.h
//  PandaKeyboard
//
//  Created by wolf on 2017/6/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMHostInfoc : NSObject
+ (void) activeReport;

+ (void) reportCheetahkeyboard_main_showWithTab:(NSInteger)tab inway:(NSInteger)inway;
+ (void) reportCheetahkeyboard_main_theme_clickWithThemeName:(NSString *)themeName xy:(NSInteger)xy value:(NSInteger)value;
+ (void) reportCheetahkeyboard_main_openkeyWithTab:(NSInteger)tab;
+ (void) reportCheetahkeyboard_set_lang;
+ (void) reportCheetahkeyboard_set_lang_chanWithValue:(NSUInteger)value selectlanguage:(NSString *)selectlanguage;
+ (void)reportCheetahkeyboard_set_gene;
+ (void)reportCheetahkeyboard_set_gene_capWithValue:(NSInteger)value;
+ (void)reportCheetahkeyboard_set_corr;
+ (void)reportCheetahkeyboard_set_corr_showcorrWithValue:(NSInteger)value;
+ (void)reportCheetahkeyboard_set_corr_autocorrWithValue:(NSInteger)value;
+ (void)reportCheetahkeyboard_set_corr_nextsuggWithValue:(NSInteger)value;
+ (void) reportCheetahkeyboard_set_corr_history:(BOOL)on;
+ (void)reportOthersKeyboard;

// 开关音效上报
+ (void)reportCheetahkeyboard_set_gene_sound:(NSInteger)value;

// 振动音效上报 1.6.0
+ (void)reportCheetahkeyboard_set_gene_vibra:(NSInteger)value;


// 引导界面上报
/*
 action:
 1-显示Add界面
 2-显示Add界面跳转的User Agreement界面
 3-显示Full Acess界面
 4-显示Switch界面
 */
+ (void)reportCheetahkeyboard_activate_show:(NSUInteger)action isFirstShow:(BOOL)isFirstShow;

/*
 action:
 1-点击Add按钮
 2-点击Add界面的User Agreement按钮
 3-点击Full Acess按钮
 4-点击Full Acess界面的Skip按钮
 5-在Switch界面成功切换至Cheetah
 */
+ (void)reportcheetahkeyboard_activate_click:(NSUInteger)action isFirstShow:(BOOL)isFirstShow;

+ (void)reportCheetahkeyboard_main_theme_downWithThemeName:(NSString *)themeName xy:(NSInteger)xy action:(NSInteger)action classType:(NSInteger)classType;
+ (void)reportCheetahkeyboard_set_gene_doub:(NSInteger) value;

+ (void) reportCheetahkeyboard_star:(NSInteger) action click:(NSInteger)click;


+ (void)reportCheetahkeyboard_main_theme_refreshWithAction:(NSInteger)action;
+ (void)reportCheetahkeyboard_main_deleteWithTabName:(NSInteger)tabName;

+ (void) reportCheetahkeyboard_noti_perm_show:(NSInteger)value;
+ (void) reportCheetahkeyboard_noti_perm_choo:(NSInteger)value;
+ (void) reportCheetahkeyboard_noti_perm:(NSInteger)value;

// 上报已安装list 埋点
+ (void) reportCheetahkeyboard_app;

+ (void) reportCheetahkeyboard_main_disc_clickWithName:(NSInteger)name;
+ (void) reportCheetahkeyboard_main_disc_showWithInway:(NSInteger)inway;

+ (void)reportCheetahkeyboard_ar_show:(NSInteger)inway classType:(NSInteger)classType ;
+ (void)reportCheetahkeyboard_ar_click:(NSInteger)name;
+ (void)reportCheetahkeyboard_ar_done:(NSInteger)videtime anim:(NSInteger)anim;
+ (void)reportCheetahkeyboard_ar_done_clic:(NSInteger)value;

+ (void)reportCheetahkeyboard_diy:(NSInteger)inway xy:(NSInteger)xy;
+ (void)reportCheetahkeyboard_diy_done:(NSString *)bgname bgtime:(NSInteger)bgtime btname:(NSString *)btname bttime:(NSInteger)bttime ftname:(NSString *)ftname fttime:(NSInteger)fttime voicname:(NSString *)voicname voictime:(NSInteger)voictime action:(NSInteger)action inway:(NSInteger)inway;
+ (void)reportCheetahkeyboard_cancel:(NSInteger)inway action:(NSInteger)action;

+ (void)reportCheetahkeyboard_diy_all:(NSInteger)x;
+ (void)reportCheetahkeyboard_welcom;
+ (void)reportCheetahkeyboard_diy_all_clic:(NSInteger)value y:(NSInteger)y;
+ (void)reportCheetahkeyboard_iapp:(NSString *)action sku:(NSString *)sku;
@end
