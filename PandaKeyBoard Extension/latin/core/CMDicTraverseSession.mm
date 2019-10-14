//
//  DicTraverseSession.m
//  test
//
//  Created by wolf on 17/1/12.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "CMDicTraverseSession.h"
//#import "Latin_DicTraverseSession.h"

//#import "dic_traverse_session.h"
#include "suggest/core/session/dic_traverse_session.h"


using namespace latinime;

@interface CMDicTraverseSession (){
}

@end



@implementation CMDicTraverseSession : NSObject


+ (long long) latinime_setDicTraverseSession:(NSString*)localeJStr dictSize:(long long)dictSize {
    void *traverseSession = DicTraverseSession::getSessionInstance(0,nullptr, dictSize);
    return reinterpret_cast<long long>(traverseSession);
}

+ (void) latinime_initDicTraverseSession:(long long) traverseSession dictionary:(long long)dictionary previousWord:(int[]) previousWord previousWordLength:(int)previousWordLength {
    DicTraverseSession *ts = reinterpret_cast<DicTraverseSession *>(traverseSession);
    if (!ts) {
        return;
    }
    Dictionary *dict = reinterpret_cast<Dictionary *>(dictionary);
    if (!previousWord) {
        NgramContext emptyNgramContext;
        ts->init(dict, &emptyNgramContext, 0 /* suggestOptions */);
        return;
    }
    //    int prevWord[previousWordLength];
    //    env->GetIntArrayRegion(previousWord, 0, previousWordLength, prevWord);
    NgramContext ngramContext(previousWord, previousWordLength, false /* isStartOfSentence */);
    ts->init(dict, &ngramContext, 0 /* suggestOptions */);
}

+ (void) latinime_releaseDicTraverseSession:(long long) traverseSession {
    DicTraverseSession *ts = reinterpret_cast<DicTraverseSession *>(traverseSession);
    DicTraverseSession::releaseSessionInstance(ts);
}

- (instancetype)initWithLocale:(NSString*)locale dictionary:(long long)dictionary dictSize:(long)dictSize
{
    self = [super init];
    if (self) {
        mNativeDicTraverseSession = [CMDicTraverseSession latinime_setDicTraverseSession:locale dictSize:dictSize];
        [self setupSessionWithDictionary:dictionary];
        
        _mNativeSuggestOptions = [[NativeSuggestOptions alloc] init];
        
    }
    return self;
}

- (void)setupSessionWithDictionary:(long long) dictionary{
    [self setupSessionWithDictionary:dictionary previousWord:NULL previousWordLength:0];
}

- (void)setupSessionWithDictionary:(long long) dictionary previousWord:(int[])previousWord previousWordLength:(int)previousWordLength{
    [CMDicTraverseSession latinime_initDicTraverseSession:mNativeDicTraverseSession dictionary:dictionary previousWord:previousWord previousWordLength:previousWordLength];
}

- (void)dealloc
{
    [self closeInternal];
}

- (void)close{
    [self closeInternal];
}

- (void)closeInternal{
    if(mNativeDicTraverseSession != 0){
        [CMDicTraverseSession latinime_releaseDicTraverseSession:mNativeDicTraverseSession];
        mNativeDicTraverseSession = 0;
    }
}


@end
