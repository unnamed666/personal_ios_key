//
//  CMInputLogic.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/5.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMInputLogic.h"
#import "CMWordComposer.h"
#import "CMEvent.h"
#import "KeyboardViewController.h"

#import "CMSuggest.h"
#import "Character.h"

#import "CMInputTransaction.h"
#import "CMNgramContext.h"

#import "CMSettingManager.h"
#import "CMSpacingAndPunctuations.h"
#import "Constants.h"
#import "CMKeyModel.h"
#import "CMKeyboardManager.h"
#import "CMSuggestionViewModel.h"
#import "NSString+Common.h"

#import "CMSettingManager.h"
#import "SuggestedWordInfo.h"
#import "CMStringUtils.h"
#import "LastComposedWord.h"
#import "CMTextInputModel.h"
#import "DictionaryFacilitatorImpl.h"

#import "CMInfoc.h"

#import "CMCommUtil.h"

#import "CMExtensionBizHelper.h"

#ifndef SCHEME
#import "CMCloudPrediction.h"
#endif
typedef NS_ENUM(int, SpaceState) {
    SpaceStateNONE ,
    SpaceStateDOUBLE,
    SpaceStateSWAP_PUNCTUATION,
    SpaceStateWEAK,
    SpaceStatePHANTOM
};

@interface CMInputLogic (){
    BOOL firstInit;
    BOOL _isActiveInput;
    SpaceState mSpaceState;
    volatile BOOL mIsInDoubleSpaceKey;
}

//@property (nonatomic,strong) NSMutableArray * prevWords;
@property (nonatomic,strong) SuggesteWords *suggestedWords;
@property (nonatomic,weak) CMInputTransaction *completeInputTransaction;
@property (nonatomic,strong) LastComposedWord *lastComposeWord;
@property (nonatomic, strong)NSBlockOperation * op;
@property (nonatomic,strong) NSRegularExpression *emojiRegExp;
@property (nonatomic,strong) NSRegularExpression *spaceRegExp;

// 滑动输入
@property (nonatomic, assign)BOOL isInBatchInput;
@property (nonatomic, strong)NSString* autoCorrectionSeperator;
@end


@implementation CMInputLogic
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.wordComposer = [[CMWordComposer alloc] init];
//        self.prevWords = [NSMutableArray new];
        
        self.mSuggest = [[CMSuggest alloc] init];
        firstInit = YES;
        mIsInDoubleSpaceKey = false;
        _isActiveInput = NO;
        
    }
    return self;
}

- (void)dealloc {
//    kLogTrace();
    self.mSuggest = nil;
    self.wordComposer = nil;
}

- (void)handleMemoryWarning {
//    kLogTrace();
    [self.mSuggest handleMemoryWarning];
}

- (NSRegularExpression *)emojiRegExp{
    if(!_emojiRegExp){
        NSString * regExpStr = @"(?:[\\uD83C\\uDF00-\\uD83D\\uDDFF]|[\\uD83E\\uDD00-\\uD83E\\uDDFF]|[\\uD83D\\uDE00-\\uD83D\\uDE4F]|[\\uD83D\\uDE80-\\uD83D\\uDEFF]|[\\u2600-\\u26FF]\\uFE0F?|[\\u2700-\\u27BF]\\uFE0F?|\\u24C2\\uFE0F?|[\\uD83C\\uDDE6-\\uD83C\\uDDFF]{1,2}|[\\uD83C\\uDD70\\uD83C\\uDD71\\uD83C\\uDD7E\\uD83C\\uDD7F\\uD83C\\uDD8E\\uD83C\\uDD91-\\uD83C\\uDD9A]\\uFE0F?|[\\u0023\\u002A\\u0030-\\u0039]\\uFE0F?\\u20E3|[\\u2194-\\u2199\\u21A9-\\u21AA]\\uFE0F?|[\\u2B05-\\u2B07\\u2B1B\\u2B1C\\u2B50\\u2B55]\\uFE0F?|[\\u2934\\u2935]\\uFE0F?|[\\u3030\\u303D]\\uFE0F?|[\\u3297\\u3299]\\uFE0F?|[\\uD83C\\uDE01\\uD83C\\uDE02\\uD83C\\uDE1A\\uD83C\\uDE2F\\uD83C\\uDE32-\\uD83C\\uDE3A\\uD83C\\uDE50\\uD83C\\uDE51]\\uFE0F?|[\\u203C\\u2049]\\uFE0F?|[\\u25AA\\u25AB\\u25B6\\u25C0\\u25FB-\\u25FE]\\uFE0F?|[\\u00A9\\u00AE]\\uFE0F?|[\\u2122\\u2139]\\uFE0F?|\\uD83C\\uDC04\\uFE0F?|\\uD83C\\uDCCF\\uFE0F?|[\\u231A\\u231B\\u2328\\u23CF\\u23E9-\\u23F3\\u23F8-\\u23FA]\\uFE0F?)";
        
        // 创建 NSRegularExpression 对象,匹配 正则表达式
      _emojiRegExp  = [[NSRegularExpression alloc] initWithPattern:regExpStr
                                               options:NSRegularExpressionCaseInsensitive
                                                 error:nil];
    }
    return _emojiRegExp;
}

- (NSRegularExpression *)spaceRegExp{
    if(!_spaceRegExp){
        NSString * regExpStr = @"\\s+";
        
        _spaceRegExp  = [[NSRegularExpression alloc] initWithPattern:regExpStr
                                                             options:NSRegularExpressionCaseInsensitive
                                                               error:nil];
    }
    return _spaceRegExp;
}

- (void)setIsActiveInput:(NSNumber* )isActiveInput{
    _isActiveInput = [isActiveInput boolValue];;
}

- (void)beginInput{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startCloudPrediction) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setIsActiveInput:) object:@(NO)];
    _isActiveInput = YES;
}
- (void)endInput{
    [self performSelector:@selector(setIsActiveInput:) withObject:@(NO) afterDelay:0.25];
}

#pragma mark - public

//是否是单词结束


- (BOOL)isWordsEnd{
    if([self.wordComposer isComposingWord]){
        return NO;
    }
    NSString* str = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    if(str.length == 0)return YES;
    
    unichar c = [str characterAtIndex:str.length-1];
    return [kCMSettingManager.spacingAndPunctuations isWordSeparator:c];
}

//是否是句子结束
- (BOOL)isSentencesEnd{
    if([self.wordComposer isComposingWord]){
        return NO;
    }
    
    NSString* str = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    return [self isSentencesEnd:str];
}


