//
//  CMBinaryDictionaryUtils.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/16.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMBinaryDictionaryUtils.h"
#include "autocorrection_threshold_utils.h"

@implementation CMBinaryDictionaryUtils

+ (float)calcNormalizedScore:(NSString*)before after:(NSString*)after score:(int)score{
    int beforeLength = (int)before.length;
    int afterLength = (int)after.length;
    
    int beforeCodePoints[beforeLength];
    int afterCodePoints[afterLength];
    
    
    unichar beforeChars[beforeLength];
    unichar afterChars[afterLength];
    [before getCharacters:beforeChars range:NSMakeRange(0, beforeLength)];
    [after getCharacters:afterChars range:NSMakeRange(0, afterLength) ];
    for (int i = 0; i<beforeLength; i++) {
        beforeCodePoints[i] = beforeChars[i];
    }
    for (int i = 0; i<afterLength; i++) {
        afterCodePoints[i] = afterChars[i];
    }
    return latinime::AutocorrectionThresholdUtils::calcNormalizedScore(beforeCodePoints,beforeLength,afterCodePoints,afterLength,score);
}

@end
