//
//  CMNgramContext.h
//  test
//
//  Created by yanzhao on 2017/3/25.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMNgramContext : NSObject
@property (nonatomic,assign) int mMaxPrevWordCount;
@property (nonatomic,strong) NSMutableArray<NSString*> * mPrevWords;
@property (nonatomic,strong) NSMutableArray<NSNumber*> * mIsBeginningOfSentence;//BOOL
@property (nonatomic, assign)BOOL mIsUsedForGuidAutoCorrect;
- (void)reset;
- (void)insertPreWord:(NSString*)preWord isBeginningOfSentence:(BOOL)isBeginningOfSentence;
- (void)addPreWord:(NSString*)preWord isBeginningOfSentence:(BOOL)isBeginningOfSentence;

@end
