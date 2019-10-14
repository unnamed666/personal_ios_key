//
//  LasetComposedWord.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InputPointers;

@interface LastComposedWord : NSObject
@property (nonatomic,readonly) InputPointers *inputPointes;
@property (nonatomic,readonly) NSString *typedWord;
@property (nonatomic,readonly) NSString *committedWord;
@property (nonatomic,readonly) NSString *separatorString;
@property (nonatomic,readonly) KeyboardShiftState shiftState;


- (instancetype)initWithInputPointers:(InputPointers*) inputPointes
                            typedWord:(NSString*)typedWord
                        committedWord:(NSString*)committedWord
                      separatorString:(NSString*)separatorString
                           shiftState:(KeyboardShiftState)shiftState;
- (void)deactivate;

- (BOOL)canRevertCommit;

@end