- (BOOL)isSentencesEnd:(NSString *)string
{
    if(string.length == 0)return YES;
    
    for (int len =1; len<=string.length; len++) {
        unichar c = [string characterAtIndex:string.length-len];
        if( c == CODE_ENTER) return YES;
        if(len == 1 && c != CODE_SPACE) return NO;
        if(c == CODE_SPACE)continue;
        return [kCMSettingManager.spacingAndPunctuations isSentenceTerminator:c];
    }
    
    return YES;
}
//
//- (void)doubleTapSpadeWithCompleteInputTransaction:(CMInputTransaction*)completeInputTransaction{
//    [self beginInput];
//    self.completeInputTransaction = completeInputTransaction;
//    [self.completeInputTransaction reset];
//    
//    if(!kCMSettingManager.useDoubleSpacePeriod)return;
//    NSString * str;
//    SuggestedWordInfo *autoCorrectioin = self.wordComposer.autoCorrectioin;
////    
////    if([self.wordComposer isComposingWord] ){
////        
////        str =  [self.wordComposer commitWord];
////       
////    }else{
////        str = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
////    }
//    
//    int c = 0;
//    for(int i = 1;i<=str.length; i++){
//        c = [str characterAtIndex:str.length-i];
//        if(![Character isHighSurrogate:c]&&![Character isLowSurrogate:c]){
//            break;
//        }
//        if([Character isHighSurrogate:c]){
//            if(i==1){
//                break;
//            }else{
//                c = [Character codePointAt:str index:(int)str.length-i];
//                break;
//            }
//        }
//    }
//    
//    
//    if([self canBeFollowedByDoubleSpacePeriod:c]){
//        
//        NSString * textToInsert = kCMSettingManager.spacingAndPunctuations.mSentenceSeparatorAndSpace;
//        NSMutableString *commitText = [NSMutableString new];
//        if(autoCorrectioin){
//            [self deleteTextBeforeCursor:str.length];
//            [commitText appendString:autoCorrectioin.word];
//        }
//        [commitText appendString:textToInsert];
//        CMEvent *event = [CMEvent obtainEventByLetter:commitText];
//        [self.keyboardViewController commit:event];
//        [event recycle];
//        self.completeInputTransaction.needCommint = NO;
//        
//    }else{
//        CMEvent *event = [CMEvent obtainEventByLetter:@"  "];
//        [self.keyboardViewController commit:event];
//        [event recycle];
//        self.completeInputTransaction.needCommint = NO;
//    }
//    
//
//    
////
//    
//    
//    mSpaceState = SpaceStateDOUBLE;
//    
//    
//    [self endInput];
//}

- (void)restartSuggestionsOnWordTouchedByCursorWithCompleteInputTransaction:(CMInputTransaction*)completeInputTransaction textInputModel:(CMTextInputModel*)textInputModel{
    kLogTrace();
    self.completeInputTransaction = completeInputTransaction;
    if(_isActiveInput)return;
    [self.completeInputTransaction reset];
    
//    self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
    
    
    [self.wordComposer reset];
    //自动更正为 NO
    if(UITextAutocorrectionTypeNo == textInputModel.autocorrectionType)return;
    
    mSpaceState = SpaceStateNONE;
    
    [self restartSuggestionsOnWordTouchedByCursor:nil];
    if(!self.completeInputTransaction.mRequiresUpdateSuggestions){
        [self.keyboardViewController resetKeyboardTopView];
    }
}


- (void)onPickSuggestionManually:(SuggestedWordInfo*)suggestInfo completeInputTransaction:(CMInputTransaction*)completeInputTransaction{
    [self beginInput];
#ifndef SCHEME
    if([suggestInfo isKindOf:KIND_CLOUD_CORRECTION] || [suggestInfo isKindOf:KIND_CLOUD_PREDICTION] ){
        [kCMKeyboardManager.cloudManager clickCloudPredictionIndex:suggestInfo.score upack:suggestInfo.upack];
    }
#endif
    
    self.completeInputTransaction = completeInputTransaction;
    [self.completeInputTransaction reset];
    self.completeInputTransaction.mSpaceState = mSpaceState;
    
    if (self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeURL || self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeEmailAddress) {
        //if(isComposingWord){
        [self.wordComposer commitWord:@""  separatorString:@""];
        CMEvent *event = [CMEvent obtainEventByLetter:suggestInfo.word];
        if(self.completeInputTransaction.needCommint){
            [self.keyboardViewController commit:event];
        }
        [event recycle];
        [CMInfoc reportCheetahkeyboard_input_str:suggestInfo.word lang:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType] inputType:kCMKeyboardManager.inputLogic.keyboardType];
        return;
       // }
    }
    BOOL isBatchMode = self.wordComposer.isBatchMode;
    NSString *iword = [self.wordComposer.typeWordCache copy]; // 输入的单词

    BOOL isEmoji = [suggestInfo isKindOf:KIND_EMOJI] ;
    
    BOOL isComposingWord = [self.wordComposer isComposingWord];
    
    
    
    
    if(!isEmoji && kCMSettingManager.autoCorrectEnabled){//判断一下不是 emoji
        int n = isComposingWord ? 2:1;
        [self addUserHistoryWithWord:suggestInfo.word n:n];
    }
    
    NSString* commitWord;
    if (mSpaceState == SpaceStatePHANTOM || self.completeInputTransaction.mSpaceState == SpaceStatePHANTOM)
    {
        [self insertAutomaticSpaceIfOptionsAndTextAllow];
    }
    
    if (!isEmoji)
    {
        mSpaceState = SpaceStatePHANTOM;
        self.completeInputTransaction.mSpaceState = mSpaceState;
        commitWord = suggestInfo.word;
    }
    else
    {
        commitWord = [self insertAutomaticSpaceIfOptionsAndTextAllow:suggestInfo.word];
    }
     // [self insertAutomaticSpaceIfOptionsAndTextAllow:suggestInfo.word];
    if(isComposingWord){
        self.lastComposeWord = [self.wordComposer commitWord:commitWord  separatorString:@""];
        [self deleteTextBeforeCursor: self.lastComposeWord.typedWord.length];
    }
    
    CMEvent *event = [CMEvent obtainEventByLetter:commitWord];
    if(self.completeInputTransaction.needCommint){
        [self.keyboardViewController commit:event];
    }
    [event recycle];

    
    if(kCMSettingManager.showPrediction){
        self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
    }else{
        [self.keyboardViewController resetKeyboardTopView];
    }
    if(!(isEmoji && isComposingWord)){
        [self.lastComposeWord deactivate];
    }
    
    if(isEmoji){
        _completeInputTransaction.suggestEmoji = suggestInfo.suggestEmoji;
    }
    
    
    [CMInfoc reportCheetahKeyboard_word:iword
                                  cWord:suggestInfo.word
                                  cType:isBatchMode?4:[suggestInfo infocCType]
                                  dType:[suggestInfo infocDType]
                              inputType:self.keyboardType
                               language:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType]
                                dictver:[self.mSuggest binaryDictionaryVersion]];
    
    [self endInput];
}

