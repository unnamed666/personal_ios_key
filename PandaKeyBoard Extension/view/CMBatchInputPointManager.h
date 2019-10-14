//
//  CMBatchInputPointManager.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InputPointers;
@class CMKeyModel;

@interface CMBatchInputPointManager : NSObject
@property (nonatomic, readonly, strong)InputPointers* inputPointerModel;


- (void)setKeyWidth:(CGFloat)keyWidth keyboardHeight:(CGFloat)keyboardHeight;

- (void)addTouchDownEventPoint:(CGPoint)point identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel elapsedTimeSinceFirstTouchDown:(NSTimeInterval)downElapsed elapsedTimeSinceLastType:(NSTimeInterval)typeElapsed;

- (BOOL)addEventPoint:(CGPoint)point elapsedTimeSinceFirstGestureDown:(NSTimeInterval)downElapsed identify:(UITouch *)touch keyModel:(CMKeyModel *)keyModel isMajorEvent:(BOOL)isMajorEvent;

- (BOOL)hasRecognitionTimePast:(long)currentTime lastRecognitionTime:(long)lastRecognitionTime;

- (BOOL)isStartOfAGesture;

- (NSInteger)getLength;

- (void)reset;

@end
