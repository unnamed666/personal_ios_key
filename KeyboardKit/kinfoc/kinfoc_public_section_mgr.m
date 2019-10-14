//
//  kinfoc_public_section_mgr.m
//  KEWL
//
//  Created by Jin Ye on 5/5/16.
//  Copyright © 2016 CMCM. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CMMacro.h"
#import "CMAppConfig.h"
#import "NSString+Common.h"

//#import "KEWLMultiLanguage.h"
#import "kinfoc_oc2cpp_adapter.h"

#import "kinfoc_public_section_mgr.h"

@implementation KInfocPublicSectionMgr

- (void) rebuildPublicSection
{
    [self buildPublicSectionInfo];
}

- (NSData*) getPublicSectionData
{
    @synchronized (self) {
        if (nil == m_publicSectionData && nil == m_publicSection) {
            [self buildPublicSectionInfo];
        }
        
        if (nil != m_publicSection) {
            m_publicSectionData = [KInfocOc2CppFunc getPublicSectionBinary:m_publicSection];
            m_publicSection = nil;
        }
        
        return m_publicSectionData;
    }
}

////////////////////////////////////////////////////////////////////////////////

-(void) buildPublicSectionInfo
{
    @synchronized (self) {
        m_publicSection = nil;
        [self addPublicSectionItemValue:@selector(getDeviceID) forKeyName:@"userid"];
        [self addPublicSectionItemValue:@selector(getVersionID) forKeyName:@"ver"];
        [self addPublicSectionItemValue:@selector(getBundleIdentifier) forKeyName:@"pkg_name"];
        [self addPublicSectionItemValue:@selector(getChannel) forKeyName:@"channel"];
        [self addPublicSectionItemValue:@selector(getChannel) forKeyName:@"child_channel"];
        [self addPublicSectionItemValue:@selector(getMCC) forKeyName:@"mcc"];
        [self addPublicSectionItemValue:@selector(getMNC) forKeyName:@"mnc"];
        [self addPublicSectionItemValue:@selector(getCountry) forKeyName:@"country_setting"];
        [self addPublicSectionItemValue:@selector(getLanguage) forKeyName:@"language_setting"];
        [self addPublicSectionItemValue:@selector(getBrand) forKeyName:@"brand"];
        [self addPublicSectionItemValue:@selector(getModel) forKeyName:@"model"];
        [self addPublicSectionItemValue:@selector(getOSVersion) forKeyName:@"osver"];
        [self addPublicSectionItemValue:@selector(getInstalltime) forKeyName:@"installtime"];
        [self addPublicSectionItemValue:@selector(gethorizontalResolution) forKeyName:@"resolution"];
        [self addPublicSectionItemValue:@selector(getDisplay) forKeyName:@"screensize"];

        
//        [self addPublicSectionItemValue:@selector(getXAID) forKeyName:@"xaid"];
//        [self addPublicSectionItemValue:@selector(getMyVersion) forKeyName:@"ver"];
//        [self addPublicSectionItemValue:@selector(getMyVersionCode) forKeyName:@"vercode"];
//        [self addPublicSectionItemValue:@selector(getMCC) forKeyName:@"mcc"];
//        [self addPublicSectionItemValue:@selector(getMNC) forKeyName:@"mnc"];
//        [self addPublicSectionItemValue:@selector(getCL) forKeyName:@"cl"];
//        [self addPublicSectionItemValue:@selector(getChannel) forKeyName:@"channel"];
//        [self addPublicSectionItemValue:@selector(getOSVersion) forKeyName:@"osver"];
//        [self addPublicSectionItemValue:@selector(getAPILevel) forKeyName:@"apilevel"];
//        [self addPublicSectionItemValue:@selector(getBrand) forKeyName:@"brand"];
//        [self addPublicSectionItemValue:@selector(getModel) forKeyName:@"model"];
//        [self addPublicSectionItemValue:@selector(getDisplay) forKeyName:@"display"];
//        [self addPublicSectionItemValue:@selector(getSerial) forKeyName:@"serial"];
//        [self addPublicSectionItemValue:@selector(getLoginType) forKeyName:@"logintype"];
//        [self addPublicSectionItemValue:@selector(getUserId) forKeyName:@"userid"];
//        [self addPublicSectionItemValue:@selector(getLiveId) forKeyName:@"liveid"];
//        [self addPublicSectionItemValue:@selector(getProdId) forKeyName:@"prodid"];
//        [self addPublicSectionItemValue:@selector(getTimeZone) forKeyName:@"tmzone"];
//        [self addPublicSectionItemValue:@selector(getChannel2) forKeyName:@"channel2"];
//        [self addPublicSectionItemValue:@selector(country0) forKeyName:@"country0"];
//        [self addPublicSectionItemValue:@selector(country1) forKeyName:@"country1"];
//        [self addPublicSectionItemValue:@selector(afid) forKeyName:@"afid"];
    }
}

