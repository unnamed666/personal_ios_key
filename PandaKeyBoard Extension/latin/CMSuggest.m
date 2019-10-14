//
//  CMSuggest.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/30.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMSuggest.h"
#import "SuggestedWordInfo.h"
#import "CMBinaryDictionary.h"
#import "CmposedData.h"
#import "CMNgramContext.h"
#import "CMProximityInfo.h"
#import "InputPointers.h"
#import "CMStringUtils.h"
#import "CMSettingManager.h"
#import "CMAutoCorrectionUtils.h"
#import "CMCommUtil.h"
#import "DictionaryFacilitatorImpl.h"
#import "CMSuggestionUtil.h"
#import "CMKeyModel.h"
#import "NSString+Common.h"
#import "CMEmojiSuggest.h"

@interface CMSuggest ()

@property (nonatomic,strong) NSDictionary *sLanguageToMaximumAutoCorrectionWithSpaceLength;
//@property (nonatomic,strong) CMBinaryDictionary *bDic;
//@property (nonatomic,strong) CmposedData * cmposseData;
@property (nonatomic,strong) CMNgramContext *ngramContext;

@property (nonatomic, strong) CMEmojiSuggest *emojiSuggest;

//for debug
@property (nonatomic, strong)NSMutableArray* mutArray;
@property (nonatomic, strong)NSMutableDictionary* mutDic;

@end


static int SUPPRESS_SUGGEST_THRESHOLD = -2000000000;


@implementation CMSuggest

- (NSMutableArray *)mutArray {
    if (!_mutArray) {
        _mutArray = [NSMutableArray array];
    }
    return _mutArray;
}

- (NSMutableDictionary *)mutDic {
    if (!_mutDic) {
        _mutDic = [NSMutableDictionary dictionary];
    }
    return _mutDic;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        int MAXIMUM_AUTO_CORRECT_LENGTH_FOR_GERMAN = 12;
        _sLanguageToMaximumAutoCorrectionWithSpaceLength = @{@"de":@(MAXIMUM_AUTO_CORRECT_LENGTH_FOR_GERMAN)};
        
        self.dictionaryFacilitator = [[DictionaryFacilitatorImpl alloc] init];
        [self reset];
        self.emojiSuggest = [[CMEmojiSuggest alloc] init];
     }
    return self;
}

- (void)reset {
    [self.dictionaryFacilitator resetDictionariesWithLanguageType:kCMSettingManager.languageType];
    self.ngramContext = [[CMNgramContext alloc] init];
}

- (void)suggestionFromWordComposer:(CMWordComposer*)wordComposer ngramContext:(CMNgramContext*)ngramContext proximityInfo:(CMProximityInfo*)proximityInfo completion:(void (^)(SuggesteWords *suggestedWords))completion {
    if(!wordComposer.isBatchMode){
        if(!proximityInfo){
            if(completion)
                completion(nil);
            completion = nil;
            return;
        }
        if(wordComposer.typeWordCache.length <=0 && (ngramContext.mPrevWords.count==1&&ngramContext.mPrevWords.firstObject.length<=0)){
            if(completion)
                completion(nil);
            completion = nil;
        }

        [self getSuggestedWordsForNonBatchInputFromWordComposer:wordComposer ngramContext:ngramContext proximityInfo:proximityInfo completion:completion];
    }
    else {
        [self getSuggestedWordsForBatchInput:wordComposer ngramContext:ngramContext proximityInfo:proximityInfo completionBlock:completion];
    }
}

- (void)dealloc
{
//    kLogTrace();
    self.dictionaryFacilitator = nil;
    self.ngramContext = nil;
    if (_mutDic) {
        [_mutDic removeAllObjects];
        _mutDic = nil;
    }
    if (_mutArray) {
        [_mutArray removeAllObjects];
        _mutArray = nil;
    }
}

- (void)handleMemoryWarning {
//    kLogTrace();
    [self.dictionaryFacilitator handleMemoryWarning];
}

