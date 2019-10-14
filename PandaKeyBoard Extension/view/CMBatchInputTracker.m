//
//  CMBatchInputTracker.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBatchInputTracker.h"
#import "CMBatchInputPointManager.h"
#import "CMKeyModel.h"

static NSInteger kLastRecognitionPointSize = 0;
static NSInteger kLastRecognitionTime = 0;

@interface CMBatchInputTracker ()
@property(nonatomic, strong)CMBatchInputPointManager* pointManager;
@property(nonatomic, assign)long gestureFirstDownTime;

@end

@implementation CMBatchInputTracker

- (instancetype)initWithDelegate:(id<CMBatchInputTrackerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)setKeyWidth:(CGFloat)keyWidth keyboardHeight:(CGFloat)keyboardHeight {
    [self.pointManager setKeyWidth:keyWidth keyboardHeight:keyboardHeight];
}

/**
 * Calculate elapsed time since the first gesture down.
 *
 * @param eventTime the time of this event.
 * @return the elapsed time in millisecond from the first gesture down.
 */
- (NSInteger)getElapsedTimeSinceFirstDown:(long)eventTime {
    NSInteger elapseTime = (NSInteger)(eventTime - self.gestureFirstDownTime);
//    kLogInfo(@"[BATCH]gestureFirstDownTime(%ld) elapsedTimeSinceFirstDown(%ld)", self.gestureFirstDownTime, elapseTime);
    return elapseTime;
}

/**
 * Add a down event point.
 *
 * @param point                    the coordinate of this down event.
 * @param downEventTime        the time of this down event.
 * @param lastLetterTypingTime the last typing input time.
 * @param activePointerCount   the number of active pointers when this pointer down event occurs.
 */
- (void)addDownEventPoint:(CGPoint)point identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel downEventTime:(long)downEventTime lastLetterTypingTime:(long)lastLetterTypingTime activePointerCount:(NSInteger)activePointerCount {
    if (activePointerCount == 1) {
        self.gestureFirstDownTime = downEventTime;
    }
    NSInteger elapsedTimeSinceFirstDown = [self getElapsedTimeSinceFirstDown:downEventTime];
    NSInteger elapsedTimeSinceLastTyping = (NSInteger)(downEventTime - lastLetterTypingTime + 2);
    [self.pointManager addTouchDownEventPoint:point identify:touch keyModel:keyModel elapsedTimeSinceFirstTouchDown:elapsedTimeSinceFirstDown elapsedTimeSinceLastType:elapsedTimeSinceLastTyping];
}

/**
 * Add a move event point.
 *
 * @param point                    the coordinate of this down event.
 * @param moveEventTime the time of this move event.
 * @param isMajorEvent  false if this is a historical move event.
 * @return true if this move event occurs on the valid gesture area.
 */
- (BOOL)addMoveEventPoint:(CGPoint)point identify:(UITouch *)touch moveEventTime:(long)moveEventTime keyModel:(CMKeyModel *)keyModel isMajorEvent:(BOOL)isMajorEvent {
    NSInteger beforeLength = [self.pointManager getLength];
    BOOL onValidArea = [self.pointManager addEventPoint:point elapsedTimeSinceFirstGestureDown:[self getElapsedTimeSinceFirstDown:moveEventTime] identify:touch keyModel:keyModel isMajorEvent:isMajorEvent];
    if (self.delegate && [self.pointManager getLength] > beforeLength) {
        [self.delegate onStartUpdateBatchInputTimer:self];
    }
    return onValidArea;
}

/**
 * Determine whether the batch input has started or not.
 *
 * @return true if the batch input has started successfully.
 */
- (BOOL)mayStartBatchInput {
    if (![self.pointManager isStartOfAGesture]) {
        return NO;
    }

    kLastRecognitionTime = 0;
    kLastRecognitionPointSize = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStartbatchInput:)]) {
        [self.delegate onStartbatchInput:self];
    }
    return YES;
}

- (void)reset {
    [self.pointManager reset];
}

/**
 * Determine whether we have enough gesture points to lookup dictionary.
 *
 * @param moveEventTime the time of this move event.
 *       {@link BatchInputArbiterListener#onUpdateBatchInput(InputPointers, long)} of
 *                      this <code>listener</code> will be called when enough event points we have. Also
 *                      {@link BatchInputArbiterListener#onStartUpdateBatchInputTimer()} will be called to have
 *                      possible future synthetic move event.
 */
- (void)updateBatchInput:(long)moveEventTime {
    NSInteger size = [self.pointManager getLength];
    if (size > kLastRecognitionPointSize && [self.pointManager hasRecognitionTimePast:moveEventTime lastRecognitionTime:kLastRecognitionTime]) {
        if (self.delegate) {
            [self.delegate onUpateBatchInput:self pointModel:self.pointManager.inputPointerModel moveEventTime:moveEventTime];
            [self.delegate onStartUpdateBatchInputTimer:self];
        }
        kLastRecognitionPointSize = [self.pointManager getLength];
        kLastRecognitionTime = moveEventTime;
    }
}

/**
 * Determine whether the batch input has ended successfully or continues.
 *
 * @param upEventTime        the time of this up event.
 * @param activePointerCount the number of active pointers when this pointer up event occurs.
 *            {@link BatchInputArbiterListener#onEndBatchInput(InputPointers, long)} of this
 *                           <code>listener</code> will be called when the batch input has started successfully.
 * @return true if the batch input has ended successfully.
 */
- (BOOL)mayEndBatchInput:(long)upEventTime activePointerCount:(NSInteger)activePointerCount {
    if (activePointerCount == 1 && self.delegate) {
        [self.delegate onEndBatchInput:self pointModel:self.pointManager.inputPointerModel upEventTime:upEventTime];
        return YES;
    }
    return NO;
}

#pragma mark - setter/getter
- (CMBatchInputPointManager *)pointManager {
    if (!_pointManager) {
        _pointManager = [CMBatchInputPointManager new];
    }
    return _pointManager;
}

@end
