//
//  CMSuggest.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/30.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMWordComposer.h"
@class SuggesteWords;
@class CMProximityInfo;
@class CMNgramContext;
@class DictionaryFacilitatorImpl;
@interface CMSuggest : NSObject


@property (nonatomic,strong) DictionaryFacilitatorImpl * dictionaryFacilitator;

- (void)suggestionFromWordComposer:(CMWordComposer*)wordComposer ngramContext:(CMNgramContext*)ngramContext  proximityInfo:(CMProximityInfo*)proximityInfo completion:(void (^)(SuggesteWords *suggestedWords))completion;

- (void)fetchTFSuggestions:(CMWordComposer*)wordComposer completion:(void (^)(SuggesteWords *suggestedWords))completion;

//更新主词库 当切换语言的时候
- (void)reset;
//主词库版本号
- (int)binaryDictionaryVersion;

- (BOOL)isMainDictionaryValid;

- (void)saveToLog:(BOOL)tf;

- (void)handleMemoryWarning;

@end
