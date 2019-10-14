//
//  InfoC.m
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/5.
//  Copyright © 2016年 cm. All rights reserved.
//

#import "InfoC.h"
#import "InfoCReportManager.h"

@implementation InfoC

+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel{
    return [[InfoCReportManager sharedManager] logEvent:eventName
                                         andRecordLevel:recordLevel];
}

//在进入后台时，会自动记录时长，所以无须自行检测切入后台动作
+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                             timed:(BOOL)timed
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel{
    return [[InfoCReportManager sharedManager] logEvent:eventName
                                                  timed:timed
                                         andRecordLevel:recordLevel];
}

+ (void)endTimedEvent:(NSString *)eventName {
    return [[InfoCReportManager sharedManager] endTimedEvent:eventName];
}

+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel
                     andParameters:(NSDictionary *)parameters{
    return [[InfoCReportManager sharedManager] logEvent:eventName
                                         andRecordLevel:recordLevel
                                          andParameters:parameters];
}

//在进入后台时，会自动记录时长，所以无须自行检测切入后台动作
+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                             timed:(BOOL)timed
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel
                     andParameters:(NSDictionary *)parameters{
    return [[InfoCReportManager sharedManager] logEvent:eventName
                                                  timed:timed
                                         andRecordLevel:recordLevel
                                          andParameters:parameters];
}

+ (void)endTimedEvent:(NSString *)eventName
        andParameters:(NSDictionary *)parameters {
    [[InfoCReportManager sharedManager] endTimedEvent:eventName
                                       andParameters:parameters];
}

+ (NSString *)getBussinessIndexWithEventName:(NSString *)eventName {
    if (!eventName || eventName.length == 0) {
        return @"";
    }
    
    if ([eventName isEqualToString:cheetahkeyboard_active]) {
        return @"101";
    }else if ([eventName isEqualToString:cheetahkeyboard_main_active]) {
        return @"102";
    }else if ([eventName isEqualToString:cheetahkeyboard_activate_show]) {
        return @"103";
    }else if ([eventName isEqualToString:cheetahkeyboard_activate_click]) {
        return @"104";
    }else if ([eventName isEqualToString:cheetahkeyboard_main_show]) {
        return @"105";
    }else if ([eventName isEqualToString:cheetahkeyboard_main_theme_click]) {
        return @"106";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_lang]) {
        return @"107";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_lang_chan]) {
        return @"108";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_gene]) {
        return @"109";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_gene_cap]) {
        return @"110";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_corr]) {
        return @"111";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_corr_showcorr]) {
        return @"112";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_corr_autocorr]) {
        return @"113";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_corr_nextsugg]) {
        return @"114";
    }else if([eventName isEqualToString:cheetahkeyboard_emoji]){
        return @"115";
    }else if ([eventName isEqualToString:cheetahkeyboard_emoji_click]){
        return @"116";
    }else if ([eventName isEqualToString:cheetahkeyboard_close]){
        return @"117";
    }else if ([eventName isEqualToString:cheetahkeyboard_switch_nextkey]){
        return @"118";
    }else if ([eventName isEqualToString:cheetahkeyboard_coexist]){
        return @"119";
    }else if ([eventName isEqualToString:cheetahkeyboard_input_collect]){
        return @"120";
    }else if ([eventName isEqualToString:cheetahkeyboard_input_words]){
        return @"121";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_gene_sound]){
        return @"122";
    }else if ([eventName isEqualToString:cheetahkeyboard_set_corr_history]){
        return @"123";
    }else if ([eventName isEqualToString:cheetahkeyboard_tip_show]){
        return @"124";
    }else if ([eventName isEqualToString:cheetahkeyboard_tip_click]){
        return @"125";
    }else if ([eventName isEqualToString:cheetahkeyboard_tip_close]){
        return @"126";
    }else if ([eventName isEqualToString:cheetahkeyboard_setting_fun_click]){
        return @"127";
    }else if ([eventName isEqualToString:cheetahkeyboard_setting_click]){
        return @"128";
    }else if ([eventName isEqualToString:cheetahkeyboard_star]){
        return @"129";
    }else if ([eventName isEqualToString:cheetahkeyboard_main_theme_down]){
        return @"130";
    }else if ([eventName isEqualToString:cheetahkeyboard_main_theme_refresh]){
        return @"131";
    }
    return @"";
}

@end
