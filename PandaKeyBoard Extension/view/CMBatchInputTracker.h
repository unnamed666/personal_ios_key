//
//  CMBatchInputTracker.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMBatchInputTracker;
@class InputPointers;
@class CMKeyModel;

@protocol CMBatchInputTrackerDelegate <NSObject>

- (void)onStartbatchInput:(CMBatchInputTracker *)tracker;

- (void)onUpateBatchInput:(CMBatchInputTracker *)tracker pointModel:(InputPointers *)inputPointerModel moveEventTime:(NSTimeInterval)moveTime;

- (void)onStartUpdateBatchInputTimer:(CMBatchInputTracker *)tracker;

- (void)onEndBatchInput:(CMBatchInputTracker *)tracker pointModel:(InputPointers *)inputPointerModel upEventTime:(NSTimeInterval)upTime;

@end

@interface CMBatchInputTracker : NSObject
@property (nonatomic, weak)id<CMBatchInputTrackerDelegate> delegate;

- (instancetype)initWithDelegate:(id<CMBatchInputTrackerDelegate>)delegate;

- (void)setKeyWidth:(CGFloat)keyWidth keyboardHeight:(CGFloat)keyboardHeight;

- (NSInteger)getElapsedTimeSinceFirstDown:(long)eventTime;

- (BOOL)addMoveEventPoint:(CGPoint)point identify:(UITouch *)touch moveEventTime:(long)moveEventTime keyModel:(CMKeyModel *)keyModel isMajorEvent:(BOOL)isMajorEvent;

- (void)addDownEventPoint:(CGPoint)point identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel downEventTime:(long)downEventTime lastLetterTypingTime:(long)lastLetterTypingTime activePointerCount:(NSInteger)activePointerCount;

- (void)updateBatchInput:(long)moveEventTime;

- (BOOL)mayStartBatchInput;

- (BOOL)mayEndBatchInput:(long)upEventTime activePointerCount:(NSInteger)activePointerCount;

- (void)reset;

@end
