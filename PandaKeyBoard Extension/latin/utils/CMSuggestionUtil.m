//
//  CMSuggestionUtil.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMSuggestionUtil.h"
#import "NSString+Common.h"
#import "SuggestedWordInfo.h"

@implementation CMSuggestionUtil

// 翻译自android/SuggestedWords.java
+ (NSInteger)removeDup:(NSString *)typedWord suggestedWordInfoArray:(NSMutableArray<SuggestedWordInfo *>*)candidates {
    if (!candidates || candidates.count <= 0) {
        return -1;
    }
    NSInteger firstOccurrenceOfWord = -1;
    if (![NSString stringIsEmpty:typedWord]) {
        firstOccurrenceOfWord = [CMSuggestionUtil removeSuggestedWordInfo:typedWord fromArray:candidates startIndex:-1];
    }
    [candidates enumerateObjectsUsingBlock:^(SuggestedWordInfo * _Nonnull wordInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [CMSuggestionUtil removeSuggestedWordInfo:wordInfo.word fromArray:candidates startIndex:idx];
    }];
    return firstOccurrenceOfWord;
}

// 翻译自android/SuggestedWords.java
+ (NSInteger)removeSuggestedWordInfo:(NSString *)word fromArray:(NSMutableArray<SuggestedWordInfo *>*)candidates startIndex:(NSUInteger)startIndexExclusive {
    NSInteger firstOccurenceOfWord = -1;
    for (NSInteger i = startIndexExclusive+1; i < candidates.count; i++) {
        SuggestedWordInfo* previous = [candidates objectAtIndex:i];
        if ([word isEqualToString:previous.word]) {
            if (firstOccurenceOfWord == -1) {
                firstOccurenceOfWord = i;
            }
            [candidates removeObjectAtIndex:i];
            --i;
        }
    }
    return firstOccurenceOfWord;
}


@end
