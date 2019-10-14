//
//  LastComposedWord.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "LastComposedWord.h"
#import "InputPointers.h"

@interface LastComposedWord (){
    BOOL mActive;
}
@property (nonatomic,copy) InputPointers *inputPointes;
@property (nonatomic,copy) NSString *typedWord;
@property (nonatomic,copy) NSString *committedWord;
@property (nonatomic,copy) NSString *separatorString;
@property (nonatomic,assign) KeyboardShiftState shiftState;
@end

@implementation LastComposedWord

- (instancetype)initWithInputPointers:(InputPointers*) inputPointes
                            typedWord:(NSString*)typedWord
                        committedWord:(NSString*)committedWord
                      separatorString:(NSString*)separatorString
                           shiftState:(KeyboardShiftState)shiftState
{
    self = [super init];
    if (self) {
        mActive = YES;
        self.inputPointes = inputPointes;
        self.typedWord = typedWord;
        self.committedWord = committedWord;
        self.separatorString = separatorString;
        self.shiftState = shiftState;
    }
    return self;
}

- (void)deactivate{
    mActive = NO;
}

- (BOOL)canRevertCommit{
    return mActive && self.committedWord.length>0 && ! [self.typedWord isEqualToString:self.committedWord];
}

@end
