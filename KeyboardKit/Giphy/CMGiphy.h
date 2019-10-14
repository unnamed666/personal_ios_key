//
//  CMGiphy.h
//  iMessage
//
//  Created by yanzhao on 2017/9/25.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMGiphyImage.h"

@interface CMGiphy : NSObject
@property (readonly, strong, nonatomic) NSString * gifID;
@property (readonly, strong, nonatomic) NSString * type;
@property (readonly, strong, nonatomic) CMGiphyImage * fixedWidthImageDownsampled;
@property (readonly, strong, nonatomic) CMGiphyImage * fixedWidthSmall;
@property (readonly, strong, nonatomic) CMGiphyImage * fixedHeightSmall;

+ (void) giphyTrendingRequestWithLimit:(NSUInteger) limit offset:(NSUInteger) offset  completion:(void (^)(NSArray<CMGiphy *> * giphyArry, NSError *error))block;
+ (void)giphySearchTagWithQ:q Limit:(NSUInteger) limit offset:(NSUInteger) offset  completion:(void (^)(NSArray<CMGiphy *> * giphyArry, NSError *error))block;
@end