- (int)binaryDictionaryVersion{
    return [self.dictionaryFacilitator mainDictionaryVersion];
}

- (BOOL)isMainDictionaryValid {
    return [self.dictionaryFacilitator isValidMainDictionary];
}

- ( NSMutableArray<SuggestedWordInfo*>*)getTransformedSuggestedWordInfoList:(CMWordComposer*)wordComposer suggestion:(NSArray<SuggestedWordInfo*>*)suggestion trailingSingleQuotesCount:(int)trailingSingleQuotesCount{
    BOOL shouldMakeSuggestionsAllUpperCase = wordComposer.isAllUpperCase && !wordComposer.isResumed;
    BOOL isOnlyFirstCharCapitalized = wordComposer.isOrWillBeOnlyFirstCharCapitalized;
    NSArray * array = suggestion.count>18?[suggestion subarrayWithRange:NSMakeRange(0, 17)]:suggestion;
    NSMutableArray<SuggestedWordInfo*>* suggestionsContainer = [[NSMutableArray alloc] initWithArray:array];
    if(isOnlyFirstCharCapitalized || shouldMakeSuggestionsAllUpperCase || 0 != trailingSingleQuotesCount){
        for (SuggestedWordInfo * wordInfo in suggestionsContainer) {
            NSMutableString *sb = [[NSMutableString alloc] initWithCapacity:wordInfo.word.length];
            if(shouldMakeSuggestionsAllUpperCase){
                [sb appendString: [wordInfo.word uppercaseString]];
            }else if(isOnlyFirstCharCapitalized){
                [sb appendString:[wordInfo.word capitalizedString]];
            }else{
                [sb appendString:wordInfo.word];
            }
            NSRange range = [wordInfo.word rangeOfString:@"'"];
            
            int quotesToAppend = trailingSingleQuotesCount - (range.location == NSNotFound ?0:1);
            for (int i = quotesToAppend -1; i>=0; --i) {
                [sb appendString:@"'"];
            }
            wordInfo.word = [sb copy];
            
        }
    }
    return suggestionsContainer;
}
- (SuggestedWordInfo*)getWhitelistedWordInfoOrNull:(NSArray<SuggestedWordInfo*> *)suggestions{
    if(suggestions.count == 0)return nil;
    SuggestedWordInfo * firstSuggestedWordInfo = suggestions[0];
    
    if(![firstSuggestedWordInfo isKindOf:KIND_WHITELIST]){
        return nil;
    }
    
    return firstSuggestedWordInfo;
}

- (BOOL)isAllowedByAutoCorrectionWithSpaceFilter:(SuggestedWordInfo*)info{
    
    NSNumber * maximumLengthForThisLanguage = _sLanguageToMaximumAutoCorrectionWithSpaceLength[info.local];
    if(!maximumLengthForThisLanguage)return YES;
    NSRange range = [info.word rangeOfString:@"'"];
    return (info.word.length <= [maximumLengthForThisLanguage intValue]) || (range.location == NSNotFound);
}

