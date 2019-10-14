//
//  CMInfoc.m
//  PandaKeyboard
//
//  Created by wolf on 2017/6/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMInfoc.h"
#import "kinfoc_client.h"
#import "CMOReachability.h"

@implementation CMInfoc
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

+ (void) activeReport:(UIKeyboardType)keyboardType language:(NSString*)lang dictver:(int)dicter themeName:(NSString*)themeName{
    
    NSString * tableName = @"cheetahkeyboard_active";
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
                               @"clktime":@(clktime),
                               @"inputtype":@(keyboardType),
                               @"lang":lang?lang:@"",
                               @"dictver":@(dicter),
                               @"theme":themeName};
    [CMInfoc forceReportData:dataDic3 toTable:tableName];
    
}

// Emoji界面的显示
+ (void)reportEmojiShow:(NSUInteger)source class:(int)classValue {
    NSString * tableName = @"cheetahkeyboard_emoji";
    int clktime = (int)time(NULL);
    if(classValue == 2){
        classValue = 3;
    }else if(classValue == 3){
        classValue =2;
    }
    NSDictionary* dataDic = @{@"value":@(source),
                              @"clktime":@(clktime),
                              @"class":@(classValue)
                              };
    [CMInfoc forceReportData:dataDic toTable:tableName];
}


// Emoji按键的点击
+ (void)reportEmojiTapped:(NSUInteger)source emoji:(NSString *)emoji {
    NSString * tableName = @"cheetahkeyboard_emoji_click";
    int clktime = (int)time(NULL);
    
    NSDictionary* dataDic = @{@"value":emoji,
                              @"inway":@(source),
                              @"clktime":@(clktime)};
    [CMInfoc forceReportData:dataDic toTable:tableName];
}

// 键盘收起按键的点击
+ (void)reportKeyboardDismissBtnTap {
    NSString * tableName = @"cheetahkeyboard_close";
    int clktime = (int)time(NULL);

    NSDictionary* dataDic = @{@"value":@(1),
                               @"clktime":@(clktime)};
    [CMInfoc forceReportData:dataDic toTable:tableName];
}


// 键盘切换按键的点击
+ (void)reportSwitchKeyboardKeyTap {
    NSString * tableName = @"cheetahkeyboard_switch_nextkey";
    int clktime = (int)time(NULL);
    
    NSDictionary* dataDic = @{@"value":@(1),
                              @"clktime":@(clktime)};
    [CMInfoc forceReportData:dataDic toTable:tableName];
}

// 单词上报
+ (void)reportCheetahKeyboard_word:(NSString *)iWord cWord:(NSString *)cWord cType:(int)cType dType:(int)dType inputType:(UIKeyboardType)inputType language:(NSString *)lang dictver:(int)dicter
{
    NSString * reportName = @"cheetahkeyboard_input_words";
    if(cType == 0)iWord= nil;
    // 修复 '&' 导致的代码上报崩溃
    iWord = [iWord stringByReplacingOccurrencesOfString:@"&"withString:@"%26"];
    [CMInfoc forceReportData:@{@"iword": iWord ? iWord : @"",
                               @"cword": cWord ? cWord : @"",
                               @"clktime":@((int)time(NULL)),
                               @"ctype": @(cType),
                               @"dtype": @(dType),// dType 1:main词库 2:history词库 3:usertype
                               @"inputtype": @(inputType),
                               @"lang": lang,
                               @"dictver": @(dicter)}
                     toTable:reportName];
}

// 句子上报
+ (void)reportCheetahKeyboard_sentence:(NSString *)sentence language:(NSString *)lang inputType:(UIKeyboardType)inputType dictver:(int)dicter
{
    NSString * reportName = @"cheetahkeyboard_input_collect";
    // 修复 '&' 导致的代码上报崩溃
    sentence = [sentence stringByReplacingOccurrencesOfString:@"&"withString:@"%26"];
    [CMInfoc forceReportData:@{@"value": sentence ? sentence : @"",
                               @"lang": lang,
                               @"inputtype": @(inputType),
                               
                               @"dictver": @(dicter),
                               @"clktime":@((int)time(NULL))}
                     toTable:reportName];
}

