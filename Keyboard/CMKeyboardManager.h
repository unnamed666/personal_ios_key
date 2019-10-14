//
//  CMKeyboardManager.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#import "CMKeyboardModel.h"
#import "CMBizHelper.h"

@class CMKeyboardViewModel;
@class CMSuggestionViewModel;
@class CMError;
@class ProximityInfoKey;
@class CMProximityInfo;
@class CMTextInputModel;

@class CMGeneralRowsModel;
@class CMThemeManager;
@class CMCloudPrediction;
@class CMInputLogic;
@class KeyboardViewController;
@class CMCloudConfig;

typedef NS_ENUM(NSInteger, CMScreenOrientation) {
    CMScreenOrientationUnspecified,
    CMScreenOrientationPortrait,
    CMScreenOrientationLandscape,
};

typedef void(^loadKeyboardCompletionHandler)(CMKeyboardViewModel* viewModel, CMError* error);

typedef void(^loadFunctionRowCompletionBlock)(CMRowModel* rowModel, CMError* error);

typedef void(^loadGeneralRowCompletionBlock)(CMGeneralRowsModel* generalRows, CMError* error);


#define kCMKeyboardManager [CMKeyboardManager sharedInstance]

@interface CMKeyboardManager : NSObject
AS_SINGLETON(CMKeyboardManager)
@property (nonatomic, readonly, strong)NSMutableArray* keyboardArray;
@property (nonatomic, readonly, strong)NSMutableArray* functionRowArray;

//@property (nonatomic, readonly, strong)CMProximityInfo *proximityInfo;

@property (nonatomic, readonly, assign) CMKeyboardLanguageType currentLanguageType;
@property (nonatomic, readonly, copy) NSString* languageCode;
@property (nonatomic, readonly, assign) BOOL multiLanguage;
@property (nonatomic, readonly, copy) NSArray<NSString *> *spaceKeyPopupCharacters;

@property (nonatomic, readwrite, assign) CMKeyboardType keyboardType;

@property (nonatomic, assign) BOOL needKeyboardExpandAnimation;// 是否需要键盘展开的动画

@property (nonatomic, assign) BOOL lastIsRecentlyEmojiSection;// 上次退出emoji时 是不是在最近使用Section里
@property (nonatomic, assign) int  emoji_emoticon_index;//退出 emoji 界面时时在哪个面板里

// 单例管理
@property (nonatomic, strong)CMThemeManager* themeManager;
@property (nonatomic, strong)CMCloudPrediction* cloudManager;
@property (nonatomic, strong)CMInputLogic* inputLogic;
@property (nonatomic, strong)CMCloudConfig* cloundConfig;

@property (nonatomic, weak)KeyboardViewController* keyboardViewController;

@property (nonatomic, assign)BOOL isFullAccessAllowed;

//
@property (nonatomic, strong)UIImpactFeedbackGenerator* feedbackGenerator;

// emoji images
@property (nonatomic, readonly, strong)NSMutableArray *emojiImages;

- (void)initCloudConfigIfNeeded;

- (void)handleMemoryWarning;

- (void)cancelAllTasks;

- (void)preCacheKeyboardLayoutsByInputModel:(CMTextInputModel *)inputModel completionBlock:(loadKeyboardCompletionHandler)block;

- (void)loadKeyboardByLayoutType:(CMKeyboardType)layoutType inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler;

- (void)loadKeyboardToNextLanguage:(CMKeyboardLanguageType)languageType inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler;

- (void)loadKeyboardByLayoutId:(NSString *)layoutId inputModel:(CMTextInputModel *)inputModel completionHandler:(loadKeyboardCompletionHandler)handler;

- (void)setupKeyCache:(NSDictionary*)dimDic;
//- (void)setupProximityInfo:(NSDictionary *)dimDic;

- (ProximityInfoKey *)proximityInfo:(unichar )key;

// 重构
- (void)loadGeneralRowBylayoutType:(CMKeyboardType)layoutType competionBlock:(loadGeneralRowCompletionBlock)block;


- (CGFloat)getRealWidthByRatio:(CGFloat)ratio;

+ (CGFloat)keyboardHeight;
+ (CGFloat)toolbarHeight;
+ (CGFloat)keyHeight;
+ (CGFloat)keyMargin;
+ (CGFloat)rowTopPadding;
+ (CGFloat)rowBottomPadding;

+ (CGFloat)keyBoardTipStackHeight; //ljd tip高度

- (BOOL)isDefaultTheme;
// 魔方云控
@end
