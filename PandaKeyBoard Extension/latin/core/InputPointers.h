//
//  InputPointers.h
//  test
//
//  Created by yanzhao on 2017/3/24.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMKeyModel;

@interface InputPointers : NSObject

@property (nonatomic, readonly, copy)NSArray* mXCoordinates;
@property (nonatomic, readonly, copy)NSArray* mYCoordinates;
@property (nonatomic, readonly, copy)NSArray* mPointerIds;
@property (nonatomic, readonly, copy)NSArray* mTimes;

@property (nonatomic, readonly, copy)NSArray<CMKeyModel *>* keyModelArray;

- (void)addPointerAt:(int)index x:(float)x y:(float)y pointerId:(int)pointerId time:(int)time;

- (void)addPointer:(CGPoint)point eventTime:(NSInteger)eventTime identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel atIndex:(NSUInteger)index;
- (void)appendPointer:(CGPoint)point eventTime:(NSInteger)eventTime identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel;
- (void)reset;

@end
