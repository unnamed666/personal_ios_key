//
//  DictionaryFacilitatorImpl.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/22.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "DictionaryFacilitatorImpl.h"
#import "CMCommUtil.h"
#import "CMBinaryDictionary.h"
#import "UserHistoryDictionary.h"
#import "CmposedData.h"
#import "SuggestedWordInfo.h"
#import "CMNgramContext.h"
#import "Constants.h"
#import "OCDefines.h"
#import "CMEmojiSuggestManager.h"
#import "CMSettingManager.h"

const int WEIGHT_FOR_MOST_PROBABLE_LANGUAGE = 1.0f;
const int WEIGHT_FOR_GESTURING_IN_NOT_MOST_PROBABLE_LANGUAGE = 0.95f;
const int WEIGHT_FOR_TYPING_IN_NOT_MOST_PROBABLE_LANGUAGE = 0.6f;
// HACK: This threshold is being used when adding a capitalized entry in the User History
// dictionary.
const int CAPITALIZED_FORM_MAX_PROBABILITY_FOR_INSERT = 140;

@interface DictionaryFacilitatorImpl ()
@property (nonatomic,strong) NSMutableDictionary <NSString*,CMDictionary*>* dictionaryGroup;
@property (nonatomic,strong) NSMutableArray * alldictonaryTypes;
@end

@implementation DictionaryFacilitatorImpl

- (void)resetDictionariesWithLanguageType:(CMKeyboardLanguageType)languageType{
    self.dictionaryGroup = [NSMutableDictionary new];
    
    NSString * local = [CMCommUtil keyboardLanguageTypeToLocaleString:languageType];
    
    
    
    NSString * lang = [CMCommUtil keyboardLanguageTypeToLang:languageType];
    NSString *fileName = [NSString stringWithFormat:@"main_%@",lang?lang:@"en"];
    NSString *path =  [[NSBundle mainBundle] pathForResource:fileName ofType:@"diction"];
    
    self.alldictonaryTypes = [NSMutableArray new];
    CMBinaryDictionary *bDic = [[CMBinaryDictionary alloc] initWithFilePath:path locale:local isUpadtable:false useFullEditDistance:NO];
    if([bDic isValidDictionary]){
        [self.dictionaryGroup setObject:bDic forKey:TYPE_MAIN];
        [self.alldictonaryTypes addObject:TYPE_MAIN];
    }
    if(kCMSettingManager.historyEnabled){
        UserHistoryDictionary *hDic = [[UserHistoryDictionary alloc] initWithLocal:local];//内部创建为异步线程,在这里判断 isValidDictionary 肯定会返还 NO
        [self.dictionaryGroup setObject:hDic forKey:TYPE_USER_HISTORY];
        [self.alldictonaryTypes addObject:TYPE_USER_HISTORY];
    }
}

- (BOOL)isValidMainDictionary {
    CMBinaryDictionary *bDic = (CMBinaryDictionary*) self.dictionaryGroup[TYPE_MAIN];
    return bDic ? [bDic isValidDictionary] : NO;
}

- (void)dealloc
{
    [self.dictionaryGroup removeAllObjects];
    self.dictionaryGroup = nil;
}


- (int)mainDictionaryVersion{
   CMBinaryDictionary *bDic = (CMBinaryDictionary*) self.dictionaryGroup[TYPE_MAIN];
    return [bDic getVersion];
}

- (BOOL)hasAtLeastOneInitializedMainDictionary{
    CMBinaryDictionary *bDic = (CMBinaryDictionary*) self.dictionaryGroup[TYPE_MAIN];
    return [bDic isInitialized];
}

