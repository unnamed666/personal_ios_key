//
//  CMKeyboardShiftState.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMKeyModel;

@protocol CMKeyboardShiftStateDelegate <NSObject>
- (BOOL)switchAlphabetKeyboard;
- (BOOL)switchAlphabetShiftedKeyboard;
- (BOOL)switchAlphabetShiftedLockKeyboard;

//是否是单词结束
- (BOOL)isWordsEnd;
//是否是句子结束
- (BOOL)isSentencesEnd;
@end

@interface CMKeyboardShiftState : NSObject{
}

@property(nonatomic) UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences

@property (nonatomic,weak) id<CMKeyboardShiftStateDelegate> delegate;


@property (nonatomic,readonly) KeyboardShiftState currentShiftState;

- (void)singleTap:(CMKeyModel*)key;

- (void)reset;

@end