- (void)fetchTFSuggestions:(CMWordComposer*)wordComposer completion:(void (^)(SuggesteWords *suggestedWords))completion {
    BOOL isBatchMode = wordComposer.isBatchMode;
    NSString * lastword = [wordComposer.typeWordCache copy];
    InputPointers * inputPointers =  [wordComposer.inputPointers copy];
    int trailingSingleQuotesCount = [CMStringUtils getTrailingSingleQuotesCount:lastword];
    
    CmposedData * localData = [[CmposedData alloc] initWithInputPointers:inputPointers isBatchMode:isBatchMode typeWord:lastword];

//    self.cmposseData.inputPointers = inputPointers;
//    self.cmposseData.isBatchMode = isBatchMode;
//    self.cmposseData.typeWord = lastword;
    
    NSArray<SuggestedWordInfo*> * suggestions= [self.dictionaryFacilitator fetchTFSuggestions:localData];
    if (!suggestions || suggestions.count <= 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    NSMutableArray<SuggestedWordInfo*> *suggestionsContainer = [self getTransformedSuggestedWordInfoList:wordComposer suggestion:suggestions trailingSingleQuotesCount:trailingSingleQuotesCount];
    if (YES/*SHOULD_REMOVE_PREVIOUSLY_REJECTED_SUGGESTION*/ && suggestionsContainer.count > 1 && [[suggestionsContainer firstObject].word isEqualToString:wordComposer.rejectedBatchModeSuggestion]) {
        SuggestedWordInfo* rejected = suggestionsContainer.firstObject;
        [suggestionsContainer removeObjectAtIndex:0];
        [suggestionsContainer insertObject:rejected atIndex:1];
    }
    [CMSuggestionUtil removeDup:nil suggestedWordInfoArray:suggestionsContainer];
    
    for (NSInteger i = suggestionsContainer.count - 1; i >= 0; i--) {
        if ([suggestionsContainer objectAtIndex:i].score < SUPPRESS_SUGGEST_THRESHOLD) {
            [suggestionsContainer removeObjectAtIndex:i];
        }
    }
    SuggestedWordInfo* pseudoTypedWordInfo = (!suggestionsContainer || suggestionsContainer.count <= 0) ? nil : [suggestionsContainer objectAtIndex:0];
    
    SuggesteWords* suggestedWord = [[SuggesteWords alloc] init];
    suggestedWord.suggestionsList = [suggestionsContainer copy];
    suggestedWord.willAutoCorrect = NO;
    suggestedWord.typedWordInfo = pseudoTypedWordInfo;
    suggestedWord.typedWordValid = YES;
    
    NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
    NSMutableString* mutStr = [NSMutableString string];
    NSMutableArray* mutArray = [NSMutableArray array];
    
    InputPointers* inputPointer = wordComposer.inputPointers;
    
    __block NSUInteger count = 0;
    [inputPointer.keyModelArray enumerateObjectsUsingBlock:^(CMKeyModel * _Nonnull keyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![NSString stringIsEmpty:keyModel.key]) {
            [mutStr appendString:[keyModel.key lowercaseString]];
            count++;
        }
    }];
    
    [mutDic setObject:@(count) forKey:@"originalCount"];
    [mutDic setObject:[mutStr copy] forKey:@"codes"];

    [suggestedWord.suggestionsList enumerateObjectsUsingBlock:^(SuggestedWordInfo * _Nonnull word, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutArray addObject:word.word];
    }];
    
    [mutDic setObject:[mutArray copy] forKey:@"suggestWords"];
    
    [self.mutArray addObject:[mutDic copy]];

    if (completion) {
        completion(suggestedWord);
    }
}