- (void)onCodeInput:(CMEvent*)event completeInputTransaction:(CMInputTransaction*)completeInputTransaction shiftState:(KeyboardShiftState)shiftState  textInputModel:(CMTextInputModel*)textInputModel{
    [self beginInput];
    
    self.completeInputTransaction = completeInputTransaction;
    [self.completeInputTransaction reset];
    
    if(UITextAutocorrectionTypeNo != textInputModel.autocorrectionType && textInputModel.keyboardType != UIKeyboardTypeURL && textInputModel.keyboardType != UIKeyboardTypeEmailAddress)
    {
        self.completeInputTransaction.shiftState = shiftState;
        self.completeInputTransaction.mSpaceState = mSpaceState;
        
        if (event.key.mCode == CODE_SPACE || event.key.mCode == CODE_DELETE)
        {
            mSpaceState = SpaceStateNONE;
        }
        
        if (mSpaceState == SpaceStatePHANTOM && ![kCMSettingManager.spacingAndPunctuations isWordSeparator:event.key.mCode])
        {
            [self insertAutomaticSpaceIfOptionsAndTextAllow];
            mSpaceState = SpaceStateNONE;
        }
        
        CMKeyModel *key = event.key;
        
        if(firstInit)
        {
            firstInit = NO;
            [self restartSuggestionsOnWordTouchedByCursor:nil];
            self.wordComposer.isResumed = NO;
        }
        
        if(key.mCode <= 0 ){
            [self handleFunctionalEvent:event];
        }else{
            [self handleNonFunctionalEvent:event];
        }
    }

    if(self.completeInputTransaction.needCommint)
        [self.keyboardViewController commit:event];
    
    [self endInput];
    if(! self.completeInputTransaction.didAutoCorrect && event.key.mCode != CODE_SHIFT && event.key.mCode != CODE_SWITCH_ALPHA_SYMBOL){
        [self.lastComposeWord deactivate];
    }
}

- (void) doubleTapSpaceKey
{
    mIsInDoubleSpaceKey = false;
}

#pragma mark - private
- (void)performAdditionToUserHistoryDictionary:(NSString*)suggestion  ngram:(CMNgramContext*)ngramContext {
    
    if(!kCMSettingManager.autoCorrectEnabled) return;
    if(suggestion.length <=0) return;
    
    BOOL wasAutoCapitalized = [self.wordComposer wasAutoCapitalized] && ![self.wordComposer isMostlyCaps];
    long timeStampInSeconds = (long)[[NSDate date]  timeIntervalSince1970];
    kLog(@"add history %@",suggestion);
    kLog(@"add history %@",ngramContext);
    [self.mSuggest.dictionaryFacilitator addToUserHistory:suggestion wasAutoCapitalized:wasAutoCapitalized ngramContext:ngramContext timeStampInSeconds:timeStampInSeconds blockPotentiallyOffensive:YES];
    
}


// Android 双击空格加句号需求
- (BOOL)canBeFollowedByDoubleSpacePeriod:(int)codePoint{
    
    return [Character isLetterOrDigit:codePoint]
    || codePoint == CODE_SINGLE_QUOTE
    || codePoint == CODE_DOUBLE_QUOTE
    || codePoint == CODE_CLOSING_PARENTHESIS
    || codePoint == CODE_CLOSING_SQUARE_BRACKET
    || codePoint == CODE_CLOSING_CURLY_BRACKET
    || codePoint == CODE_CLOSING_ANGLE_BRACKET
    || codePoint == CODE_PLUS
    || codePoint == CODE_PERCENT
    || [Character getType:codePoint] == OTHER_SYMBOL;
}

// iOS 双击空格加句号需求
- (BOOL)canBeFollowedByDoubleSpacePeriodForCM:(int)codePoint{
    return ([Character isLetterOrDigit:codePoint] || [Character getType:codePoint] == OTHER_SYMBOL) ||
    (codePoint != CODE_DASH
     && codePoint != CODE_PERIOD
     && codePoint != CODE_COMMA
     && codePoint != CODE_QUESSTION
     && codePoint != CODE_EXCLAMATION
     && codePoint != CODE_COLON
     && codePoint != CODE_SEMICOLON
     && codePoint != CODE_SPACE);
}

- (BOOL)isPartOfCompositionForScript:(int) codePoint{
    
    return ([kCMSettingManager.spacingAndPunctuations isWordConnector:codePoint]
            || (![kCMSettingManager.spacingAndPunctuations isWordSeparator:codePoint] && [CMCommUtil isLetterPartOfScriptWithcodePoint:codePoint languageType:kCMSettingManager.languageType]));
}


- (void)restartSuggestionsOnWordTouchedByCursor:(CMEvent*)event{

    NSString * str = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    if(event){
        CMKeyModel *key = event.key;
        if(str.length>0 && key.mCode == CODE_DELETE){
            int lastWordLen = [CMStringUtils getlastWordLen:str];
            str =  [str substringWithRange:NSMakeRange(0, str.length-lastWordLen)];
        }
    }
    
    if(str.length>0){
        NSString * resultStr = [self regString:str];
        __block int lastChar= 0;
        __block int len = 0;
        [resultStr enumerateSubstringsInRange:NSMakeRange(0, resultStr.length) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            int codePoint = [Character codePointAt:substring index:0];
            
//            unichar c = [substring characterAtIndex:0];
            if(lastChar==0){
                lastChar = codePoint;
            }
            if(![self isPartOfCompositionForScript:codePoint]){
                *stop = YES;
            }else{
                len += (int)substring.length;
            }
        }];
        
        if(len>0){
            NSString *s =  [resultStr substringWithRange:NSMakeRange(resultStr.length-len, len)];
            NSMutableArray* xarr = [NSMutableArray new];
            NSMutableArray* yarr = [NSMutableArray new];
            [self.keyboardViewController coordinateWithString:s xArr:xarr yArr:yarr];
            [self.wordComposer composingWord:s x:xarr y:yarr];
        }
        if(![kCMSettingManager.spacingAndPunctuations isSentenceTerminator:lastChar]){
            self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
        }
    }
    
}

