//
//  CMKeyboardViewModel.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMBaseKeyboardViewModel.h"
@class CMRowModel;
@class CMKeyModel;
@class CMGeneralRowsModel;

@interface CMKeyboardViewModel : CMBaseKeyboardViewModel
@property (nonatomic, readonly, strong)CMKeyModel* layoutKeyModel;
@property (nonatomic, readonly, strong)CMKeyModel* deleteKeyModel;
@property (nonatomic, readonly, strong)CMKeyModel* returnKeyModel;

@property (nonatomic, copy)NSString* currentLayoutId;
@property (nonatomic, copy)NSString* currentLayoutKey;

+ (instancetype)viewModelWithModel:(CMKeyboardModel *)keyboardModel;


- (CMRowModel *)rowModelArray:(NSUInteger)row;

- (NSUInteger)keyModelRows;

- (void)shiftStateSelected;
- (void)shiftStateUnSelected;
- (void)shiftStateLock;


- (BOOL)isEqualToViewModel:(CMKeyboardViewModel *)model;

- (BOOL)isRowLayoutEqual:(CMKeyboardViewModel *)model;

@end
