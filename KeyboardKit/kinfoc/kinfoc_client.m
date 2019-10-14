//
//  kinfoc_client.m
//  KEWL
//
//  Created by Jin Ye on 4/26/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#include <sys/time.h>
#include <time.h>

#import "kinfoc_log.h"
#import "kinfoc_config.h"
#import "kinfoc_httpposter.h"
#import "kinfoc_oc2cpp_adapter.h"
#import "CMBizHelper.h"
#import "NSString+Common.h"

#import "kinfoc_client.h"

@interface HttpPostResultImpl : NSObject <HttpPostResult>
{
    @private
    BOOL m_isForce;
    NSData* m_pData;
    NSString* m_strLogTag;
    emKInfoPriority m_nPriority;
    KInfocCacheFileMgr* m_pCacheFileMgr;
    void (^m_Callback)(BOOL);
}

- (id) initWithData: (NSData*) pData withLogTag:(NSString*) tag
            andPriority:(emKInfoPriority) nPriority
            andCacheFileMgr:(KInfocCacheFileMgr*) pCacheFileMgr
            forForceReport:(BOOL) isForce;
- (id) initWithData: (NSData*) pData withLogTag:(NSString*) tag
        andPriority:(emKInfoPriority) nPriority
        andCacheFileMgr:(KInfocCacheFileMgr*) pCacheFileMgr
        andPostResultCallback:(void (^)(BOOL)) rstCallback
        forForceReport:(BOOL) isForce;

@end

@implementation HttpPostResultImpl

- (id) initWithData: (NSData*) pData withLogTag:(NSString*) tag
            andPriority:(emKInfoPriority) nPriority
            andCacheFileMgr:(KInfocCacheFileMgr*) pCacheFileMgr
            forForceReport:(BOOL) isForce
{
    return [self initWithData:pData withLogTag:tag andPriority:nPriority
       andCacheFileMgr:pCacheFileMgr andPostResultCallback:nil forForceReport:isForce];
}

- (id) initWithData: (NSData*) pData withLogTag:(NSString*) tag
        andPriority:(emKInfoPriority) nPriority
        andCacheFileMgr:(KInfocCacheFileMgr*) pCacheFileMgr
        andPostResultCallback:(void (^)(BOOL)) rstCallback
        forForceReport:(BOOL) isForce
{
    if (self = [super init]) {
        m_pData = pData;
        m_strLogTag = tag;
        m_nPriority = nPriority;
        m_pCacheFileMgr = pCacheFileMgr;
        m_isForce = isForce;
        m_Callback = rstCallback;
    }
    
    return self;
}

- (void) onSuccess
{
    if (nil != m_Callback) {
        m_Callback(YES);
        return;
    }
    
    [m_pCacheFileMgr checkForceCacheFile];
    if (NO == m_isForce) {
        [m_pCacheFileMgr checkNormalCacheFile];
    }
}

