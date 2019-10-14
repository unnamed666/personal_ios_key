//
//  kinfoc_control.mm
//  KEWL
//
//  Created by Jin Ye on 4/26/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#include "core/stdafx.h"
#include "core/KIniWrap.h"

#import "kinfoc_config.h"
#import "kinfoc_control.h"



@implementation KInfoControl

- (id) init {
    m_bInited = false;
    if (self = [super init]) {
        m_pKCtrlDatReader = new KIniWrap();
//        NSString *configFilePath =
//        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/kctrl.dat"];
        NSString * mainPath = [[NSBundle mainBundle] resourcePath];
        NSRange range;
        range = [mainPath rangeOfString:@"PlugIns"];
        if(range.location != NSNotFound){
            mainPath = [mainPath substringToIndex:range.location];
        }
        NSString* configFilePath = [mainPath stringByAppendingPathComponent:@"Frameworks/KeyboardKit.framework/kctrl.dat"];
        if (mainPath && mainPath.length > 0)
        {
            K_BOOL bRst = ((KIniWrap*)m_pKCtrlDatReader)->LoadFile([configFilePath UTF8String]);
            if (FALSE != bRst)
            {
                m_bInited = true;
            }
        }
    }
    
    return self;
}

- (void) dealloc {
    if (NULL != m_pKCtrlDatReader) {
        delete ((KIniWrap*)m_pKCtrlDatReader);
        m_pKCtrlDatReader = NULL;
    }
}

- (bool) isInited
{
    return m_bInited;
}

- (NSInteger) getProductID
{
    if (!m_bInited)
    {
        return 0;
    }
    NSAssert(NULL != m_pKCtrlDatReader, @"m_pKCtrlDatReader is NULL.");
    return ((KIniWrap*)m_pKCtrlDatReader)->Read("common", "product", 0);
}

- (NSInteger) getValidityDays
{
    if (!m_bInited)
    {
        return 0;
    }
    NSAssert(NULL != m_pKCtrlDatReader, @"m_pKCtrlDatReader is NULL.");
    return ((KIniWrap*)m_pKCtrlDatReader)->Read("common", "validity", 0);
}

- (NSInteger) getProbability:(NSString*) strTableName
{
    int nProbability = MAX_PROBABILITY;
    if (!m_bInited)
    {
        return nProbability;
    }
    NSAssert(NULL != m_pKCtrlDatReader, @"m_pKCtrlDatReader is NULL.");
    return ((KIniWrap*)m_pKCtrlDatReader)->Read([strTableName UTF8String], "probability", nProbability);
}

- (NSInteger) getUserProbability:(NSString*) strTableName
{
    int nProbability = MAX_PROBABILITY;
    if (!m_bInited)
    {
        return nProbability;
    }
    NSAssert(NULL != m_pKCtrlDatReader, @"m_pKCtrlDatReader is NULL.");
    return ((KIniWrap*)m_pKCtrlDatReader)->Read([strTableName UTF8String], "userprobability", nProbability);
}

- (NSString*) getServerUrl:(emKInfoPriority) nPriority
{
#ifndef RELEASE_PRODUCT
    return @"http://118.89.55.235/c/";
#endif

    if (!m_bInited)
    {
        return [KInfocConfig getDefaultServerUrl];
    }
    NSAssert(NULL != m_pKCtrlDatReader, @"m_pKCtrlDatReader is NULL.");
    CString strKeyName;
    strKeyName.Format("%s%d", "server", (int)nPriority);
    LPCWSTR szUrl = ((KIniWrap*)m_pKCtrlDatReader)->Read("common", (LPCWSTR)strKeyName,
                                            [[KInfocConfig getDefaultServerUrl] UTF8String]);
    if (NULL == szUrl || '\0' == szUrl[0])
    {
        return [KInfocConfig getDefaultServerUrl];
    }
    
    return [[NSString alloc] initWithUTF8String:szUrl];
}

@end
