//
//  CMWordComposer.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/4.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMWordComposer.h"
#import "InputPointers.h"
#import "CMEvent.h"
#import "CMKeyModel.h"
#import "OCDefines.h"
#import "Character.h"
#import "CMStringUtils.h"

#import "Character.h"

#import "LastComposedWord.h"


@interface CMWordComposer (){
    int codePointSize;
    int mCapsCount;
    int mDigitsCount;
    BOOL mIsOnlyFirstCharCapitalized;
}
@property (nonatomic,strong) NSMutableString * typeWordCache;
@property (nonatomic,strong)InputPointers * inputPointers;
@end

@implementation CMWordComposer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _typeWordCache = [NSMutableString new];
        self.inputPointers = [[InputPointers alloc] init];
    }
    return self;
}

- (void)reset{
    [self.typeWordCache deleteCharactersInRange:NSMakeRange(0, self.typeWordCache.length)];
    [self.inputPointers reset];
    self.isBatchMode = NO;
    codePointSize = 0;
    self.isResumed = NO;
    mCapsCount= 0;
    mDigitsCount= 0;
    mIsOnlyFirstCharCapitalized = NO;
    self.shiftState = 0;
    self.autoCorrectioin = nil;
    self.rejectedBatchModeSuggestion = nil;
}


- (void)applyProcessedEvent:(CMEvent*)event{
    if(event.key.keyType == CMKeyTypeDel && self.typeWordCache.length>0){
        int lastWordLen = [CMStringUtils getlastWordLen:self.typeWordCache];
        [self.typeWordCache deleteCharactersInRange:NSMakeRange(self.typeWordCache.length -lastWordLen, lastWordLen)];
        codePointSize -= lastWordLen;
        if(self.typeWordCache.length == 0){
            mIsOnlyFirstCharCapitalized = NO;
        }
        
    }else if(event.key.keyType != CMKeyTypeSpace){
        int newIndex = codePointSize;
        [self.typeWordCache appendString:event.key.key];
        codePointSize = (int)self.typeWordCache.length;
        
        if(newIndex<MAX_WORD_LENGTH){
            //        int mCode = event.key.mCode;
            if(!self.isBatchMode){
                [self.inputPointers addPointerAt:newIndex x:event.touchPoint.x  y:event.touchPoint.y pointerId:0 time:0];
            }
        }
        int codePoint =  [Character codePointAt:event.key.key index:0];
        
        if(newIndex == 0){
            mIsOnlyFirstCharCapitalized = [Character isUpperCase:codePoint];
        }else{
            mIsOnlyFirstCharCapitalized = mIsOnlyFirstCharCapitalized && ![Character isUpperCase:codePoint];
        }
        
        if([Character isDigit:codePoint]){
            mDigitsCount++;//如果有数字
        }
        if([Character isUpperCase:codePoint]){
            mCapsCount++;//如果有大写字母
        }
    }
    if(codePointSize==0)mIsOnlyFirstCharCapitalized = NO;
    self.autoCorrectioin = nil;
    
    self.isBatchMode = NO;
}

- (void)composingWord:(NSString*)word x:(NSArray*)xArray y:(NSArray*)yArray{
    [self reset];
    [self.typeWordCache appendString:word];
    
    for (int i= 0; i<word.length; i++) {
        unichar codePoint;
        [word getCharacters:&codePoint range:NSMakeRange(i, 1)];
        
        BOOL isppercase = [Character isUpperCase:codePoint];
        if(i == 0){
            mIsOnlyFirstCharCapitalized = isppercase;
        }else{
            mIsOnlyFirstCharCapitalized = mIsOnlyFirstCharCapitalized && !isppercase;
        }
        
        if([Character isDigit:codePoint]){
            mDigitsCount++;//如果有数字
        }
        if(isppercase){
            mCapsCount++;//如果有大写字母
        }
    }
    
    codePointSize = (int)self.typeWordCache.length;
    for (int i=0; i<xArray.count; i++) {
        if(i>=codePointSize)break;
        int x = [xArray[i] intValue];
        int y = [yArray[i] intValue];
//        if(!self.isBatchMode){
            [self.inputPointers addPointerAt:i x:x  y:y pointerId:0 time:0];
//        }
    }
    
    self.isResumed = YES;
}

- (LastComposedWord*)commitWord:(NSString*)committedWord separatorString:(NSString*)separatorString{
    
    LastComposedWord *lastComposedWord = [[LastComposedWord alloc] initWithInputPointers:self.inputPointers typedWord:self.typeWordCache committedWord:committedWord separatorString:separatorString shiftState:self.shiftState];
    [self reset];
    return lastComposedWord;
}

- (BOOL)isComposingWord{
    return codePointSize>0;
}
- (BOOL)isMostlyCaps{
    return mCapsCount >1;
}
- (BOOL)hasDigits{
    return mDigitsCount >0;
}

- (BOOL)isOrWillBeOnlyFirstCharCapitalized{
    return [self isComposingWord]? mIsOnlyFirstCharCapitalized : (KeyboardShiftStateAlpha != self.shiftState && 0 != self.shiftState);
}

- (BOOL)wasAutoCapitalized {
    return self.shiftState == KeyboardShiftStateAutomaticShiftedAlpha
    || self.shiftState == KeyboardShiftStateShiftedLockAlpha;
}

- (BOOL)isAllUpperCase{
    if (codePointSize <= 1) {
        return self.shiftState == KeyboardShiftStateShiftedLockAlpha;
    }
    return mCapsCount == codePointSize;
}

- (BOOL)isSingleLetter{
    return codePointSize == 1;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@  %@", _typeWordCache , _inputPointers];
}

- (CMWordComposer *)composedDataSnapshot
{
    CMWordComposer* cmWordCompose = [[CMWordComposer alloc] init];
    cmWordCompose.inputPointers = self.inputPointers;
    cmWordCompose.isBatchMode = self.isBatchMode;
    cmWordCompose.typeWordCache = self.typeWordCache;
    return cmWordCompose;
}
- (void)setbatchInputWord:(NSString*)word{
    [self composingWord:word x:nil y:nil];
    self.isBatchMode = YES;
    self.isResumed = NO;
    
}
#pragma mark - setter/getter
- (void)setInputPointers:(InputPointers *)inputPointers {
    _inputPointers = inputPointers;
    self.isBatchMode = YES;
}

@end
