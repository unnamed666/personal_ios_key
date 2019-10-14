//
//  CMDictionary.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString* const  TYPE_MAIN;
UIKIT_EXTERN NSString* const  TYPE_USER_HISTORY;
#define NOT_A_WEIGHT_OF_LANG_MODEL_VS_SPATIAL_MODEL (-1.0f)
UIKIT_EXTERN int  const NOT_A_PROBABILITY;

@class CmposedData;
@class CMNgramContext;

@interface CMDictionary : NSObject
@property (nonatomic,copy) NSString *locale;

@property (nonatomic,strong) NSString *dictType;

- (BOOL)isInitialized;

- (NSArray*) getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId weightForLocale:(float)weightForLocale  inOutWeightOfLangModelVsSpatialModel:(float)inOutWeightOfLangModelVsSpatialModel;

- (int)frequencyWithWord:(NSString*)word;
- (BOOL)isValidWord:(NSString*)word;
@end
