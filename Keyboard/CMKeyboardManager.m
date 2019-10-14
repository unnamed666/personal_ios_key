//
//  CMKeyboardManager.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyboardManager.h"
#import "NSString+Common.h"
#import "CMKeyboardViewModel.h"
#import "CMError.h"
#import "CMCloudConfig.h"
#ifndef HostApp
#import "CMNgramContext.h"
#import "SuggestedWordInfo.h"
#import "CMBinaryDictionary.h"
#import "CMProximityInfo.h"
#import "InputPointers.h"
#import "CmposedData.h"
#import "KeyboardViewController.h"
#import "CMCloudPrediction.h"
#import "CMSuggestionViewModel.h"
#import "CMSuggest.h"
#import "CMInputLogic.h"
#import "CMSettingManager.h"
#endif
#import "CMCommUtil.h"
#import "CMKeyModel.h"
#import "CMKeyboardModel.h"
#import "CMKeyboardViewModel.h"
#import "CMRowModel.h"
#import "NSDictionary+Common.h"
#import "CMKeyboardModel.h"
#import "CMTextInputModel.h"
#import "UserDefaultsMacro.h"
#import "CMGeneralRowsModel.h"
#import "UIDevice+Util.h"
#import "CMThemeManager.h"

@interface CMKeyboardManager ()
//@property (nonatomic,strong) CMBinaryDictionary *bDic;
//@property (nonatomic,strong) CMProximityInfo *proximityInfo;

@property (nonatomic, strong)NSMutableArray* functionRowArray;

@property (nonatomic, strong)dispatch_queue_t keyboardLoadSerailQueue;

@property (nonatomic, strong)dispatch_queue_t keyboardConfigSerailQueue;

//
@property (nonatomic, assign)UIKeyboardType currentKeyType;

@property (nonatomic,strong) NSDictionary * keyCache;

@property (nonatomic, readwrite, assign) CMKeyboardLanguageType currentLanguageType;
@property (nonatomic, readwrite, copy) NSString* languageCode;

@property (nonatomic, readwrite, assign) CMKeyboardType currentLayoutType;
@property (nonatomic, readwrite, copy) NSArray<NSString *> *spaceKeyPopupCharacters;

@property (nonatomic, readwrite, strong)NSMutableArray *emojiImages;

// 重构
@property (nonatomic, strong)CMGeneralRowsModel* letterRowsModel; // 字母键盘的general行
@property (nonatomic, strong)CMGeneralRowsModel* numberRowsModel; // 数字键盘的general行
@property (nonatomic, strong)CMGeneralRowsModel* puncRowsModel; // 符号键盘的general行

@property (nonatomic, strong)dispatch_semaphore_t semaphore;
@property (nonatomic, strong)dispatch_block_t preCacheBlock;
@property (nonatomic, strong)dispatch_block_t loadLayoutBlock;

@end



@implementation CMKeyboardManager
DEF_SINGLETON(CMKeyboardManager)

- (instancetype)init {
    if (self = [super init]) {

#ifndef HostApp
        if ([UIDevice hasHapticFeedback] && IOS10_OR_LATER) {
            [self feedbackGenerator];
        }
        self.lastIsRecentlyEmojiSection = [[NSUserDefaults standardUserDefaults] boolForKey:kLastIsRecentlyEmojiSection];
#endif
    }
    return self;
}

- (void)initCloudConfigIfNeeded {
    dispatch_async(self.keyboardConfigSerailQueue, ^{
        [self.cloundConfig initCloudConfig:[CMAppConfig cloudProductName] pkg:[CMAppConfig bundleIdentifier] channelId:[CMAppConfig channelId] language:[CMAppConfig currentLanguage]];
    });
}

- (void)handleMemoryWarning {
    kLogTrace();
    
    [self.themeManager resetThemeCache];
    if (self.currentLayoutType == CMKeyboardTypeLetter) {
        self.numberRowsModel = nil;
        self.puncRowsModel = nil;
    }
    else if (self.currentLayoutType == CMKeyboardTypeNumber) {
        self.letterRowsModel = nil;
        self.puncRowsModel = nil;
    }
    else {
        self.letterRowsModel = nil;
        self.numberRowsModel = nil;
    }
#ifndef HostApp
    if (_inputLogic) {
        [_inputLogic handleMemoryWarning];
        _inputLogic = nil;
    }
#endif

}