- (void)getSuggestedWordsForBatchInput:(CMWordComposer *)wordComposer ngramContext:(CMNgramContext *)ngramContext proximityInfo:(CMProximityInfo *)proximityInfo completionBlock:(void (^)(SuggesteWords *suggestedWords))block {
    BOOL isBatchMode = wordComposer.isBatchMode;
    NSString * lastword = [wordComposer.typeWordCache copy];
    InputPointers * inputPointers =  [wordComposer.inputPointers copy];
    int trailingSingleQuotesCount = [CMStringUtils getTrailingSingleQuotesCount:lastword];
    
    CmposedData * localData = [[CmposedData alloc] initWithInputPointers:inputPointers isBatchMode:isBatchMode typeWord:lastword];

//    self.cmposseData.inputPointers = inputPointers;
//    self.cmposseData.isBatchMode = isBatchMode;
//    self.cmposseData.typeWord = lastword;
    
    NSArray<SuggestedWordInfo*> * suggestions= [self.dictionaryFacilitator getSuggestionsWithComposedData:localData ngramContext:ngramContext proximityInfoHandle:proximityInfo.mNativeProximityInfo sessionId:0];

    NSMutableArray<SuggestedWordInfo*> *suggestionsContainer = [self getTransformedSuggestedWordInfoList:wordComposer suggestion:suggestions trailingSingleQuotesCount:trailingSingleQuotesCount];

    if (YES/*SHOULD_REMOVE_PREVIOUSLY_REJECTED_SUGGESTION*/ && suggestionsContainer.count > 1 && [[suggestionsContainer firstObject].word isEqualToString:wordComposer.rejectedBatchModeSuggestion]) {
        SuggestedWordInfo* rejected = suggestionsContainer.firstObject;
        [suggestionsContainer removeObjectAtIndex:0];
        [suggestionsContainer insertObject:rejected atIndex:1];
    }
    [CMSuggestionUtil removeDup:nil suggestedWordInfoArray:suggestionsContainer];
    
    for (NSInteger i = suggestionsContainer.count - 1; i >= 0; i--) {
        if ([suggestionsContainer objectAtIndex:i].score < SUPPRESS_SUGGEST_THRESHOLD) {
            [suggestionsContainer removeObjectAtIndex:i];
        }
    }
    
    // In the batch input mode, the most relevant suggested word should act as a "typed word"
    // (typedWordValid=true), not as an "auto correct word" (willAutoCorrect=false).
    // Note that because this method is never used to get predictions, there is no need to
    // modify inputType such in getSuggestedWordsForNonBatchInput.
    SuggestedWordInfo* pseudoTypedWordInfo = (!suggestionsContainer || suggestionsContainer.count <= 0) ? nil : [suggestionsContainer objectAtIndex:0];
    
    SuggesteWords* suggestedWord = [[SuggesteWords alloc] init];
    suggestedWord.suggestionsList = [suggestionsContainer copy];
    suggestedWord.willAutoCorrect = NO;
    suggestedWord.typedWordInfo = pseudoTypedWordInfo;
    suggestedWord.typedWordValid = YES;
    
    NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
    NSMutableString* mutStr = [NSMutableString string];
    NSMutableArray* mutArray = [NSMutableArray array];
    
    InputPointers* inputPointer = wordComposer.inputPointers;
    
    __block NSUInteger count = 0;
    [inputPointer.keyModelArray enumerateObjectsUsingBlock:^(CMKeyModel * _Nonnull keyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![NSString stringIsEmpty:keyModel.key]) {
            [mutStr appendString:[keyModel.key lowercaseString]];
            count++;
        }
    }];
    
    [mutDic setObject:@(count) forKey:@"originalCount"];
    [mutDic setObject:[mutStr copy] forKey:@"codes"];
    
    [suggestedWord.suggestionsList enumerateObjectsUsingBlock:^(SuggestedWordInfo * _Nonnull word, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutArray addObject:word.word];
    }];
    
    [mutDic setObject:[mutArray copy] forKey:@"suggestWords"];
    
    [self.mutArray addObject:[mutDic copy]];
    
    
    if (block) {
        block(suggestedWord);
    }
}

- (void)saveToLog:(BOOL)tf {
    if (self.mutArray.count <= 0) {
        return;
    }
    [self.mutDic setObject:[self.mutArray copy] forKey:@"data"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self.mutDic copy]
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        kLogError(@"[%@] Got an error: %@", tf?@"TENSOR":@"NGRAM", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        kLogError(@"[%@] %@", tf?@"TENSOR":@"NGRAM", jsonString);
    }
    [self.mutDic removeAllObjects];
    [self.mutArray removeAllObjects];
}