- (NSArray*) getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId{

    
    float mWeightForGesturingInLocale = WEIGHT_FOR_MOST_PROBABLE_LANGUAGE;
    float mWeightForTypingInLocale = WEIGHT_FOR_MOST_PROBABLE_LANGUAGE;
    float weightForLocale = cmposseData.isBatchMode ? mWeightForGesturingInLocale : mWeightForTypingInLocale;
    
    NSMutableArray<SuggestedWordInfo*> * suggestionResults = [NSMutableArray new];
    for (NSString* key in self.alldictonaryTypes) {
        CMDictionary *dic = self.dictionaryGroup[key];
        NSArray * array = [dic getSuggestionsWithComposedData:cmposseData ngramContext:cmNgramContext proximityInfoHandle:proximityInfoHandle sessionId:sessionId weightForLocale:weightForLocale inOutWeightOfLangModelVsSpatialModel:NOT_A_WEIGHT_OF_LANG_MODEL_VS_SPATIAL_MODEL];
        if(!array || array.count == 0)continue;
        
//        kLog(@"%@",array);
        [suggestionResults addObjectsFromArray:array];
    }
    
    return [suggestionResults sortedArrayUsingComparator:^NSComparisonResult(SuggestedWordInfo *  _Nonnull o1, SuggestedWordInfo *  _Nonnull o2) {
//        NSLog(@"o1 = %@ ,p2 = %@ ",o1,o2);
        if (o1.score > o2.score) return NSOrderedAscending;
        if (o1.score < o2.score) return NSOrderedDescending;
        if (o1.timestamp > o2.timestamp) return NSOrderedAscending;
        if (o1.timestamp < o2.timestamp) return NSOrderedDescending;
        if (o1.word.length < o2.word.length) return NSOrderedAscending;
        if (o1.word.length > o2.word.length) return NSOrderedDescending;
        return [o1.word compare:o2.word];
        
    }];;
}

- (void)addToUserHistory:(NSString*)suggestion wasAutoCapitalized:(BOOL)wasAutoCapitalized ngramContext:(CMNgramContext*)ngramContext timeStampInSeconds:(long)time blockPotentiallyOffensive:(BOOL)blockPotentiallyOffensive{
  
     NSArray * arr = [suggestion componentsSeparatedByString:STRING_SPACE];
    __block CMNgramContext *ngramContextForCurrentWord = ngramContext;
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL wasCurrentWordAutoCapitalized = (idx == 0) ? wasAutoCapitalized : false;
        [self addWordToUserHistory:obj wasAutoCapitalized:wasCurrentWordAutoCapitalized ngramContext:ngramContextForCurrentWord timeStampInSeconds:time blockPotentiallyOffensive:blockPotentiallyOffensive];
        
        CMNgramContext * tem = [ngramContextForCurrentWord copy];
        ngramContextForCurrentWord = tem;
        [ngramContextForCurrentWord addPreWord:obj isBeginningOfSentence:NO];
    }];
    
}

- (BOOL)isValidSuggestionWord:(NSString*)word{
    for (NSString* key in self.alldictonaryTypes) {
        CMDictionary *dic = self.dictionaryGroup[key];
        if([dic isValidWord:word]){
            return YES;
        }
    }
    return NO;
}

- (void)saveToUserHistoryDictionary{
    UserHistoryDictionary *userHistoryDictionary = (UserHistoryDictionary*)self.dictionaryGroup[TYPE_USER_HISTORY];
    [userHistoryDictionary flushBinaryDictionary];
}

- (void)unlearnFromUserHistory:(NSString*)word{
    UserHistoryDictionary *userHistoryDictionary = (UserHistoryDictionary*)self.dictionaryGroup[TYPE_USER_HISTORY];
    [userHistoryDictionary removeUnigramEntryDynamically:word];
}

#pragma mark - private

