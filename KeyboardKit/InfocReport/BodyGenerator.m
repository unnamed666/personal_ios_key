//
//  BodyGenerator.m
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "BodyGenerator.h"
#import "PublicSection.h"
#import "FmtManager.h"
#import "InfoCDefine.h"

@implementation BodyGenerator

+ (instancetype)shareGenerator
{
    static BodyGenerator* generator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generator = [[BodyGenerator alloc] init];
    });
    return generator;
}

- (BOOL)checkQuery:(NSInteger)businessIndex params:(NSDictionary*)params
{
    NSArray* infos = [[FmtManager shareManager] fmtForReportNo:businessIndex];
    __block BOOL result = YES;
    [infos enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!params[key]) {
                NSAssert(NO, @"%@ no data",key);
                result = NO;
            }
        }];
    }];
    return result;
}

- (NSString*)getQueryString:(NSInteger)businessIndex params:(NSDictionary*)params withHeader:(NSDictionary *)publicInfo
{
    if (![self checkQuery:businessIndex params:params]) {
        return nil;
    }
    
    NSMutableDictionary* querys = [NSMutableDictionary dictionaryWithDictionary:publicInfo];
    [querys addEntriesFromDictionary:params];
    __block NSMutableString* ms = [NSMutableString string];
    [ms appendFormat:@"%@=%d&",@"product_no",kProductNo];
    [querys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSData class]]) {
            
        }
        [ms appendFormat:@"%@=%@&",key,obj];
    }];
    [ms appendFormat:@"%@=%ld", @"business_index", (long)businessIndex];
    
    return ms;
}

- (void)xorString:(const char*)src toString:(char* )dest
{
    int i = 0;
    while (src[i]) {
        int s = src[i];
        s ^= 0x88;
        dest[i++] = s;
    }
}

- (NSData*)buildSection:(short)index withQuerys:(NSDictionary*)querys
{
    if (![self checkQuery:index params:querys]) {
        return nil;
    }
    
    NSMutableData* data = [NSMutableData data];
    
    [data appendBytes:&index length:sizeof(short)];
    
    Byte byte = 0;
    int byteCount = 0;
    NSMutableData* byteData = nil;
    
    NSArray* orderArray = [[FmtManager shareManager] fmtForReportNo:index];
    
    for (NSDictionary* dict in orderArray) {
        for (NSString* key in dict.allKeys) {
            int length = [dict[key] intValue];
            if (length == LengthTypeBit) {
                char value = [querys[key] charValue];
                byte |= value << byteCount++;
                if (byteCount == 8) {
                    if (!byteData) {
                        byteData = [NSMutableData data];
                    }
                    [byteData appendBytes:&byte length:1];
                    byte = 0;
                    byteCount = 0;
                }
            } else if (length == LengthTypeBinaray) {
                NSData* binaray = querys[key];
                short len = binaray.length;
                [data appendBytes:&len length:sizeof(short)];
                [data appendBytes:binaray.bytes length:len];
            } else if (length == LengthTypeString) {
                const char* binaray = [querys[key] UTF8String];
                short len = strlen(binaray);
                char* dest = (char*)malloc(len);
                [self xorString:binaray toString:dest];
                [data appendBytes:&len length:sizeof(short)];
                [data appendBytes:dest length:len];
                free(dest);
            } else {
                int64_t value = [querys[key] intValue];
                [data appendBytes:&value length:length];
            }
        }
    }
    if (byteCount > 0) {
        if (!byteData) {
            byteData = [NSMutableData data];
        }
        [byteData appendBytes:&byte length:1];
        byte = 0;
        byteCount = 0;
    }
    
    if (byteData) {
        [data replaceBytesInRange:NSMakeRange(sizeof(short), 0) withBytes:byteData.bytes length:byteData.length];
    }
    return data;
}

@end
