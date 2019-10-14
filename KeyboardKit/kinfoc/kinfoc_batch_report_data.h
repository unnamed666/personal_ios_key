//
//  kinfoc_batch_report_data.h
//  KEWL
//
//  Created by Jin Ye on 5/6/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

@protocol KInfocBatchReportDataAdapter <NSObject>

- (KInfocPublicSectionMgr*) getPublicSectionMgr;
- (NSInteger) getProductID;
- (void) postBatchData:(NSData*) pBatchData withPriority:(emKInfoPriority) nPriority;

@end

@interface KInfocBatchReportData : NSObject
{
    @private
    NSArray* m_pPriorityBatchData;
    __weak id<KInfocBatchReportDataAdapter> m_Adapter;
}

-(id) initWithAdapter:(id<KInfocBatchReportDataAdapter>) adapter;

-(void) addData:(NSData*) pData forPriority:(emKInfoPriority) nPriority;
-(void) flush;

@end
