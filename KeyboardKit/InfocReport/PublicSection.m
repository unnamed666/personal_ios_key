//
//  HeaderGenerator.m
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "PublicSection.h"
#import "CMAppConfig.h"
#import "CMMacro.h"
@implementation PublicSection

+ (NSDictionary*)querys
{
    NSDictionary *result = @{// gridios_public:4 uuid:binary action:int ver:string lang:string country:string osver:string model:string net:bit
                             //                  newuser:byte newusertime:int slogin:byte mcc:short mnc:short uptime:int uid:string
                             //cheetahkeyboard_public:1 userid:string ver:string channel:string pkg_name:string child_channel:string mcc:short mnc:short language_setting:string brand:string model:string country_setting:string osver:string installtime:int resolution:short screensize:string
                             @"public_index" : @(1),
                             @"userid" : [self getDeviceID],
                             @"ver" : [self getVersionID],
                             @"channel" : [self getChannel],
                             @"pkg_name" : [self getBundleIdentifier],
                             @"child_channel" : [self getChannel],
                             @"mcc" : [self getMCC],
                             @"mnc" : [self getMNC],
                             @"language_setting" : [self getLanguage],
                             @"brand" : [self getBrand],
                             @"model" : [self getModel],
                             @"country_setting" : [self getCountry],
                             @"osver" : [self getOSVersion],
                             @"installtime" : [self getInstalltime],
                             @"resolution" : [self gethorizontalResolution],
                             @"screensize" : [self getDisplay]
                             };
    
    return result;
}
#pragma mark - 参数配置
+(NSString*)getDeviceID{
    return [CMAppConfig deviceId];
}
+ (NSString*)getVersionID{
    return [CMAppConfig buildId];
}
+(NSString*) getChannel
{
    // 此字段未使用
    return @"app-store";
}
+ (NSString*)getBundleIdentifier{
    return [CMAppConfig bundleIdentifier];
}
+(NSString*) getMCC
{
    return [CMAppConfig mobileCountryCode];
}
+(NSString*) getMNC
{
    return [CMAppConfig mobileNetworkCode];
}
+(NSString*)getLanguage{
    return [CMAppConfig currentLanguage];
}
 +(NSString*) getBrand{
        // 此字段未使用
        return @"0";
}
+(NSString*) getModel
{
    return [CMAppConfig deviceModel];
}
+(NSString*)getCountry{
    return [CMAppConfig country];
}
+(NSString*) getOSVersion{
    return [CMAppConfig systemVersion];
}
+(NSString*) getInstalltime{
    return  [CMAppConfig firstLaunchTime];
}

+(NSString*) gethorizontalResolution{
    return [NSString stringWithFormat:@"%d", (int)[CMAppConfig horizontalResolution]];
}

+(NSString*) getDisplay
{
    return [NSString stringWithFormat:@"%dx%d", (int)kScreenWidth, (int)kScreenHeight];
}

@end
