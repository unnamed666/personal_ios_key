//
//  BinaryDictionary.h
//  test
//
//  Created by wolf on 17/1/12.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMDictionary.h"


//UIKIT_EXTERN float const NOT_A_WEIGHT_OF_LANG_MODEL_VS_SPATIAL_MODEL;
//const float NOT_A_WEIGHT_OF_LANG_MODEL_VS_SPATIAL_MODEL = -1.0f;


@interface CMBinaryDictionary : CMDictionary

- (instancetype)initWithFilePath:(NSString*)filePath
                          locale:(NSString*)locale
             useFullEditDistance:(BOOL)useFullEditDistance
                        dictType:(NSString*)dictType
                   formatVersion:(int)formatVersion
             attributeDictionary:(NSDictionary*)attributeDictionary;

- (instancetype)initWithFilePath:(NSString*)filePath locale:(NSString*)locale isUpadtable:(BOOL)isUpadtable useFullEditDistance:(BOOL)useFullEditDistance;


- (void)close;

- (BOOL)isValidDictionary;
- (int)getFormatVersion;
- (BOOL)migrateTo:(int)newFormatVersion;
- (int)getVersion;
- (BOOL)needsToRunGC:(BOOL)mindsBlockByGC;

- (void)flushWithGCIfHasUpdated;

- (BOOL)flushWithGC;
- (BOOL)flush;
- (BOOL)isCorruptedNative;

- (BOOL)updateEntriesForWordWithNgramContext:(CMNgramContext*)ngram word:(NSString*)word isValidWord:(BOOL)isValidWord count:(int)count timestamp:(int)timestamp;

- (BOOL)removeUnigramEntryNative:(NSString*)word;

@end
