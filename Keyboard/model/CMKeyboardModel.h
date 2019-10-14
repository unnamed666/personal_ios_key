//
//  CMKeyboardModel.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/5.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMShiftKeyState) {
    CMShiftKeyStateNormal = 0,
    CMShiftKeyStateSelected,
    CMShiftKeyStateLocked,
};

typedef NS_ENUM(NSUInteger, CMKeyboardType) {
    CMKeyboardTypeLetter = 0, // 字母键盘
    CMKeyboardTypeNumber, // 带数字
    CMKeyboardTypePunc // 带标点
};

@class CMRowModel;
@class CMGeneralRowsModel;
@class CMTextInputModel;

@interface CMKeyboardModel : NSObject

@property (nonatomic, strong)NSMutableArray<CMRowModel *>* rowModelArray;

@property (nonatomic, assign)CMShiftKeyState shiftKeyState;

@property (nonatomic, assign)CMKeyboardType keyboardType;

@property (nonatomic, copy)CMTextInputModel* inputModel;

@property (nonatomic, assign)CMKeyboardLanguageType languageType;

+ (instancetype)modelWithGeneralRowsModel:(CMGeneralRowsModel *)generalRowsModel funcRowModel:(CMRowModel *)funcRowModel;

- (BOOL)isEqualToModel:(CMKeyboardModel *)model;


@end
