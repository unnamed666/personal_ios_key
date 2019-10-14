//
//  CMSuggestionUtil.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SuggestedWordInfo;

@interface CMSuggestionUtil : NSObject

+ (NSInteger)removeDup:(NSString *)typedWord suggestedWordInfoArray:(NSMutableArray<SuggestedWordInfo *>*)candidates;

+ (NSInteger)removeSuggestedWordInfo:(NSString *)word fromArray:(NSMutableArray<SuggestedWordInfo *>*)candidates startIndex:(NSUInteger)startIndexExclusive;

@end
