//
//  CMKeyboardModel.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/5.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyboardModel.h"
#import "CMKeyModel.h"
#import "CMRowModel.h"
#import "CMTextInputModel.h"
#import "CMGeneralRowsModel.h"

@interface CMKeyboardModel () <NSCopying>

@end

@implementation CMKeyboardModel

- (instancetype)init {
    if (self = [super init]) {
        self.rowModelArray = [NSMutableArray new];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CMKeyboardModel* model = [[[self class] allocWithZone:zone] init];
    model.shiftKeyState = _shiftKeyState;
    model.keyboardType = _keyboardType;
    model.rowModelArray = [_rowModelArray mutableCopy];
    model.inputModel = [_inputModel copy];
    model.languageType = _languageType;
    return model;
}


+ (instancetype)modelWithGeneralRowsModel:(CMGeneralRowsModel *)generalRowsModel funcRowModel:(CMRowModel *)funcRowModel {
    if (!funcRowModel || !generalRowsModel) {
        return nil;
    }
    CMKeyboardModel* model = [CMKeyboardModel new];
    [funcRowModel updateLayoutIdAndSpaceKey:generalRowsModel.layoutKeyNext layoutKey:generalRowsModel.layoutKeyText];
    [model.rowModelArray addObjectsFromArray:generalRowsModel.rowModelArray];
    [model.rowModelArray addObject:funcRowModel];
    return model;
}

- (BOOL)isEqualToModel:(CMKeyboardModel *)model {
    if (!model) {
        return NO;
    }
    BOOL haveEqualInputModel = self.inputModel == model.inputModel;
    BOOL haveEqualKeyboardType = self.keyboardType == model.keyboardType;
    BOOL haveEqualLanguageType = self.languageType == model.languageType;

    return haveEqualInputModel && haveEqualKeyboardType && haveEqualLanguageType;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMKeyboardModel class]]) {
        return NO;
    }
    
    return [self isEqualToModel:(CMKeyboardModel *)object];
}

- (void)setRowModelArray:(NSArray<CMRowModel *> *)rowModelArray{
    _rowModelArray = [rowModelArray mutableCopy];
    for (CMRowModel * row in _rowModelArray) {
        for (CMKeyModel * key in row.keyArray) {
            key.parent = self;
        }
    }
}


@end