- (void)insertAutomaticSpaceIfOptionsAndTextAllow
{
    NSString* committedTextBeforeComposingText = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    if([kCMSettingManager shouldInsertSpacesAutomatically:self.keyboardType] &&
       kCMSettingManager.spacingAndPunctuations.mCurrentLanguageHasSpaces &&
       ![CMStringUtils lastPartLooksLikeURL:committedTextBeforeComposingText])
    {
        CMEvent *event = [CMEvent obtainEvent];
        event.code = CMEventCodeInput;
        event.key = [[CMKeyModel alloc] init];
        event.key.keyType = CMKeyTypeSpace;
        event.key.mCode = CODE_SPACE;
        event.key.key = STRING_SPACE;
        [self.keyboardViewController commit:event];
        [event recycle];
    }
}

- (void)insertPeriodIfOptionsAndTextAllow
{
    if([kCMSettingManager shouldInsertSpacesAutomatically:self.keyboardType] &&
       kCMSettingManager.spacingAndPunctuations.mCurrentLanguageHasSpaces)
    {
        CMEvent *event = [CMEvent obtainEvent];
        event.code = CMEventCodeInput;
        event.key = [[CMKeyModel alloc] init];
        event.key.keyType = CMKeyTypeLetter;
        event.key.mCode = CODE_PERIOD;
        event.key.key = @".";
        [self.keyboardViewController commit:event];
        [event recycle];
    }
}

- (NSString*)insertAutomaticSpaceIfOptionsAndTextAllow:(NSString*)word{
    
    NSString* committedTextBeforeComposingText = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    if([kCMSettingManager shouldInsertSpacesAutomatically:self.keyboardType] &&
       kCMSettingManager.spacingAndPunctuations.mCurrentLanguageHasSpaces &&
       ![CMStringUtils lastPartLooksLikeURL:committedTextBeforeComposingText]) {
        mSpaceState = SpaceStateWEAK;
        return [NSString stringWithFormat:@"%@%@",word,STRING_SPACE];
    }
    return word;
}



- (void)handleFunctionalEvent:(CMEvent*)event{
    CMKeyModel *key = event.key;
    
    if (CODE_DELETE == key.mCode) {
        [self handleBackspaceEvent:event];
    } else  if (CODE_SHIFT == key.mCode){
        
    }

}

- (void)handleNonFunctionalEvent:(CMEvent*)event{
    CMKeyModel *key = event.key;

    if (CODE_ENTER == key.mCode) {
        if([self.wordComposer isComposingWord]){
            [self addUserHistoryWithWord:self.wordComposer.typeWordCache n:2];
        }
        self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
        [self.wordComposer reset];
        _isActiveInput = NO;
    } else {
        [self handleNonSpecialCharacterEvent:event];
    }
}

- (void)handleNonSpecialCharacterEvent:(CMEvent*)event{
    

    CMKeyModel *key = event.key;
    if ([kCMSettingManager.spacingAndPunctuations isWordSeparator:key.mCode] || [Character getType:key.mCode]  == OTHER_SYMBOL) {
        [self handleSeparatorEvent:event];
    }else{
        
        [self handleNonSeparatorEvent:event];
    }
}

- (void)handleNonSeparatorEvent:(CMEvent*)event{
    BOOL isComposingWord = [self.wordComposer isComposingWord];
       CMKeyModel *key = event.key;
    if(!isComposingWord &&
       [kCMSettingManager isWordCodePoint:key.mCode]){
        isComposingWord = ![kCMSettingManager.spacingAndPunctuations isWordConnector:key.mCode];
        [self.wordComposer reset];
    }
    if(isComposingWord){
        [self.wordComposer applyProcessedEvent:event];
        if([self.wordComposer isSingleLetter]){
            self.wordComposer.shiftState = self.completeInputTransaction.shiftState;
        }  
    }

    self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
    
}

- (void)deleteTextBeforeCursor:(NSUInteger)beforeLenght{
    for (int i=0; i<beforeLenght; i++) {
        [self.keyboardViewController.textDocumentProxy deleteBackward];
    }
}
//删除尾部的一个空格
- (void)removeTrailingSpace{
    NSString* focuseWord = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    NSString *lastString =[focuseWord substringFromIndex:focuseWord.length-1];
    if([lastString isEqualToString:STRING_SPACE]){
        [self deleteTextBeforeCursor:1];
    }
}
//判断各种条件 是否 删除尾部空格
- (BOOL)tryStripSpaceAndReturnWhetherShouldSwapInstead:(CMEvent*)event{
    CMKeyModel *key = event.key;
    int codePoint = key.mCode;
    
    if(CODE_SPACE == codePoint){
        return NO;
    }
    if(CODE_ENTER == codePoint && SpaceStateSWAP_PUNCTUATION == self.completeInputTransaction.mSpaceState){
        [self removeTrailingSpace];
        return NO;
    }
    
    unichar c = codePoint;
    if([kCMSettingManager.spacingAndPunctuations isUsuallyPrecededBySpace:c]){
        return NO;
    }
    if([kCMSettingManager.spacingAndPunctuations isUsuallyFollowedBySpace:c]){
        return YES;
    }
//    
//    if(SpaceStateWEAK == self.completeInputTransaction.mSpaceState || SpaceStateSWAP_PUNCTUATION ==  self.completeInputTransaction.mSpaceState ){
//        [self removeTrailingSpace];
//    }
    return NO;
}

- (void)addUserHistoryWithWord:(NSString*)word n:(int)n{
    NSString * strBeforeInput = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    CMNgramContext *ngramContext = [self getCMngramContextFromNthPrewiousWord:strBeforeInput n:n];
//    if([self.wordComposer isResumed] && [STRING_SPACE isEqualToString:_autoCorrectionSeperator]){
    if([self.wordComposer isResumed] && _autoCorrectionSeperator && _autoCorrectionSeperator.length == 0){
        // 在误纠的情况下，加入到history之前往上下文里添加一个标志位，表明它是个合理的词，减少误纠的次数
        ngramContext.mIsUsedForGuidAutoCorrect = YES;
    }
    [self performAdditionToUserHistoryDictionary:word ngram:ngramContext];
}

