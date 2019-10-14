//
//  CmposedData.h
//  test
//
//  Created by yanzhao on 2017/3/23.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InputPointers;

@interface CmposedData : NSObject
@property (nonatomic,strong) InputPointers *inputPointers;
@property (nonatomic,assign) BOOL isBatchMode;
@property (nonatomic,strong) NSString* typeWord;

- (instancetype)initWithInputPointers:(InputPointers*)inputPointers isBatchMode:(BOOL)isBatchMode typeWord:(NSString*)typeWord;

- (int)copyCodePointsExceptTrailingSingleQuotesAndReturnCodePointCount:(int[])destination destinationLen:(int)len;

@end