- (void)cancelAllTasks {
    if (_preCacheBlock) {
        dispatch_block_cancel(self.preCacheBlock);
        _preCacheBlock = nil;
    }
    if (_loadLayoutBlock) {
        dispatch_block_cancel(self.loadLayoutBlock);
        _loadLayoutBlock = nil;
    }
}

- (void)preCacheKeyboardLayoutsByInputModel:(CMTextInputModel *)inputModel completionBlock:(loadKeyboardCompletionHandler)block {
    if (_preCacheBlock) {
        dispatch_block_cancel(self.preCacheBlock);
        _preCacheBlock = nil;
    }
    dispatch_block_t preCacheBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_UTILITY, -8, ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        __block CMError* localError;
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_enter(group);
        [self loadGeneralRowInQueue:concurrentQueue layoutType:CMKeyboardTypeLetter languageType:self.currentLanguageType competionBlock:^(CMGeneralRowsModel *generalRows, CMError *error) {
            localError = error;
            dispatch_group_leave(group);
        }];

        dispatch_group_enter(group);
        [self loadGeneralRowInQueue:concurrentQueue layoutType:CMKeyboardTypeNumber languageType:self.currentLanguageType competionBlock:^(CMGeneralRowsModel *generalRows, CMError *error) {
            localError = error;
            dispatch_group_leave(group);
        }];

        dispatch_group_enter(group);
        [self loadGeneralRowInQueue:concurrentQueue layoutType:CMKeyboardTypePunc languageType:self.currentLanguageType competionBlock:^(CMGeneralRowsModel *generalRows, CMError *error) {
            localError = error;
            dispatch_group_leave(group);
        }];

        if (inputModel) {
            dispatch_group_enter(group);
            [self loadFunctionRowInQueue:concurrentQueue languageType:self.currentLanguageType inputModel:inputModel completionBlock:^(CMRowModel *rowModel, CMError *error) {
                localError = error;
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (block) {
                block(nil, localError);
            }
            dispatch_semaphore_signal(self.semaphore);
        });
    });
    dispatch_async(self.keyboardLoadSerailQueue, preCacheBlock);
    self.preCacheBlock = preCacheBlock;
}

- (void)setupKeyCache:(NSDictionary*)dimDic{
    
    self.keyCache = dimDic[@"keyCache"];
}


//- (void)setupProximityInfo:(NSDictionary *)dimDic {
//#ifndef HostApp
//    if([self.proximityInfo isEqual:dimDic]){
//        return;
//    }
//    [self.proximityInfo close];
//    self.proximityInfo = [CMProximityInfo proximityInfo:dimDic];
//#endif
//}

- (ProximityInfoKey *)proximityInfo:(unichar )keyCode {
    if (self.keyCache == nil) {
        return nil;
    }
    return self.keyCache[@(keyCode)];
}


#pragma mark - setter/getter

- (NSMutableArray *)functionRowArray {
    if (!_functionRowArray) {
        _functionRowArray = [NSMutableArray new];
    }
    return _functionRowArray;
}
#ifndef HostApp
- (CMInputLogic *)inputLogic {
    if (!_inputLogic) {
        _inputLogic = [[CMInputLogic alloc] init];
    }
    _inputLogic.keyboardViewController = self.keyboardViewController;
    return _inputLogic;
}
#endif
- (CMRowModel *)rowModelWithInputModel:(CMTextInputModel *)inputModel languageType:(CMKeyboardLanguageType)languageType {
    __block CMRowModel* result;
    [self.functionRowArray enumerateObjectsUsingBlock:^(CMRowModel*  _Nonnull rowModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([rowModel.inputModel isEqualToModel:inputModel] && rowModel.languageType == languageType && rowModel.isMultiLanguage == self.multiLanguage) {
            result = rowModel;
            *stop = YES;
        }
    }];
    return result;
}

