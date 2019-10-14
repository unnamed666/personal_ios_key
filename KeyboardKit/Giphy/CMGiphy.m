//
//  CMGiphy.m
//  iMessage
//
//  Created by yanzhao on 2017/9/25.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMGiphy.h"

#import "NSString+Common.h"
#import "CMRequestFactory.h"
#import "CMAppConfig.h"

@interface CMGiphy ()<NSCoding>
@property (readwrite, strong, nonatomic) NSString * gifID;
@property (readwrite, strong, nonatomic) NSString * type;
//@property (readwrite, strong, nonatomic) NSURL * url;
//@property (readwrite, strong, nonatomic) NSURL * bitlyURL;
//@property (readwrite, strong, nonatomic) NSURL * bitlyGIFURL;
//@property (readwrite, strong, nonatomic) NSURL * embedURL;
//@property (readwrite, strong, nonatomic) NSString * username;
//@property (readwrite, strong, nonatomic) NSURL * source;
//@property (readwrite, strong, nonatomic) NSString * rating;
//@property (readwrite, strong, nonatomic) NSDate * trendingDateTime;
@property (readwrite, strong, nonatomic) CMGiphyImage * fixedWidthImageDownsampled;
@property (readwrite, strong, nonatomic) CMGiphyImage * fixedWidthSmall;
@property (readwrite, strong, nonatomic) CMGiphyImage * fixedHeightSmall;
@end


@implementation CMGiphy

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _gifID = [[aDecoder decodeObjectForKey:@"gifID"] copy];
        _type = [[aDecoder decodeObjectForKey:@"type"] copy];
        _fixedWidthImageDownsampled = [aDecoder decodeObjectForKey:@"fixedWidthImageDownsampled"];
        _fixedWidthSmall = [aDecoder decodeObjectForKey:@"fixedWidthSmall"];
        _fixedHeightSmall = [aDecoder decodeObjectForKey:@"fixedHeightSmall"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.gifID forKey:@"gifID"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.fixedWidthImageDownsampled forKey:@"fixedWidthImageDownsampled"];
    [aCoder encodeObject:self.fixedWidthSmall forKey:@"fixedWidthSmall"];
    [aCoder encodeObject:self.fixedHeightSmall forKey:@"fixedHeightSmall"];
}


- (instancetype) initWithDictionary: (NSDictionary *) dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.gifID = dictionary[@"id"];
    self.type = dictionary[@"type"];
    NSDictionary * images = dictionary[@"images"];
    self.fixedWidthSmall = [[CMGiphyImage alloc] initWithDictionary:images[@"fixed_width_small"]];
    self.fixedWidthImageDownsampled = [[CMGiphyImage alloc] initWithDictionary:images[@"fixed_width_downsampled"]];
    self.fixedHeightSmall = [[CMGiphyImage alloc] initWithDictionary:images[@"fixed_height_small"]];
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"id = %@  image = %@",_gifID,_fixedWidthImageDownsampled];
}
+ (NSArray<CMGiphy *> *) CMGiphyArrayFromDictArray:(NSArray *) array
{
    NSMutableArray * gifArray = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * dict = obj;
        CMGiphy * gif = [[CMGiphy alloc] initWithDictionary:dict];
        [gifArray addObject:gif];
    }];
    return gifArray;
}

//+ (BOOL)giphyDataCache:(NSString*)dataPath completion:(void (^)(NSArray<CMGiphy *> * giphyArry, NSError *error))block{
//    
//
//    NSFileManager *fileMgr = [NSFileManager defaultManager] ;
//    if(![fileMgr fileExistsAtPath:dataPath])return NO;
//    NSError *error = nil;
//    NSDictionary *fileAttrs = [fileMgr attributesOfItemAtPath:dataPath error:&error];
//    NSDate *fileModifiedDate = [fileAttrs objectForKey:NSFileModificationDate];
//    NSDate * data = [NSDate date];
//    NSTimeInterval intervalTime = [data timeIntervalSinceDate:fileModifiedDate];
//    if(intervalTime > 60*60*2)return NO;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSData * data = [NSData dataWithContentsOfFile:dataPath];
//        if(data){
//            NSError * error;
//            NSDictionary * results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//            if (error) {
//                block(nil, error);
//            } else {
//                NSArray<CMGiphy *> * gifArray = [CMGiphy CMGiphyArrayFromDictArray:results[@"data"]];
//                block(gifArray, nil);
//            }
//        }else{
//            [fileMgr removeItemAtPath:dataPath error:nil];
//        }
//    });
//    
//    return YES;
//}

+ (void) giphyTrendingRequestWithLimit:(NSUInteger) limit offset:(NSUInteger) offset  completion:(void (^)(NSArray<CMGiphy *> * giphyArry, NSError *error))block
{
    
    [CMRequestFactory giphyTrendingRequestWithLimit:limit offset:offset lang:[CMAppConfig preferredLanguage] completion:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        if (dicOrArray && [dicOrArray isKindOfClass:[NSDictionary class]]){
            NSDictionary *results = (NSDictionary *)dicOrArray;
            NSArray<CMGiphy *> * gifArray = [CMGiphy CMGiphyArrayFromDictArray:results[@"data"]];
            block(gifArray, nil);
        }else{
            block(nil, nil);
        }
    }];
    
}

+ (void)giphySearchTagWithQ:q Limit:(NSUInteger) limit offset:(NSUInteger) offset  completion:(void (^)(NSArray<CMGiphy *> * giphyArry, NSError *error))block{
    [CMRequestFactory giphySearchTagWithQ:q Limit:limit offset:offset lang:[CMAppConfig preferredLanguage] completion:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        if (dicOrArray && [dicOrArray isKindOfClass:[NSDictionary class]]){
            NSDictionary *results = (NSDictionary *)dicOrArray;
            NSArray<CMGiphy *> * gifArray = [CMGiphy CMGiphyArrayFromDictArray:results[@"data"]];
            block(gifArray, nil);
        }else{
            block(nil, nil);
        }
    }];
}


@end
