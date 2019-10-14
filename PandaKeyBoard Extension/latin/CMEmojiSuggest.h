//
//  CMEmojiSuggestManager.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/26.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CmposedData;
@interface CMEmojiSuggest : NSObject

- (NSArray *)getSuggestEmojiList:(NSString *)dataToGetEmoji;

@end
