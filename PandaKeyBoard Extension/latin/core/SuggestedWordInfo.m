//
//  SuggestedWordInfo.m
//  test
//
//  Created by yanzhao on 2017/3/27.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "SuggestedWordInfo.h"

#import "CMDictionary.h"

int const NOT_AN_INDEX = -1;
int const NOT_A_CONFIDENCE = -1;
int const NOT_A_TIMESTAMP = -1;
int const MAX_SCORE = 0x7fffffff;

int const KIND_MASK_KIND = 0xFF; // Mask to get only the kind
int const KIND_TYPED = 0; // What user typed
int const KIND_CORRECTION = 1; // Simple correction/suggestion
int const KIND_COMPLETION = 2; // Completion (suggestion with appended chars)
int const KIND_WHITELIST = 3; // Whitelisted word
int const KIND_BLACKLIST = 4; // Blacklisted word
int const KIND_HARDCODED = 5; // Hardcoded suggestion, e.g. punctuation
int const KIND_APP_DEFINED = 6; // Suggested by the application
int const KIND_SHORTCUT = 7; // A shortcut
int const KIND_PREDICTION = 8; // A prediction (== a suggestion with no input)
// KIND_RESUMED: A resumed suggestion (comes from a span, currently this type is used only
// in java for re-correction)
int const KIND_RESUMED = 9;
int const KIND_OOV_CORRECTION = 10; // Most probable string correction
int const KIND_EMOJI = 11; // Most probable string correction
int const KIND_CLIPBOARD = 12;
int const KIND_CLOUD_CORRECTION = 13;
int const KIND_CLOUD_PREDICTION = 14;
int const KIND_FLAG_APPROPRIATE_FOR_AUTO_CORRECTION = 0x10000000;

@interface SuggestedWordInfo ()
@property (nonatomic,weak) CMDictionary* sourceDict;
@end


@implementation SuggestedWordInfo

- (instancetype)initWithWord:(NSString*)word prevWordsContext:(NSString*)prevWordsContext score:(int)score sourceDict:(CMDictionary*)sourceDict kindAndFlags:(int)kindAndFlags indexOfTouchPointOfSecondWord:(int)indexOfTouchPointOfSecondWord autoCommitFirstWordConfidence:(int)autoCommitFirstWordConfidence timestamp:(int)timestamp{
    self = [super init];
    if (self) {
        _word = word;
        _prevWordsContext = prevWordsContext;
        _score = score;
        _sourceDict = sourceDict;
        _kindAndFlags  = kindAndFlags;
        _indexOfTouchPointOfSecondWord = indexOfTouchPointOfSecondWord;
        _autoCommitFirstWordConfidence = autoCommitFirstWordConfidence;
        _timestamp = timestamp;
    }
    return self;
}


- (instancetype)initWithCloudWord:(NSString*)word upack:(NSString*)upack score:(int)cloudIndex kindAndFlags:(int)kindAndFlags{
    self = [self initWithWord:word prevWordsContext:@"" score:cloudIndex sourceDict:nil kindAndFlags:kindAndFlags indexOfTouchPointOfSecondWord:NOT_AN_INDEX autoCommitFirstWordConfidence:NOT_A_CONFIDENCE timestamp:NOT_A_TIMESTAMP];
    _upack = upack;
    return self;
}


- (BOOL)isKindOf:(int)kind{
    return kind == (_kindAndFlags & KIND_MASK_KIND);
}
- (BOOL)isAppropriateForAutoCorrection{
    return (_kindAndFlags & KIND_FLAG_APPROPRIATE_FOR_AUTO_CORRECTION) != 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ _kindAndFlags = %d, score = %d", _word,(_kindAndFlags & KIND_MASK_KIND),_score];
}

- (int)infocCType{
    switch (_kindAndFlags & KIND_MASK_KIND) {
        case KIND_TYPED:
            return 0;
        case KIND_CORRECTION:
            return 1;
        case KIND_PREDICTION:
            return 2;
        case KIND_EMOJI:
            return 3;
        case KIND_CLOUD_CORRECTION:
            return 5;
        case KIND_CLOUD_PREDICTION:
            return 6;
        default:
            return -1;
    }
}

- (int)infocDType{
    if(_kindAndFlags == KIND_CLOUD_PREDICTION || _kindAndFlags == KIND_CLOUD_CORRECTION)
        return 4;
    if(!_sourceDict)return 3;
    
    if(_sourceDict.dictType == TYPE_MAIN){
        return 1;
    }else if(_sourceDict.dictType == TYPE_USER_HISTORY){
        return 2;
    }
    return 0;
}

@end

int const INDEX_OF_AUTO_CORRECTION = 0;

@implementation SuggesteWords

- (instancetype)init
{
    self = [super init];
    if (self) {
        _willAutoCorrect =-1;
    }
    return self;
}
@end
