//
//  CMDiyBackgroundModel.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDiySourceModel.h"

@implementation CMDiySourceModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _sourceId = [[aDecoder decodeObjectForKey:@"id"] copy];
        _cover_url = [[aDecoder decodeObjectForKey:@"cover_url"] copy];
        _download_url = [[aDecoder decodeObjectForKey:@"download_url"] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.sourceId forKey:@"id"];
    [aCoder encodeObject:self.cover_url forKey:@"cover_url"];
    [aCoder encodeObject:self.download_url forKey:@"download_url"];
}

- (instancetype)initWithFetchedInfoDic:(NSDictionary *)infoDic
{
    if (self = [super init]) {
        _sourceId = [[infoDic stringValueForKey:@"id"] copy];
        _cover_url = [[infoDic stringValueForKey:@"cover_url"] copy];
        _download_url = [[infoDic stringValueForKey:@"download_url"] copy];
    }
    return self;
}

- (instancetype)initWithPlistInfoDic:(NSDictionary *)infoDic
{
    if (self = [super init]) {
        _sourceId = [[infoDic stringValueForKey:@"id"] copy];
        _cover_url = [[infoDic stringValueForKey:@"cover_url"] copy];
        NSString *scaleStr = kNativeScale == 3.0f ? @"3x" : @"2x";
        NSString *resourceName = [[[infoDic stringValueForKey:@"download_url"] copy] stringByAppendingFormat:@"@%@.9", scaleStr];
        _download_url = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
    }
    return self;
}

+ (instancetype)modelWithFetchedInfoDic:(NSDictionary *)infoDic
{
    return [[CMDiySourceModel alloc] initWithFetchedInfoDic:infoDic];
}

@end
