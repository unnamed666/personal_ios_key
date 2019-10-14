//
//  kinfoc_oc2cpp_adapter.mm
//  KEWL
//
//  Created by Jin Ye on 4/22/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import "kinfoc_config.h"
#import "kinfoc_oc2cpp_adapter.h"

#include <vector>

#include "core/stdafx.h"
#include "core/crc32.h"
#include "core/KDataStream.h"
#include "core/KFunction.h"
#include "core/KInfocClient.h"

@implementation KInfocOc2CppFunc

+ (NSData*) buildReportDataForProduct:(NSInteger) prodId
        byPublicSection: (NSData*) pPublicSection
        andDataSection: (NSData*) pDataSection;
{
    if (nil == pPublicSection || pPublicSection.length <= 0 ||
        nil == pDataSection || pDataSection.length <= 0)
    {
        // 因为数据字段至少要有uptime2和data字段，所以pDataSection绝对不可能为空。
        return nil;
    }
    
    KStreamWriter stream;
    InfocPackHeader infoHead;
    
    //写入消息头部的空串
    stream.WriteBinary(&infoHead, sizeof(infoHead));
    
    //写入公共字段
    [KInfocOc2CppFunc writeByteData:pPublicSection toStream:stream];
    
    //写入数据字段
    [KInfocOc2CppFunc writeByteData:pDataSection toStream:stream];
    
    //填写头部信息
    [KInfocOc2CppFunc writeHeadInfo:stream infoCount:2 productId:(int)prodId];
    
    NSData* pRstData = nil;
    //设置返回数据
    pRstData = [[NSData alloc] initWithBytes:stream.GetStream() length:stream.GetSize()];
    
    return pRstData;
}

+ (NSData*) getPublicSectionBinary: (NSString*) strPublicDataString
{
    return [KInfocOc2CppFunc getDataSectionBinary:strPublicDataString forTable:[KInfocConfig getPublicTableName]];
}

+ (NSData*) getDataSectionBinary: (NSString*) strDataString forTable:(NSString*) strTableName;
{
    if (nil == strDataString || nil == strTableName)
    {
        return nil;
    }
    
    static BOOL hasSettedModulePath = NO;
    if (!hasSettedModulePath) {
//        NSString *configFolderPath = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] URLForResource:@"KeyboardKit" withExtension:@"framework" subdirectory:@"Frameworks"].path];
        NSString * mainPath = [[NSBundle mainBundle] resourcePath];
        NSRange range;
        range = [mainPath rangeOfString:@"PlugIns"];
        if(range.location != NSNotFound){
            mainPath = [mainPath substringToIndex:range.location];
        }
        NSString* configFolderPath = [mainPath stringByAppendingPathComponent:@"Frameworks/KeyboardKit.framework"];
        
        if (NULL == configFolderPath || configFolderPath.length == 0)
        {
            return nil;
        }
        
        const char* szConfigFolderPath = [configFolderPath UTF8String];
        if (NULL == szConfigFolderPath || '\0' == szConfigFolderPath[0])
        {
            return nil;
        }
        
        KFunction::SetModulePath(szConfigFolderPath);
        hasSettedModulePath = YES;
    }
    
    KInfocClient client;
    
    if (!client.Initialize())
    {
        return nil;
    }
    
    const char* szDataPublic = [strDataString UTF8String];
    const char* szTableName = [strTableName UTF8String];
    if (NULL == szDataPublic || '\0' == szDataPublic[0] ||
        NULL == szTableName || '\0' == szTableName[0])
    {
        return nil;
    }
    
    KStreamWriter stream;
    client.SetTableName(szTableName);
    if (client.AddInfo(szDataPublic) && client.Serialize())
    {
        stream.WriteBinary(client.GetStream(), client.GetSize());
        client.Clear();
    }
    else
    {
        return nil;
    }
    
    NSData* pRstData = nil;
    pRstData = [[NSData alloc] initWithBytes:stream.GetStream() length:stream.GetSize()];
    stream.Clear();
    
    return pRstData;
}