- (void) test
{
    NSString* str = @"Hello";
    if(str.length>0){
        NSString * resultStr = [self regString:str];
        __block int lastChar= 0;
        __block int len = 0;
        [resultStr enumerateSubstringsInRange:NSMakeRange(0, resultStr.length) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
        {
            int codePoint = [Character codePointAt:substring index:0];
            
            //            unichar c = [substring characterAtIndex:0];
            if(lastChar==0){
                lastChar = codePoint;
            }
            if(![self isPartOfCompositionForScript:codePoint]){
                *stop = YES;
            }else{
                len += (int)substring.length;
            }
        }];
        
        if(len>0){
            NSString *s =  [resultStr substringWithRange:NSMakeRange(resultStr.length-len, len)];
            NSMutableArray* xarr = [NSMutableArray new];
            NSMutableArray* yarr = [NSMutableArray new];
            [self.keyboardViewController coordinateWithString:s xArr:xarr yArr:yarr];
            [self.wordComposer composingWord:s x:xarr y:yarr];
        }
        if(![kCMSettingManager.spacingAndPunctuations isSentenceTerminator:lastChar]){
            self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
        }
    }
    
}

- (BOOL)tryPerformDoubleSpacePeriod:(NSString*) theStringBeforeCursor
{
    if (theStringBeforeCursor.length < 2)
    {
        return NO;
    }
    
    if ([theStringBeforeCursor characterAtIndex:theStringBeforeCursor.length - 1] != CODE_SPACE)
    {
        return NO;
    }

    __block int firstCodePoint;
    __block NSString* firstCodeString;
    [theStringBeforeCursor enumerateSubstringsInRange:NSMakeRange(0, theStringBeforeCursor.length-1) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop)
    {
        firstCodePoint = [Character codePointAt:substring index:0];
        firstCodeString = [substring copy];
        *stop = YES;
    }];
    
    if([self canBeFollowedByDoubleSpacePeriodForCM:firstCodePoint] || [Character stringContainsEmoji:firstCodeString])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) detectDoubleSpaceTapped
{
    if (!mIsInDoubleSpaceKey)
    {
        mIsInDoubleSpaceKey = true;
        [self performSelector:@selector(doubleTapSpaceKey) withObject:nil afterDelay:0.5];
        kLog(@"空格状态 ========>>>>>>>> 单击");
    }
    else
    {
        NSString* beforeCursorString = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
        if ([self tryPerformDoubleSpacePeriod:beforeCursorString])
        {
            mSpaceState = SpaceStateDOUBLE;
            [self removeTrailingSpace];
            mIsInDoubleSpaceKey = false;
            [self insertPeriodIfOptionsAndTextAllow];
            [self.keyboardViewController resetKeyboardTopView];
            return;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doubleTapSpaceKey) object:nil];
        mIsInDoubleSpaceKey = false;
        kLog(@"空格状态 ========>>>>>>>> 双击");
    }
}

- (void)handleSeparatorEvent:(CMEvent*)event
{
    CMKeyModel *key = event.key;
    int codePoint = key.mCode;
    if (event.key.mCode == CODE_SPACE && kCMSettingManager.useDoubleSpacePeriod)
    {
        [self detectDoubleSpaceTapped];
    }

    BOOL wasComposingWord = [self.wordComposer isComposingWord];
//    BOOL shouldAvoidSendingCode = CODE_SPACE == codePoint
//    && !kCMSettingManager.spacingAndPunctuations.mCurrentLanguageHasSpaces
//    && wasComposingWord;
    
    BOOL swapWeakSpace = [self tryStripSpaceAndReturnWhetherShouldSwapInstead:event];
    
    int infocCType = 0;
    int infocDType = 3;
    NSString* iword = nil; // 输入的单词
    NSString* cword = nil; // 最终上屏的单词
    if( [self.wordComposer isComposingWord])
    {
        self.completeInputTransaction.didAutoCorrect = YES;
        SuggestedWordInfo *autoCorrectioin = self.wordComposer.autoCorrectioin;
        if(self.wordComposer.isBatchMode)
        {
            infocCType = 4;
        }
        
//        NSString *spaceString = (CODE_SPACE == codePoint)?STRING_SPACE:key.key;
        NSString *spaceString = (CODE_SPACE == codePoint)?@"":key.key; //回退吞空格
//        NSString * s = [NSString stringWithFormat:@"%@%@",autoCorrectioin.word?autoCorrectioin.word:@"",spaceString?spaceString:@""];
        
        if(autoCorrectioin.word)
        {
            cword = autoCorrectioin.word;
        }
        else
        {
            cword = [self.wordComposer.typeWordCache copy];
        }
        iword = [self.wordComposer.typeWordCache copy];
        
        if(autoCorrectioin && key.keyType != CMKeyTypeEmoji)
        {
            [self addUserHistoryWithWord:cword n:2];
         
            kLog(@"空格状态 ========>>>>>>>> %@ ==>> 1", self.lastComposeWord);
            self.lastComposeWord = [self.wordComposer commitWord:autoCorrectioin.word?autoCorrectioin.word:@"" separatorString:spaceString];
            [self deleteTextBeforeCursor:self.lastComposeWord.typedWord.length];
            kLog(@"空格状态 ========>>>>>>>> %@ ==>> 2", self.lastComposeWord);
            CMEvent *event1 = [CMEvent obtainEventByLetter:cword?cword:@""];
            [self.keyboardViewController commit:event1];
            self.completeInputTransaction.needCommint = NO;
            mSpaceState = SpaceStatePHANTOM;
            
            infocCType = [autoCorrectioin infocCType];
            infocDType = [autoCorrectioin infocDType];
        }else{
            
            [self addUserHistoryWithWord:iword n:2];
            kLog(@"空格状态 ========>>>>>>>> %@ ==>> 3", self.lastComposeWord);
            self.lastComposeWord = [self.wordComposer commitWord:autoCorrectioin.word?autoCorrectioin.word:@"" separatorString:spaceString];
            kLog(@"空格状态 ========>>>>>>>> %@ ==>> 4", self.lastComposeWord);
            [self.lastComposeWord deactivate];
            cword=iword;
        }
    }
    else
    {
        [self.lastComposeWord deactivate];
        kLog(@"");
    }
    if(swapWeakSpace){
//        if(self.completeInputTransaction.mSpaceState == SpaceStateWEAK){
//            [self deleteTextBeforeCursor:1];
//        }
//        CMEvent *event = [CMEvent obtainEventByLetter:[self insertAutomaticSpaceIfOptionsAndTextAllow:key.key]];
        
        CMEvent *event = [CMEvent obtainEventByLetter:key.key];
        [self.keyboardViewController commit:event];
        self.completeInputTransaction.needCommint = NO;
        [self.keyboardViewController resetKeyboardTopView];
//        mSpaceState = SpaceStateSWAP_PUNCTUATION;
    }else if(codePoint == CODE_SPACE){
        if(wasComposingWord || self.suggestedWords.suggestionsList.count==0){
            self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
        }
    }else{
        [self.keyboardViewController resetKeyboardTopView];
    }
    
    
    
    if (cword.length > 0) {
        [CMInfoc reportCheetahKeyboard_word:iword
                                      cWord:cword
                                      cType:infocCType
                                      dType:infocDType
                                  inputType:self.keyboardType
                                   language:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType]
                                    dictver:[self.mSuggest binaryDictionaryVersion]];
    }
    
        NSString *needCommitStr = nil;
        if (self.completeInputTransaction.needCommint) {
            needCommitStr = [NSString stringWithFormat:@"%@%@", cword != nil ? cword : @"", (key.keyType == CMKeyTypeSpace ? STRING_SPACE : key.key)];
        }
    
        NSString *text = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput] ;
        text = text ? text : @"";
        NSString *str = [NSString stringWithFormat:@"%@%@", text, needCommitStr ? needCommitStr : @""];
        
    if ([self isSentencesEnd:str]) {
        NSInteger j = str.length - 3;
        for ( ; j >= 0; j--) {
            if ([self isSentencesEnd:[str substringToIndex:j]]) break;
        }
        
        // j < 0的情况 eg：直接输入 点号+空格； 连输两个空格
        if (j >= 0) {
            NSString *sentenceStr = [str substringWithRange:NSMakeRange(j, str.length - j - 1)];
            if (j == 0) {
                NSString *tmp = [sentenceStr stringByReplacingOccurrencesOfString:STRING_SPACE withString:@""];
                // tmp.length == 0的情况  代表连输几个空格（因为如果一开始输入空格 仍然认为是句子的结束） 但这种情况不需要上报
                if (tmp.length > 0) {
                    [CMInfoc reportCheetahKeyboard_sentence:sentenceStr
                                                   language:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType]
                                                  inputType:self.keyboardType
                                                    dictver:[self.mSuggest binaryDictionaryVersion]];
                }
            } else if (sentenceStr.length > 1) {
                [CMInfoc reportCheetahKeyboard_sentence:sentenceStr
                                               language:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType]
                                              inputType:self.keyboardType
                                                dictver:[self.mSuggest binaryDictionaryVersion]];
            }
        }
    }
    
}

