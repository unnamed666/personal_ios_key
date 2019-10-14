//
//  CMGeneralRowsModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMGeneralRowsModel.h"
#import "CMTextInputModel.h"
#import "CMKeyboardManager.h"

@interface CMGeneralRowsModel ()
@property (nonatomic, readwrite, copy)NSArray<CMRowModel *>* rowModelArray;
@property (nonatomic, readwrite, copy)NSString* layoutKeyNext;
@property (nonatomic, readwrite, copy)NSString* layoutKeyText;
@property (nonatomic, readwrite, assign)CMKeyboardLanguageType languageType;

@end

@implementation CMGeneralRowsModel

- (instancetype)initWithRowArray:(NSArray<CMRowModel *>*)rowModelArray
                   layoutKeyText:(NSString *)keyText
                   layoutKeyNext:(NSString *)keyNext
                    languageType:(CMKeyboardLanguageType)languageType {
    if (self = [super init]) {
        _rowModelArray = [rowModelArray copy];
        _layoutKeyNext = [keyNext copy];
        _layoutKeyText = [keyText copy];
        _languageType = languageType;
    }
    return self;
}

+ (instancetype)modelWithRowArray:(NSArray<CMRowModel *>*)rowModelArray
                    layoutKeyText:(NSString *)keyText
                    layoutKeyNext:(NSString *)keyNext
                     languageType:(CMKeyboardLanguageType)languageType {
    CMGeneralRowsModel* model = [[CMGeneralRowsModel alloc] initWithRowArray:rowModelArray layoutKeyText:keyText layoutKeyNext:keyNext languageType:languageType];
    return model;
}

- (BOOL)isEqualToModel:(CMGeneralRowsModel *)model {
    if (!model) {
        return NO;
    }
    BOOL count = self.rowModelArray.count == model.rowModelArray.count;
    BOOL content = [self.layoutKeyText isEqualToString:model.layoutKeyText]
    && [self.layoutKeyNext isEqualToString:model.layoutKeyNext]
    && self.languageType == model.languageType;
    
    return count && content;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMGeneralRowsModel class]]) {
        return NO;
    }
    
    return [self isEqualToModel:(CMGeneralRowsModel *)object];
}


@end