+ (NSMutableData*) buildReportDataHeader:(NSData*) pPublicSection
{
    if (nil == pPublicSection || pPublicSection.length <= 0)
    {
        return nil;
    }
    
    KStreamWriter stream;
    InfocPackHeader infoHead;
    memset(&infoHead, 0, sizeof(InfocPackHeader));
    infoHead.count = 1;
    
    //写入消息头部
    stream.WriteBinary(&infoHead, sizeof(infoHead));
    
    //写入公共字段
    [KInfocOc2CppFunc writeByteData:pPublicSection toStream:stream];

    NSMutableData* pRstData = nil;
    //设置返回数据
    pRstData = [[NSMutableData alloc] initWithBytes:stream.GetStream() length:stream.GetSize()];
    
    return pRstData;
}

#define MAX_BATCH_BUFFER_LENGTH 3072

+ (BOOL) addReportData:(NSData*) pDataSection toDataObj:(NSMutableData*) dataObj
{
    if (nil == dataObj || dataObj.length <= 0 ||
        nil == pDataSection || pDataSection.length <= 0)
    {
        // 因为数据字段至少要有uptime2和data字段，所以pDataSection绝对不可能为空。
        return YES;
    }
    
    if (dataObj.length + pDataSection.length > MAX_BATCH_BUFFER_LENGTH) {
        // 太大了，留着下一批再报。
        return NO;
    }
    
    //写入添加的数据字段
    [dataObj appendData:pDataSection];
    
    //取出消息头部
    InfocPackHeader infoHead;
    [dataObj getBytes:&infoHead length:sizeof(InfocPackHeader)];
    
    //修改头部信息
    ++infoHead.count;
    [dataObj replaceBytesInRange:NSMakeRange(0, sizeof(InfocPackHeader)) withBytes:&infoHead];
    
    return YES;
}

+ (NSData*) finishBuildBatchReportDataForProduct:(NSInteger) prodId withDataObj:(NSMutableData*) pDataObj
{
    if (nil == pDataObj || pDataObj.length <= 0) {
        return nil;
    }
    
    unsigned int uCrc32 = CRC32(0, ((unsigned char*)pDataObj.bytes) + sizeof(InfocPackHeader),
                                pDataObj.length - sizeof(InfocPackHeader));
    //取出消息头部
    InfocPackHeader infoHead;
    [pDataObj getBytes:&infoHead length:sizeof(InfocPackHeader)];
    
    //修改头部信息
    infoHead.size = pDataObj.length;
    infoHead.version = 1;
    infoHead.product = prodId;
    infoHead.crc32 = uCrc32;
    [pDataObj replaceBytesInRange:NSMakeRange(0, sizeof(InfocPackHeader)) withBytes:&infoHead];
    
    return pDataObj;
}

////////////////////////////////////////////////////////////////////////////////

+(void) writeByteData:(NSData*) pData toStream:(KStreamWriter&) stream
{
    if (nil == pData || pData.length <= 0) {
        return;
    }
    
    std::vector<unsigned char> vecBuffer;
    vecBuffer.resize(pData.length);
    [pData getBytes:&(vecBuffer[0]) length:vecBuffer.size()];
    stream.WriteBinary(&(vecBuffer[0]), vecBuffer.size());
}

+(void) writeHeadInfo:(KStreamWriter&) stream infoCount:(int) nInfoCount productId:(int) nProductId
{
    int nSize = 0;
    LPBYTE pBuffer = NULL;
    PInfocPackHeader pPackHead = NULL;
    
    nSize = stream.GetSize();
    pBuffer = (LPBYTE)stream.GetStream();
    pPackHead = (PInfocPackHeader)pBuffer;
    
    unsigned int uCrc32 = CRC32(0, pBuffer + sizeof(InfocPackHeader), nSize - sizeof(InfocPackHeader));
    pPackHead->size = nSize;
    pPackHead->version = 1;
    pPackHead->product = nProductId;
    pPackHead->count = nInfoCount;
    pPackHead->crc32 = uCrc32;
}

@end