- (void)handleBackspaceEvent:(CMEvent*)event{
    mSpaceState = SpaceStateNONE;
    if( [self.wordComposer isComposingWord]){
        if(self.wordComposer.isBatchMode){
            NSString * rejectedSuggestion = [self.wordComposer.typeWordCache copy];
            [self.wordComposer reset];
            self.wordComposer.rejectedBatchModeSuggestion = rejectedSuggestion;
            [self deleteTextBeforeCursor:rejectedSuggestion.length];
            self.completeInputTransaction.needCommint = NO;
            [self.mSuggest.dictionaryFacilitator unlearnFromUserHistory:rejectedSuggestion];
        }else{
            [self.wordComposer applyProcessedEvent:event];
        }
        
        self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
    }else{
        if([self.lastComposeWord canRevertCommit]){
            NSString *separatorString = self.lastComposeWord.separatorString;
            self.autoCorrectionSeperator = [separatorString copy];
            int len =  [CMStringUtils getCodePointArray:NULL world:[NSString stringWithFormat:@"%@%@",self.lastComposeWord.committedWord,separatorString]];
            [self deleteTextBeforeCursor:len];
            
            BOOL usePhantomSpace = [self.lastComposeWord.separatorString isEqualToString:STRING_SPACE];
            NSString * stringTocommit = (usePhantomSpace || separatorString.length == 0)?self.lastComposeWord.typedWord:[NSString stringWithFormat:@"%@%@",self.lastComposeWord.typedWord,separatorString];
            
            CMEvent *event1 = [CMEvent obtainEventByLetter:stringTocommit];
            [self.keyboardViewController commit:event1];
            self.completeInputTransaction.needCommint = NO;
            
            [self.mSuggest.dictionaryFacilitator unlearnFromUserHistory:self.lastComposeWord.committedWord];
            [self restartSuggestionsOnWordTouchedByCursor:nil];
            self.wordComposer.shiftState = self.lastComposeWord.shiftState;
            self.lastComposeWord = nil;
            
            return;
        }
        
        [self restartSuggestionsOnWordTouchedByCursor:event];
        self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
    }
}

- (NSString*)regString:(NSString*)str{
    
    if(str.length==0)return nil;
//    NSString * regExpStr = @"\\s+";
//    NSString * regExpStr = @"(\\s+)|[(\\ud83e\\udd00-\\ud83e\\uddff)|(\\ud83c\\udf00-\\ud83d\\ude4f)|(\\ud83d\\ude80-\\ud83d\\udeff)|(\u2600-\u26ff)|([\\uD83C\\uDDE6-\\uD83C\\uDDFF]{1,2})]";

    NSString *resultStr ;
    // 替换匹配的字符串为 searchStr
    resultStr = [self.emojiRegExp stringByReplacingMatchesInString:str
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, str.length)
                                            withTemplate:STRING_SPACE];
    
    resultStr = [self.spaceRegExp stringByReplacingMatchesInString:resultStr
                                                           options:NSMatchingReportProgress
                                                             range:NSMakeRange(0, resultStr.length)
                                                      withTemplate:STRING_SPACE];
    
    return resultStr;
}

