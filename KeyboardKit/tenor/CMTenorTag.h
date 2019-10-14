//
//  CMTenorTag.h
//  KeyboardKit
//
//  Created by yanzhao on 2017/11/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTenorTag : NSObject
@property (nonatomic, strong)NSString *searchterm;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *imageUrlStr;//要存放 giphy 中的第一个图片地址
- (instancetype) initWithDictionary: (NSDictionary *) dictionary;
+ (void)TenorTagList:(void (^)(NSArray<CMTenorTag*>* arr))block;
@end
