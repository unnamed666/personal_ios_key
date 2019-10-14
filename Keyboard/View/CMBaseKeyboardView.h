//
//  CMBaseKeyboardView.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/16.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMBaseKeyboardView;
@class CMKeyModel;
@class CMBaseKeyboardViewModel;
@class CMKeyButton;
@class CMKeyPreviewView;
@class CMMoreKeysView;
@class CMBatchInputTracker;
@class InputPointers;
@class CMInputOptionView;

@protocol CMBaseKeyboardViewDelegate <NSObject>

@optional

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard touchDownKeyModel:(CMKeyModel *)keyModel touchPt:(CGPoint)touchPt fromeRepeate:(BOOL)fromRepeate;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard touchUpInsideKeyModel:(CMKeyModel *)keyModel touchPt:(CGPoint)touchPt fromeRepeate:(BOOL)fromRepeate;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard layoutFinished:(NSDictionary *)dimDic;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard doubleTappedKeyModel:(CMKeyModel *)keyModel;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard longPressedKeyModel:(CMKeyModel *)keyModel;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard selectedInputOption:(NSString *)optionTitle;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard upateBatchInputPointerModel:(InputPointers *)inputPointerModel;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard startbatchInput:(NSDictionary *)infoDic;

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard endBatchInputPointerModel:(InputPointers *)inputPointerModel;

@end

@protocol CMBaseKeyboardViewDataSource <NSObject>

- (BOOL)isMainDicValidInkeyboardView:(CMBaseKeyboardView *)keyboard;

@end

typedef NS_ENUM(int, DeleteButtonRepeateType) {
    DeleteButtonRepeateTypeLong ,
    DeleteButtonRepeateTypeShort,
    DeleteButtonRepeateTypeNormal
};


@interface CMBaseKeyboardView : UIView
{
    CMBaseKeyboardViewModel* _viewModel;
    CMKeyPreviewView* _previewView;
    CMInputOptionView* _inputOptionView;
}
@property (nonatomic, weak)id<CMBaseKeyboardViewDelegate> delegate;
@property (nonatomic, weak)id<CMBaseKeyboardViewDataSource> dataSource;

@property (nonatomic, strong)CMBaseKeyboardViewModel* viewModel;
@property (nonatomic, strong)CMKeyPreviewView* previewView;
//@property (nonatomic, strong)CMMoreKeysView* inputOptionView;
@property (nonatomic, strong)CMInputOptionView* inputOptionView;


@property (nonatomic, assign)CGFloat rowMargin;
@property (nonatomic, assign)CGFloat keyMargin;
@property (nonatomic, assign)CGFloat keyWidth;
@property (nonatomic, assign)CGFloat keyboardHeight;

@property(nonatomic, strong) CMKeyModel* deleteKeyModel;
@property(nonatomic, assign) BOOL isDeleteButtonDown;
@property(nonatomic, assign) CGPoint deleteTouchPoint;

@property (nonatomic, assign, readonly)BOOL isHideKey;

@property (nonatomic, strong)CMBatchInputTracker* inputTracker;

- (void)bindData:(CMBaseKeyboardViewModel *)viewModel;

- (void)showPreview:(CMKeyButton *)keyBtn;

- (void)hidePreView:(BOOL)animate;

- (void)showInputOptionView:(CMKeyButton *)keyBtn;

- (BOOL)shouldUseBatchInpupt;

- (void)hideInputOptionView;
- (void)startDeleteRepeate : (NSNumber*) repeateType;
- (void)cancleDeleteRepeate : (CMBaseKeyboardView*) keyboardView deleteButton:(CMKeyButton*) deleteButton;

@end
