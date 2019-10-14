//
//  CMBatchInputPointManager.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBatchInputPointManager.h"
#import "CMBizHelper.h"
#import "CMKeyModel.h"
#import "InputPointers.h"

static NSInteger MSEC_PER_SEC = 1000;

@interface CMBatchInputPointManager ()
@property (nonatomic, assign)CGFloat keyWidth; // pixel
@property (nonatomic, assign)CGFloat minYCoordinate; // pixel
@property (nonatomic, assign)CGFloat maxYCoordinate; // pixel

// Static threshold for starting gesture detection
@property (nonatomic, assign)NSInteger detectFastMoveSpeedThreshold; // pixel /sec
@property (nonatomic, assign)NSInteger detectFastMoveTime;
@property (nonatomic, assign)NSInteger detectFastMoveX;
@property (nonatomic, assign)NSInteger detectFastMoveY;
@property (nonatomic, strong)UITouch* detectFastMoveTouch;


// Dynamic threshold for gesture after fast typing
@property (nonatomic, assign)BOOL afterFastTyping;
@property (nonatomic, assign)NSInteger gestureDynamicDistanceThresholdFrom; // pixel
@property (nonatomic, assign)NSInteger gestureDynamicDistanceThresholdTo; // pixel

// Variables for gesture sampling
@property (nonatomic, assign)NSInteger gestureSamplingMinimumDistance; // pixel
@property (nonatomic, assign)long lastMajorEventTime;
@property (nonatomic, assign)NSInteger lastMajorEventX;
@property (nonatomic, assign)NSInteger lastMajorEventY;

// Variables for gesture recognition
@property (nonatomic, assign)NSInteger gestureRecognitionSpeedThreshold; // pixel /sec
@property (nonatomic, assign)NSInteger incrementalRecognitionSize;
@property (nonatomic, assign)NSInteger lastIncrementalBatchSize;

@property (nonatomic, readwrite, strong)InputPointers* inputPointerModel;

@end

@implementation CMBatchInputPointManager

#pragma mark - getter/setter
- (InputPointers *)inputPointerModel {
    if (!_inputPointerModel) {
        _inputPointerModel = [InputPointers new];
    }
    return _inputPointerModel;
}

- (void)setKeyWidth:(CGFloat)keyWidth keyboardHeight:(CGFloat)keyboardHeight {
    self.keyWidth = keyWidth;
    self.minYCoordinate = 0.0f;
    self.maxYCoordinate = keyboardHeight;
    self.detectFastMoveSpeedThreshold = (NSInteger)(keyWidth * 1.5); //keyWidth * mRecognitionParams.mDetectFastMoveSpeedThreshold keyWidth/sec
    self.gestureDynamicDistanceThresholdFrom = (NSInteger)(keyWidth * 6.0); //  keyWidth * mRecognitionParams.mDynamicDistanceThresholdFrom
    self.gestureDynamicDistanceThresholdTo = (NSInteger)(keyWidth * 0.35); // keyWidth * mRecognitionParams.mDynamicDistanceThresholdTo
    self.gestureSamplingMinimumDistance = (NSInteger)(keyWidth / 6.0); // keyWidth * mRecognitionParams.mSamplingMinimumDistance(1/6)
    self.gestureRecognitionSpeedThreshold = (NSInteger)(keyWidth * 5.5); // keyWidth * mRecognitionParams.mRecognitionSpeedThreshold
//    kLogInfo(@"[BATCH]setKeyboardGeometry: keyWidth=%3f tT=%3d >> %3d tD=%3ld >> %3ld", keyWidth, 300, 20, (long)self.gestureDynamicDistanceThresholdFrom, (long)self.gestureDynamicDistanceThresholdTo);
}

- (void)addTouchDownEventPoint:(CGPoint)point identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel elapsedTimeSinceFirstTouchDown:(NSTimeInterval)downElapsed elapsedTimeSinceLastType:(NSTimeInterval)typeElapsed {
    // reset
    [self reset];
    if (typeElapsed < 350) { // mStaticTimeThresholdAfterFastTyping // msec
        self.afterFastTyping = YES;
    }
    [self addEventPoint:point elapsedTimeSinceFirstGestureDown:downElapsed identify:touch keyModel:keyModel isMajorEvent:YES];
}

- (NSInteger)getLength {
    return self.inputPointerModel.mTimes.count;
}

