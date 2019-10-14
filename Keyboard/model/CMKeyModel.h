//
//  CMKeyModel.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMKeyboardModel;
/*
 public static final int SPACE = 32;
 public static final int ENTER = 10;
 public static final int TAB = 9;
 public static final int ESCAPE = 27;
 public static final int DELETE = -5;
 public static final int DELETE_WORD = -7;
 public static final int QUICK_TEXT = -10;
 public static final int QUICK_TEXT_POPUP = -102;
 public static final int DOMAIN = -9;
 public static final int SHIFT = -1;
 public static final int ALT = -6;
 public static final int CTRL = -11;
 public static final int SHIFT_LOCK = -14;
 public static final int CTRL_LOCK = -15;
 public static final int MODE_SYMOBLS = -2;
 public static final int MODE_ALPHABET = -99;
 public static final int MODE_ALPHABET_POPUP = -98;
 public static final int KEYBOARD_CYCLE = -97;
 public static final int KEYBOARD_REVERSE_CYCLE = -96;
 public static final int KEYBOARD_CYCLE_INSIDE_MODE = -95;
 public static final int KEYBOARD_MODE_CHANGE = -94;
 public static final int ARROW_LEFT = -20;
 public static final int ARROW_RIGHT = -21;
 public static final int ARROW_UP = -22;
 public static final int ARROW_DOWN = -23;
 public static final int MOVE_HOME = -24;
 public static final int MOVE_END = -25;
 public static final int SETTINGS = -100;
 public static final int CANCEL = -3;
 public static final int CLEAR_INPUT = -13;
 public static final int VOICE_INPUT = -4;
 public static final int DISABLED = 0;
 public static final int SPLIT_LAYOUT = -110;
 public static final int MERGE_LAYOUT = -111;
 public static final int COMPACT_LAYOUT_TO_LEFT = -112;
 public static final int COMPACT_LAYOUT_TO_RIGHT = -113;
 public static final int UTILITY_KEYBOARD = -120;
 public static final int CLIPBOARD_COPY = -130;
 public static final int CLIPBOARD_CUT = -131;
 public static final int CLIPBOARD_PASTE = -132;
 public static final int CLIPBOARD_PASTE_POPUP = -133;
 public static final int CLIPBOARD_SELECT = -134;
 public static final int CLIPBOARD_SELECT_ALL = -135;
 */

typedef NS_ENUM(NSUInteger, CMKeyType) {
    CMKeyTypeLetter = 1,
    CMKeyTypeShift = 2,
    CMKeyTypeDel = 3,
    CMKeyTypeAlt = 4,
    CMKeyTypeEmoji = 5,
    CMKeyTypeSpace = 6,
    CMKeyTypeSymbol = 7,
    CMKeyTypeReturn = 8,
    CMKeyTypeLayoutSwitch = 9,
    CMKeyTypeSwitchKeyboard = 10,
    CMKeyTypePunctuationSlider = 11,
    CMKeyTypeMultiLanguage = 12
};


@interface CMKeyModel : NSObject
@property (nonatomic, copy)NSString* keyId;
@property (nonatomic, copy)NSString* keyCode;

@property (nonatomic, assign)int mShifteCode; // 兼容代码
@property (nonatomic, assign)int mCode; // 兼容代码

@property (nonatomic, assign)NSUInteger row;
@property (nonatomic, assign)NSUInteger column;
@property (nonatomic, copy)NSString* key;
@property (nonatomic, copy)NSString* topKeys;



@property (nonatomic, copy)NSString* shiftedKey;
@property (nonatomic, assign)CMKeyType keyType;
@property (nonatomic, assign)UIReturnKeyType returnType;

@property (nonatomic, assign)BOOL isFuncationnal;


@property (nonatomic, copy)NSArray* inputOptionArray;
@property (nonatomic, assign)NSInteger inputOptionDefaultSelected;
@property (nonatomic, assign)BOOL isLeftMost;
@property (nonatomic, assign)BOOL isRightMost;
@property (nonatomic, assign)CGFloat leftPadding;
@property (nonatomic, assign)CGFloat leftPaddingiPad;
@property (nonatomic, assign)CGFloat rightPadding;
@property (nonatomic, assign)CGFloat rightPaddingiPad;
@property (nonatomic, assign)CGFloat keyWidthRatio;


@property (nonatomic, copy)NSString* layoutId;


@property (nonatomic,weak) CMKeyboardModel * parent;

- (instancetype)initEmojiWithKey:(NSString*)key;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)keyModelWithDictionary:(NSDictionary *)dic;

- (instancetype)initWithJsonString:(NSString *)jsonStr;

+ (instancetype)keyModelWithJsonString:(NSString *)jsonStr;

- (BOOL)shouldShowKey;

- (BOOL)shouldUseBatchInput;

- (BOOL)shouldUseFixedBgImageKey;

- (BOOL)shouldInsetBgImageKey;

- (BOOL)shouldShowShiftedKey;

// 按键按下时响应事件
- (BOOL)shouldUseTouchDownEvent;

// 按键在内部抬起时响应事件
- (BOOL)shouldUseTouchUnInsideEvent;

- (BOOL)shouldDoubleTapKey;

- (BOOL)shouldLongPressKey;

- (BOOL)shouldShowPreView;

- (BOOL)shouldShowInputOptionsView;

- (BOOL)shouldShowSwitchView;

- (BOOL)shouldUseFunctionalKeyTextFont;

- (BOOL)shouldUseFunctionalBackground;

- (BOOL)shouldUseLetterKeyBackground;


@end
