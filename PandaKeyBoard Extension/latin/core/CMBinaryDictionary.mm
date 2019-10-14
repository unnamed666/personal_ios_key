//
//  BinaryDictionary.m
//  test
//
//  Created by wolf on 17/1/12.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "CMBinaryDictionary.h"
//#import "Latin_BinaryDictionary.h"
#import "CMDicTraverseSession.h"
#import "CmposedData.h"
#import "InputPointers.h"
#import "CMNgramContext.h"
#import "SuggestedWordInfo.h"
#import "CMStringUtils.h"
//#include "dictionary_structure_with_buffer_policy_factory.h"
//#include "dictionary.h"
//#include "proximity_info.h"
//#include "suggest_options.h"
//#include "suggestion_results.h"
#import "dictionary/structure/dictionary_structure_with_buffer_policy_factory.h"
#import "dictionary/interface/dictionary_header_structure_policy.h"
#import "suggest/core/dictionary/dictionary.h"
#import "suggest/core/layout/proximity_info.h"
#import "suggest/core/suggest_options.h"
#import "suggest/core/result/suggestion_results.h"

#import "dictionary/header/header_read_write_utils.h"

#import <suggest/policyimpl/gesture/gesture_suggest_policy_factory.h>
#import <suggest/policyimpl/gesture/gesture_suggest_policy.h>
#import "fst/fst.h"

@interface CMBinaryDictionary
(){
    long long mNativeDict;
    int mDictSize;
    BOOL mIsUpdatable;
    BOOL mHasUpdated;
    BOOL mUseFullEditDistance;
}
@property (nonatomic,strong) NSString *mDictFilePath;


@property (nonatomic,strong) NSMutableDictionary<NSNumber*,CMDicTraverseSession*> *mDicTraverseSessions;

@end


using namespace latinime;
//using namespace latinime;
@implementation CMBinaryDictionary


+ (long long)latinime_BinaryDictionary_open:(NSString*)path dictOffset:(int)dictOffset DictSize:(int)dictSize Updatable:(BOOL)isUpdatable{
    
    
    latinime::DictionaryStructureWithBufferPolicy::StructurePolicyPtr dictionaryStructureWithBufferPolicy(
                                                                                                latinime::DictionaryStructureWithBufferPolicyFactory::newPolicyForExistingDictFile(
                                                                                                                                                                         [path UTF8String], static_cast<int>(dictOffset), static_cast<int>(dictSize),
                                                                                                                                                                         isUpdatable));
    
    if(dictionaryStructureWithBufferPolicy == nullptr)return 0;
    
    latinime::Dictionary *const dictionary = new latinime::Dictionary(0, std::move(dictionaryStructureWithBufferPolicy));
    
    return reinterpret_cast<long long>(dictionary);
}

+ (void)latinime_BinaryDictionary_close:(long long)dict{
    latinime::Dictionary *dictionary = reinterpret_cast<latinime::Dictionary *>(dict);
    if (!dictionary) return;
    delete dictionary;
}


+ (long long)latinime_BinaryDictionary_createOnMemory:(int)formatVersion locale:(NSString*)locale attributeDictionary:(NSDictionary<NSString*,NSString*>*)attributeDictionary {
    
    std::vector<int> localeCodePoints;
    
    HeaderReadWriteUtils::insertCharactersIntoVector([locale UTF8String], &localeCodePoints);

    __block  DictionaryHeaderStructurePolicy::AttributeMap attributeMap;
    
    [attributeDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        DictionaryHeaderStructurePolicy::AttributeMap::key_type skey;
        HeaderReadWriteUtils::insertCharactersIntoVector([key UTF8String], &skey);
        DictionaryHeaderStructurePolicy::AttributeMap::mapped_type svalue;
        HeaderReadWriteUtils::insertCharactersIntoVector([obj UTF8String], &svalue);
        attributeMap[skey]=svalue;
    }];
    
    DictionaryStructureWithBufferPolicy::StructurePolicyPtr dictionaryStructureWithBufferPolicy =
    DictionaryStructureWithBufferPolicyFactory::newPolicyForOnMemoryDict(formatVersion, localeCodePoints, &attributeMap);
    if (!dictionaryStructureWithBufferPolicy) {
        return 0;
    }
    