- (dispatch_queue_t)keyboardLoadSerailQueue {
    if (!_keyboardLoadSerailQueue) {
        _keyboardLoadSerailQueue = dispatch_queue_create("load_keyboard_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _keyboardLoadSerailQueue;
}

- (dispatch_queue_t)keyboardConfigSerailQueue {
    if (!_keyboardConfigSerailQueue) {
        _keyboardConfigSerailQueue = dispatch_queue_create("keyboard.config.serial.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _keyboardConfigSerailQueue;
}

- (void)loadGeneralRowBylayoutType:(CMKeyboardType)layoutType competionBlock:(loadGeneralRowCompletionBlock)block {
    [self loadGeneralRowInQueue:self.keyboardLoadSerailQueue layoutType:layoutType languageType:self.currentLanguageType competionBlock:block];
}

- (void)loadGeneralRowByInputModel:(CMTextInputModel *)inputModel competionBlock:(loadGeneralRowCompletionBlock)block {
    if (inputModel.keyboardType == UIKeyboardTypeNumbersAndPunctuation || inputModel.keyboardType == UIKeyboardTypeDecimalPad || inputModel.keyboardType == UIKeyboardTypeNumberPad) {
        [self loadGeneralRowBylayoutType:CMKeyboardTypeNumber competionBlock:block];
    }
    else {
        [self loadGeneralRowBylayoutType:CMKeyboardTypeLetter competionBlock:block];
    }
}

- (void)loadGeneralRowInQueue:(dispatch_queue_t)queue layoutType:(CMKeyboardType)layoutType languageType:(CMKeyboardLanguageType)languageType competionBlock:(loadGeneralRowCompletionBlock)block {
    if (layoutType == CMKeyboardTypeLetter && self.letterRowsModel && self.letterRowsModel.languageType == languageType) {
        kLogInfo(@"[LoadKeyboard]命中缓存，使用缓存letterRowsModel(languageType=%ld)", (long)self.letterRowsModel.languageType);
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self.letterRowsModel, nil);
            });
        }
    }
    else if (layoutType == CMKeyboardTypeNumber && self.numberRowsModel && self.numberRowsModel.languageType == languageType) {
        kLogInfo(@"[LoadKeyboard]命中缓存，使用缓存numberRowsModel(languageType=%ld)", (long)self.numberRowsModel.languageType);
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self.numberRowsModel, nil);
            });
        }
    }
    else if (layoutType == CMKeyboardTypePunc && self.puncRowsModel && self.puncRowsModel.languageType == languageType) {
        kLogInfo(@"[LoadKeyboard]命中缓存，使用缓存puncRowsModel(languageType=%ld)", (long)self.puncRowsModel.languageType);
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self.puncRowsModel, nil);
            });
        }
    }
    else {
        kLogInfo(@"[LoadKeyboard]未命中缓存，加载键盘类型(layoutType=%ld, languageType=%ld)", (long)layoutType, (long)languageType);
        dispatch_async(queue, ^{
            NSString *layoutName = nil;
            switch (layoutType) {
                case CMKeyboardTypeLetter:
                {
                    if (languageType == CMKeyboardLanguageTypeEnglishUnitedState) {
                        layoutName = @"keyboard_layout_standard_qwerty";
                    }else if (languageType == CMKeyboardLanguageTypeNorwegianBokmal) {
                        layoutName = @"keyboard_layout_standard_qwerty_norwegian_bokmal";
                    }else{
                        NSString *string = [[CMCommUtil keyboardLanguageTypeToLanguageString:languageType] lowercaseString];
                        layoutName = [NSString stringWithFormat:@"keyboard_layout_standard_qwerty_%@", string];
                    }
                }
                    break;
                case CMKeyboardTypeNumber:
                {
                    if (languageType == CMKeyboardLanguageTypeArabic ) {
                    layoutName = @"keyboard_layout_symbols_arabic";
                    }else {
                       layoutName = @"keyboard_layout_symbols";
                    }
                }
                    break;
                case CMKeyboardTypePunc:
                {
                    if (languageType == CMKeyboardLanguageTypeArabic ) {
                    layoutName = @"keyboard_layout_symbols_alt_arabic";
                    }else {
                    layoutName = @"keyboard_layout_symbols_alt";
                    }
                }
                    break;
                default:
                    break;
            }
            
            NSString* layoutPath = [[NSBundle mainBundle] pathForResource:layoutName ofType:@"plist"];
            if (![NSString stringIsEmpty:layoutPath]) {
                NSDictionary* layoutInfoDic = [NSDictionary dictionaryWithContentsOfFile:layoutPath];
                NSMutableArray* rowMutArray = [NSMutableArray array];
                __block NSString* layoutId;
                __block NSString* layoutKey;
                __block NSArray<NSString *>* spaceKeyPopupCharacters = nil;
                NSArray* rowInfoArray = [layoutInfoDic arrayValueForKey:@"rows"];
                [rowInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull rowInfoDic, NSUInteger rowIdx, BOOL * _Nonnull stop) {
                    NSArray* keyArray = [rowInfoDic arrayValueForKey:@"keys"];
                    if (keyArray && keyArray.count > 0) {
                        NSMutableArray* keyMutArray = [NSMutableArray array];
                        [keyArray enumerateObjectsUsingBlock:^(NSDictionary* _Nonnull keyInfoDic, NSUInteger keyIdx, BOOL * _Nonnull stop) {
                            CMKeyModel* keyModel = [CMKeyModel keyModelWithDictionary:keyInfoDic];
                            if (keyIdx == 0) {
                                keyModel.isLeftMost = YES;
                                keyModel.isRightMost = NO;
                            }
                            else if (keyIdx == keyArray.count - 1) {
                                keyModel.isLeftMost = NO;
                                keyModel.isRightMost = YES;
                            }
                            else {
                                keyModel.isLeftMost = NO;
                                keyModel.isRightMost = NO;
                            }
                            [keyMutArray addObject:keyModel];
                        }];
                        CMRowModel* rowModel = [CMRowModel rowModelWithArray:keyMutArray];
                        [rowMutArray addObject:rowModel];
                    }else{
                        NSDictionary* funRowInfo = [rowInfoDic dictionaryValueForKey:@"function_row"];
                        if (funRowInfo) {
                            layoutId = [funRowInfo stringValueForKey:@"layout_switching_id" defaultValue:@"symbols"];
                            layoutKey = [funRowInfo stringValueForKey:@"layout_switching_label" defaultValue:@"123"];
                            if ([funRowInfo objectForKey:@"spacekey_popup_characters"]) {
                                spaceKeyPopupCharacters = [funRowInfo arrayValueForKey:@"spacekey_popup_characters"];
                            }
                        }
                    }
                }];
                if (spaceKeyPopupCharacters) {
                    self.spaceKeyPopupCharacters = spaceKeyPopupCharacters;
                }
                CMGeneralRowsModel* generalRowsModel = [CMGeneralRowsModel modelWithRowArray:[rowMutArray copy] layoutKeyText:layoutKey layoutKeyNext:layoutId languageType:languageType];
                if (layoutType == CMKeyboardTypeLetter) {
                    self.letterRowsModel = generalRowsModel;
                }
                else if (layoutType == CMKeyboardTypeNumber) {
                    self.numberRowsModel = generalRowsModel;
                }
                else if (layoutType == CMKeyboardTypePunc) {
                    self.puncRowsModel = generalRowsModel;
                }
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(generalRowsModel, nil);
                    });
                }
            }
            else {
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, [CMError errorWithCode:CMErrorCodeLayoutNotFound errorMessage:[NSString stringWithFormat:@"布局文件(%@)NotFound", layoutPath]]);
                    });
                }
            }
        });
    }
}