-(void) addPublicSectionItemValue:(SEL) getValueFunc forKeyName:(NSString*) keyName
{
    if (NO == [keyName isNotBlank])
    {
        return;
    }
    
    if ([m_publicSection isNotBlank])
    {
        m_publicSection = [m_publicSection stringByAppendingString:@"&"];
    } else {
        m_publicSection = @"";
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    m_publicSection = [m_publicSection stringByAppendingString:keyName];
    m_publicSection = [m_publicSection stringByAppendingString:@"="];
    NSString* value = [[self class] performSelector:getValueFunc];
    if (nil == value) {
        value = @"";
    }
    m_publicSection = [m_publicSection stringByAppendingString:value];
#pragma clang diagnostic pop
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

+(NSString*) getOSVersion{
    return [CMAppConfig systemVersion];
}

+(NSString*) getModel
{
    return [CMAppConfig deviceModel];
}

+(NSString*) getBrand
{
    // 此字段未使用
    return @"0";
}

+(NSString*)getLanguage{
    return [CMAppConfig currentLanguage];
}

+(NSString*)getCountry{
    return [CMAppConfig country];
}

+(NSString*)getDeviceID{
    return [CMAppConfig deviceId];
}

+ (NSString*)getVersionID{
    return [CMAppConfig buildId];
}

+ (NSString*)getBundleIdentifier{
     return [CMAppConfig bundleIdentifier];
}
+(NSString*) getChannel
{
    // 此字段未使用
    return @"app-store";
}

+(NSString*) getMCC
{
    return [CMAppConfig mobileCountryCode];
}

+(NSString*) getMNC
{
    return [CMAppConfig mobileNetworkCode];
}

//+(NSString*) getXAID
//{
//    return [CMSApp currentApp].deviceID;
//}
//
//+(NSString*) getMyVersion
//{
//    return [CMSApp currentApp].appVersion;
//}
//
//+(NSString*) getMyVersionCode
//{
//    return [CMSApp currentApp].appInternalVersion;
//}
//
//+(NSString*) getMCC
//{
//    return [Common mobileCountryCode];
//}
//
//+(NSString*) getMNC
//{
//    return [Common mobileNetworkCode];
//}
//
//+(NSString*) getCL
//{
//    return [CMSApp currentApp].currentLanguage;
//}
//
//+(NSString*) getChannel
//{
//    // 此字段未使用
//    return @"";
//}
//
//+(NSString*) getOSVersion
//{
//    return [CMSApp currentApp].systemVersion;
//}
//
//+(NSString*) getAPILevel
//{
//    // 此字段未使用
//    return @"";
//}
//
//+(NSString*) getBrand
//{
//    // 此字段未使用
//    return @"";
//}
//
//+(NSString*) getModel
//{
//    return [CMSApp currentApp].deviceModel;
//}
//
//+(NSString*) getDisplay
//{
//    return [NSString stringWithFormat:@"%fx%f", [Common screenWidth], [Common screenHeight]];
//}
//
//+(NSString*) getSerial
//{
//    return [CMSApp currentApp].advertisingIdentifier;
//}
//
//+(NSString*) getLoginType
//{
//    // 此字段未使用
//    return @"";
//}
//
//+(NSString*) getUserId
//{
//    if (NO == [kCurrentUser isGuest]) {
//        return kCurrentUser.uId;
//    } else {
//        return [KInfocPublicSectionMgr getXAID];
//    }
//}
//
//+(NSString*) getLiveId
//{
//    // 此字段未使用
//    return @"";
//}
//
//+(NSString*) getProdId
//{
////    if([KEWLMultiLanguage isJpVersion])
////        return @"3";
//    return @"2";
//}
//
//+(NSString*) getTimeZone
//{
//    NSTimeZone* tz = [NSTimeZone localTimeZone];
//    if (nil == tz) {
//        return @"";
//    }
//    
//    // 与Android版上报的数据保持一致。为了让infoc里收到的都是正数，所以要加上12。
//    NSString* rst = [[NSString alloc] initWithFormat:@"%ld",[tz secondsFromGMT] / (60 * 60) + 12];
//    return rst;
//}
//
//+(NSString*) getChannel2
//{
//    // 此字段未使用
//    return @"";
//}
//
//+(NSString*) country0
//{
//    // 终身分区
//    NSString* rst = kCurrentUser.userInfo.countryCode;
//    return [rst isNotBlank] ? rst : @"-1";
//}
//
//+(NSString*) country1
//{
//    // 当前分区
//    NSString* rst = [CMSApp currentApp].isoCountryCode;
//    return [rst isNotBlank] ? rst : @"-1";
//}
//
//+(NSString*) afid
//{
//    // appsflyer 设备ID
//    return [Common afid];
//}

@end
