//
//  CMExpandableBinaryDictionary.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMDictionary.h"

extern NSString * const USES_FORGETTING_CURVE_KEY;
extern NSString * const HAS_HISTORICAL_INFO_KEY;
extern NSString * const ATTRIBUTE_VALUE_TRUE;

@interface CMExpandableBinaryDictionary : CMDictionary
@property (nonatomic,readonly,copy) NSString *dictName;
@property (nonatomic,assign,getter=isNeedsToRecreate) BOOL needsToRecreate;


-(void)reset:(NSString*)dictName;

- (void)reloadDictionaryIfRequired;

- (NSMutableDictionary*) getHeaderAttributeMap;

//把内存中的 内容写入字典文件
- (void)flushBinaryDictionary;
- (void)asyncFlushBinaryDictionary;

- (BOOL) isValidDictionary;


- (void)updateEntriesForWord:(NSString*)word ngramContext:(CMNgramContext*)ngram isValidWord:(BOOL)isValid count:(int)count timestamp:(int)time;


- (void)removeUnigramEntryDynamically:(NSString*)word;
@end
