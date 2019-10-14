//
//  CMRowModel.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/9.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMKeyModel;
@class CMTextInputModel;

@interface CMRowModel : NSObject

@property (nonatomic, assign)NSUInteger num;
@property (nonatomic, assign)CGFloat rowHeightRatio;
@property (nonatomic, assign)CGFloat rowTopPaddingRatio;
@property (nonatomic, assign)CGFloat rowBottomPaddingRatio;

@property (nonatomic, strong)CMTextInputModel* inputModel;
@property (nonatomic, assign)CMKeyboardLanguageType languageType;
@property (nonatomic, assign)BOOL isMultiLanguage;

@property (nonatomic, readonly, strong)NSMutableArray<CMKeyModel *>* keyArray;

+ (instancetype)rowModelWithArray:(NSArray<CMKeyModel *>*)keys;

+ (instancetype)rowModelWithDictionary:(NSDictionary *)dic;

- (void)updateLayoutIdAndSpaceKey:(NSString *)layoutId layoutKey:(NSString *)layoutKey;


@end
