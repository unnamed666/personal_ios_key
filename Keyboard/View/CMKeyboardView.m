//
//  CMKeyboardView.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyboardView.h"
#import "CMKeyboardViewModel.h"
#import "CMKeyModel.h"
#import "UIButton+Block.h"
#import "CMKeyButton.h"
#import "CMRowModel.h"
#import "CMNotificationConstants.h"
#import "NSDictionary+Common.h"
#import "CMRowView.h"
#import "UIView+Util.h"
#import "CMKeyboardManager.h"
#import "UIView+Constraint.h"
#import "CMBaseKeyboardViewModel.h"
#import "CMKeyboardViewModel.h"
#import "CMKeyboardModel.h"
#import "UIView+Animate.h"
#import "CMInputOptionView.h"
#import "CMSwitchView.h"

#ifndef HostApp
#import "CMInfoc.h"
#import "CMProximityInfo.h"
#import "CMBatchInputTracker.h"
#endif
@interface CMKeyboardView () <CMSwitchViewDelegate>
@property (nonatomic, strong)NSMutableArray<CMRowView *>* rowViewArray;
@property (nonatomic, strong)CMSwitchView* switchView;

@end


static void  *PrivateKVOContext = &PrivateKVOContext;

@implementation CMKeyboardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isLayoutFinish = NO;
        _isKVO = NO;
        _keyboardViewType = CMKeyboardViewTypeMain;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

+ (BOOL)requiresConstraintBasedLayout {
    return NO;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        // 移除KVO
        [self removeViewModelKVO];
    }else if(!self.isKVO && newWindow != nil && self.viewModel != nil){
        [self addViewModeKVO];
    }
}

- (CMKeyboardType)keyboardType {
    NSAssert(self.viewModel != nil && [self.viewModel isKindOfClass:[CMKeyboardViewModel class]], @"[keyboardType]: self.viewModel invalid");
    CMKeyboardViewModel* model = (CMKeyboardViewModel *)self.viewModel;
    return model.keyboadModel.keyboardType;
}

- (void)drawRect:(CGRect)rect {
    UIView* subView = [self.rowViewArray firstObject];
    
    if ([subView.subviews lastObject].frame.size.width > 0 && !self.isLayoutFinish) {
        if (self.delegate) {
            [self.delegate onKeyboard:self layoutFinished:[self measureSubviews]];
        }
        self.isLayoutFinish = YES;
    }
    [super drawRect:rect];
}

