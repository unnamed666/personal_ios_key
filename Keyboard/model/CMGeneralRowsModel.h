//
//  CMGeneralRowsModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMRowModel;
@class CMTextInputModel;

@interface CMGeneralRowsModel : NSObject
@property (nonatomic, readonly, copy)NSArray<CMRowModel *>* rowModelArray;
@property (nonatomic, readonly, assign)CMKeyboardLanguageType languageType;
@property (nonatomic, readonly, copy)NSString* layoutKeyNext;
@property (nonatomic, readonly, copy)NSString* layoutKeyText;


- (instancetype)initWithRowArray:(NSArray<CMRowModel *>*)rowModelArray
                   layoutKeyText:(NSString *)keyText
                   layoutKeyNext:(NSString *)keyNext
                    languageType:(CMKeyboardLanguageType)languageType;

+ (instancetype)modelWithRowArray:(NSArray<CMRowModel *>*)rowModelArray
                    layoutKeyText:(NSString *)keyText
                    layoutKeyNext:(NSString *)keyNext
                     languageType:(CMKeyboardLanguageType)languageType;

@end
