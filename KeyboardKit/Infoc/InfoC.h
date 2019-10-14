//
//  InfoC.h
//  CMInstanews
//
//  Created by 唱宏博 on 16/5/5.
//  Copyright © 2016年 cm. All rights reserved.
//


/*
 需要引用的Framework有:
 1.CoreTelephony
 2.Foundation
 3.AdSupport
 */

#import <UIKit/UIKit.h>

//按需要自行定义事件
//change
#define cheetahkeyboard_activate_click        @"cheetahkeyboard_activate_click"     //104
#define cheetahkeyboard_active                @"cheetahkeyboard_active"      //101
#define cheetahkeyboard_main_active            @"cheetahkeyboard_main_active"  //102
#define cheetahkeyboard_activate_show               @"cheetahkeyboard_activate_show"    //103
#define cheetahkeyboard_main_show               @"cheetahkeyboard_main_show"     //105
#define cheetahkeyboard_main_theme_click     @"cheetahkeyboard_main_theme_click"    //107
#define cheetahkeyboard_set_lang               @"cheetahkeyboard_set_lang"     //108

#define cheetahkeyboard_set_lang_chan            @"cheetahkeyboard_set_lang_chan"         //109
#define cheetahkeyboard_set_gene              @"cheetahkeyboard_set_gene"    //110
#define cheetahkeyboard_set_gene_cap  @"cheetahkeyboard_set_gene_cap" //111
#define cheetahkeyboard_set_corr          @"cheetahkeyboard_set_corr"    //112
#define cheetahkeyboard_set_corr_showcorr                  @"cheetahkeyboard_set_corr_showcorr"        //113
#define cheetahkeyboard_set_corr_autocorr                 @"cheetahkeyboard_set_corr_autocorr"       //114
#define cheetahkeyboard_set_corr_nextsugg      @"cheetahkeyboard_set_corr_nextsugg"  //115
//add
#define cheetahkeyboard_emoji          @"cheetahkeyboard_emoji"        //116
#define cheetahkeyboard_emoji_click          @"cheetahkeyboard_emoji_click"       //117
#define cheetahkeyboard_close             @"cheetahkeyboard_close"   //118
#define cheetahkeyboard_switch_nextkey            @"cheetahkeyboard_switch_nextkey"  //119
#define cheetahkeyboard_coexist                 @"cheetahkeyboard_coexist"       //120

#define cheetahkeyboard_input_collect               @"cheetahkeyboard_input_collect"     //121
#define cheetahkeyboard_input_words       @"cheetahkeyboard_input_words"  //122
#define cheetahkeyboard_set_gene_sound               @"cheetahkeyboard_set_gene_sound"     //123
#define cheetahkeyboard_set_corr_history               @"cheetahkeyboard_set_corr_history"     //124
#define cheetahkeyboard_tip_show                 @"cheetahkeyboard_tip_show"       //125
#define cheetahkeyboard_tip_click                   @"cheetahkeyboard_tip_click"         //126
#define cheetahkeyboard_tip_close               @"cheetahkeyboard_tip_close"     //127
#define cheetahkeyboard_setting_fun_click               @"cheetahkeyboard_setting_fun_click"     //128
#define cheetahkeyboard_setting_click              @"cheetahkeyboard_setting_click"    //129
#define cheetahkeyboard_star            @"cheetahkeyboard_star"  //130
#define cheetahkeyboard_main_theme_down              @"cheetahkeyboard_main_theme_down"    //131
#define cheetahkeyboard_main_theme_refresh                 @"cheetahkeyboard_main_theme_refresh"       //132


#define INFOC_ApiV   @"7"

typedef NS_ENUM (NSInteger, InfoCEventRecordStatus) {
    InfoCEventFailedWithoutApiKey    = 0,
    InfoCEventFailedWithoutEventName = 1,
    InfoCEventRecorded               = 2
};

typedef NS_ENUM (NSInteger, InfoCEventRecordLevel) {
    InfoCEventRecordLevelUploadNow    = 0, //立即上报
    InfoCEventRecordLevelUploadLater  = 1  //稍后上报，程序进入后台时进行上报，一般用于数量统计
//    InfoCEventRecordLevelLocal        = 2
};

@interface InfoC : NSObject

#pragma mark -
#pragma mark InfoC配置方法

#pragma mark -
#pragma mark 计数上报方法
+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel;
+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel
                     andParameters:(NSDictionary *)parameters;
#pragma mark -
#pragma mark 时长上报方法
+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                             timed:(BOOL)timed
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel;
+ (InfoCEventRecordStatus)logEvent:(NSString *)eventName
                             timed:(BOOL)timed
                    andRecordLevel:(InfoCEventRecordLevel)recordLevel
                     andParameters:(NSDictionary *)parameters;
#pragma mark -
#pragma mark 关闭时长上报方法
+ (void)endTimedEvent:(NSString *)eventName;
+ (void)endTimedEvent:(NSString *)eventName
        andParameters:(NSDictionary *)parameters;

#pragma mark -
#pragma mark 工具方法
+ (NSString *)getBussinessIndexWithEventName:(NSString *)eventName;
@end