- (void)getSuggestedWordsForNonBatchInputFromWordComposer:(CMWordComposer*)wordComposer ngramContext:(CMNgramContext*)ngramContext  proximityInfo:(CMProximityInfo*)proximityInfo completion:(void (^)(SuggesteWords *suggestedWords))completion{
    
    BOOL isBatchMode = wordComposer.isBatchMode;
    NSString * lastword = [wordComposer.typeWordCache copy];
    InputPointers * inputPointers =  [wordComposer.inputPointers copy];
    BOOL resumed = wordComposer.isResumed;
    BOOL hasDigits = wordComposer.hasDigits;
    BOOL isMostlyCaps = wordComposer.isMostlyCaps;
    BOOL resultsArePredictions = ![wordComposer isComposingWord];
    //    runOnBackground(^(){
    int trailingSingleQuotesCount = [CMStringUtils getTrailingSingleQuotesCount:lastword];
    NSString* consideredWord = trailingSingleQuotesCount>0 ? [lastword substringWithRange:NSMakeRange(0, lastword.length - trailingSingleQuotesCount)]:lastword;
    
    CmposedData * localData = [[CmposedData alloc] initWithInputPointers:inputPointers isBatchMode:isBatchMode typeWord:lastword];
//    self.cmposseData.inputPointers = inputPointers;
//    self.cmposseData.isBatchMode = isBatchMode;
//    self.cmposseData.typeWord = lastword;
   
    NSArray<SuggestedWordInfo*> * suggestions= [self.dictionaryFacilitator getSuggestionsWithComposedData:localData  ngramContext:ngramContext proximityInfoHandle:proximityInfo.mNativeProximityInfo sessionId:0];
    if(!suggestions)suggestions = [NSArray new];
    
    NSMutableArray<SuggestedWordInfo*> *suggestionsContainer = [self getTransformedSuggestedWordInfoList:wordComposer suggestion:suggestions trailingSingleQuotesCount:trailingSingleQuotesCount];
    
//    BOOL foundInDictionary = NO;
//    
//    for (SuggestedWordInfo * info in suggestionsContainer) {
//        if( [info.word isEqualToString:lastword]){
//            foundInDictionary = YES;
//            break;
//        }
//    }
    
    //去重
    NSMutableSet *set = [NSMutableSet new];
    NSMutableArray<SuggestedWordInfo*> *deleteContainer = [NSMutableArray new];
    for (SuggestedWordInfo* info in suggestionsContainer) {
        if([set containsObject:info.word]){
            [deleteContainer addObject:info];
        }else{
            [set addObject:info.word];
        }
    }
    [suggestionsContainer removeObjectsInArray:deleteContainer];
    
    //删除与输入内容相同的 correction
    int firstOccurrenceOfTypeWordInSuggestions = -1;
     SuggestedWordInfo * firstSuggestion = suggestions.firstObject;
    if([firstSuggestion isAppropriateForAutoCorrection] && lastword.length>0){
        for (int i = (int)suggestionsContainer.count -1 ; i>=0; i--) {
            SuggestedWordInfo * info = suggestionsContainer[i];
            if([info.word isEqualToString:lastword]){
                [suggestionsContainer removeObjectAtIndex:i];
                firstOccurrenceOfTypeWordInSuggestions = i;
            }else if(info.score<0){
                [suggestionsContainer removeObjectAtIndex:i];
            }
        }
    }else{
        for (int i = (int)suggestionsContainer.count -1 ; i>0; i--){
            SuggestedWordInfo * info = suggestionsContainer[i];
            if(info.score<0){
                [suggestionsContainer removeObjectAtIndex:i];
            }
        }
    }
    
//
//    for (SuggestedWordInfo * info in suggestionsContainer){
//        NSLog(@"autocorrection =  %d",[info isAppropriateForAutoCorrection]) ;
//    }
//    
    
    SuggestedWordInfo * whitelistedWordInfo = [self getWhitelistedWordInfoOrNull:suggestionsContainer];
    NSString *whitelistedWord = whitelistedWordInfo == nil ? nil : whitelistedWordInfo.word;
    
    BOOL SHOULD_AUTO_CORRECT_USING_NON_WHITE_LISTED_SUGGESTION = NO;
    //正在输入的字符大于1 同时 返回的内容没有和输入字符相同
    BOOL allowsToBeAutoCorrected = (SHOULD_AUTO_CORRECT_USING_NON_WHITE_LISTED_SUGGESTION || whitelistedWord!=nil)
    ||(consideredWord.length > 1 && (-1 == firstOccurrenceOfTypeWordInSuggestions)) ||
    ([consideredWord isEqualToString:@"i"] && kCMSettingManager.languageType == CMKeyboardLanguageTypeEnglishUnitedState);
//    BOOL allowsToBeAutoCorrected = (whitelistedWord!=nil)||(consideredWord.length > 1 && (NO == foundInDictionary));
    BOOL hasAutoCorrection = NO;
    if(!kCMSettingManager.autoCorrectEnabled ||
       !allowsToBeAutoCorrected ||
       resultsArePredictions ||//没有正在输入的字符
       suggestions.count == 0 ||
       hasDigits||//有数字
       isMostlyCaps||//大写字母多于一个的
       resumed ||//非点击输入的
       ![self.dictionaryFacilitator hasAtLeastOneInitializedMainDictionary]|| //没有主词库
       [suggestions.firstObject isKindOf:KIND_SHORTCUT]){
        hasAutoCorrection = NO;
    }else{
        SuggestedWordInfo * firstSuggestion = suggestions.firstObject;
        //根据score(权重) 判断是否autoCorrection
        if(![CMAutoCorrectionUtils suggestionExceedsThreshold:firstSuggestion consideredWord:consideredWord threshold:kCMSettingManager.autoCorrectionThreshold]){
            hasAutoCorrection = NO;
        }else{
            hasAutoCorrection = [self isAllowedByAutoCorrectionWithSpaceFilter:firstSuggestion];
        }
    }
    
    SuggesteWords * suggesteWords = [[SuggesteWords alloc] init];
    if(hasAutoCorrection){
        suggesteWords.willAutoCorrect = INDEX_OF_AUTO_CORRECTION;
    }
    
    if( lastword.length>0){
        SuggestedWordInfo * typeWordInfo =  [[SuggestedWordInfo alloc] initWithWord:lastword prevWordsContext:@"" score:MAX_SCORE sourceDict:nil  kindAndFlags:KIND_TYPED indexOfTouchPointOfSecondWord:NOT_AN_INDEX autoCommitFirstWordConfidence:NOT_A_CONFIDENCE timestamp:NOT_A_TIMESTAMP];
        if(hasAutoCorrection){
            suggesteWords.willAutoCorrect +=1;
        }
        [suggestionsContainer insertObject:typeWordInfo atIndex:0];
    }
    
    // 获取 Emoji 建议列表
    NSArray* suggestEmoji;
    NSString * keyword;
    if (resultsArePredictions && ngramContext.mPrevWords.count >0)
    {
        keyword = [ngramContext.mPrevWords objectAtIndex:0];
        suggestEmoji = [self.emojiSuggest getSuggestEmojiList:keyword];
    }
    else
    {
        keyword = localData.typeWord;
        suggestEmoji = [self.emojiSuggest getSuggestEmojiList:keyword];
    }
    
    if (suggestEmoji != nil && [suggestEmoji count] > 0)
    {
        SuggestedWordInfo * emojiWord =  [[SuggestedWordInfo alloc] initWithWord:[suggestEmoji objectAtIndex:0] prevWordsContext:@"" score:MAX_SCORE sourceDict:nil kindAndFlags:KIND_EMOJI indexOfTouchPointOfSecondWord:NOT_AN_INDEX autoCommitFirstWordConfidence:NOT_A_CONFIDENCE timestamp:NOT_A_TIMESTAMP];
       
        NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:suggestEmoji.count+1];
        [array addObject:keyword];
        [array addObjectsFromArray:suggestEmoji];
        emojiWord.suggestEmoji = array;
        
        if (suggestionsContainer.count >= 2)
        {
            [suggestionsContainer insertObject:emojiWord atIndex:2];
        }
        else
        {
            [suggestionsContainer insertObject:emojiWord atIndex:suggestionsContainer.count];
        }
    }
    
    suggesteWords.suggestionsList = suggestionsContainer;

    if(completion){
        completion(suggesteWords);
        completion = nil;
    }
}
@end
