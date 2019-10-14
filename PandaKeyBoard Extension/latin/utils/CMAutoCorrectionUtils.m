//
//  CMAutoCorrectionUtils.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/16.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMAutoCorrectionUtils.h"
#import "SuggestedWordInfo.h"
#import "CMBinaryDictionaryUtils.h"

@implementation CMAutoCorrectionUtils


+(BOOL)suggestionExceedsThreshold:(SuggestedWordInfo*)suggestion consideredWord:(NSString*)consideredWord threshold:(float)threshold{

    if(suggestion == NO)return NO;
    if(suggestion.timestamp != NOT_A_TIMESTAMP && suggestion.word.length >0 && [suggestion.word containsString:@" "])
        return NO;
    
    if([suggestion isKindOf:KIND_WHITELIST])return YES;
    
    if(![suggestion isAppropriateForAutoCorrection])return YES;
    
    int autoCorrectionSuggestionScore = suggestion.score;
    float normalizedScore = [CMBinaryDictionaryUtils calcNormalizedScore:consideredWord after:suggestion.word score:autoCorrectionSuggestionScore];
    
    if(normalizedScore>=threshold){
        return YES;
    }
    
    return NO;
}
@end
