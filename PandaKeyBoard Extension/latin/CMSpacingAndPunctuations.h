//
//  CMSpacingAndPunctuations.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/10.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMKeyboardManager.h"

@interface CMSpacingAndPunctuations : NSObject

@property (nonatomic ,readonly) BOOL mCurrentLanguageHasSpaces;

@property (nonatomic,readonly) NSString* mSentenceSeparatorAndSpace;

- (void)reset:(CMKeyboardLanguageType)languageType;

- (BOOL)isSentenceTerminator:(int)c;
- (BOOL)isUsuallyPrecededBySpace:(int)str;
- (BOOL)isUsuallyFollowedBySpace:(int)str;

- (BOOL)isWordSeparator:(int)str;
- (BOOL)isWordConnector:(int)str;

@end