- (CMNgramContext*)getCMngramContextFromNthPrewiousWord:(NSString*)prev n:(int)n{
    
    NSString * resultStr = [self regString:prev];
    
    NSMutableString * mutableString = [resultStr mutableCopy];
    
    
    
    
    if(mutableString.length >0){
        if([[mutableString substringFromIndex:mutableString.length-1] isEqualToString:STRING_SPACE]){
            [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length-1, 1)];
        }
    }
    //    }
    
    NSArray * arr = [mutableString componentsSeparatedByString:STRING_SPACE];
    CMNgramContext *  ngramContext =  [[CMNgramContext alloc] init];
    for (int i=0; i<ngramContext.mMaxPrevWordCount; i++) {
        int focusedwordIndex = (int)arr.count - n -i;
        
        if ((focusedwordIndex + 1) >= 0 && (focusedwordIndex + 1) < arr.count){
            NSString * wordFollowingTheNthPrevWord = arr[focusedwordIndex+1];
            if(wordFollowingTheNthPrevWord.length>0){
                NSString * firstString = [wordFollowingTheNthPrevWord substringToIndex:1];
                if([kCMSettingManager.spacingAndPunctuations isWordConnector:[firstString characterAtIndex:0]]){
                    break;
                }
            }
        }
        
        if(focusedwordIndex<0){
            [ngramContext addPreWord:@"" isBeginningOfSentence:YES];
            break;
        }
        NSString *focuseWord = arr[focusedwordIndex];
        if(focuseWord.length<=0){
            [ngramContext addPreWord:@"" isBeginningOfSentence:YES];
            break;
        }
        
        if(focuseWord.length<=0){
            [ngramContext addPreWord:@"" isBeginningOfSentence:YES];
            break;
        }
        
        unichar c = [focuseWord characterAtIndex:focuseWord.length-1];
        if([kCMSettingManager.spacingAndPunctuations isSentenceTerminator:c]){
            [ngramContext addPreWord:@"" isBeginningOfSentence:YES];
            break;
        }
        if([kCMSettingManager.spacingAndPunctuations isWordSeparator:c]){
            [ngramContext addPreWord:@"" isBeginningOfSentence:YES];
            break;
        }
        [ngramContext addPreWord:focuseWord isBeginningOfSentence:NO];
    }
    return ngramContext;
}

- (void)perfromUpdateSuggestionStrip:(CMInputTransaction*)completeInputTransaction proximityInfo:(CMProximityInfo *)proximityInfo completionBlock:(fetchSuggestWordCompletionHandler)handler {
    if (self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeURL || self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeEmailAddress) {
        completeInputTransaction.mRequiresUpdateSuggestions = YES;
    }
    if(!completeInputTransaction.mRequiresUpdateSuggestions){
        if (handler) {
            handler(nil, nil, NO);
        }
        return;
    }
    
    if(completeInputTransaction.suggestEmoji.count >0 ){
        SuggesteWords * suggestedWords = [[SuggesteWords alloc] init];
        __block NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:completeInputTransaction.suggestEmoji.count];
        suggestedWords.suggestionsList = array;
        NSArray * suggestEmoji = completeInputTransaction.suggestEmoji;
        [completeInputTransaction.suggestEmoji enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![obj isKindOfClass:[NSString class]]) {
                if (handler) {
                    handler(nil, nil, NO);
                }
                return;
            }
            int kindAndFlags;
            if(idx ==0){
                kindAndFlags = KIND_TYPED;
            }else{
                kindAndFlags = KIND_EMOJI;;
            }
            SuggestedWordInfo * emojiWord =  [[SuggestedWordInfo alloc] initWithWord:obj prevWordsContext:@"" score:MAX_SCORE sourceDict:nil kindAndFlags:kindAndFlags indexOfTouchPointOfSecondWord:NOT_AN_INDEX autoCommitFirstWordConfidence:NOT_A_CONFIDENCE timestamp:NOT_A_TIMESTAMP];
            if(idx != 0){
                emojiWord.suggestEmoji = suggestEmoji;
            }
            [array addObject:emojiWord];
        }];
        self.suggestedWords = suggestedWords;
        
        if(self.suggestedWords.willAutoCorrect > -1 && kCMSettingManager.autoCorrectEnabled){
            self.wordComposer.autoCorrectioin = suggestedWords.suggestionsList.count> suggestedWords.willAutoCorrect ?suggestedWords.suggestionsList[suggestedWords.willAutoCorrect]:nil;
        }
        
        if (handler) {
            if([NSThread isMainThread]){
                handler(suggestedWords, nil, YES);
            }else{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    handler(suggestedWords, nil, YES);
                }];
            }
        }
        return;
    }
    BOOL isComposingWord = [self.wordComposer isComposingWord];
    if(!isComposingWord && !kCMSettingManager.showPrediction){
        if (handler) {
            handler(nil, nil, YES);
        }
        return;
    }
    if(! kCMSettingManager.showCorrection){
        if(isComposingWord){
            if (handler) {
                handler(nil, nil, YES);
            }
            return;
        }
    }
    
    NSString* input = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    
    if (self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeURL || self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeEmailAddress) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDeleteAllSuggestHasClicked] == NO) {
                        
            NSArray * wordArray = nil;
            if (self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeURL) {
                wordArray = [NSArray arrayWithObjects:@"http://",@"https://",@"www.",@".com",@".net",@".edu",@".org",@".us", nil];
            }else if (self.keyboardViewController.currentInputModel.keyboardType == UIKeyboardTypeEmailAddress){
                wordArray = [NSArray arrayWithObjects:@"@gmail.com",@"@yahoo.com",@"@hotmail.com",@"@icloud.com",@"@outlook.com", nil];
            }
            
            NSMutableArray * tempArray = [NSMutableArray array];
            for (int i = 0; i < wordArray.count; i++) {
                SuggestedWordInfo * wordInfo;
                wordInfo = [[SuggestedWordInfo alloc] initWithWord:wordArray[i] prevWordsContext:@"" score:MAX_SCORE sourceDict:nil  kindAndFlags:KIND_TYPED indexOfTouchPointOfSecondWord:NOT_AN_INDEX autoCommitFirstWordConfidence:NOT_A_CONFIDENCE timestamp:NOT_A_TIMESTAMP];
                [tempArray addObject:wordInfo];
            }
            SuggesteWords * suggestedWords = [[SuggesteWords alloc] init];
            suggestedWords.suggestionsList = [NSArray arrayWithArray:tempArray];
            handler(suggestedWords, nil, YES);
            self.lastUpdateSuggestionParamInputWords = nil;
            return;
        }else{
            if (handler) {
                handler(nil, nil, YES);
            }
            self.lastUpdateSuggestionParamInputWords = nil;
            return;
        }
    }
    
    if ([NSString stringIsEmpty:input]) {
        if (handler) {
            handler(nil, nil, YES);
        }
        self.lastUpdateSuggestionParamInputWords = nil;
        return;
    }
    
    //如果查询的是更正词,使用原文本,如果是预测词,则加一空格来区分不同的状态
    NSString *inputTem = isComposingWord ? input: [NSString stringWithFormat:@"%@%@",input,STRING_SPACE];
    //如果上次查询预测词和这次一样就返回
    if([self.lastUpdateSuggestionParamInputWords isEqualToString:inputTem]){
        if (handler) {
            handler(nil, nil, NO);
        }
        return;
    }
    self.lastUpdateSuggestionParamInputWords = inputTem;
    
