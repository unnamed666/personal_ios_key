//
//  CMInputLogic.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/5.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMWordComposer;
@class CMEvent;
@class KeyboardViewController;
@class CMInputTransaction;
@class CMSuggestionViewModel;
@class CMError;
@class CMInputLogic;
@class CMKeyModel;
@class CMSuggest;
@class CMTextInputModel;
@class SuggestedWordInfo;
@class CMProximityInfo;

// 滑动输入
@class CMNgramContext;
@class InputPointers;
@class SuggesteWords;

@protocol CMInputLogicDelegate <NSObject>
- (void)onLogic:(CMInputLogic *)inputLogic functionKeyTapped:(CMKeyModel *)keyModel;


@end

@interface CMInputLogic : NSObject

typedef void(^fetchSuggestWordCompletionHandler)(SuggesteWords *suggestedWords, CMError* error, BOOL needUpate);


@property (nonatomic, weak)id<CMInputLogicDelegate> delegate;


@property (nonatomic,assign) UIKeyboardType keyboardType;
@property (nonatomic,weak) KeyboardViewController * keyboardViewController;
//@property (nonatomic,readonly) CMWordComposer * wordComposer;
//@property (nonatomic,readonly) NSMutableArray * prevWords;

@property (nonatomic,strong) CMWordComposer * wordComposer;

@property (nonatomic,strong) CMSuggest * mSuggest;

@property (nonatomic, strong)NSString * lastUpdateSuggestionParamInputWords;//上一次查询,输入框中的字符

@property (nonatomic,strong) NSOperationQueue * queue;//查询预测词用的串行 Queue


//普通按键走的函数
- (void)onCodeInput:(CMEvent*)event completeInputTransaction:(CMInputTransaction*)completeInputTransaction shiftState:(KeyboardShiftState)shiftState  textInputModel:(CMTextInputModel*)textInputModel;
//点击预测词走的函数
- (void)onPickSuggestionManually:(SuggestedWordInfo*)suggestInfo completeInputTransaction:(CMInputTransaction*)completeInputTransaction;
//移动光标 粘贴等走的函数
- (void)restartSuggestionsOnWordTouchedByCursorWithCompleteInputTransaction:(CMInputTransaction*)completeInputTransaction textInputModel:(CMTextInputModel*)textInputModel;
//双击空格走的函数
//- (void)doubleTapSpadeWithCompleteInputTransaction:(CMInputTransaction*)completeInputTransaction;

- (void)perfromUpdateSuggestionStrip:(CMInputTransaction*)completeInputTransaction proximityInfo:(CMProximityInfo *)proximityInfo completionBlock:(fetchSuggestWordCompletionHandler)handler;

- (void)perfromBatchInputSuggestion:(CMInputTransaction*)completeInputTransaction proximityInfo:(CMProximityInfo *)proximityInfo completionBlock:(fetchSuggestWordCompletionHandler)handler;

//是否是单词结束
- (BOOL)isWordsEnd;
//是否是句子结束
- (BOOL)isSentencesEnd;

- (void)handleMemoryWarning;

// 滑动输入
- (CMNgramContext*)getCMngramContextFromNthPrewiousWord:(NSString*)prev n:(int)n;

// by yaozongchao
- (int)dictionaryVersion;

- (BOOL)isMainDictionaryValid;

- (void)resetSuggest;

- (void)saveUserDictionary;

- (BOOL)isComposingWord;

/* The sequence number member is only used in onUpdateBatchInput. It is increased each time
 * auto-commit happens. The reason we need this is, when auto-commit happens we trim the
 * input pointers that are held in a singleton, and to know how much to trim we rely on the
 * results of the suggestion process that is held in mSuggestedWords.
 * However, the suggestion process is asynchronous, and sometimes we may enter the
 * onUpdateBatchInput method twice without having recomputed suggestions yet, or having
 * received new suggestions generated from not-yet-trimmed input pointers. In this case, the
 * mIndexOfTouchPointOfSecondWords member will be out of date, and we must not use it lest we
 * remove an unrelated number of pointers (possibly even more than are left in the input
 * pointers, leading to a crash).
 * To avoid that, we increase the sequence number each time we auto-commit and trim the
 * input pointers, and we do not use any suggested words that have been generated with an
 * earlier sequence number.
 */
- (void)onStartBatchInput;

- (void)onUpdateBatchInput:(InputPointers *)inputPointers;

- (void)onEndBatchInput:(InputPointers *)inputPointers;

- (void)onCancelBatchInput:(InputPointers *)inputPointers;

@end
