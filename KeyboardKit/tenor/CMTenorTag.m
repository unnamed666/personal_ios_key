//
//  CMTenorTag.m
//  KeyboardKit
//
//  Created by yanzhao on 2017/11/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTenorTag.h"
#import "CMRequestFactory.h"

@implementation CMTenorTag
- (instancetype) initWithDictionary: (NSDictionary *) dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.searchterm = dictionary[@"searchterm"];
    self.name = dictionary[@"name"];
    return self;
}


- (NSString *)description{
    return [NSString stringWithFormat:@"name = %@ imageUrl = %@",_name,_imageUrlStr?_imageUrlStr:@""];
}

+ (void)TenorTagList:(void (^)(NSArray<CMTenorTag*>* arr))block{
    
    [CMRequestFactory fetchGifTags:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        if([dicOrArray isKindOfClass:[NSArray class]]){
            NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:128];
            for (NSDictionary *dic in (NSArray*)dicOrArray) {
                CMTenorTag * tag =[[CMTenorTag alloc] initWithDictionary:dic];
                [arr addObject:tag];
            }
            block(arr);
        }else{
            block(nil);
        }
    }];
}
@end