- (void)loadFunctionRowInQueue:(dispatch_queue_t)queue languageType:(CMKeyboardLanguageType)languageType inputModel:(CMTextInputModel *)inputModel completionBlock:(loadFunctionRowCompletionBlock)block {
    CMRowModel* result = [self rowModelWithInputModel:inputModel languageType:languageType];
    if (result) {
        kLogInfo(@"[LoadKeyboard]命中缓存，使用缓存功能Row(%@)", inputModel);
        result.inputModel = inputModel;
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result, nil);
            });
        }
    }
    else {
        kLogInfo(@"[LoadKeyboard]未命中缓存，加载功能Row(%@)", inputModel);
        dispatch_async(queue, ^{
            // 功能键加载的布局文件
            NSString* funRowName = nil;
            NSString* funRowPath = nil;
            
            switch (inputModel.keyboardType) {
                case UIKeyboardTypeDefault:
                case UIKeyboardTypeASCIICapable:
                case UIKeyboardTypeNumbersAndPunctuation:
                case UIKeyboardTypeDecimalPad:
                case UIKeyboardTypeNumberPad:
                    funRowName = @"function_row_default";
                    break;
                case UIKeyboardTypeURL:
                    funRowName = @"function_row_url";
                    break;
                case UIKeyboardTypeEmailAddress:
                    funRowName = @"function_row_email";
                    break;
                case UIKeyboardTypeTwitter:
                    funRowName = @"function_row_twitter";
                    break;
                case UIKeyboardTypeWebSearch:
                    funRowName = @"function_row_search";
                    break;
                default:
                    funRowName = @"function_row_default";
                    break;
            }
            funRowName = self.multiLanguage ? [funRowName stringByAppendingString:@"_multi_language"] : funRowName;
            funRowPath = [[NSBundle mainBundle] pathForResource:funRowName ofType:@"plist"];
            if (![NSString stringIsEmpty:funRowPath]) {
                NSDictionary* rowInfoDic = [NSDictionary dictionaryWithContentsOfFile:funRowPath];
                
                NSArray* keyArray = [rowInfoDic arrayValueForKey:@"keys"];
                NSMutableArray* funcRow = [NSMutableArray array];
                [keyArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull keyInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    CMKeyModel* keyModel = [CMKeyModel keyModelWithDictionary:keyInfoDic];
                    if (keyModel.keyType == CMKeyTypeReturn) {
                        keyModel.returnType = inputModel.returnKeyType;
                    }else if (keyModel.keyType == CMKeyTypeMultiLanguage) {
                        keyModel.key = [[CMCommUtil keyboardLanguageTypeToLang:languageType] uppercaseString];
                    }else if (keyModel.keyType == CMKeyTypeSpace) {
                        keyModel.key = [CMCommUtil keyboardLanguageTypeToLocaleLanguageStr:languageType];
                    }
                    if (idx == 0) {
                        keyModel.isLeftMost = YES;
                        keyModel.isRightMost = NO;
                    }
                    else if (idx == keyArray.count - 1) {
                        keyModel.isLeftMost = NO;
                        keyModel.isRightMost = YES;
                    }
                    else {
                        keyModel.isLeftMost = NO;
                        keyModel.isRightMost = NO;
                    }
                    [funcRow addObject:keyModel];
                }];
                CMRowModel* rowModel = [CMRowModel rowModelWithArray:funcRow];
                rowModel.inputModel = inputModel;
                rowModel.languageType = languageType;
                rowModel.isMultiLanguage = self.multiLanguage;
                if (rowModel && ![self rowModelWithInputModel:inputModel languageType:languageType]) {
                    [self.functionRowArray addObject:rowModel];
                }
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(rowModel, nil);
                    });
                }
            }
            else {
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil);
                    });
                }
            }
        });
    }
}

