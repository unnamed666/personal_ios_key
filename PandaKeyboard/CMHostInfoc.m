//
//  CMHostInfoc.m
//  PandaKeyboard
//
//  Created by wolf on 2017/6/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMHostInfoc.h"
#import "kinfoc_client.h"
#import "CMOReachability.h"
#import "CMGroupDataManager.h"
#import "CMAppConfig.h"
#import "InfoC.h"

@implementation CMHostInfoc

+ (void) reportData:(NSDictionary*) dataDic toTable:(NSString*) tableName//上报
{
    #ifdef DEBUG
    [[KInfocClient getInstance] forceReportData:dataDic toTable:tableName];
        return;
    #else
        [[KInfocClient getInstance] reportData:dataDic toTable:tableName];
    #endif
    
}
+ (void) forceReportData:(NSDictionary*) dataDic toTable:(NSString*) tableName//强制上报
{
    [[KInfocClient getInstance] forceReportData:dataDic toTable:tableName];
}


+ (void) activeReport{
    
    NSString * tableName = @"cheetahkeyboard_main_active";
    kNavNetWorkStatus  networkReachabilityStatus =[CMOReachability status];
    int network = 0;
    switch (networkReachabilityStatus) {
        case kNavNetWorkWIFI:
            network = 1;
            break;
        case kNavNetWorkWWAN:
            network = 2;
            break;
        case kNavNetWorkNotReachable:
            network = 3;
            break;
        default:
            network = 0;
            break;
    }
    //    NSDate * date = [NSDate date];
    //    time_t t = time(NULL);
    //    struct tm * time = localtime(&t);
    int clktime = (int)time(NULL);
    
    NSDictionary* dataDic3 = @{@"network":@(network),
                               @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:dataDic3 toTable:tableName];
    
}

+ (void) reportCheetahkeyboard_set_corr_history:(BOOL)on{
    NSString * reportName = @"cheetahkeyboard_set_corr_history";
    NSDictionary* reportDic = @{@"value":on?@"1":@"2"};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
    
}