- (void)addWordToUserHistory:(NSString*)word wasAutoCapitalized:(BOOL)wasAutoCapitalized ngramContext:(CMNgramContext*)ngramContext timeStampInSeconds:(long)time blockPotentiallyOffensive:(BOOL)blockPotentiallyOffensive{
    
    if(word.length > MAX_WORD_LENGTH)return;
    
    
    UserHistoryDictionary *userHistoryDictionary = (UserHistoryDictionary*)self.dictionaryGroup[TYPE_USER_HISTORY];
    if(!userHistoryDictionary)return;
    
    int maxFreq = [self frequencyWithWord:word];
    int maxFreqKeep = maxFreq;
    NSString* lowerCasedWord = [word lowercaseString];
    
    NSString* secondWord = word;
    if(![lowerCasedWord isEqualToString:word]){
        if(maxFreq == 0 && blockPotentiallyOffensive){
            return ;
        }
        int lowerCaseFreqInMainDict = self.dictionaryGroup[TYPE_MAIN]?[self.dictionaryGroup[TYPE_MAIN] frequencyWithWord:lowerCasedWord]:NOT_A_PROBABILITY;
        
        if (lowerCaseFreqInMainDict > maxFreq) {
            maxFreq = lowerCaseFreqInMainDict;
        }
        
        if (wasAutoCapitalized) {
            if ([self isValidSuggestionWord:word] && ![self isValidSuggestionWord:lowerCasedWord]) {
                // If the word was auto-capitalized and exists only as a capitalized word in the
                // dictionary, then we must not downcase it before registering it. For example,
                // the name of the contacts in start-of-sentence position would come here
                // with the
                // wasAutoCapitalized flag: if we downcase it, we'd register a lower-case
                // version
                // of that contact's name which would end up popping in suggestions.
                secondWord = word;
            } else {
                // If however the word is not in the dictionary, or exists as a lower-case word
                // only, then we consider that was a lower-case word that had been
                // auto-capitalized.
                secondWord = lowerCasedWord;
            }
        } else {
            // HACK: We'd like to avoid adding the capitalized form of common words to the User
            // History dictionary in order to avoid suggesting them until the dictionary
            // consolidation is done.
            // TODO: Remove this hack when ready.
            if (maxFreqKeep < lowerCaseFreqInMainDict
                && lowerCaseFreqInMainDict >= CAPITALIZED_FORM_MAX_PROBABILITY_FOR_INSERT) {
                // Use lower cased word as the word can be a distracter of the popular word.
                secondWord = lowerCasedWord;
            } else {
                secondWord = word;
            }
        }
    }
    BOOL isValid = maxFreq > 0 || ngramContext.mIsUsedForGuidAutoCorrect;
    [userHistoryDictionary addWord:secondWord ngramContext:ngramContext isValid:isValid timestamp:(int)time];
}

- (int)frequencyWithWord:(NSString*)word{
    if(word.length <=0 || word.length>500 ) return NOT_A_PROBABILITY;//500值是随便填的, emoji 长度有为11的
    int maxFreq = NOT_A_PROBABILITY;
    for (NSString* key in self.alldictonaryTypes) {
        CMDictionary *dic = self.dictionaryGroup[key];
        int tempFreq = [dic frequencyWithWord:word];
        if(tempFreq >= maxFreq){
            maxFreq = tempFreq;
        }
    }
    return maxFreq;
}

- (NSArray*) getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId weightForLocale:(float)weightForLocale  inOutWeightOfLangModelVsSpatialModel:(float)inOutWeightOfLangModelVsSpatialModel
{
     CMBinaryDictionary *bDic = (CMBinaryDictionary*) self.dictionaryGroup[TYPE_MAIN];
    return [bDic getSuggestionsWithComposedData:cmposseData ngramContext:cmNgramContext proximityInfoHandle:proximityInfoHandle sessionId:sessionId weightForLocale:weightForLocale inOutWeightOfLangModelVsSpatialModel:inOutWeightOfLangModelVsSpatialModel];
}

- (NSArray*) getEmojiSuggestResult:(NSString *)dataToGetEmoji
{
    return [[CMEmojiSuggestManager shareInstance] getSuggestEmojiList:dataToGetEmoji];;
}

@end
