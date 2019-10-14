//
//  CMKeyboardViewModel.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyboardViewModel.h"
#import "CMRowModel.h"
#import "CMKeyModel.h"
#import "CMKeyboardModel.h"
#import "CMKeyboardManager.h"

@interface CMKeyboardViewModel ()<NSCopying>
@property (nonatomic, strong)CMKeyModel* layoutKeyModel;
@property (nonatomic, strong)CMKeyModel* deleteKeyModel;
@property (nonatomic, strong)CMKeyModel* returnKeyModel;

@end

@implementation CMKeyboardViewModel

- (id)copyWithZone:(NSZone *)zone {
    CMKeyboardViewModel* model = [super copyWithZone:zone];
    model.layoutKeyModel = _layoutKeyModel;
    model.deleteKeyModel = _deleteKeyModel;
    model.returnKeyModel = _returnKeyModel;
    model.currentLayoutId = [_currentLayoutId copy];
    model.currentLayoutKey = [_currentLayoutKey copy];
    return model;
}

+ (instancetype)viewModelWithModel:(CMKeyboardModel *)keyboardModel {
    CMKeyboardViewModel* viewModel = [[CMKeyboardViewModel alloc] initWithKeyboardModel:keyboardModel];
    
    [keyboardModel.rowModelArray enumerateObjectsUsingBlock:^(CMRowModel * _Nonnull rowModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (CMKeyModel* keyModel in rowModel.keyArray) {
            if (keyModel.keyType == CMKeyTypeLayoutSwitch && idx == keyboardModel.rowModelArray.count - 1) {
                viewModel.layoutKeyModel = keyModel;
            }
            else if (keyModel.keyType == CMKeyTypeDel) {
                viewModel.deleteKeyModel = keyModel;
            }else if (keyModel.keyType == CMKeyTypeReturn) {
                viewModel.returnKeyModel = keyModel;
            }
        }
    }];
    return viewModel;
}

- (CMRowModel *)rowModelArray:(NSUInteger)row
{
    if (self.keyboadModel && self.keyboadModel.rowModelArray && self.keyboadModel.rowModelArray.count > 0) {
        return [self.keyboadModel.rowModelArray objectAtIndex:row];
    }
    return nil;
}

- (NSUInteger)keyModelRows {
    if (self.keyboadModel && self.keyboadModel.rowModelArray && self.keyboadModel.rowModelArray.count > 0) {
        return self.keyboadModel.rowModelArray.count;
    }
    return 0;
}

- (void)shiftStateSelected{
    if (self.keyboadModel.shiftKeyState != CMShiftKeyStateSelected) {
        self.keyboadModel.shiftKeyState = CMShiftKeyStateSelected;
    }
}

- (void)shiftStateUnSelected{

    if (self.keyboadModel.shiftKeyState != CMShiftKeyStateNormal) {
        self.keyboadModel.shiftKeyState = CMShiftKeyStateNormal;
    }
}

- (void)shiftStateLock {
    if (self.keyboadModel.shiftKeyState != CMShiftKeyStateLocked) {
        self.keyboadModel.shiftKeyState = CMShiftKeyStateLocked;
    }
}

- (BOOL)isEqualToViewModel:(CMKeyboardViewModel *)model {
    if (!model) {
        return NO;
    }
    
    return [self.keyboadModel isEqual:model.keyboadModel];
}

- (BOOL)isRowLayoutEqual:(CMKeyboardViewModel *)model {
    if (!model) {
        return NO;
    }
    return self.keyModelRows == model.keyModelRows;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMKeyboardViewModel class]]) {
        return NO;
    }
    
    return [self isEqualToViewModel:(CMKeyboardViewModel *)object];
}


@end