- (void)loadKeyboardByLayoutType:(CMKeyboardType)layoutType inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler {
    [self loadKeyboardByLayoutType:layoutType languageType:self.currentLanguageType inputModel:inputModel completionHandler:handler];
}

- (void)loadKeyboardToNextLanguage:(CMKeyboardLanguageType)languageType inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler {
    [self loadKeyboardByLayoutType:self.currentLayoutType languageType:languageType inputModel:inputModel completionHandler:handler];
}

- (void)loadKeyboardByLayoutId:(NSString *)layoutId inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler {
    CMKeyboardType type = CMKeyboardTypeLetter;
    if ([layoutId isEqualToString:@"symbols"]) {
        type = CMKeyboardTypeNumber;
    }
    else if ([layoutId isEqualToString:@"symbols_alt"]) {
        type = CMKeyboardTypePunc;
    }
    [self loadKeyboardByLayoutType:type inputModel:inputModel completionHandler:handler];
}

- (void)loadKeyboardByLayoutType:(CMKeyboardType)layoutType languageType:(CMKeyboardLanguageType)languageType inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler {
    if (_loadLayoutBlock) {
        dispatch_block_cancel(self.loadLayoutBlock);
        _loadLayoutBlock = nil;
    }

    dispatch_block_t loadLayoutBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_UTILITY, -8, ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        __block CMGeneralRowsModel* generalRowsModel;
        __block CMRowModel* funcModel;
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_enter(group);
        [self loadGeneralRowInQueue:concurrentQueue layoutType:layoutType languageType:languageType competionBlock:^(CMGeneralRowsModel *generalRows, CMError *error) {
            if (!error) {
                generalRowsModel = generalRows;
            }
            dispatch_group_leave(group);
        }];

        dispatch_group_enter(group);
        [self loadFunctionRowInQueue:concurrentQueue languageType:languageType inputModel:inputModel completionBlock:^(CMRowModel *rowModel, CMError *error) {
            if (!error) {
                funcModel = rowModel;
            }
            dispatch_group_leave(group);
        }];

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (!generalRowsModel || !funcModel) {
                if (handler) {
                    handler(nil, [CMError errorWithCode:CMErrorCodeLayoutNotFound errorMessage:@"load layout failed"]);
                }
            }
            else {
                CMKeyboardModel* keyboardModel = [CMKeyboardModel modelWithGeneralRowsModel:generalRowsModel funcRowModel:funcModel];
                if (keyboardModel) {
                    self.currentLayoutType = layoutType;
                    self.currentLanguageType = languageType;
                    keyboardModel.keyboardType = layoutType;
                    keyboardModel.inputModel = inputModel;
                    keyboardModel.languageType = languageType;
                    CMKeyboardViewModel* viewModel = [CMKeyboardViewModel viewModelWithModel:keyboardModel];
                    if (handler) {
                        handler(viewModel, nil);
                    }
                }
                else {
                    if (handler) {
                        handler(nil, [CMError errorWithCode:CMErrorCodeLayoutNotFound errorMessage:@"load layout failed"]);
                    }
                }
            }
            dispatch_semaphore_signal(self.semaphore);
        });
    });
    dispatch_async(self.keyboardLoadSerailQueue, loadLayoutBlock);
    self.loadLayoutBlock = loadLayoutBlock;
}


