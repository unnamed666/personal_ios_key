//
//  kinfoc_cachefile_mgr.m
//  KEWL
//
//  Created by Jin Ye on 5/5/16.
//  Copyright © 2016 CMCM. All rights reserved.
//
#include <sys/time.h>
#import <Foundation/Foundation.h>

#import "CMBizHelper.h"
#import "NSString+Common.h"

#import "kinfoc_cachefile_mgr.h"

@implementation KInfocCacheFileMgr

-(id) initWithAdapter:(id<KInfocCacheFileMgrAdapter>) adapter;
{
    if (self = [super init]) {
        m_Adapter = adapter;
        NSAssert(nil != adapter, @"KInfocCacheFileMgr: adapter is nil");
        
        m_setFilterRptDataPathForce = [[NSMutableSet alloc] init];
        m_OpQueueForForceData = [[NSOperationQueue alloc] init];
        [m_OpQueueForForceData setMaxConcurrentOperationCount:1];
        
        m_setFilterRptDataPathNormal = [[NSMutableSet alloc] init];
        m_OpQueueForNormalData = [[NSOperationQueue alloc] init];
        [m_OpQueueForNormalData setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////

-(void) saveDataCache:(NSData*) pBinData withPriority:(emKInfoPriority) nPriority
       forForceReport:(BOOL) isForceReport
{
    if (nil == pBinData || pBinData.length <= 0 ||
        nPriority <= Unknow || nPriority >= End) {
        return;
    }
    
    NSOperationQueue* opQueue;
    if (YES == isForceReport) {
        opQueue = m_OpQueueForForceData;
    } else {
        opQueue = m_OpQueueForNormalData;
    }
    
    if (nil == opQueue) {
        return;
    }
    
    [opQueue addOperationWithBlock:^{
        NSString* path = [self getInfocCacheFolderPath:isForceReport];
        path = [self createUniqueCacheFileNameForPriority:nPriority inTheFolder:path];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm createFileAtPath:path contents:pBinData attributes:nil];
    }];
}

////////////////////////////////////////////////////////////////////////////////

-(void) checkForceCacheFile
{
    [self checkCacheFiles:YES];
}

////////////////////////////////////////////////////////////////////////////////

-(void) checkNormalCacheFile
{
    [self checkCacheFiles:NO];
}

////////////////////////////////////////////////////////////////////////////////

-(void) checkCacheFiles:(BOOL) isForceReport
{
    NSMutableSet* filterSet;
    NSOperationQueue* opQueue;
    if (YES == isForceReport) {
        filterSet = m_setFilterRptDataPathForce;
        opQueue = m_OpQueueForForceData;
    } else {
        filterSet = m_setFilterRptDataPathNormal;
        opQueue = m_OpQueueForNormalData;
    }
    
    if (nil == opQueue) {
        return;
    }
    
    [opQueue addOperationWithBlock:^{
        id<KInfocCacheFileMgrAdapter> adapter = m_Adapter;
        if (nil == adapter) {
            return;
        }
        
        if (NO == [self checkNetForReport:isForceReport]) {
            return;
        }
        
        NSString* path = [self getInfocCacheFolderPath:isForceReport];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSArray* subNameArray = [fm contentsOfDirectoryAtPath:path error:nil];
        if (nil == subNameArray || subNameArray.count <= 0) {
            return;
        }
        
        NSInteger expireDay = [adapter getValidityDays];
        
        for (NSString* subName in subNameArray) {
            if (NO == [subName isNotBlank]) {
                continue;
            }
            
            BOOL isDir = NO;
            NSString* filePath = [path stringByAppendingPathComponent:subName];
            if (NO == [fm fileExistsAtPath:filePath isDirectory:&isDir]) {
                continue;
            }
            
            if (YES == isDir) {
                [fm removeItemAtPath:filePath error:nil];
                continue;
            }
            
            NSRange findRst = [subName rangeOfString:@"_"];
            if (NSNotFound == findRst.location && 0 == findRst.length) {
                [fm removeItemAtPath:filePath error:nil];
                continue;
            }
            emKInfoPriority nPriority = (emKInfoPriority)[[subName substringToIndex:findRst.location] integerValue];
            if (nPriority <= Unknow || nPriority >= End) {
                [fm removeItemAtPath:filePath error:nil];
                continue;
            }
            
            long nRptTimeStartPos = ++findRst.location;
            findRst.length = subName.length - findRst.location;
            findRst = [subName rangeOfString:@"_" options:0 range:findRst];
            if (NSNotFound == findRst.location && 0 == findRst.length) {
                [fm removeItemAtPath:filePath error:nil];
                continue;
            }
            
            findRst.length = findRst.location - nRptTimeStartPos;
            findRst.location = nRptTimeStartPos;
            unsigned long long ullTemp = 0LL;
            NSScanner* scanner = [NSScanner scannerWithString:[subName substringWithRange:findRst]];
            [scanner scanHexLongLong:&ullTemp];
            long rptTime = (long)ullTemp;
            if (rptTime < 0 || ((long)(([self getUniqueNumberByTime] - rptTime) / 1000000 / 60 / 60 / 24 + 0.5)) >= expireDay) {
                // 超时，不再上报，直接删除。
                [fm removeItemAtPath:filePath error:nil];
                continue;
            }
            
            NSData* pBinData = [NSData dataWithContentsOfFile:filePath];
            if (nil == pBinData || pBinData.length <= 0) {
                [fm removeItemAtPath:filePath error:nil];
                continue;
            }
            
            if (NO == [self checkNetForReport:isForceReport]) {
                break;
            }
            
            if ([filterSet containsObject:filePath]) {
                // 正在上报
                continue;
            }
            
            [filterSet addObject:filePath];
            [adapter postCacheData:pBinData withPriority:nPriority andPostResultCallback:^(BOOL success) {
                if (YES == success) {
                    // 上报成功，删掉对应的文件。
                    [opQueue addOperationWithBlock:^{
                        [fm removeItemAtPath:filePath error:nil];
                        [filterSet removeObject:filePath];
                    }];
                }
            } byForce:isForceReport];
        }
    }];
}

-(BOOL) checkNetForReport:(BOOL) isForceReport
{
    if (NO == [CMBizHelper hasNetWork]) {
        return NO;
    }
    
    if (YES == isForceReport) {
        return YES;
    }
    
    return [CMBizHelper isWifiNetWork];
}

-(NSString*) getInfocCacheFolderPath:(BOOL) isForce
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                        NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:isForce ? @"kinfoc/force" : @"kinfoc/normal"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (YES == [fm fileExistsAtPath:path isDirectory:&isDir]) {
        if (NO == isDir) {
            [fm removeItemAtPath:path error:nil];
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return path;
    }
    
    [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

-(long) getUniqueNumberByTime
{
    struct timeval stTime;
    memset(&stTime, 0, sizeof(struct timeval));
    int nRst = gettimeofday(&stTime, NULL);
    if (0 == nRst) {
        return (stTime.tv_sec * 1000000) + stTime.tv_usec;
    }
    
    return time(NULL) * 1000 + (arc4random() % 1000);
}

-(NSString*) createUniqueCacheFileNameForPriority:(emKInfoPriority) nPriority
                                      inTheFolder:(NSString*) folderPath
{
    if (NO == [folderPath isNotBlank] || nPriority <= Unknow || nPriority >= End) {
        return nil;
    }
    NSString* path = [folderPath stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%d_%016lX_%08X.kic",
                            nPriority, [self getUniqueNumberByTime], arc4random()]];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (YES == [fm fileExistsAtPath:path isDirectory:&isDir]) {
        if (YES == isDir) {
            [fm removeItemAtPath:path error:nil];
            return path;
        }
        
        return [self createUniqueCacheFileNameForPriority:nPriority inTheFolder:folderPath];
    }
    
    return path;
}

@end
