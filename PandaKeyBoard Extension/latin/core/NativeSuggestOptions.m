//
//  NativeSuggestOptions.m
//  test
//
//  Created by yanzhao on 2017/3/25.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "NativeSuggestOptions.h"
// Need to update suggest_options.h when you add, remove or reorder options.
const int  IS_GESTURE = 0;
const int USE_FULL_EDIT_DISTANCE =1;
const int BLOCK_OFFENSIVE_WORDS =2;
const int SPACE_AWARE_GESTURE_ENABLED =3;
const int WEIGHT_FOR_LOCALE_IN_THOUSANDS= 4;
const int OPTIONS_SIZE = 5;

@interface NativeSuggestOptions (){
   
}

@end

@implementation NativeSuggestOptions

- (void)setIsGesture:(BOOL)value{
    [self setBOOLOption:IS_GESTURE value:value];
}

- (void)setUseFullEditDistance:(BOOL)value{
    [self setBOOLOption:USE_FULL_EDIT_DISTANCE value:value];
}

- (void)setBlockOffensiveWords:(BOOL)value{
    [self setBOOLOption:BLOCK_OFFENSIVE_WORDS value:value];
}

- (void)setWeightForLocale:(float)value{
    // We're passing this option as a fixed point value, in thousands. This is decoded in
    // native code by SuggestOptions#weightForLocale().
    
    [self setIntOption:WEIGHT_FOR_LOCALE_IN_THOUSANDS value:(int)(value*1000)];
}

- (void)setBOOLOption:(int)key value:(BOOL)value{
    mOptions[key] = value ?1:0;
}
- (void)setIntOption:(int)key value:(int)value{
    mOptions[key]=value;
}

@end