#pragma mark - setter/getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}

- (UIImpactFeedbackGenerator *)feedbackGenerator {
    if (!_feedbackGenerator) {
        _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [_feedbackGenerator prepare];
    }
    else {
        [_feedbackGenerator prepare];
    }
    return _feedbackGenerator;
}

- (NSMutableArray *)emojiImages
{
    if (!_emojiImages) {
        _emojiImages = [NSMutableArray new];
    }
    return _emojiImages;
}

- (CMThemeManager *)themeManager {
    if (!_themeManager) {
        _themeManager = [CMThemeManager new];
    }
    return _themeManager;
}

#ifndef HostApp
- (CMCloudPrediction *)cloudManager {
    if (!_cloudManager) {
        _cloudManager = [CMCloudPrediction new];
    }
    return _cloudManager;
}
#endif
- (CMCloudConfig *)cloundConfig {
    if (!_cloundConfig) {
        _cloundConfig = [CMCloudConfig new];
    }
    return _cloundConfig;
}
- (BOOL)multiLanguage {
    #ifndef HostApp
    return kCMSettingManager.languages.count > 1 ? YES : NO;
    #endif
    return NO;
}

#ifndef HostApp
- (void)setCurrentLanguageType:(CMKeyboardLanguageType)currentLanguageType
{
    kCMSettingManager.languageType = currentLanguageType;
}

- (CMKeyboardLanguageType)currentLanguageType {
    return kCMSettingManager.languageType;
}
#endif

- (void)setLastIsRecentlyEmojiSection:(BOOL)lastIsRecentlyEmojiSection
{
    _lastIsRecentlyEmojiSection = lastIsRecentlyEmojiSection;
    
#ifndef HostApp
    [[NSUserDefaults standardUserDefaults] setBool:_lastIsRecentlyEmojiSection forKey:kLastIsRecentlyEmojiSection];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

- (int)emoji_emoticon_index{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:kEmojiEmoticonIndex];
}
- (void)setEmoji_emoticon_index:(int)emoji_emoticon_index{

#ifndef HostApp
    [[NSUserDefaults standardUserDefaults] setInteger:emoji_emoticon_index forKey:kEmojiEmoticonIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}


#pragma mark - Keyboard Width And Height
- (CGFloat)getRealWidthByRatio:(CGFloat)ratio {
    CGFloat viewWidth = self.themeManager.keyboardViewControllerWidth == 0 ? [CMBizHelper adapterScreenWidth] : self.themeManager.keyboardViewControllerWidth;
    return ceil(ratio * viewWidth);
}

+ (CGFloat)keyboardHeight
{
    CGFloat ratio = [UIDevice currentDevice].isScreenPortrait ? ([UIDevice isIpad] ? 0.2463f : 0.333f) : ([UIDevice isIpad] ? 0.442f : 0.44f);
    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight568]) {
            ratio = 0.3762;
        }
        else if ([UIDevice isHeight667]) {
            ratio = 0.3234;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.2383;
        }
        else if ([UIDevice isHeight1024]) {
            ratio = 0.2547;
        }
        else if ([UIDevice isHeight736]) {
            ratio = 0.3070;
        }
        else if ([UIDevice isHeight812]) {
            ratio = 0.2645;
        }
    }
    else {
        if ([UIDevice isHeight568]) {
            ratio = 0.514f;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.407f;
        }

    }
    return ceil(ratio * [CMBizHelper adapterScreenHeight]);
}

