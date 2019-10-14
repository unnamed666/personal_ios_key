//
//  DictionaryFacilitatorImpl.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/22.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CmposedData;
@class CMNgramContext;
@interface DictionaryFacilitatorImpl : NSObject

- (void)resetDictionariesWithLanguageType:(CMKeyboardLanguageType)languageType;
- (void)resetTensorFlowDicWithLanguageType:(CMKeyboardLanguageType)languageType;

- (BOOL)isValidMainDictionary;

- (int)mainDictionaryVersion;
- (BOOL)hasAtLeastOneInitializedMainDictionary;

- (NSArray*)getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId;

- (NSArray*)fetchTFSuggestions:(CmposedData *)cmposseData;

- (void)addToUserHistory:(NSString*)suggestion wasAutoCapitalized:(BOOL)wasAutoCapitalized ngramContext:(CMNgramContext*)ngramContext timeStampInSeconds:(long)time blockPotentiallyOffensive:(BOOL)blockPotentiallyOffensive;

- (void)saveToUserHistoryDictionary;
- (void)unlearnFromUserHistory:(NSString*)word;

- (void)handleMemoryWarning;

@end