//    GestureSuggestPolicyFactory::setGestureSuggestPolicyFactoryMethod(&GestureSuggestPolicy::getInstance);
    Dictionary *const dictionary = new Dictionary(0, std::move(dictionaryStructureWithBufferPolicy));
    return reinterpret_cast<long long>(dictionary);
    
}

+ (BOOL)latinime_BinaryDictionary_flushWithGC:(long long)dict filePath:(NSString*)filePath{
    latinime::Dictionary *dictionary = reinterpret_cast<latinime::Dictionary *>(dict);
    if (!dictionary) return false;
    return dictionary->flushWithGC([filePath UTF8String]);
}


+ (BOOL)latinime_BinaryDictionary_flush:(long long)dict filePath:(NSString*)filePath{
    latinime::Dictionary *dictionary = reinterpret_cast<latinime::Dictionary *>(dict);
    if (!dictionary) return false;
    return dictionary->flush([filePath UTF8String]);
}


static DictionaryStructureWithBufferPolicy::StructurePolicyPtr runGCAndGetNewStructurePolicy(
                                                                                             DictionaryStructureWithBufferPolicy::StructurePolicyPtr structurePolicy,
                                                                                             const char *const dictFilePath) {
    structurePolicy->flushWithGC(dictFilePath);
    structurePolicy.release();
    return DictionaryStructureWithBufferPolicyFactory::newPolicyForExistingDictFile(dictFilePath, 0 /* offset */, 0 /* size */, true /* isUpdatable */);
}

+ (BOOL)latinime_BinaryDictionary_migrateNative:(long long)dict filePath:(NSString*)dictFilePath newFormatVersion:(int)newFormatVersion{
    latinime::Dictionary *dictionary = reinterpret_cast<latinime::Dictionary *>(dict);
    if (!dictionary) return false;
    
    const DictionaryHeaderStructurePolicy *const headerPolicy = dictionary->getDictionaryStructurePolicy()->getHeaderStructurePolicy();
    DictionaryStructureWithBufferPolicy::StructurePolicyPtr dictionaryStructureWithBufferPolicy = DictionaryStructureWithBufferPolicyFactory::newPolicyForOnMemoryDict(newFormatVersion, *headerPolicy->getLocale(), headerPolicy->getAttributeMap());
    if (!dictionaryStructureWithBufferPolicy) {
        printf("Cannot migrate header.");
        return false;
    }
    
    int wordCodePoints[MAX_WORD_LENGTH];
    int wordCodePointCount = 0;
    int token = 0;
    // Add unigrams.
    do {
        token = dictionary->getNextWordAndNextToken(token, wordCodePoints, &wordCodePointCount);
        const WordProperty wordProperty = dictionary->getWordProperty(CodePointArrayView(wordCodePoints, wordCodePointCount));
        if (wordCodePoints[0] == CODE_POINT_BEGINNING_OF_SENTENCE) {
            // Skip beginning-of-sentence unigram.
            continue;
        }
        if (dictionaryStructureWithBufferPolicy->needsToRunGC(true /* mindsBlockByGC */)) {
            dictionaryStructureWithBufferPolicy = runGCAndGetNewStructurePolicy(std::move(dictionaryStructureWithBufferPolicy), [dictFilePath UTF8String]);
            if (!dictionaryStructureWithBufferPolicy) {
                printf("Cannot open dict after GC.");
                return false;
            }
        }
        if (!dictionaryStructureWithBufferPolicy->addUnigramEntry(
                                                                  CodePointArrayView(wordCodePoints, wordCodePointCount),
                                                                  &wordProperty.getUnigramProperty())) {
            printf("Cannot add unigram to the new dict.");
            return false;
        }
    } while (token != 0);
    
    // Add ngrams.
    do {
        token = dictionary->getNextWordAndNextToken(token, wordCodePoints, &wordCodePointCount);
        const WordProperty wordProperty = dictionary->getWordProperty(CodePointArrayView(wordCodePoints, wordCodePointCount));
        if (dictionaryStructureWithBufferPolicy->needsToRunGC(true /* mindsBlockByGC */)) {
            dictionaryStructureWithBufferPolicy = runGCAndGetNewStructurePolicy(std::move(dictionaryStructureWithBufferPolicy), [dictFilePath UTF8String]);
            if (!dictionaryStructureWithBufferPolicy) {
                printf("Cannot open dict after GC.");
                return false;
            }
        }
        for (const NgramProperty &ngramProperty : wordProperty.getNgramProperties()) {
            if (!dictionaryStructureWithBufferPolicy->addNgramEntry(&ngramProperty)) {
                printf("Cannot add ngram to the new dict.");
                return false;
            }
        }
    } while (token != 0);
    // Save to File.
    dictionaryStructureWithBufferPolicy->flushWithGC([dictFilePath UTF8String]);
    return YES;
}