- (BOOL)isStartOfAGesture {
    if (self.detectFastMoveTime <= 0) {
        return NO;
    }
    if ([self getLength] <= 0) {
        return NO;
    }
    
    NSInteger lastIndex = [self getLength] - 1;
    UITouch* touch = [self.inputPointerModel.mPointerIds objectAtIndex:lastIndex];
    if (touch != self.detectFastMoveTouch) {
        return NO;
    }
    NSInteger deltaTime = [[self.inputPointerModel.mTimes objectAtIndex:lastIndex] integerValue] - self.detectFastMoveTime;
    if (deltaTime < 0) {
        return NO;
    }
    
    NSInteger deltaDistance = [CMBizHelper distanceBetweenPoint:CGPointMake([[self.inputPointerModel.mXCoordinates objectAtIndex:lastIndex] integerValue], [[self.inputPointerModel.mYCoordinates objectAtIndex:lastIndex] integerValue]) point:CGPointMake(self.detectFastMoveX, self.detectFastMoveY)];
    NSInteger distanceThreshold = [self getGestureDynamicDistanceThreshold:deltaTime];
    NSInteger timeThreshold = [self getGestureDynamicTimeThreshold:deltaTime];
    BOOL isStartOfAGesture = deltaTime >= timeThreshold && deltaDistance >= distanceThreshold;
    if (isStartOfAGesture) {
//        kLogInfo(@"[BATCH]isStartOfAGesture: dT=%3ld tT=%3ld dD=%3ld tD=%3ld%@%@", (long)deltaTime, (long)timeThreshold, (long)deltaDistance, (long)distanceThreshold, self.afterFastTyping ? @"afterFastTyping" : @"", isStartOfAGesture ? @"startOfAGesture" : @"");
    }
    return isStartOfAGesture;
}

- (void)duplicateLastPointWithEventTime:(NSInteger)time {
    NSInteger lastIndex = self.inputPointerModel.mTimes.count - 1;
    if (lastIndex >= 0) {
        NSInteger x = [[self.inputPointerModel.mXCoordinates objectAtIndex:lastIndex] integerValue];
        NSInteger y = [[self.inputPointerModel.mYCoordinates objectAtIndex:lastIndex] integerValue];
        UITouch* touch = [self.inputPointerModel.mPointerIds objectAtIndex:lastIndex];
        CMKeyModel* keyModel = [self.inputPointerModel.keyModelArray objectAtIndex:lastIndex];
//        kLogInfo(@"[BATCH]duplicateLastPointWith: %ld,%ld|%ld|%@,keyModel(%@)", (long)x, (long)y, (long)time, touch, keyModel);
        [self appendPoint:CGPointMake(x, y) eventTime:time identify:touch keyModel:keyModel];
    }
}

- (NSInteger)getGestureDynamicDistanceThreshold:(NSInteger) deltaTime {
    if (!self.afterFastTyping || deltaTime >= 450) { //mDynamicThresholdDecayDuration msec
        return self.gestureDynamicDistanceThresholdTo;
    }
    NSInteger decayedThreshold = (self.gestureDynamicDistanceThresholdFrom - self.gestureDynamicDistanceThresholdTo)*deltaTime/450;
    return self.gestureDynamicDistanceThresholdFrom - decayedThreshold;
}

- (NSInteger)getGestureDynamicTimeThreshold:(NSInteger) deltaTime {
    if (!self.afterFastTyping || deltaTime >= 450) { //mDynamicThresholdDecayDuration msec
        return 20; // mDynamicTimeThresholdTo msec
    }
    NSInteger decayedThreshold = (300 - 20)*deltaTime/450; // (mDynamicTimeThresholdFrom - mDynamicTimeThresholdTo)*deltaTime /
    return 300 - decayedThreshold; // mDynamicTimeThresholdFrom - decayedThreshold
}

/**
 * Add an event point to this gesture stroke recognition points. Returns true if the event
 * point is on the valid gesture area.
 *
 * @param point            the coordinate of the event point
 * @param downElapsed         the elapsed time in millisecond from the first gesture down
 * @param isMajorEvent false if this is a historical move event
 * @return YES if the event point is on the valid gesture area
 */
