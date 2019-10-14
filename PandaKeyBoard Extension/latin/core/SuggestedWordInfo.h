//
//  SuggestedWordInfo.h
//  test
//
//  Created by yanzhao on 2017/3/27.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMDictionary;

UIKIT_EXTERN int const NOT_AN_INDEX;
UIKIT_EXTERN int const NOT_A_CONFIDENCE;
UIKIT_EXTERN int const NOT_A_TIMESTAMP;
UIKIT_EXTERN int const MAX_SCORE;


UIKIT_EXTERN int const KIND_MASK_KIND; // Mask to get only the kind
UIKIT_EXTERN int const KIND_TYPED ; // What user typed
UIKIT_EXTERN int const KIND_CORRECTION; // Simple correction/suggestion
UIKIT_EXTERN int const KIND_COMPLETION; // Completion (suggestion with appended chars)
UIKIT_EXTERN int const KIND_WHITELIST; // Whitelisted word
UIKIT_EXTERN int const KIND_BLACKLIST; // Blacklisted word
UIKIT_EXTERN int const KIND_HARDCODED; // Hardcoded suggestion, e.g. punctuation
UIKIT_EXTERN int const KIND_APP_DEFINED; // Suggested by the application
UIKIT_EXTERN int const KIND_SHORTCUT; // A shortcut
UIKIT_EXTERN int const KIND_PREDICTION; // A prediction (== a suggestion with no input)
// KIND_RESUMED: A resumed suggestion (comes from a span, currently this type is used only
// in java for re-correction)
UIKIT_EXTERN int const KIND_RESUMED ;
UIKIT_EXTERN int const KIND_OOV_CORRECTION ; // Most probable string correction
UIKIT_EXTERN int const KIND_EMOJI; // Most probable string correction
UIKIT_EXTERN int const KIND_CLIPBOARD;
UIKIT_EXTERN int const KIND_CLOUD_CORRECTION;
UIKIT_EXTERN int const KIND_CLOUD_PREDICTION;
UIKIT_EXTERN int const KIND_FLAG_APPROPRIATE_FOR_AUTO_CORRECTION;



@interface SuggestedWordInfo : NSObject
@property (nonatomic,strong) NSString *local;
@property (nonatomic,strong) NSString *word;
@property (nonatomic,readonly) NSString *prevWordsContext;
@property (nonatomic,readonly) int score;
@property (nonatomic,readonly) int kindAndFlags;
@property (nonatomic,readonly) int indexOfTouchPointOfSecondWord;
@property (nonatomic,readonly) int autoCommitFirstWordConfidence;
@property (nonatomic,readonly) int timestamp;

//云预测专用
@property (nonatomic,readonly) NSString *upack;//云预测传过来的 upack

@property (nonatomic,strong) NSArray* suggestEmoji;//如果kindAndFlags == KIND_EMOJI,这里存储的是 emoji 列表,否则 nil

- (instancetype)initWithWord:(NSString*)word prevWordsContext:(NSString*)prevWordsContext score:(int)score sourceDict:(CMDictionary*)sourceDict kindAndFlags:(int)kindAndFlags indexOfTouchPointOfSecondWord:(int)indexOfTouchPointOfSecondWord autoCommitFirstWordConfidence:(int)autoCommitFirstWordConfidence timestamp:(int)timestamp;

- (instancetype)initWithCloudWord:(NSString*)word upack:(NSString*)upack score:(int)cloudIndex kindAndFlags:(int)kindAndFlags;

- (BOOL)isKindOf:(int)kind;

- (BOOL)isAppropriateForAutoCorrection;

- (int)infocDType;
- (int)infocCType;
@end


UIKIT_EXTERN int const INDEX_OF_AUTO_CORRECTION;

@interface SuggesteWords : NSObject

@property (nonatomic,strong) NSArray<SuggestedWordInfo*> *suggestionsList;
@property (nonatomic,assign) SInt8 willAutoCorrect;
// 滑动输入
@property (nonatomic, strong)SuggestedWordInfo* typedWordInfo;
@property (nonatomic, assign, getter=isTypedWordValid)BOOL typedWordValid;

@end