- (instancetype)initWithFilePath:(NSString*)filePath locale:(NSString*)locale useFullEditDistance:(BOOL)useFullEditDistance dictType:(NSString*)dictType formatVersion:(int)formatVersion attributeDictionary:(NSDictionary*)attributeDictionary
{
    self = [super init];
    if (self) {
        self.mDictFilePath = filePath;
        mIsUpdatable = YES;
        mHasUpdated = NO;
        mDictSize = 0;
        mNativeDict = [CMBinaryDictionary latinime_BinaryDictionary_createOnMemory:formatVersion locale:locale attributeDictionary:attributeDictionary];
    }
    return self;
}


- (instancetype)initWithFilePath:(NSString*)filePath  locale:(NSString*)locale isUpadtable:(BOOL)isUpadtable useFullEditDistance:(BOOL)useFullEditDistance
{
    self = [super init];
    if (self) {
        if(filePath.length < 5)return self;
        if(![CMDirectoryHelper fileExists:filePath])return self;
        
        _mDicTraverseSessions = [NSMutableDictionary new];
        self.mDictFilePath = filePath;
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        mDictSize =  [attributes[NSFileSize] intValue];
        
        mNativeDict = [CMBinaryDictionary latinime_BinaryDictionary_open:filePath dictOffset:0 DictSize:mDictSize Updatable:isUpadtable];
        
        mUseFullEditDistance = useFullEditDistance;
        self.locale = locale;
        self.dictType = TYPE_MAIN;
        mIsUpdatable = isUpadtable;
        mHasUpdated = NO;
    }
    return self;
}

-(void)dealloc{
    [self close];
}



- (void)close{
    @synchronized (_mDicTraverseSessions) {
        [_mDicTraverseSessions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [obj close];
        }];
        [_mDicTraverseSessions removeAllObjects];
  
    }
    
    @synchronized (self) {
        if(mNativeDict != 0){
            [CMBinaryDictionary latinime_BinaryDictionary_close:mNativeDict];
            mNativeDict = 0;
        }
    }

}
#pragma mark - public

- (BOOL)isCorruptedNative{
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) return NO;
    return dictionary->getDictionaryStructurePolicy()->isCorrupted();
}

- (BOOL)needsToRunGC:(BOOL)mindsBlockByGC{
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) return NO;
    return dictionary->needsToRunGC(mindsBlockByGC == YES);
}

- (BOOL)migrateTo:(int)newFormatVersion{
    NSString *migratingDir = [NSString stringWithFormat:@"%@.migrating",self.mDictFilePath];
    [CMDirectoryHelper deleteDirOrFile:migratingDir];
    [CMDirectoryHelper createDir:migratingDir];
    NSString* tmpDictFilePath =  [NSString stringWithFormat:@"%@.migrate",self.mDictFilePath];
    if(![CMBinaryDictionary latinime_BinaryDictionary_migrateNative:mNativeDict filePath:tmpDictFilePath newFormatVersion:newFormatVersion]){
        return NO;
    }
    [self close];
    
    [CMDirectoryHelper deleteDirOrFile:self.mDictFilePath];
    
    if(![CMDirectoryHelper moveDirOrFileAtPath:tmpDictFilePath toPath:self.mDictFilePath]){
        return NO;
    }
    
    mDictSize = [CMDirectoryHelper fielLen:self.mDictFilePath];
    [self loadDictionary:0 length:mDictSize isUpdatable:mIsUpdatable];
    return YES;
//    [CMDirectoryHelper deleteDirOrFile:migratingDir];
}