- (BOOL)addEventPoint:(CGPoint)point elapsedTimeSinceFirstGestureDown:(NSTimeInterval)downElapsed identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel isMajorEvent:(BOOL)isMajorEvent {
    if (self.inputPointerModel.mTimes.count <= 0) {
//        kLogInfo(@"[BATCH]append第一次点击的Point, key=%@", keyModel.key);
        [self appendPoint:point eventTime:downElapsed identify:touch keyModel:keyModel];
        [self updateMajorEvent:point eventTime:downElapsed];
    }
    else {
        NSInteger distance = [self detectFastMove:point eventTime:downElapsed];
        if (distance > self.gestureSamplingMinimumDistance) {
//            kLogInfo(@"[BATCH]根据采样的最小距离(%ld)，append采样点(distance=%ld), downElapsed=%f", self.gestureSamplingMinimumDistance, distance, downElapsed);
            [self appendPoint:point eventTime:downElapsed identify:touch keyModel:keyModel];
        }
    }
    if (isMajorEvent) {
        [self updateMajorEvent:point eventTime:downElapsed];
    }
    BOOL result = point.y >= self.minYCoordinate && point.y < self.maxYCoordinate;
//    kLogInfo(@"[BATCH]addEventPoint, key=%@, result=%d", keyModel.key, result);
    return result;
}

- (void)reset {
    self.incrementalRecognitionSize = 0;
    self.lastIncrementalBatchSize = 0;
    [self.inputPointerModel reset];
    self.lastMajorEventTime = 0;
    self.detectFastMoveTime = 0;
    self.afterFastTyping = NO;
}

- (void)appendPoint:(CGPoint)point eventTime:(NSInteger)eventTime identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel {
    // The point that is created by {@link duplicateLastPointWith(int)} may have later event
    // time than the next {@link MotionEvent}. To maintain the monotonicity of the event time,
    // drop the successive point here.
    NSInteger lastIndex = [self getLength] - 1;
    if (lastIndex >= 0 && [[self.inputPointerModel.mTimes objectAtIndex:lastIndex] integerValue] > eventTime) {
//        kLogInfo(@"[BATCH]drop stale event: %f,%f|%ld last: %ld,%ld|%ld", point.x, point.y, eventTime, [[self.inputPointerModel.mXCoordinates objectAtIndex:lastIndex] integerValue], [[self.inputPointerModel.mYCoordinates objectAtIndex:lastIndex] integerValue], [[self.inputPointerModel.mTimes objectAtIndex:lastIndex] integerValue]);
        return;
    }
    [self.inputPointerModel appendPointer:point eventTime:eventTime identify:touch keyModel:keyModel];
//    kLogInfo(@"[BATCH]after append pointer   : batchPoints=%@", self.inputPointerModel);
}

- (void)updateMajorEvent:(CGPoint)point eventTime:(NSInteger)eventTime {
    self.lastMajorEventTime = eventTime;
    self.lastMajorEventX = point.x;
    self.lastMajorEventY = point.y;
}

- (NSInteger)detectFastMove:(CGPoint)point eventTime:(NSInteger)eventTime {
    NSInteger lastIndex = [self getLength] - 1;
    NSInteger lastX = [[self.inputPointerModel.mXCoordinates objectAtIndex:lastIndex] integerValue];
    NSInteger lastY = [[self.inputPointerModel.mYCoordinates objectAtIndex:lastIndex] integerValue];
    UITouch* touch = [self.inputPointerModel.mPointerIds objectAtIndex:lastIndex];
    NSInteger dist = [CMBizHelper distanceBetweenPoint:CGPointMake(lastX, lastY) point:point];
    NSInteger msecs = eventTime - [[self.inputPointerModel.mTimes objectAtIndex:lastIndex] integerValue];
    if (msecs > 0) {
        NSInteger pixelsPerSec = dist * MSEC_PER_SEC;
        if (self.detectFastMoveTime <= 0 && pixelsPerSec > self.detectFastMoveSpeedThreshold*msecs) {
            self.detectFastMoveTime = eventTime;
            self.detectFastMoveX = point.x;
            self.detectFastMoveY = point.y;
            self.detectFastMoveTouch = touch;
        }
    }
    return dist;
}

- (BOOL)hasRecognitionTimePast:(long)currentTime lastRecognitionTime:(long)lastRecognitionTime {
    return currentTime > lastRecognitionTime + 100; // mRecognitionMinimumTime msec
}

@end
