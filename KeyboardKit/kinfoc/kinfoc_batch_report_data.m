//
//  kinfoc_batch_report_data.m
//  KEWL
//
//  Created by Jin Ye on 5/6/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import <Foundation/NSArray.h>

#import "kinfoc_control.h"
#import "kinfoc_public_section_mgr.h"
#import "kinfoc_oc2cpp_adapter.h"
#import "kinfoc_httpposter.h"

#import "kinfoc_batch_report_data.h"


#define MIN_BATCH_REPORT_FILE_COUNT 30


@implementation KInfocBatchReportData

-(id) initWithAdapter:(id<KInfocBatchReportDataAdapter>) adapter
{
    if (self = [super init]) {
        m_Adapter = adapter;
        NSAssert(nil != adapter, @"KInfocBatchReportData: adapter is nil");
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////

-(void) addData:(NSData*) pData forPriority:(emKInfoPriority) nPriority
{
    if (nil == pData || pData.length <= 0 || nPriority <= Unknow || nPriority >= End) {
        return;
    }
    
    @synchronized (self) {
        if (nil == m_pPriorityBatchData) {
            m_pPriorityBatchData = [[NSArray alloc] initWithObjects:
                                    [NSMutableArray arrayWithCapacity:0],
                                    [NSMutableArray arrayWithCapacity:0],
                                    [NSMutableArray arrayWithCapacity:0],
                                    [NSMutableArray arrayWithCapacity:0], nil];
            NSAssert(m_pPriorityBatchData.count >= End, @"m_pPriorityBatchData.count < End");
        }
        
        NSMutableArray* dataArray = m_pPriorityBatchData[nPriority];
        [dataArray addObject:pData];
        if (dataArray.count >= MIN_BATCH_REPORT_FILE_COUNT) {
            [self flush];
            return;
        }
        
        [self performSelectorOnMainThread:@selector(runOnMainThread) withObject:nil waitUntilDone:NO];
    }
}

-(void) flush
{
    @synchronized (self) {
        id<KInfocBatchReportDataAdapter> adapter = m_Adapter;
        if (nil == m_pPriorityBatchData || nil == adapter) {
            return;
        }
        
        NSData* pPubData = [[adapter getPublicSectionMgr] getPublicSectionData];
        if (nil == pPubData || pPubData.length <= 0) {
            return;
        }
        
        NSInteger prodId = [adapter getProductID];
        
        BOOL needRpt = NO;
        NSMutableData* rptData;
        for (emKInfoPriority nPriority = High; nPriority < End; ++nPriority) {
            NSMutableArray* dataArray = m_pPriorityBatchData[nPriority];
            if (dataArray.count <= 0) {
                continue;
            }
            
            for (NSData* pData in dataArray) {
LOOP_WITHOUT_ITERATION:
                if (nil == rptData) {
                    rptData = [KInfocOc2CppFunc buildReportDataHeader:pPubData];
                    if (nil == rptData) {
                        return;
                    }
                    needRpt = NO;
                }
                
                if (NO == [KInfocOc2CppFunc addReportData:pData toDataObj:rptData]) {
                    [KInfocOc2CppFunc finishBuildBatchReportDataForProduct:prodId withDataObj:rptData];
                    
                    [adapter postBatchData:rptData withPriority:nPriority];
                    
                    rptData = nil;
                    needRpt = NO;
                    goto LOOP_WITHOUT_ITERATION;
                } else {
                    needRpt = YES;
                }
            }
            
            if (YES == needRpt && nil != rptData && rptData.length > 0) {
                [KInfocOc2CppFunc finishBuildBatchReportDataForProduct:prodId withDataObj:rptData];
                
                [adapter postBatchData:rptData withPriority:nPriority];
                
                rptData = nil;
                needRpt = NO;
            }
            
            [dataArray removeAllObjects];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

#define REPORT_INTERVAL_SECONDS (3 * 60)

- (void) runOnMainThread
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(flush) withObject:nil afterDelay:REPORT_INTERVAL_SECONDS];
}

@end