+ (void) reportCheetahkeyboard_main_showWithTab:(NSInteger)tab inway:(NSInteger)inway
{
    NSString * reportName = @"cheetahkeyboard_main_show";
    int clktime = (int)time(NULL);
    if (!tab) {
        tab = 0;
    }
    if (!inway) {
        inway = 0;
    }
    NSDictionary* reportDic = @{@"tab":@(tab),
                                @"inway":@(inway),
                                @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
//    [InfoC logEvent:cheetahkeyboard_main_show andRecordLevel:InfoCEventRecordLevelUploadNow andParameters:reportDic];
}

+ (void) reportCheetahkeyboard_main_theme_clickWithThemeName:(NSString *)themeName xy:(NSInteger)xy value:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_main_theme_click";
    int clktime = (int)time(NULL);
    if (!themeName) {
        themeName = @"";
    }
    if (!xy) {
        xy = 0;
    }
    
    if (!value) {
        value = 0;
    }
    NSDictionary* reportDic = @{@"name":themeName,
                                @"xy":@(xy),
                                @"value":@(value),
                                @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}


+ (void) reportCheetahkeyboard_main_openkeyWithTab:(NSInteger)tab
{
    NSString * reportName = @"cheetahkeyboard_main_openkey";
    int clktime = (int)time(NULL);
    if (!tab) {
        tab = 0;
    }
    
    NSDictionary* reportDic = @{@"tab":@(tab),
                                @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void) reportCheetahkeyboard_set_lang
{
    NSString * reportName = @"cheetahkeyboard_set_lang";

    NSDictionary* reportDic = @{@"value":@(1)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];

}
+ (void) reportCheetahkeyboard_set_lang_chanWithValue:(NSUInteger)value selectlanguage:(NSString *)selectlanguage
{
    NSString * reportName = @"cheetahkeyboard_set_lang_chan";
    
    if (!value) {
        value = 0;
    }
    if (!selectlanguage) {
        selectlanguage = @"";
    }
    
    NSDictionary* reportDic = @{@"value":@(value),
                                @"class":selectlanguage};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];

}

+ (void)reportCheetahkeyboard_set_gene
{
    NSString * reportName = @"cheetahkeyboard_set_gene";
    
    NSDictionary* reportDic = @{@"value":@(1)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_set_gene_capWithValue:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_set_gene_cap";
    
    if (!value) {
        value = 0;
    }
    
    NSDictionary* reportDic = @{@"value":@(value)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

// 开关音效上报
+ (void)reportCheetahkeyboard_set_gene_sound:(NSInteger)value {
    NSString * reportName = @"cheetahkeyboard_set_gene_sound";
    
    if (!value) {
        value = 0;
    }
    
    NSDictionary* reportDic = @{@"value":@(value)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

// 振动音效上报
+ (void)reportCheetahkeyboard_set_gene_vibra:(NSInteger)value {
    NSString * reportName = @"cheetahkeyboard_set_gene_vibra";
    
    if (!value) {
        value = 0;
    }
    
    NSDictionary* reportDic = @{@"value":@(value)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}


+ (void)reportCheetahkeyboard_set_corr
{
    NSString * reportName = @"cheetahkeyboard_set_corr";
    
    NSDictionary* reportDic = @{@"value":@(1)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_set_corr_showcorrWithValue:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_set_corr_showcorr";
    
    if (!value) {
        value = 0;
    }
    
    NSDictionary* reportDic = @{@"value":@(value)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];

}

+ (void)reportCheetahkeyboard_set_corr_autocorrWithValue:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_set_corr_autocorr";
    
    if (!value) {
        value = 0;
    }
    
    NSDictionary* reportDic = @{@"value":@(value)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];

}

+ (void)reportCheetahkeyboard_set_corr_nextsuggWithValue:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_set_corr_nextsugg";
    
    if (!value) {
        value = 0;
    }
    
    NSDictionary* reportDic = @{@"value":@(value)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_activate_show:(NSUInteger)action isFirstShow:(BOOL)isFirstShow {
    NSString * reportName = @"cheetahkeyboard_activate_show";
    
    if (!action) {
        action = 0;
    }
    
    int clktime = (int)time(NULL);
    
    NSDictionary* reportDic = @{@"isfirst":@(isFirstShow ? 1 : 2),
                                @"action":@(action),
                                @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportcheetahkeyboard_activate_click:(NSUInteger)action isFirstShow:(BOOL)isFirstShow {
    NSString * reportName = @"cheetahkeyboard_activate_click";
    
    if (!action) {
        action = 0;
    }
    
    int clktime = (int)time(NULL);
    
    NSDictionary* reportDic = @{@"isfirst":@(isFirstShow ? 1 : 2),
                                @"action":@(action),
                                @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportOthersKeyboard
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    // 86400 为 24 * 60 * 60，即一天
    if (timeInterval - kCMGroupDataManager.othersKeyboardTimestamp < 86400.0) {
        // 距离上次上报埋点小于一天，本次不上报该埋点信息
        return;
    }
    
    kCMGroupDataManager.othersKeyboardTimestamp = timeInterval;
    
    NSString *reportName = @"cheetahkeyboard_coexist";
    
    NSArray<UITextInputMode *> *array = [UITextInputMode activeInputModes];
    [array enumerateObjectsUsingBlock:^(UITextInputMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id extension = [obj valueForKeyPath:@"extension"];
        if (extension) {
            // 第三方键盘
            NSString *bundleIdKey = [NSString stringWithFormat:@"id%@fi%@", @"enti", @"er"];
            NSString *bundleId = [extension valueForKeyPath:bundleIdKey];
            
            if (![bundleId isEqualToString:[CMAppConfig bundleIdAddUpperCaseExtension]] && ![bundleId isEqualToString:[CMAppConfig bundleIdAddLowerCaseExtension]]) {
                [CMHostInfoc forceReportData:@{@"app": bundleId, @"lang": @(1), @"layout": @(1)} toTable:reportName];
            }
        }else{
            // 系统键盘
            NSString *layoutKey = [NSString stringWithFormat:@"soft%@L%@", @"ware", @"ayout"];
            NSString *layout = [obj valueForKey:layoutKey];
            [CMHostInfoc forceReportData:@{@"app": @(1), @"lang": obj.primaryLanguage?obj.primaryLanguage:@"", @"layout": layout?layout:@""} toTable:reportName];
        }
    }];
    
    
}

+ (void)reportCheetahkeyboard_main_theme_downWithThemeName:(NSString *)themeName xy:(NSInteger)xy action:(NSInteger)action classType:(NSInteger)classType
{
    NSString * reportName = @"cheetahkeyboard_main_theme_down";
    if (!themeName) {
        themeName = @"";
    }
    if (!xy) {
        xy = 0;
    }
    if (!action) {
        action = 0;
    }
    if (!classType) {
        classType = 0;
    }
    NSDictionary * reportDic = @{@"name":themeName,
                                 @"xy":@(xy),
                                 @"action":@(action),
                                 @"class":@(classType)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
    
}

+ (void)reportCheetahkeyboard_set_gene_doub:(NSInteger) value
{
    NSString * reportName = @"cheetahkeyboard_set_gene_doub";

    if (!value) {
        value = 0;
    }

    NSDictionary * reportDic = @{@"value":@(value)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
    
}

+ (void)reportCheetahkeyboard_star:(NSInteger)action click:(NSInteger)click
{
    NSString * reportName = @"cheetahkeyboard_star";
    
    if (!action)
    {
        action = 0;
    }
    if (!click)
    {
        click = 0;
    }
    NSDictionary * reportDic = @{@"action":@(action),
                                 @"click":@(click)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_main_theme_refreshWithAction:(NSInteger)action
{
    NSString * reportName = @"cheetahkeyboard_main_theme_refresh";
    if (!action) {
        action = 0;
    }
    NSDictionary * reportDic = @{@"action":@(action)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
    
}

+ (void)reportCheetahkeyboard_main_deleteWithTabName:(NSInteger)tabName
{
    NSString * reportName = @"cheetahkeyboard_main_delete";
    if (!tabName) {
        tabName = 0;
    }
    int clktime = (int)time(NULL);
    NSDictionary * reportDic = @{@"tab":@(tabName),
                                 @"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
    
}

+ (void) reportCheetahkeyboard_noti_perm_show:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_noti_perm_show";
    if (!value)
    {
        value = 0;
    }
    NSDictionary * reportDic = @{@"value":@(value)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void) reportCheetahkeyboard_noti_perm_choo:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_noti_perm_choo";
    if (!value)
    {
        value = 1;
    }
    NSDictionary * reportDic = @{@"value":@(value)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void) reportCheetahkeyboard_noti_perm:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_noti_perm";
    if (!value)
    {
        value = 0;
    }
    NSDictionary * reportDic = @{@"value":@(value)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void) reportCheetahkeyboard_app{
    
    NSString * reportName = @"cheetahkeyboard_app";
    if (@available(iOS 11.0, *)) {
        return;
    } else {
        
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kHasReportTheInstalledAppListDate];
        NSDate *currentDate = [NSDate date];
        if ([[NSCalendar currentCalendar] isDate:date inSameDayAsDate:currentDate]) {
            return;
        }
        // 获取 installed list 安装
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *appListArr = [CMAppConfig getAllAppsFromDevice];
            NSString *appListStr = [appListArr componentsJoinedByString:@" "];
            appListStr = [[@" "stringByAppendingString:appListStr]stringByAppendingString:@" "];
            NSMutableArray *subPageStrArr = [NSMutableArray arrayWithCapacity:0];
    
            //对字符串进行大小分割
            while (appListStr.length > 3700){
                NSInteger number = 3700;
                while (number > 0 && [appListStr characterAtIndex:number] != ' ')
                {
                    number --;
                }
                NSString *subLeftStr = [appListStr substringToIndex:number+1];
                [subPageStrArr addObject:subLeftStr];
                appListStr = [appListStr substringFromIndex:number];
            }
            [subPageStrArr addObject:appListStr];
            
            //字符串分条上报
            [subPageStrArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *reportStr = (NSString *)obj;
                NSDictionary* reportDic = @{@"pkg":reportStr ? reportStr:@"0",};
                [CMHostInfoc forceReportData:reportDic toTable:reportName];
            }];
            
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kHasReportTheInstalledAppListDate];
        });
    }
}

+ (void) reportCheetahkeyboard_main_disc_clickWithName:(NSInteger)name
{
    NSString * reportName = @"cheetahkeyboard_main_disc_click";
    if (!name) {
        name = 0;
    }
    int clktime = (int)time(NULL);
    NSDictionary * reportDic = @{@"name":@(name),
                                 @"clktime":@(clktime)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void) reportCheetahkeyboard_main_disc_showWithInway:(NSInteger)inway
{
    NSString * reportName = @"cheetahkeyboard_main_disc_show";
    if (!inway) {
        inway = 0;
    }
    int clktime = (int)time(NULL);
    NSDictionary * reportDic = @{@"inway":@(inway),
                                 @"clktime":@(clktime)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
    
}

+ (void)reportCheetahkeyboard_ar_show:(NSInteger)inway classType:(NSInteger)classType
{
    NSString * reportName = @"cheetahkeyboard_ar_show";
    NSDictionary * reportDic = @{@"inway":@(inway), @"class": @(classType), @"clktime": @((int)time(NULL))};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_ar_click:(NSInteger)name
{
    NSString * reportName = @"cheetahkeyboard_ar_click";
    NSDictionary * reportDic = @{@"name":@(name), @"clktime": @((int)time(NULL))};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_ar_done:(NSInteger)videtime anim:(NSInteger)anim
{
    NSString * reportName = @"cheetahkeyboard_ar_done";
    NSDictionary * reportDic = @{@"videtime":@(videtime), @"anim": @(anim)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_ar_done_clic:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_ar_done_clic";
    NSDictionary * reportDic = @{@"value":@(value)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_diy:(NSInteger)inway xy:(NSInteger)xy
{
    NSString * reportName = @"cheetahkeyboard_diy";
    NSDictionary * reportDic = @{@"inway":@(inway), @"xy": @(xy), @"clktime": @((int)time(NULL))};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_diy_done:(NSString *)bgname bgtime:(NSInteger)bgtime btname:(NSString *)btname bttime:(NSInteger)bttime ftname:(NSString *)ftname fttime:(NSInteger)fttime voicname:(NSString *)voicname voictime:(NSInteger)voictime action:(NSInteger)action inway:(NSInteger)inway
{
    NSString * reportName = @"cheetahkeyboard_diy_done";
    NSDictionary * reportDic = @{@"bgname":bgname, @"bgtime":@(bgtime), @"btname":btname, @"bttime":@(bttime), @"ftname":ftname, @"fttime":@(fttime), @"voicname":voicname, @"voictime":@(voictime), @"action":@(action), @"inway":@(inway), @"clktime": @((int)time(NULL))};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_cancel:(NSInteger)inway action:(NSInteger)action
{
    NSString * reportName = @"cheetahkeyboard_diy_cancel";
    NSDictionary * reportDic = @{@"inway":@(inway), @"action": @(action)};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_diy_all:(NSInteger)x
{
    NSString * reportName = @"cheetahkeyboard_diy_all";
    int clktime = (int)time(NULL);
    NSDictionary * reportDic = @{@"clktime":@(clktime),@"x":@(x)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}
+ (void)reportCheetahkeyboard_welcom {
    NSString * reportName = @"cheetahkeyboard_welcom";
    int clktime = (int)time(NULL);
    NSDictionary * reportDic = @{@"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_diy_all_clic:(NSInteger)value y:(NSInteger)y
{
    NSString * reportName = @"cheetahkeyboard_diy_all_clic";
    int clktime = (int)time(NULL);
    NSDictionary * reportDic = @{@"value":@(value),@"y":@(y),@"clktime":@(clktime)};
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}

+ (void)reportCheetahkeyboard_iapp:(NSString *)action sku:(NSString *)sku
{
    NSString * reportName = @"cheetahkeyboard_guide";
    NSDictionary * reportDic = @{@"action":action,@"sku":sku};
    
    [CMHostInfoc forceReportData:reportDic toTable:reportName];
}
@end
