//
//  CMNgramContext.m
//  test
//
//  Created by yanzhao on 2017/3/25.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "CMNgramContext.h"
#import "OCDefines.h"




@interface CMNgramContext ()<NSCopying>

@end


@implementation CMNgramContext
///**
// * @param prev 传入当前textView中的字符串 40以内
// * @param spacingAndPunctuations 未知
// * @param n  textView中有未提交的文字（带下滑线的，android）传 2 没有则传1 （ CMNgramContext中保存的3个字符 必须是提交过的字符）
// */
//- (NgramContext) getNgramContextFromNthPreviousWord:(NSString*)prev spacingAndPunctuations:(id)spacingAndPunctuations n:(int)n{
//    
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mMaxPrevWordCount = MAX_PREV_WORD_COUNT_FOR_N_GRAM;
        self.mPrevWords = [NSMutableArray new];
        self.mIsBeginningOfSentence = [NSMutableArray new];
        _mIsUsedForGuidAutoCorrect = NO;
    }
    return self;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone{
    CMNgramContext * ngram = [[[self class] allocWithZone:zone] init];
    ngram.mMaxPrevWordCount = self.mMaxPrevWordCount;
    ngram.mPrevWords = [self.mPrevWords mutableCopy];
    ngram.mIsBeginningOfSentence = [self.mIsBeginningOfSentence mutableCopy];
    ngram.mIsUsedForGuidAutoCorrect = self.mIsUsedForGuidAutoCorrect;
    return ngram;
}
- (void)reset{
    [self.mPrevWords removeAllObjects];
    [self.mIsBeginningOfSentence removeAllObjects];
    _mIsUsedForGuidAutoCorrect = NO;
//    for (int i=0; i< self.mMaxPrevWordCount; i++) {
//        [self.mPrevWords addObject:@""];
//        [self.mIsBeginningOfSentence addObject:@(NO)];
//    }
}

- (void)insertPreWord:(NSString*)preWord isBeginningOfSentence:(BOOL)isBeginningOfSentence{
    if(self.mMaxPrevWordCount <= self.mPrevWords.count){
        [self.mPrevWords removeLastObject];
        [self.mIsBeginningOfSentence removeLastObject];
    }
    [self.mPrevWords insertObject:preWord atIndex:0];
    [self.mIsBeginningOfSentence insertObject:@(isBeginningOfSentence) atIndex:0];
}

- (void)addPreWord:(NSString*)preWord isBeginningOfSentence:(BOOL)isBeginningOfSentence{
    if(self.mMaxPrevWordCount > self.mPrevWords.count){
        [self.mPrevWords addObject:preWord];
        [self.mIsBeginningOfSentence addObject:@(isBeginningOfSentence)];
    }
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@  %@", self.mPrevWords, self.mIsBeginningOfSentence];
}
@end
