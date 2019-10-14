//
//  UserHistoryDictionary.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMExpandableBinaryDictionary.h"

@interface UserHistoryDictionary : CMExpandableBinaryDictionary


- (instancetype)initWithLocal:(NSString*)local;
- (void)resetWithLocal:(NSString*)local;

- (void)addWord:(NSString*)word ngramContext:(CMNgramContext*)ngram isValid:(BOOL)isValid timestamp:(int)timestamp;
@end