- (BOOL)flushWithGC{
    if(mNativeDict ==0){return NO;}
    if(![CMBinaryDictionary latinime_BinaryDictionary_flushWithGC:mNativeDict filePath:_mDictFilePath]){
        return NO;
    }
    [self reOpen];
    return YES;
}

- (BOOL)flush{
    if(mNativeDict ==0){return NO;}
    if(mHasUpdated){
        if(![CMBinaryDictionary latinime_BinaryDictionary_flush:mNativeDict filePath:_mDictFilePath]){
            return NO;
        }
        [self reOpen];
        mHasUpdated = NO;
    }
    return YES;
    
}

- (void)flushWithGCIfHasUpdated{
    if(mHasUpdated){
        [self flushWithGC];
    }
}


- (BOOL)isValidDictionary{
    return mNativeDict != 0;
}

- (int)getVersion{
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) {
        return 0;
    }
    
   const  DictionaryHeaderStructurePolicy * const headerPolicy = dictionary->getDictionaryStructurePolicy()->getHeaderStructurePolicy();
    return headerPolicy->getVersion();
}

- (int)getFormatVersion{
    
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) return 0;
    const DictionaryHeaderStructurePolicy *const headerPolicy =
    dictionary->getDictionaryStructurePolicy()->getHeaderStructurePolicy();
    return headerPolicy->getFormatVersionNumber();
}


- (NSArray*) getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId weightForLocale:(float)weightForLocale inOutWeightOfLangModelVsSpatialModel:(float)inOutWeightOfLangModelVsSpatialModel{

    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) {
        return nil;
    }
    
    
    CMDicTraverseSession *session = [self getTraverseSession:sessionId];
    
    DicTraverseSession *traverseSession = reinterpret_cast<DicTraverseSession *>(session->mNativeDicTraverseSession);
    if (!traverseSession) {
        return nil;
    }
    
    ProximityInfo *pInfo = reinterpret_cast<ProximityInfo *>(proximityInfoHandle);

    
    memset(session->mInputCodePoints, -1, MAX_WORD_LENGTH * sizeof(session->mInputCodePoints[0]));
    
    int inputSize = 0;
    if(!cmposseData.isBatchMode){
        inputSize = [cmposseData copyCodePointsExceptTrailingSingleQuotesAndReturnCodePointCount:session->mInputCodePoints destinationLen:MAX_WORD_LENGTH];
        if(inputSize<0)return nil;
    }else{
        inputSize = (UInt32)cmposseData.inputPointers.mXCoordinates.count;
    }
    
    
    int xCoordinates[inputSize];
    int yCoordinates[inputSize];
    int times[inputSize];
    int pointerIds[inputSize];
    NSArray*mXCoordinates = cmposseData.inputPointers.mXCoordinates;
    NSArray*mYCoordinates = cmposseData.inputPointers.mYCoordinates;
    NSArray*mTimes = cmposseData.inputPointers.mTimes;
    for (int i = 0 ; i<inputSize; i++) {
        xCoordinates[i] = mXCoordinates.count>i?(int)([mXCoordinates[i] floatValue]*kNativeScale) :-1;
        yCoordinates[i] = mYCoordinates.count>i?(int)([mYCoordinates[i] floatValue]*kNativeScale):-1;
        times[i] = mTimes.count>i?[mTimes[i] intValue]:0;
        pointerIds[i] = 0;
//        pointerIds[i] = [cmposseData.inputPointers.mPointerIds[i] intValue];
    }
    
    
    [session.mNativeSuggestOptions setIsGesture:cmposseData.isBatchMode];
    [session.mNativeSuggestOptions setUseFullEditDistance:mUseFullEditDistance];
    [session.mNativeSuggestOptions setBlockOffensiveWords:YES];
    [session.mNativeSuggestOptions setWeightForLocale:weightForLocale];
    
    
    SuggestOptions givenSuggestOptions(session.mNativeSuggestOptions->mOptions, sizeof(session.mNativeSuggestOptions->mOptions)/sizeof(session.mNativeSuggestOptions->mOptions[0]));
    
    SuggestionResults suggestionResults(MAX_RESULTS);
    
    NgramContext ngramContext = [self constructNgramContextFromCMNgramContext:cmNgramContext];
    
    if(givenSuggestOptions.isGesture() || inputSize > 0){
        dictionary->getSuggestions(pInfo, traverseSession, xCoordinates, yCoordinates, times, pointerIds, session->mInputCodePoints, inputSize, &ngramContext, &givenSuggestOptions, inOutWeightOfLangModelVsSpatialModel, &suggestionResults);
    }else{
        dictionary->getPredictions(&ngramContext, &suggestionResults);
    }
    