#ifndef SCHEME
    BOOL fromeRepeate = completeInputTransaction.fromeRepeate;
#endif
    [_op cancel];
    @weakify(self)
    self.op = [NSBlockOperation blockOperationWithBlock:^{
        @stronglize(self)
        BOOL wasComposingWord = [self.wordComposer isComposingWord];
        int n = wasComposingWord ? 2:1;
        CMNgramContext *ngramContext = [self getCMngramContextFromNthPrewiousWord:input n:n];
        [self.mSuggest suggestionFromWordComposer:self.wordComposer ngramContext:ngramContext proximityInfo:proximityInfo completion:^(SuggesteWords *suggestedWords) {
            @stronglize(self)
            self.suggestedWords = suggestedWords;
            
            if(self.suggestedWords.willAutoCorrect > -1 && kCMSettingManager.autoCorrectEnabled){
                self.wordComposer.autoCorrectioin = suggestedWords.suggestionsList.count> suggestedWords.willAutoCorrect ?suggestedWords.suggestionsList[suggestedWords.willAutoCorrect]:nil;
            }
        
            if (handler) {
                if([NSThread isMainThread]){
                    handler(suggestedWords, nil, YES);
                }else{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        handler(suggestedWords, nil, YES);
                    }];
                }
            }
            [_op cancel];
            self.op = nil;
        }];
#ifndef SCHEME
        if(!fromeRepeate){//循环删除的不请求云预测
            [self performSelectorOnMainThread:@selector(startCloudPrediction) withObject:nil waitUntilDone:NO];
            [kCMKeyboardManager.cloudManager updateSendId];
        }
#endif
    }];
    [self.queue addOperation:_op];
}

#ifndef SCHEME
- (void )startCloudPrediction{
    
    BOOL wasComposingWord = [self.wordComposer isComposingWord];
    NSString* input = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    NSString * afterInput = [self.keyboardViewController.textDocumentProxy documentContextAfterInput];
    if(afterInput.length == 0 && input.length>0){
        NSString * sendword;
        if(!wasComposingWord && kCMSettingManager.spacingAndPunctuations.mCurrentLanguageHasSpaces){
            sendword = [NSString stringWithFormat:@"%@%@",input,STRING_SPACE];
        }else{
            sendword = input;
        }
        [kCMKeyboardManager.cloudManager sendWord:sendword];

    }
}
#endif

- (void)perfromBatchInputSuggestion:(CMInputTransaction*)completeInputTransaction proximityInfo:(CMProximityInfo *)proximityInfo completionBlock:(fetchSuggestWordCompletionHandler)handler {
    NSString* input = [self.keyboardViewController.textDocumentProxy documentContextBeforeInput];
    
    void (^completionBlock)(SuggesteWords *suggestedWords) = ^(SuggesteWords *suggestedWords){
        if (suggestedWords) {
            self.suggestedWords = suggestedWords;
            
            if(self.suggestedWords.willAutoCorrect > -1 && kCMSettingManager.autoCorrectEnabled){
                self.wordComposer.autoCorrectioin = suggestedWords.suggestionsList.count> suggestedWords.willAutoCorrect ?suggestedWords.suggestionsList[suggestedWords.willAutoCorrect]:nil;
            }
            
            if (handler) {
                if([NSThread isMainThread]){
                    handler(suggestedWords, nil, YES);
                }else{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        handler(suggestedWords, nil, YES);
                    }];
                }
            }
            NSString * word = suggestedWords.typedWordInfo.word;
            if(word.length>0){
                [self.wordComposer setbatchInputWord:word];
                CMEvent *event = [CMEvent obtainEventByLetter:word];
                [self.keyboardViewController commit:event];
                [event recycle];
            }
            
            [_op cancel];
            self.op = nil;
        }
    };
    
//#ifndef SCHEME
//    [self performSelector:@selector(startCloudPrediction) withObject:nil afterDelay:0.28];
//    [kCMCloudPrediction updateSendId];
//#endif
    
    
    [_op cancel];
    @weakify(self)
    self.op = [NSBlockOperation blockOperationWithBlock:^{
        @stronglize(self);
        if ([CMExtensionBizHelper shouldUseTensorFlow]) {
            [self.mSuggest fetchTFSuggestions:self.wordComposer completion:completionBlock];
        }
        else {
            int n = [self.wordComposer isComposingWord] ? 2:1;
            CMNgramContext *ngramContext = [self getCMngramContextFromNthPrewiousWord:input n:n];
            [self.mSuggest suggestionFromWordComposer:self.wordComposer ngramContext:ngramContext proximityInfo:proximityInfo completion:completionBlock];
        }
    }];
    [self.queue addOperation:_op];
}

- (void)onStartBatchInput {
    [self beginInput];
    if ([self.wordComposer isComposingWord] || mSpaceState == SpaceStatePHANTOM ) {
        [self.wordComposer commitWord:@""  separatorString:@""];
        [self insertAutomaticSpaceIfOptionsAndTextAllow];
        mSpaceState = SpaceStateNONE;
    }
    self.wordComposer.isBatchMode = YES;
}

- (void)onUpdateBatchInput:(InputPointers *)inputPointers {
    
}

- (void)onEndBatchInput:(InputPointers *)inputPointers {
    [self.wordComposer setInputPointers:[inputPointers copy]];
    [self endInput];
}

- (void)onCancelBatchInput:(InputPointers *)inputPointers {
    [self endInput];
}

// by yaozongchao
- (int)dictionaryVersion {
    return [self.mSuggest binaryDictionaryVersion];
}

- (BOOL)isMainDictionaryValid {
    return [self.mSuggest isMainDictionaryValid];
}

- (BOOL)isComposingWord {
    return [self.wordComposer isComposingWord];
}

- (void)resetSuggest {
    [self.mSuggest reset];
}

- (void)saveUserDictionary {
    [self.mSuggest.dictionaryFacilitator saveToUserHistoryDictionary];
}

#pragma mark - setter/getter

- (NSOperationQueue*)queue{
    if(!_queue){
        _queue  = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return _queue;
}

@end
