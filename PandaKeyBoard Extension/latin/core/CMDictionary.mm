//
//  CMDictionary.mm
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDictionary.h"

NSString* const  TYPE_MAIN = @"main";
NSString* const TYPE_USER_HISTORY = @"history";

int  const NOT_A_PROBABILITY = -1;
@implementation CMDictionary

- (BOOL)isInitialized{
    return YES;
}

- (NSArray*) getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId weightForLocale:(float)weightForLocale inOutWeightOfLangModelVsSpatialModel:(float)inOutWeightOfLangModelVsSpatialModel{
    return nil;
}

- (int)frequencyWithWord:(NSString*)word{
    return NOT_A_PROBABILITY;
}

- (BOOL)isValidWord:(NSString*)word{
    return NO;
}
@end