- (void) onFail
{
    KkLog(@"[KINFOC]\t###### report failed!!! {%@:%lu}", m_strLogTag, (unsigned long)[m_pData hash]);
    
    if (nil != m_Callback) {
        m_Callback(NO);
        return;
    }
    
    // 记录缓存，下次再报。
    [m_pCacheFileMgr saveDataCache:m_pData withPriority:m_nPriority forForceReport:m_isForce];
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation KInfocClient

static KInfocClient* sg_instance = nil;
+ (KInfocClient*) getInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        sg_instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return sg_instance ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [KInfocClient getInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [KInfocClient getInstance] ;
}

- (id) init
{
    if (self = [super init])
    {
        [self createPoster];
        [self createKCtrol];
        [self createPublicSectionMgr];
        [self createCacheFileMgr];
        [self createBatchRptData];
        m_dicForUserProbability = [[NSMutableDictionary alloc] init];
        m_bStopRpt = NO;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// KInfocBatchReportDataAdapter

- (KInfocPublicSectionMgr*) getPublicSectionMgr
{
    return m_pPublicSectionMgr;
}

- (NSInteger) getProductID
{
    return m_nProductId;
}

- (void) postBatchData:(NSData*) pBatchData withPriority:(emKInfoPriority) nPriority
{
    if (NO != [CMBizHelper isWifiNetWork]) {
        [m_pPoster postData:pBatchData
                     toUrl:[m_pKCtrl getServerUrl:nPriority]
                     andResultCall:[[HttpPostResultImpl alloc]
                                    initWithData:pBatchData withLogTag:@"*BatchReport*"
                                    andPriority:nPriority
                                    andCacheFileMgr:m_pCacheFileMgr
                                    forForceReport:NO]];// 批量上报的肯定不是强制上报
    } else {
        [m_pCacheFileMgr saveDataCache:pBatchData withPriority:nPriority forForceReport:NO];// 批量上报的肯定不是强制上报
    }
}

////////////////////////////////////////////////////////////////////////////////
// KInfocCacheFileMgrAdapter

- (NSInteger) getValidityDays
{
    return [m_pKCtrl getValidityDays];
}

- (void) postCacheData:(NSData*) pCacheData withPriority:(emKInfoPriority) nPriority
 andPostResultCallback:(void (^)(BOOL)) rstCallback byForce:(BOOL) isForceReport
{
    [m_pPoster postData:pCacheData
                         toUrl:[m_pKCtrl getServerUrl:nPriority]
                         andResultCall:[[HttpPostResultImpl alloc]
                                initWithData:pCacheData withLogTag:@"*CacheReport*"
                                andPriority:nPriority
                                andCacheFileMgr:m_pCacheFileMgr
                                andPostResultCallback:rstCallback
                                forForceReport:isForceReport]];
}

////////////////////////////////////////////////////////////////////////////////

- (void) rebuildPublicSection
{
    [m_pBatchReportData flush];
    [self createPublicSectionMgr];
}

- (void) stopReport
{
    m_bStopRpt = YES;
}

- (BOOL) needReportData:(NSString*) tableName byReCalcUserProbability:(BOOL) reCalcUserProbability
{
    if (m_bStopRpt) {
        return NO;
    }
    
    @synchronized (m_dicForUserProbability) {
        if (NO == reCalcUserProbability) {
            NSNumber* needRpt = [m_dicForUserProbability valueForKey:tableName];
            if (nil != needRpt) {
                return [needRpt boolValue];
            }
        }
        
        NSInteger userProbability = [m_pKCtrl getUserProbability:tableName];
        if (0 == userProbability) {
            [m_dicForUserProbability setValue:[NSNumber numberWithBool:NO] forKey:tableName];
            return NO;
        } else if (userProbability < MAX_PROBABILITY &&
                   (arc4random() % (MAX_PROBABILITY)) > userProbability) {
            [m_dicForUserProbability setValue:[NSNumber numberWithBool:NO] forKey:tableName];
            return NO;
        }
        
        [m_dicForUserProbability setValue:[NSNumber numberWithBool:YES] forKey:tableName];
    }
    
    NSInteger probability = [m_pKCtrl getProbability:tableName];
    if (0 == probability) {
        return NO;
    } else if (probability < MAX_PROBABILITY &&
               (arc4random() % (MAX_PROBABILITY)) > probability) {
        return NO;
    }
    
    return YES;
}

- (void) reportData:(NSDictionary*) dataDic toTable:(NSString*) tableName
{
    [self doReportData:[self dictionary2String:dataDic] toTable:tableName byForce:NO];
}

- (void) forceReportData:(NSDictionary*) dataDic toTable:(NSString*) tableName
{
    [self doReportData:[self dictionary2String:dataDic] toTable:tableName byForce:YES];
}

////////////////////////////////////////////////////////////////////////////////

-(NSString*) dictionary2String:(NSDictionary*) dataDic
{
    if (nil == dataDic || 0 == [dataDic count]) {
        return nil;
    }
    
    NSString* value = nil;
    NSString* rstData = @"";
    for (NSString* key in [dataDic allKeys]) {
        if (NO == [key isNotBlank]) {
            continue;
        }
        
        if ([rstData isNotBlank]) {
            rstData = [rstData stringByAppendingString:@"&"];
        }
        
        value = dataDic[key];
        rstData = [rstData stringByAppendingFormat:@"%@=%@", key, (nil != value ? value : @"")];
    }
    
    if (NO == [rstData isNotBlank]) {
        return nil;
    }
    
    return rstData;
}

- (void) doReportData:(NSString*) dataString toTable:(NSString*) tableName byForce:(BOOL) isForceReport
{
    if (m_bStopRpt) {
        return;
    }
    
    if (NO == [tableName isNotBlank]) {
        return;
    }
    
    if (NO == isForceReport) {
        if (NO == [KInfocConfig didUserAllowedUploadInfo])
        {
            return;
        }
    }
    
    if (nil == m_pPoster) {
        [self createPoster];
        if (nil == m_pPoster) {
            return;
        }
    }
    
    if (nil == m_pKCtrl) {
        [self createKCtrol];
        if (nil == m_pKCtrl) {
            return;
        }
    }
    
    if (nil == m_pPublicSectionMgr) {
        [self createPublicSectionMgr];
        if (nil == m_pPublicSectionMgr) {
            return;
        }
    }
    
    if (nil == m_pCacheFileMgr) {
        [self createCacheFileMgr];
        if (nil == m_pCacheFileMgr) {
            return;
        }
    }
    
    if (nil == m_pBatchReportData) {
        [self createBatchRptData];
        if (nil == m_pBatchReportData) {
            return;
        }
    }
    
    if (NO == [self needReportData:tableName byReCalcUserProbability:NO]) {
        return;
    }
    
//    if (nil == dataString || (NO == [dataString hasPrefix:@"uptime2="] && NO == [dataString containsString:@"&uptime2="])) {
//        if ([dataString isNotBlank]) {
//            dataString = [dataString stringByAppendingString:@"&uptime2="];
//        } else {
//            dataString = @"uptime2=";
//        }
//        
//        dataString = [dataString stringByAppendingFormat:@"%d", (int)time(NULL)];
//    }
//    
//    if (nil == dataString || (NO == [dataString hasPrefix:@"data="] && NO == [dataString containsString:@"&data="])) {
//        if ([dataString isNotBlank]) {
//            dataString = [dataString stringByAppendingString:@"&data="];
//        } else {
//            dataString = @"data=";
//        }
//        
//        dataString = [dataString stringByAppendingString:[Common commonNetType2InfocNetType:[Common getNetType]]];
//    }

    NSData* pDataSection = [KInfocOc2CppFunc getDataSectionBinary:dataString forTable:tableName];
    if (nil == pDataSection) {
        NSAssert(false, @"[KINFOC]\t###### format error!!! TableName:%@, data:%@", tableName, dataString);
        return;
    } else {
        KkLog(@"[KINFOC] (%d) %@: %@", isForceReport, tableName, dataString);
    }
    
    emKInfoPriority nPriority = Normal;
    if (NO == isForceReport) {
        [m_pBatchReportData addData:pDataSection forPriority:nPriority];
    } else {
        NSData* pBinData = [KInfocOc2CppFunc buildReportDataForProduct:m_nProductId
                                byPublicSection:[m_pPublicSectionMgr getPublicSectionData]
                                andDataSection:pDataSection];
        if (nil == pBinData || pBinData.length <= 0) {
            NSAssert(false,
                 @"[KINFOC]\t****** maybe public section error!!! TableName:%@, data:%@",
                 tableName, dataString);
        } else {
            KkLog(@"[KINFOC] before rpt: {%@:%lu}", tableName, (unsigned long)[pBinData hash]);
        
        }
        if (NO != [CMBizHelper hasNetWork]) {
            [m_pPoster postData:pBinData
                        toUrl:[m_pKCtrl getServerUrl:nPriority]
                        andResultCall:[[HttpPostResultImpl alloc]
                            initWithData:pBinData withLogTag:tableName
                            andPriority:nPriority andCacheFileMgr:m_pCacheFileMgr
                            forForceReport:YES]];
        } else {
            [m_pCacheFileMgr saveDataCache:pBinData withPriority:nPriority forForceReport:YES];
        }
    }
}

-(void) createKCtrol
{
    @synchronized (self) {
        m_pKCtrl = [[KInfoControl alloc] init];
        if (nil != m_pKCtrl && ![m_pKCtrl isInited])
        {
            m_pKCtrl = nil;
        }
        
        if (nil != m_pKCtrl)
        {
            m_nProductId = [m_pKCtrl getProductID];
            m_nValidityDays = [m_pKCtrl getValidityDays];
        }
    }
}

-(void) createPoster
{
    @synchronized (self) {
        m_pPoster = [[KInfocHttpPoster alloc] init];
    }
}

-(void) createPublicSectionMgr
{
    @synchronized (self) {
        m_pPublicSectionMgr = [[KInfocPublicSectionMgr alloc] init];
        [m_pPublicSectionMgr rebuildPublicSection];
    }
}

-(void) createCacheFileMgr
{
    @synchronized (self) {
        m_pCacheFileMgr = [[KInfocCacheFileMgr alloc] initWithAdapter:self];
    }
}

-(void) createBatchRptData
{
    @synchronized (self) {
        m_pBatchReportData = [[KInfocBatchReportData alloc] initWithAdapter:self];
    }
}

@end
