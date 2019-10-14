//
//  CMEmojiSectionModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMKeyModel;

@interface CMEmojiSectionModel : NSObject
@property (nonatomic, copy)NSArray<CMKeyModel *>* emojiArray;
@property (nonatomic, copy)NSString* sectionNormalIconName;
@property (nonatomic, copy)NSString* sectionHighlightIconName;

@property (nonatomic, copy)NSString* sectionName;

@end