#ifdef DEBUG
    suggestionResults.dumpSuggestions();
#endif
    int outputSuggestionCount=0;
    unichar outputCodePoints[MAX_WORD_LENGTH * MAX_RESULTS];
    int outputScores[MAX_RESULTS];
    int outputIndices[MAX_RESULTS];
    int outputTypes[MAX_RESULTS];
    int outputTimestamp[MAX_RESULTS];
    int outputAutoCommitFirstWordConfidence[1];
//    memset(outputCodePoints, 0, MAX_WORD_LENGTH * MAX_RESULTS*sizeof(int));
    
    suggestionResults.outputSuggestions(&outputSuggestionCount, outputCodePoints, outputScores, outputIndices, outputTypes, outputAutoCommitFirstWordConfidence, &inOutWeightOfLangModelVsSpatialModel,outputTimestamp);
    
    NSMutableSet * set =[[NSMutableSet alloc] initWithCapacity:outputSuggestionCount];
    
#ifdef DEBUG
    kLog(@"----%@-----",self.dictType);
    NSMutableArray<SuggestedWordInfo*> *suggestionstem = [[NSMutableArray alloc] initWithCapacity:outputSuggestionCount];
    for (int j= outputSuggestionCount-1; j>=0; --j) {
        int start = j*MAX_WORD_LENGTH;
        int len =0;
        while (len<MAX_WORD_LENGTH && outputCodePoints[start+len] != 0) {
            ++len;
        }
        if(len>0){
            NSString * str = [NSString stringWithCharacters:outputCodePoints+start length:len];
            int score = (int)(outputScores[j]*weightForLocale);
            SuggestedWordInfo * suggestedWordInfo = [[SuggestedWordInfo alloc] initWithWord:str prevWordsContext:nil score:score  sourceDict:self kindAndFlags:outputTypes[j] indexOfTouchPointOfSecondWord:outputIndices[j] autoCommitFirstWordConfidence:outputAutoCommitFirstWordConfidence[0] timestamp:outputTimestamp[j]];
            [suggestionstem addObject:suggestedWordInfo];
        }
    }
    kLog(@"%@",suggestionstem);
#endif
    
    NSMutableArray<SuggestedWordInfo*> *suggestions = [[NSMutableArray alloc] initWithCapacity:outputSuggestionCount];
    for (int j= outputSuggestionCount-1; j>=0; --j) {
        int start = j*MAX_WORD_LENGTH;
        int len =0;
        while (len<MAX_WORD_LENGTH && outputCodePoints[start+len] != 0) {
            ++len;
        }
        if(len>0){
            NSString * str = [NSString stringWithCharacters:outputCodePoints+start length:len];
            
            if([set containsObject:str])continue;
            [set addObject:str];
            int score = (int)(outputScores[j]*weightForLocale);
//            kLog(@" %@  %d",str,score);
            if(suggestions.count>0 && score<0)continue;
            SuggestedWordInfo * suggestedWordInfo = [[SuggestedWordInfo alloc] initWithWord:str prevWordsContext:nil score:score  sourceDict:self kindAndFlags:outputTypes[j] indexOfTouchPointOfSecondWord:outputIndices[j] autoCommitFirstWordConfidence:outputAutoCommitFirstWordConfidence[0] timestamp:outputTimestamp[j]];
            [suggestions addObject:suggestedWordInfo];
        }
    }

    return suggestions;
}

- (int)frequencyWithWord:(NSString*)word{
    if(word.length <= 0) return NOT_A_PROBABILITY;
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) {
        return NOT_A_PROBABILITY;
    }
    
    int codePoints[(int)word.length];
    int len = [CMStringUtils getCodePointArray:codePoints world:word];
    
    return dictionary->getProbability(CodePointArrayView(codePoints,len));
}