- (NSDictionary *)measureSubviews {
    NSMutableDictionary * keyCache = [NSMutableDictionary new];
    
    NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
#ifndef HostApp
    NSMutableString* ENUS_CODES = [NSMutableString string];
    NSMutableString* EnUS_X = [NSMutableString string];
    NSMutableString* EnUS_Y = [NSMutableString string];
    NSMutableString* EnUS_WITH = [NSMutableString string];
    NSMutableString* EnUS_HEIGHT = [NSMutableString string];
    __block NSUInteger commonWidth = 0;
    __block NSUInteger commonHeight = 0;
    
    __block CMKeyButton * spaceButton;
    
    NSMutableArray* proximityInfoArray = [NSMutableArray array];
    
    for (CMRowView* rowView in self.rowViewArray) {
        [rowView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([view isKindOfClass:[CMKeyButton class]]) {
                CMKeyButton* button = (CMKeyButton *)view;
                CGRect parseFrame = [button convertRect:button.bounds toView:self];
                ProximityInfoKey* info = [ProximityInfoKey new];
                info.key = button.keyModel.key;
                info.keyCode = button.keyModel.mCode;
                info.btnSize = parseFrame;
                [keyCache setObject:info forKey:@(button.keyModel.mCode)];
                
                ProximityInfoKey* infoNativeScale = [ProximityInfoKey new];
                infoNativeScale.key = button.keyModel.key;
                infoNativeScale.keyCode = button.keyModel.mCode;
                infoNativeScale.btnSize = CGRectMake(parseFrame.origin.x*kNativeScale, parseFrame.origin.y*kNativeScale, parseFrame.size.width*kNativeScale, parseFrame.size.height*kNativeScale);
                [proximityInfoArray addObject:infoNativeScale];
                
                //pt * kNativeScale
                [ENUS_CODES appendFormat:@"%d,", button.keyModel.mCode];
                [EnUS_X appendFormat:@"%d,", (int)infoNativeScale.btnSize.origin.x];
                [EnUS_Y appendFormat:@"%d,", (int)infoNativeScale.btnSize.origin.y];
                [EnUS_WITH appendFormat:@"%d,", (int)infoNativeScale.btnSize.size.width];
                [EnUS_HEIGHT appendFormat:@"%d,", (int)infoNativeScale.btnSize.size.height];
                //pt
                if (button.keyModel.keyType == CMKeyTypeLetter) {
                    commonWidth = (NSUInteger)parseFrame.size.width;
                    commonHeight = (NSUInteger)parseFrame.size.height;
                }
                if (button.keyModel.keyType == CMKeyTypeSpace) {
                    spaceButton = button;
                }
            }
        }];
    }
    
    [self.inputTracker setKeyWidth:commonWidth keyboardHeight:self.bounds.size.height];

    [mutDic setObject:[ENUS_CODES substringToIndex:ENUS_CODES.length-1] forKey:@"ENUS_CODES"];
    [mutDic setObject:[EnUS_X substringToIndex:EnUS_X.length-1] forKey:@"EnUS_X"];
    [mutDic setObject:[EnUS_Y substringToIndex:EnUS_Y.length-1] forKey:@"EnUS_Y"];
    [mutDic setObject:[EnUS_WITH substringToIndex:EnUS_WITH.length-1] forKey:@"EnUS_WITH"];
    [mutDic setObject:[EnUS_HEIGHT substringToIndex:EnUS_HEIGHT.length-1] forKey:@"EnUS_HEIGHT"];
    [mutDic setObject:@(32) forKey:@"EnUS_gridWidth"];
    [mutDic setObject:@(16) forKey:@"EnUS_gridHeight"];
    [mutDic setObject:@((NSUInteger)self.bounds.size.width*kNativeScale) forKey:@"EnUS_minWidth"];
    [mutDic setObject:@((NSUInteger)self.bounds.size.height*kNativeScale) forKey:@"EnUS_height"];
//    [mutDic setObject:@(245) forKey:@"EnUS_height"];

    [mutDic setObject:@((commonWidth+(NSUInteger)self.keyMargin)*kNativeScale ) forKey:@"EnUS_mostCommonKeyWidth"];
    [mutDic setObject:@((commonHeight+(NSUInteger)self.rowMargin)*kNativeScale ) forKey:@"EnUS_mostCommonKeyHeight"];
    [mutDic setObject:@((NSUInteger)self.keyMargin*kNativeScale) forKey:@"EnUS_X_GAP"];
    [mutDic setObject:@((NSUInteger)self.rowMargin*kNativeScale) forKey:@"EnUS_Y_GAP"];
    [mutDic setObject:[proximityInfoArray copy] forKey:@"proximityInfoArray"];
    
    [mutDic setObject:[keyCache copy] forKey:@"keyCache"];
    
    if (spaceButton) {
        [mutDic setObject:spaceButton forKey:@"spaceButton"];
    }
#endif
    return [mutDic copy];
}