+ (void)reportCheetahkeyboard_tip_showWithValue:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_tip_show";
    int clktime = (int)time(NULL);
    
    [CMInfoc forceReportData:@{@"value":value>0 ? @(value) : @(0),
                               @"clktime":@(clktime)}
                     toTable:reportName];
}

+ (void)reportCheetahkeyboard_tip_clickWithValue:(NSInteger)value
{
    NSString * reportName = @"cheetahkeyboard_tip_click";
    int clktime = (int)time(NULL);
    
    [CMInfoc reportData:@{@"value":value>0 ? @(value) : @(0),
                               @"clktime":@(clktime)}
                     toTable:reportName];
    
}

+ (void)reportCheetahkeyboard_tip_closeWithValue:(NSInteger)value closeType:(NSInteger)closeType
{
    NSString * reportName = @"cheetahkeyboard_tip_close";
    int clktime = (int)time(NULL);
    
    [CMInfoc forceReportData:@{@"value":value>0 ? @(value) : @(0),
                               @"class":closeType>0 ? @(closeType) :@(0),
                               @"clktime":@(clktime)}
                     toTable:reportName];

}

+ (void)reportCheetahkeyboard_setting_click:(NSInteger)value inputType:(NSInteger)inputType
{
    [CMInfoc reportData:@{@"value": value>0 ? @(value) : @(0),
                          @"inputtype": @(inputType)}
                toTable:@"cheetahkeyboard_setting_click"];
}

+ (void)reportCheetahkeyboard_setting_fun_click:(NSInteger)value inputType:(NSInteger)inputType
{
    [CMInfoc reportData:@{@"value": value>0 ? @(value) : @(0),
                          @"inputtype": @(inputType)}
                toTable:@"cheetahkeyboard_setting_fun_click"];
}

+(void)reportCheetahKeyboard_cursor_click:(NSInteger)value inputType:(NSInteger)inputType{
    
    [CMInfoc reportData:@{@"value": value>0 ? @(value) : @(0),
                          @"inputtype": @(inputType)
                          } toTable:@"cheetahkeyboard_cursor_click"];
}

+(void)reportCheetahKeyboard_cursor_action:(NSInteger)value inputType:(NSInteger)inputType{
    
    [CMInfoc reportData:@{@"value": value>0 ? @(value) : @(0),
                          @"inputtype" : @(inputType)
                          } toTable:@"cheetahkeyboard_cursor_action"];
}

+(void)reportCheetahkeyboard_input_str:(NSString *)value lang:(NSString *)lang inputType:(NSInteger)inputType
{
    NSString * reportName = @"cheetahkeyboard_input_str";
    int clktime = (int)time(NULL);
    
    [CMInfoc reportData:@{@"value": value ? value : @"",
                          @"lang":lang ? lang : @"",
                          @"inputtype" : @(inputType),
                          @"clktime" : @(clktime)
                          } toTable:reportName];
}

+(void)reportCheetahkeyboard_input_str_clo:(NSString *)lang inputType:(NSInteger)inputType
{
    NSString * reportName = @"cheetahkeyboard_input_str_clo";
    int clktime = (int)time(NULL);
    [CMInfoc reportData:@{@"lang":lang ? lang : @"",
                          @"inputtype" : @(inputType),
                          @"clktime" : @(clktime)
                          } toTable:reportName];
}

+ (void)report_cheetahkeyboard_switch:(NSInteger)value {
    [CMInfoc reportData:@{@"value": value>0 ? @(value) : @(0)}
                toTable:@"cheetahkeyboard_switch"];
}

+ (void)report_cheetahkeyboard_emoji_switch:(NSInteger)value {
    
    int clktime = (int)time(NULL);
    [CMInfoc reportData:@{@"value":@(value),
                          @"clktime":@(clktime)
                          }
                toTable:@"cheetahkeyboard_emoji_switch"];
}
@end
