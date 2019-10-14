//
//  InputPointers.m
//  test
//
//  Created by yanzhao on 2017/3/24.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "InputPointers.h"
#import "CMKeyModel.h"

@interface InputPointers () <NSCopying>
// add by yaozongchao
@property (nonatomic, strong)dispatch_queue_t concurrentQueue;

@property (nonatomic, strong)NSMutableArray* mTimesMutArray;
@property (nonatomic, strong)NSMutableArray* xCoordinateMutArray;
@property (nonatomic, strong)NSMutableArray* yCoordinateMutArray;
@property (nonatomic, strong)NSMutableArray* mPointerIdMutArray;
@property (nonatomic, strong)NSMutableArray<CMKeyModel *>* keyModelMutArray;

@end

@implementation InputPointers

- (void)addPointerAt:(int)index x:(float)x y:(float)y pointerId:(int)pointerId time:(int)time{
    dispatch_barrier_sync(self.concurrentQueue, ^{
        if(self.xCoordinateMutArray.count > index){
            self.xCoordinateMutArray[index] = @(x);
        }else{
            [self.xCoordinateMutArray addObject:@(x)];
        }
        if(self.yCoordinateMutArray.count >index){
            self.yCoordinateMutArray[index] = @(y);
        }else{
            [self.yCoordinateMutArray addObject:@(y)];
        }
        if(self.mPointerIdMutArray.count >index){
            self.mPointerIdMutArray[index] = @(pointerId);
        }else{
            [self.mPointerIdMutArray addObject:@(pointerId)];
        }
        if(self.mTimesMutArray.count >index){
            self.mTimesMutArray[index] = @(time);
        }else{
            [self.mTimesMutArray addObject:@(time)];
        }
    });
}

- (id)copyWithZone:(NSZone *)zone
{
    __block InputPointers* localObj;
    dispatch_barrier_sync(self.concurrentQueue, ^{
        InputPointers *cpyObj = [[InputPointers allocWithZone:zone] init];
        cpyObj.xCoordinateMutArray = [self.xCoordinateMutArray mutableCopy];
        cpyObj.yCoordinateMutArray = [self.yCoordinateMutArray mutableCopy];
        cpyObj.mPointerIdMutArray = [self.mPointerIdMutArray mutableCopy];
        cpyObj.mTimesMutArray = [self.mTimesMutArray mutableCopy];
        cpyObj.keyModelMutArray = [self.keyModelMutArray mutableCopy];
        localObj = cpyObj;
    });
    return localObj;
}

- (void)addPointer:(CGPoint)point eventTime:(NSInteger)eventTime identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel atIndex:(NSUInteger)index {
    dispatch_barrier_sync(self.concurrentQueue, ^{
        [self.mTimesMutArray insertObject:@(eventTime) atIndex:index];
        [self.xCoordinateMutArray insertObject:@(point.x) atIndex:index];
        [self.yCoordinateMutArray insertObject:@(point.y) atIndex:index];
        [self.mPointerIdMutArray insertObject:touch atIndex:index];
        [self.keyModelMutArray insertObject:keyModel atIndex:index];
    });
}

- (void)appendPointer:(CGPoint)point eventTime:(NSInteger)eventTime identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel {
    dispatch_barrier_sync(self.concurrentQueue, ^{
        [self.mTimesMutArray addObject:@(eventTime)];
        [self.xCoordinateMutArray addObject:@(point.x)];
        [self.yCoordinateMutArray addObject:@(point.y)];
        [self.mPointerIdMutArray addObject:touch];
        [self.keyModelMutArray addObject:keyModel];
    });
}

- (void)reset {
    dispatch_barrier_sync(self.concurrentQueue, ^{
        [self.mTimesMutArray removeAllObjects];
        [self.xCoordinateMutArray removeAllObjects];
        [self.yCoordinateMutArray removeAllObjects];
        [self.mPointerIdMutArray removeAllObjects];
        [self.keyModelMutArray removeAllObjects];
    });
}

#pragma mark - setter/getter
- (dispatch_queue_t)concurrentQueue {
    if (!_concurrentQueue) {
        _concurrentQueue = dispatch_queue_create("input_pointer_process", DISPATCH_QUEUE_CONCURRENT);
    }
    return _concurrentQueue;
}

- (NSMutableArray *)mTimesMutArray {
    if (!_mTimesMutArray) {
        _mTimesMutArray = [NSMutableArray array];
    }
    return _mTimesMutArray;
}

- (NSMutableArray *)xCoordinateMutArray {
    if (!_xCoordinateMutArray) {
        _xCoordinateMutArray = [NSMutableArray array];
    }
    return _xCoordinateMutArray;
}

- (NSMutableArray *)yCoordinateMutArray {
    if (!_yCoordinateMutArray) {
        _yCoordinateMutArray = [NSMutableArray array];
    }
    return _yCoordinateMutArray;
}

- (NSMutableArray<CMKeyModel *> *)keyModelMutArray {
    if (!_keyModelMutArray) {
        _keyModelMutArray = [NSMutableArray array];
    }
    return _keyModelMutArray;
}

- (NSMutableArray *)mPointerIdMutArray {
    if (!_mPointerIdMutArray) {
        _mPointerIdMutArray = [NSMutableArray array];
    }
    return _mPointerIdMutArray;
}

- (NSArray *)mTimes {
    __block NSArray* localArray;
    dispatch_sync(self.concurrentQueue, ^{
        localArray = [self.mTimesMutArray copy];
    });
    return localArray;
}

- (NSArray *)mXCoordinates {
    __block NSArray* localArray;
    dispatch_sync(self.concurrentQueue, ^{
        localArray = [self.xCoordinateMutArray copy];
    });
    return localArray;
}

- (NSArray *)mYCoordinates {
    __block NSArray* localArray;
    dispatch_sync(self.concurrentQueue, ^{
        localArray = [self.yCoordinateMutArray copy];
    });
    return localArray;
}

- (NSArray *)mPointerIds {
    __block NSArray* localArray;
    dispatch_sync(self.concurrentQueue, ^{
        localArray = [self.mPointerIdMutArray copy];
    });
    return localArray;
}

- (NSArray<CMKeyModel *> *)keyModelArray {
    __block NSArray* localArray;
    dispatch_sync(self.concurrentQueue, ^{
        localArray = [self.keyModelMutArray copy];
    });
    return localArray;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"x = %@ , y = %@, keyModel = %@", self.xCoordinateMutArray,self.yCoordinateMutArray, self.keyModelMutArray];
}
@end