- (void)bindData:(CMBaseKeyboardViewModel *)viewModel {
    if (viewModel != nil && ![viewModel isKindOfClass:[CMKeyboardViewModel class]]) {
        return;
    }
    
    CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)viewModel;

    if ([self.viewModel isEqual:theViewModel]) {
        [self setNeedsLayout];
    }
    else if ([theViewModel isRowLayoutEqual:(CMKeyboardViewModel *)self.viewModel]) {
        NSUInteger rowCount = [theViewModel keyModelRows];
        for (int i = 0; i < rowCount; i++) {
            CMRowModel* row = [theViewModel rowModelArray:i];
            CMRowView* view = [self.rowViewArray objectAtIndex:i];
            [self replaceRow:view Buttons:row.keyArray row:row.num];
        }
        self.viewModel = viewModel;
        [self setNeedsLayout];
    }
    else {
        [self.rowViewArray enumerateObjectsUsingBlock:^(CMRowView * _Nonnull rowView, NSUInteger idx, BOOL * _Nonnull stop) {
            [rowView removeFromSuperview];
        }];
        [self.rowViewArray removeAllObjects];
        
        NSUInteger rowCount = [theViewModel keyModelRows];
        for (int i = 0; i < rowCount; i++) {
            CMRowModel* row = [theViewModel rowModelArray:i];
            CMRowView* view = [self createRowofButtons:row.keyArray row:i];
            view.backgroundColor = [UIColor clearColor];
            [self.rowViewArray addObject:view];
            [self addSubview:view];
        }
        self.viewModel = viewModel;
        [self setNeedsLayout];
    }
}

- (CMRowView *)createRowofButtons:(NSArray<CMKeyModel *>*)modelArray row:(NSUInteger)row {
    CMRowView* rowView = [CMRowView new];
    rowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSMutableArray<CMKeyButton *>* buttonArray = [NSMutableArray array];
    for (CMKeyModel* keyModel in modelArray) {
        CMKeyButton* button = [self createButtonWithKeyModel:keyModel];
        if (keyModel.isLeftMost) {
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            rowView.leftPaddingRatio = [CMBizHelper isiPhone] ? keyModel.leftPadding : keyModel.leftPaddingiPad;
        }
        else if (keyModel.isRightMost) {
            button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            rowView.rightPaddingRatio = [CMBizHelper isiPhone] ? keyModel.rightPadding : keyModel.rightPaddingiPad;
        }
        [buttonArray addObject:button];
        [rowView addSubview:button];
    }
    rowView.buttonArray = [buttonArray copy];
    return rowView;
}

- (void)replaceRow:(CMRowView*)rowView Buttons:(NSArray<CMKeyModel *>*)modelArray row:(NSUInteger)row {
    [rowView removeAllSubviews];
    NSMutableArray<CMKeyButton *>* buttonArray = [NSMutableArray array];
    for (CMKeyModel* keyModel in modelArray) {
        CMKeyButton* button = [self createButtonWithKeyModel:keyModel];
        [buttonArray addObject:button];
        [rowView addSubview:button];
    }
    rowView.buttonArray = [buttonArray copy];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    __block CMRowView* lastView = nil;
    [self.rowViewArray enumerateObjectsUsingBlock:^(CMRowView * _Nonnull rowView, NSUInteger idx, BOOL * _Nonnull stop) {
        rowView.width = self.width;
        rowView.height = self.height/self.rowViewArray.count;
        if (lastView) {
            rowView.isTopMost = NO;
            rowView.isBottomMost = NO;
        }
        else {
            rowView.isTopMost = YES;
            rowView.isBottomMost = NO;
        }
        rowView.top = rowView.height * idx;

        if ([CMKeyboardManager sharedInstance].needKeyboardExpandAnimation) {
            [rowView verticalMoveAnimationFromCenterY:self.height / 2 + (rowView.height * idx - self.height / 2) * KeyboardExpandOriginalScale + self.height / 2 * KeyboardExpandOriginalScale duration:KeyboardExpandAnimationTime timingFunction:KeyboardExpandTimingFunction];
        }
        lastView = rowView;
    }];
    
    if (lastView) {
        lastView.isTopMost = NO;
        lastView.isBottomMost = YES;
        lastView.bottom = self.boundBottom;
    }

    if (!self.isLayoutFinish) {
        [self setNeedsDisplay];
    }
}