- (BOOL)isValidWord:(NSString*)word{
    return [self frequencyWithWord:word] != NOT_A_PROBABILITY;
}


- (BOOL)updateEntriesForWordWithNgramContext:(CMNgramContext*)ngram word:(NSString*)word isValidWord:(BOOL)isValidWord count:(int)count timestamp:(int)timestamp{
    if(word.length<=0)return NO;
    
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) {
        return NO;
    }
    
    NgramContext ngramContext = [self constructNgramContextFromCMNgramContext:ngram];
    
    int codePoints[(int)word.length];
    int len = [CMStringUtils getCodePointArray:codePoints world:word];
    

    const HistoricalInfo historicalInfo(timestamp, 0 /* level */, count);
    BOOL b = dictionary->updateEntriesForWordWithNgramContext(&ngramContext,
                                                            CodePointArrayView(codePoints, len), isValidWord == YES,
                                                            historicalInfo);
    if(b)mHasUpdated = YES;
    return b;
}

- (BOOL)removeUnigramEntryNative:(NSString*)word{
    if(word.length<1)return NO;
    Dictionary *dictionary = reinterpret_cast<Dictionary *>(mNativeDict);
    if (!dictionary) {
        return NO;
    }
    
    int codePoints[(int)word.length];
    int len = [CMStringUtils getCodePointArray:codePoints world:word];
    
    if(!dictionary->removeUnigramEntry(CodePointArrayView(codePoints,len)))
        return NO;
    
    mHasUpdated = YES;
    return YES;
    
}

#pragma mark - private
- (CMDicTraverseSession*)getTraverseSession:(int)traverseSessionId{
    CMDicTraverseSession *traverseSession = [self.mDicTraverseSessions objectForKey:@(traverseSessionId) ];
    if(!traverseSession){
        traverseSession = [[CMDicTraverseSession alloc] initWithLocale:self.locale dictionary:mNativeDict dictSize:mDictSize];
        self.mDicTraverseSessions[@(traverseSessionId)] = traverseSession;
    }
    return traverseSession;
}

- (NgramContext) constructNgramContextFromCMNgramContext:(CMNgramContext*)cmNgramContext{
    int prevWordCodePoints[MAX_PREV_WORD_COUNT_FOR_N_GRAM][MAX_WORD_LENGTH] = {0};
    int prevWordCodePointCount[MAX_PREV_WORD_COUNT_FOR_N_GRAM]= {0};
    bool isBeginningOfSentence[MAX_PREV_WORD_COUNT_FOR_N_GRAM]= {0};
    
    int (*pprevWordCodePoints)[MAX_WORD_LENGTH] = prevWordCodePoints;
    int *pprevWordCodePointCount = prevWordCodePointCount;
    bool *pisBeginningOfSentence = isBeginningOfSentence;
    [cmNgramContext.mIsBeginningOfSentence enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        pisBeginningOfSentence[idx] = [obj boolValue];
    }];
    [cmNgramContext.mPrevWords enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.length <= MAX_WORD_LENGTH){
            unichar buffer[obj.length];
            
            memset(buffer, 0, sizeof(unichar)*obj.length);
            
            [obj getCharacters:buffer range:NSMakeRange(0, obj.length)];
            for (int i = 0 ; i< obj.length; i++) {
                *(*(pprevWordCodePoints+idx)+i) = buffer[i];
            }
            pprevWordCodePointCount[idx] = (int)obj.length;
        }
    }];
 
    return NgramContext(prevWordCodePoints, prevWordCodePointCount, isBeginningOfSentence,
                        cmNgramContext.mPrevWords.count);
}

- (void)loadDictionary:(int)startOffset length:(int)length isUpdatable:(BOOL)isUpdatable{
    mHasUpdated = NO;
    mNativeDict = [CMBinaryDictionary latinime_BinaryDictionary_open:self.mDictFilePath dictOffset:startOffset DictSize:length Updatable:isUpdatable];
}

- (void)reOpen{
    [self close];
    mDictSize = [CMDirectoryHelper fielLen:self.mDictFilePath];
    [self loadDictionary:0 length:mDictSize isUpdatable:mIsUpdatable];
    
}
@end
