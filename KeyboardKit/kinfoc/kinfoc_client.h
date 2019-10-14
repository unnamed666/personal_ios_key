//
//  kinfoc_client.h
//  KEWL
//
//  Created by Jin Ye on 4/26/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import "kinfoc_control.h"
#import "kinfoc_httpposter.h"
#import "kinfoc_public_section_mgr.h"
#import "kinfoc_cachefile_mgr.h"
#import "kinfoc_batch_report_data.h"

@interface KInfocClient : NSObject <KInfocBatchReportDataAdapter, KInfocCacheFileMgrAdapter>
{
    @private
    KInfoControl* m_pKCtrl;
    NSInteger m_nProductId;
    NSInteger m_nValidityDays;
    NSMutableDictionary* m_dicForUserProbability;
    
    KInfocHttpPoster* m_pPoster;
    KInfocPublicSectionMgr* m_pPublicSectionMgr;
    KInfocCacheFileMgr* m_pCacheFileMgr;
    KInfocBatchReportData* m_pBatchReportData;
    
    BOOL m_bStopRpt;
}

/// singleton
+ (KInfocClient*) getInstance;

/// KInfocClient functions
- (void) rebuildPublicSection;
- (void) stopReport;
- (BOOL) needReportData:(NSString*) tableName byReCalcUserProbability:(BOOL) reCalcUserProbability;
- (void) reportData:(NSDictionary*) dataDic toTable:(NSString*) tableName;
- (void) forceReportData:(NSDictionary*) dataDic toTable:(NSString*) tableName;

@end
