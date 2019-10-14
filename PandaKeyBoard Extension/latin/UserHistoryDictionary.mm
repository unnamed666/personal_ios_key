//
//  UserHistoryDictionary.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UserHistoryDictionary.h"
#import "CMCommUtil.h"

#import "CMSettingManager.h"

#import "OCDefines.h"


@interface UserHistoryDictionary ()


@end


@implementation UserHistoryDictionary

- (instancetype)initWithLocal:(NSString*)local
{
    self = [super init];
    if (self) {
        self.dictType = TYPE_USER_HISTORY;
        [self resetWithLocal:local];
    }
    return self;
}

- (void)resetWithLocal:(NSString*)local{
    [super reset:[NSString stringWithFormat:@"UserHistoryDictionary_%@.diction",local?local:@"en"]];
    if(local){
        self.locale = local;
        [super reloadDictionaryIfRequired];
    }
    
}

- (NSMutableDictionary*) getHeaderAttributeMap{
    NSMutableDictionary * mutabledic = [super getHeaderAttributeMap];
    [mutabledic setObject:ATTRIBUTE_VALUE_TRUE forKey:USES_FORGETTING_CURVE_KEY];
    [mutabledic setObject:ATTRIBUTE_VALUE_TRUE forKey:HAS_HISTORICAL_INFO_KEY];
    return mutabledic;
}

- (void)addWord:(NSString*)word ngramContext:(CMNgramContext*)ngram isValid:(BOOL)isValid timestamp:(int)timestamp{
    if(word.length > MAX_WORD_LENGTH)return;
    [self updateEntriesForWord:word ngramContext:ngram isValidWord:isValid count:1 timestamp:timestamp];
}



@end