+ (CGFloat)keyMargin {
    CGFloat viewWidth = kCMKeyboardManager.themeManager.keyboardViewControllerWidth == 0 ? [UIScreen mainScreen].bounds.size.width : kCMKeyboardManager.themeManager.keyboardViewControllerWidth;
    
    CGFloat ratio = 0.007f;
    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight568]) {
            ratio = 0.005f;
        }
    }
    else {
        if ([UIDevice isHeight568]) {
            ratio = 0.005f;
        }
    }
    return ceil(ratio * viewWidth);
}

+ (CGFloat)rowTopPadding {
    CGFloat ratio = [UIDevice currentDevice].isScreenPortrait ? ([UIDevice isIpad] ? 0.01f : 0.008f) : ([UIDevice isIpad] ? 0.0195f : 0.015f);

    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight1366]) {
            ratio = 0.0015f;
        }
    }
    else {
        if ([UIDevice isHeight1366]) {
            ratio = 0.015f;
        }
    }
    return ceil(ratio * [UIScreen mainScreen].bounds.size.height);
}

+ (CGFloat)rowBottomPadding {
    CGFloat ratio = [[UIDevice currentDevice] isScreenPortrait] ? ([UIDevice isIpad] ? 0.01f : 0.005f) : ([UIDevice isIpad] ? 0.0149f : 0.0186f);
    
    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight1366]) {
            ratio = 0.0015f;
        }
    }
    else {
        if ([UIDevice isHeight1366]) {
            ratio = 0.0186f;
        }
    }
    return ceil(ratio *  [UIScreen mainScreen].bounds.size.height);
}

+ (CGFloat)toolbarHeight {
    CGFloat ratio = [UIDevice currentDevice].isScreenPortrait ? ([UIDevice isIpad] ? 0.0586f : 0.0625f) : ([UIDevice isIpad] ? 0.0794f : 0.096f);
    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight568]) {
            ratio = 0.067;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.038;
        }
        else if ([UIDevice isHeight1024]) {
            ratio = 0.051;
        }
        else if ([UIDevice isHeight736]) {
            ratio = 0.061;
        }
        else if ([UIDevice isHeight667]) {
            ratio = 0.063;
        }
        else if ([UIDevice isHeight812]) {
            ratio = 0.052;
        }
    }
    else {
        if ([UIDevice isHeight1366]) {
            ratio = 0.052;
        }
    }
    return ceil(ratio * [CMBizHelper adapterScreenHeight]);
}

+ (CGFloat)keyHeight {
    CGFloat ratio = [UIDevice currentDevice].isScreenPortrait ? ([UIDevice isIpad] ? 0.041f : 0.068f) : ([UIDevice isIpad] ? 0.0722f : 0.084f);
    if ([UIDevice currentDevice].isScreenPortrait) {
        if ([UIDevice isHeight568]) {
            ratio = 0.0687 * 1.1026;
        }
        else if ([UIDevice isHeight1024]) {
            ratio = 0.0553;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.0555;
        }
        else if ([UIDevice isHeight736]) {
            ratio = 0.0625;
        }
        else if ([UIDevice isHeight667]) {
            ratio = 0.0649;
        }
        else if ([UIDevice isHeight812]) {
            ratio = 0.0528;
        }
    }
    else {
        if ([UIDevice isHeight568]) {
            ratio = 0.0687 * 1.1026;
        }
        else if ([UIDevice isHeight1366]) {
            ratio = 0.0687 * 1.1026;
        }
    }
    return ceil(ratio * [CMBizHelper adapterScreenHeight]);
}

+ (CGFloat)keyBoardTipStackHeight{
    return KScalePt(40);
}


- (BOOL)isDefaultTheme{
    return [self.themeManager.currentThemeName isEqualToString:@"default"];
}
@end
