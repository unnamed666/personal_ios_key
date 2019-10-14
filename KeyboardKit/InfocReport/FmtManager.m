//
//  FmtManager.m
//  InfoC
//
//  Created by wei_wei on 16/4/8.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "FmtManager.h"
#import "InfoCDefine.h"
#import "CommonKit.h"
@interface FmtManager ()

@property (nonatomic, strong) NSMutableDictionary* dictionary;

@end

@implementation FmtManager

+ (instancetype)shareManager
{
    static FmtManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FmtManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSError* error = nil;
        NSString * mainPath = [[NSBundle mainBundle] resourcePath];
        NSRange range;
        range = [mainPath rangeOfString:@"PlugIns"];
        if(range.location != NSNotFound){
            mainPath = [mainPath substringToIndex:range.location];
        }
        NSString* configFolderPath = [mainPath stringByAppendingPathComponent:@"Frameworks/KeyboardKit.framework"];
        NSString* file = [NSString stringWithContentsOfFile:[[NSBundle bundleWithPath:configFolderPath] pathForResource:kFMTFileName ofType:nil] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DLOG(@"read fmt file got error:%@",error);
            return nil;
        }
        NSArray* lines = [file componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (NSString* line in lines) {
            __block NSString* key = nil;
            __block NSMutableArray* infos = [NSMutableArray array];
            NSArray* components = [line componentsSeparatedByString:@" "];
            if (components.count <= 1) {
                continue;
            }
            [components enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray* info = [obj componentsSeparatedByString:@":"];
                if (info.count == 0) {
                    
                }
                if (idx == 0) {
                    key = info[1];
                } else {
                    [infos addObject:@{info[0] : @([self lengthFotType:info[1]])}];
                }
            }];
            [self.dictionary setObject:infos forKey:key];
        }
    }
    return self;
}

- (NSMutableDictionary *)dictionary
{
    if (!_dictionary) {
        _dictionary = [NSMutableDictionary dictionary];
    }
    return _dictionary;
}

- (NSInteger)lengthFotType:(NSString*)type
{
    if ([type isEqualToString:@"bit"]) {
        return LengthTypeBit;
    } else if ([type isEqualToString:@"string"]) {
        return LengthTypeString;
    } else if ([type isEqualToString:@"binary"]) {
        return LengthTypeBinaray;
    } else if ([type isEqualToString:@"byte"]) {
        return 1;
    }else if ([type isEqualToString:@"short"]) {
        return 2;
    } else if ([type isEqualToString:@"int"]) {
        return 4;
    } else if ([type isEqualToString:@"int64"]) {
        return 8;
    }
    
    return 0;
}

- (NSArray *)fmtForReportNo:(NSInteger)reportNo
{
    NSArray* array = [self.dictionary objectForKey:[NSString stringWithFormat:@"%ld",(long)reportNo]];
    if ([array isKindOfClass:[NSArray class]]) {
        return array;
    }
    
#ifdef DEBUG
    NSAssert(NO, @"********** reportNo: %ld is not found in the kfmt table. ********", (long)reportNo);
#endif
    return nil;
}


@end
