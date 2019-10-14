//
//  kinfoc_cachefile_mgr.h
//  KEWL
//
//  Created by Jin Ye on 5/5/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import "kinfoc_control.h"

@protocol KInfocCacheFileMgrAdapter <NSObject>

- (NSInteger) getValidityDays;
- (void) postCacheData:(NSData*) pCacheData withPriority:(emKInfoPriority) nPriority
            andPostResultCallback:(void (^)(BOOL)) rstCallback byForce:(BOOL) isForceReport;

@end

@interface KInfocCacheFileMgr : NSObject
{
@private
    __weak id<KInfocCacheFileMgrAdapter> m_Adapter;
    
    NSOperationQueue* m_OpQueueForNormalData;
    NSOperationQueue* m_OpQueueForForceData;
    
    NSMutableSet* m_setFilterRptDataPathNormal;
    NSMutableSet* m_setFilterRptDataPathForce;
}

-(id) initWithAdapter:(id<KInfocCacheFileMgrAdapter>) adapter;

-(void) saveDataCache:(NSData*) pBinData withPriority:(emKInfoPriority) nPriority
            forForceReport:(BOOL) isForceReport;
-(void) checkForceCacheFile;
-(void) checkNormalCacheFile;

@end