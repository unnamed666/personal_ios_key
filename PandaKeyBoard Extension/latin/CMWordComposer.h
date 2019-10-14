//
//  CMWordComposer.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/4.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputPointers.h"

@class CMEvent;
@class SuggestedWordInfo;
@class LastComposedWord;

@interface CMWordComposer : NSObject

@property (nonatomic,readonly) NSMutableString * typeWordCache;
@property (nonatomic,strong) SuggestedWordInfo * autoCorrectioin;

@property (nonatomic,readonly)InputPointers * inputPointers;

@property (nonatomic,assign) BOOL isBatchMode;

@property (nonatomic,assign) BOOL isResumed;


@property (nonatomic,readonly) BOOL isMostlyCaps;
@property (nonatomic,readonly) BOOL hasDigits;
@property (nonatomic,readonly) BOOL isOrWillBeOnlyFirstCharCapitalized;
@property (nonatomic,readonly) BOOL wasAutoCapitalized;
@property (nonatomic,readonly) BOOL isAllUpperCase;

// 滑动输入
@property (nonatomic, copy)NSString* rejectedBatchModeSuggestion;

@property (nonatomic) KeyboardShiftState shiftState;

- (void)composingWord:(NSString*)word x:(NSArray*)xArray y:(NSArray*)yArray;

- (BOOL)isSingleLetter;

- (void)applyProcessedEvent:(CMEvent*)event;
- (LastComposedWord*)commitWord:(NSString*)committedWord separatorString:(NSString*)separatorString;
//- (NSString*)commitWord;
- (void)reset;
- (BOOL) isComposingWord;

- (CMWordComposer*) composedDataSnapshot;

- (void)setInputPointers:(InputPointers *)inputPointers;

- (void)setbatchInputWord:(NSString*)word;

@end