- (CMKeyButton *)createButtonWithKeyModel:(CMKeyModel *)model {
    @weakify(self)
    CMKeyButton* button = [[CMKeyButton alloc] initWithKeyModel:model];
    [button setOptionSelectedHandler:^(CMKeyButton* keyButton) {
        @stronglize(self)
        if ([keyButton.keyModel shouldShowSwitchView]) {
            NSUInteger index = self.switchView.selectedInputIndex;
            if (index != NSNotFound) {
                [self hideSwitchView];
                if (self.delegate && [self.delegate conformsToProtocol:@protocol(CMKeyboardViewDelegate)]) {
                    [(id<CMKeyboardViewDelegate>)self.delegate onKeyboard:self selectedSwitchOptionIndex:index keyModel:keyButton.keyModel];
                }
            }
        } else if ([keyButton.keyModel shouldShowInputOptionsView]) {
            if (keyButton.keyModel.inputOptionArray && keyButton.keyModel.inputOptionArray.count > 0) {
                NSUInteger index = NSNotFound;
                if (_inputOptionView && _inputOptionView.superview && _inputOptionView.keyPosition == CMKeyBtnPositionLeft) {
                    index = keyButton.keyModel.inputOptionArray.count - _inputOptionView.selectedInputIndex - 1;
                }
                else {
                    index = _inputOptionView.selectedInputIndex;
                }
                if (index != NSNotFound) {
                    NSString *inputOption = keyButton.keyModel.inputOptionArray[index];
                    if(keyButton.keyModel.parent.shiftKeyState != CMShiftKeyStateNormal){
                        inputOption = [inputOption uppercaseString];
                    }
#ifndef HostApp
                    if (keyButton.keyModel.keyType == CMKeyTypeSpace) {
                        [CMInfoc reportEmojiTapped:3 emoji:inputOption];
                    }
#endif
                    
                    if (self.delegate) {
                        [self.delegate onKeyboard:self selectedInputOption:inputOption];
                    }
                }
            }
            [self hideInputOptionView];
        }
    }];
    [button setOptionsPanHandler:^(CGPoint pt) {
        @stronglize(self)
        if (_inputOptionView && _inputOptionView.superview) {
            [self.inputOptionView updateSelectedInputIndexForPoint:pt];
        }
        
        if (_switchView && _switchView.superview) {
            [self.switchView updateSelectedInputIndexForPoint:pt];
        }
    }];
    
    [button setKeyTouchDownHandler:^(CMKeyButton* keyButton, CGPoint touchPt) {
        @stronglize(self)
        if (keyButton.keyModel.keyType == CMKeyTypeDel)
        {
            self.deleteTouchPoint = touchPt;
            self.deleteKeyModel = keyButton.keyModel;
            self.isDeleteButtonDown = YES;
            [self performSelector:@selector(startDeleteRepeate:) withObject:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeShort] afterDelay:0.6];
        }
        else
        {
            self.isDeleteButtonDown = NO;
            [self hidePreView:NO];
            [self hideInputOptionView];
            [self hideSwitchView];
            [self showPreview:keyButton];
            if (self.delegate) {
                [self.delegate onKeyboard:self touchDownKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
            }
        }
    }];
    
    [button setKeyTouchUpInsideHandler:^(CMKeyButton* keyButton, CGPoint touchPt) {
        @stronglize(self)
        self.isDeleteButtonDown = NO;
        if (keyButton.keyModel.keyType == CMKeyTypeDel)
        {
            [self startDeleteRepeate:[[NSNumber alloc] initWithInt:DeleteButtonRepeateTypeNormal]];
            [self cancleDeleteRepeate:self deleteButton:keyButton];
        }
        else
        {
            [self hidePreView:YES];
            [self hideInputOptionView];
            [self hideSwitchView];

            if (self.delegate) {
                [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
            }
        }
    }];
    [button setKeyTouchCancelHandler:^(CMKeyButton *keyButton){
        @stronglize(self)
        if (keyButton.keyModel.keyType == CMKeyTypeDel)
        {
            self.isDeleteButtonDown = NO;
            [self cancleDeleteRepeate:self deleteButton:keyButton];
        }
        [self hidePreView:NO];
    }];
    
    [button setKeyLongPressedHandler:^(CMKeyButton *keyButton, CGPoint touchPt){
        @stronglize(self)
        [self hidePreView:NO];
        [self hideInputOptionView];
        [self hideSwitchView];

        if (keyButton.keyModel.keyType == CMKeyTypeSpace) {
#ifndef HostApp
            [CMInfoc reportEmojiShow:3 class:0];
#endif
            keyButton.keyModel.inputOptionDefaultSelected = touchPt.x / (CGRectGetWidth(keyButton.frame) / 5);
        }
        if (keyButton.keyModel.keyType == CMKeyTypeSwitchKeyboard) {
            [self showSwitchView:keyButton];
        }
        else {
            [self showInputOptionView:keyButton];
        }
        
        if (self.delegate) {
            [self.delegate onKeyboard:self longPressedKeyModel:keyButton.keyModel];
        }
    }];
    [button setKeyDoubleTappedHandler:^(CMKeyButton *keyButton) {
        @stronglize(self)
        [self hidePreView:NO];
        [self hideInputOptionView];
        [self hideSwitchView];
        
        if (self.delegate) {
            [self.delegate onKeyboard:self doubleTappedKeyModel:keyButton.keyModel];
        }
    }];
    return button;
}

- (BOOL)shouldUseBatchInpupt {
    if (self.viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter) {
        return [super shouldUseBatchInpupt];
    }
    return NO;
}

- (void)showSwitchView:(CMKeyButton *)keyBtn {
    if (![keyBtn.keyModel shouldShowSwitchView] || self.keyboardViewType == CMKeyboardViewTypeDiy) {
        return;
    }
    if (_switchView && _switchView.superview) {
        return;
    }
    self.switchView.button = keyBtn;
    [self.superview addSubview:self.switchView];
    if (self.isHideKey) {
        keyBtn.alpha = 0.0f;
    }
}


- (void)hideSwitchView {
    if (!_switchView || !_switchView.superview || self.keyboardViewType == CMKeyboardViewTypeDiy) {
        return;
    }
    self.switchView.button.alpha = 1.0f;
    [self.switchView removeFromSuperview];
    self.switchView = nil;
}

#pragma mark - setter/getter
- (NSMutableArray<CMRowView *> *)rowViewArray {
    if (!_rowViewArray) {
        _rowViewArray = [NSMutableArray new];
    }
    return _rowViewArray;
}

- (void)setViewModel:(CMBaseKeyboardViewModel *)model {
        // 移除KVO
    [self removeViewModelKVO];
    _viewModel = model;
    _isLayoutFinish = NO;
    [self addViewModeKVO];
}

- (CMSwitchView *)switchView {
    if (!_switchView) {
        _switchView = [[CMSwitchView alloc] initWithFrame:self.superview.bounds];
        _switchView.delegate = self;
    }
    return _switchView;
}

#pragma mark - KVO实现

- (void)dealloc{
    if (_rowViewArray) {
        [_rowViewArray removeAllObjects];
        _rowViewArray = nil;
    }
}

- (void)removeViewModelKVO{
    if (_isKVO && _viewModel){
        [_viewModel removeObserver:self forKeyPath:@"keyboadModel.shiftKeyState" context:PrivateKVOContext];
        _isKVO = NO;
    }
}
- (void)addViewModeKVO{
    if(!_viewModel || _isKVO) return;
    [_viewModel addObserver:self forKeyPath:@"keyboadModel.shiftKeyState" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:PrivateKVOContext];
    _isKVO = YES;
    
}

//观察者需要实现的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"keyboadModel.shiftKeyState"] && object == self.viewModel) {
        CMShiftKeyState newState = [change integerValueForKey:@"new" defaultValue:CMShiftKeyStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShiftKeyTapped object:@{@"shiftKeyState":@(newState)}];
    }
}

#pragma mark - CMSwitchViewDelegate
- (void)onSwitchView:(CMSwitchView *)switchView selectedIndex:(NSUInteger)index keyModel:(CMKeyModel *)keyModel {
    [self hideSwitchView];
    if (index != NSNotFound) {
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(CMKeyboardViewDelegate)]) {
            [(id<CMKeyboardViewDelegate>)self.delegate onKeyboard:self selectedSwitchOptionIndex:index keyModel:keyModel];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
