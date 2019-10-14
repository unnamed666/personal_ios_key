//
//  CMKeyModel.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMKeyModel.h"
#import "NSDictionary+Common.h"
#import "NSString+Common.h"
#import "Constants.h"
#import "CMStringUtils.h"
#import "Character.h"
#import "CMKeyboardModel.h"
#import "CMKeyboardManager.h"
#import "CMCommUtil.h"
#import "CMGroupDataManager.h"


@interface CMKeyModel () <NSCopying>

@end

@implementation CMKeyModel

- (id)copyWithZone:(NSZone *)zone {
    CMKeyModel* model = [[[self class] allocWithZone:zone] init];
    model.keyType = _keyType;
    model.key = [_key copy];
    model.shiftedKey = [_shiftedKey copy];
    model.keyWidthRatio = _keyWidthRatio;
    model.leftPadding = _leftPadding;
    model.leftPaddingiPad = _leftPaddingiPad;
    model.rightPadding = _rightPadding;
    model.inputOptionArray = [_inputOptionArray copy];
    model.topKeys = [_topKeys copy];
    model.layoutId = [_layoutId copy];
    model.mCode = _mCode;
    model.isFuncationnal = _isFuncationnal;
    return model;
}

- (instancetype)initEmojiWithKey:(NSString*)key
{
    self = [super init];
    if (self) {
        _keyType = CMKeyTypeEmoji;
        _shiftedKey = _key = key;
        _mCode = _mShifteCode = [Character codePointAt:_key index:0];
        _isFuncationnal = NO;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        // TODO 增加语言支持，要增加对应的货币符号
        // new
        _keyType = [CMKeyModel p_parseKeyType:[dic stringValueForKey:@"type" defaultValue:@"character"]];
        _key = [dic stringValueForKey:@"character" defaultValue:@""];
        
        CMKeyboardLanguageType languageType = [CMKeyboardManager sharedInstance].currentLanguageType;
        if ([_key isEqualToString:@"$"]) {
            switch (languageType) {
                case CMKeyboardLanguageTypeIndonesian:
                    _key = @"￥";
                    break;
                case CMKeyboardLanguageTypeCzech:
                case CMKeyboardLanguageTypeGerman:
                case CMKeyboardLanguageTypeFinnish:
                case CMKeyboardLanguageTypeCroatian:
                case CMKeyboardLanguageTypeHungarian:
                case CMKeyboardLanguageTypeCatalan:
                    _key = @"€";
                    break;
//                case CMKeyboardLanguageTypeDanish:
//                case CMKeyboardLanguageTypeSwedish:
//                    _key = @"Kr";
//                    break;
                case CMKeyboardLanguageTypeFilipino:
                    _key = @"₱";
                    break;
                case CMKeyboardLanguageTypeTurkish:
                    _key = @"₺";
                    break;
                case CMKeyboardLanguageTypeRussian:
                case CMKeyboardLanguageTypeBelarusian:
                case CMKeyboardLanguageTypeUkrainian:
                {
                    _key = @"₽";
                }
                default:
                    break;
            }
        }else if ([_key isEqualToString:@"€"]) {
            switch (languageType) {
                case CMKeyboardLanguageTypeIndonesian:
                case CMKeyboardLanguageTypeCzech:
                case CMKeyboardLanguageTypeGerman:
                case CMKeyboardLanguageTypeFinnish:
                case CMKeyboardLanguageTypeCroatian:
                case CMKeyboardLanguageTypeFilipino:
                case CMKeyboardLanguageTypeHungarian:
                case CMKeyboardLanguageTypeCatalan:
                    _key = @"$";
                    break;
                    
                default:
                    break;
            }
            
        }else if ([_key isEqualToString:@"£"]) {
            switch (languageType) {
                case CMKeyboardLanguageTypeIndonesian:
                    _key = @"€";
                    break;
                case CMKeyboardLanguageTypeDanish:
                case CMKeyboardLanguageTypeTurkish:
                case CMKeyboardLanguageTypeSwedish:
                    _key = @"$";
                    break;
                    
                default:
                    break;
            }
            
        }else if ([_key isEqualToString:@"¥"]) {
            switch (languageType) {
                case CMKeyboardLanguageTypeIndonesian:
                case CMKeyboardLanguageTypeDanish:
                case CMKeyboardLanguageTypeTurkish:
                case CMKeyboardLanguageTypeSwedish:
                    _key = @"£";
                    break;
                    
                default:
                    break;
            }
        }
        
        _shiftedKey = [dic stringValueForKey:@"shiftedKey" defaultValue:@""];
        _keyWidthRatio = [dic floatValueForKey:@"weight_x" defaultValue:0.1];
        _leftPadding = [dic floatValueForKey:@"margin_left" defaultValue:0.0];
        _leftPaddingiPad = [dic floatValueForKey:@"margin_left_iPad" defaultValue:0.0];
        _rightPadding = [dic floatValueForKey:@"margin_right" defaultValue:0.0];
        _rightPaddingiPad = [dic floatValueForKey:@"margin_right_iPad" defaultValue:0.0];
        _inputOptionArray = [[dic arrayValueForKey:@"popup_characters"] copy];
        _topKeys = [dic stringValueForKey:@"top_text" defaultValue:@""];
        if (![NSString stringIsEmpty:_topKeys]) {
            [_inputOptionArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([key isEqualToString:_topKeys]) {
                    _inputOptionDefaultSelected = idx;
                    *stop = YES;
                }
            }];
        }
        NSInteger index = [dic integerValueForKey:@"popup_default_selected" defaultValue:0];
        if (index != 0) {
            _inputOptionDefaultSelected = index;
        }

        _layoutId = [dic stringValueForKey:@"layout_id" defaultValue:@"symbols_alt"];
        _isFuncationnal = [dic boolValueForKey:@"functionnal" defaultValue:NO];
        
        if ([NSString stringIsEmpty:_key]) {
            _key = [dic stringValueForKey:@"label" defaultValue:@""];
        }
        
        if (_keyType == CMKeyTypeLetter) {
            if(_key.length>0){
                _mCode = [_key characterAtIndex:0];
            }
            if(_shiftedKey.length>0){
                _mShifteCode = [_shiftedKey characterAtIndex:0];
            }
        }else if(_keyType == CMKeyTypeSpace){
            _mShifteCode = _mCode = [CMKeyModel p_parseKeyCode:_keyType];
            _key = _shiftedKey = STRING_SPACE;
        } else {
            _mShifteCode = _mCode = [CMKeyModel p_parseKeyCode:_keyType];
            if(_mCode == 0 && _key.length>0){
               _mShifteCode = _mCode = [_key characterAtIndex:0];
            }
        }
    }
    return self;
}

+ (instancetype)keyModelWithDictionary:(NSDictionary *)dic {
    CMKeyModel* model = [[CMKeyModel alloc] initWithDictionary:dic];
    return model;
}

- (instancetype)initWithJsonString:(NSString *)jsonStr {
    NSError *error = nil;
    id dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSAssert(error == nil && dic != nil && [dic isKindOfClass:[NSDictionary class]], @"initWithJsonString error");
    return [self initWithDictionary:(NSDictionary *)dic];
}

+ (instancetype)keyModelWithJsonString:(NSString *)jsonStr {
    CMKeyModel* model = [[CMKeyModel alloc] initWithJsonString:jsonStr];
    return model;
}

+ (CMKeyType)p_parseKeyType:(NSString *)style {
    if([style isEqualToString:@"character"]){
        return CMKeyTypeLetter;
    }else if([style isEqualToString:@"shift"]){
        return CMKeyTypeShift;
    }else if([style isEqualToString:@"delete"]){
        return CMKeyTypeDel;
    }else if([style isEqualToString:@"alt"]){
        return CMKeyTypeAlt;
    }else if([style isEqualToString:@"emoji"]){
        return CMKeyTypeEmoji;
    }else if([style isEqualToString:@"space"]){
        return CMKeyTypeSpace;
    }else if([style isEqualToString:@"symbol"]){
        return CMKeyTypeSymbol;
    }else if([style isEqualToString:@"return"]){
        return CMKeyTypeReturn;
    }else if([style isEqualToString:@"layout_switching"]){
        return CMKeyTypeLayoutSwitch;
    }else if([style isEqualToString:@"keyboard_switcher"]){
        return CMKeyTypeSwitchKeyboard;
    }else if([style isEqualToString:@"punctuation_slider"]){
        return CMKeyTypePunctuationSlider;
    }else if ([style isEqualToString:@"multi_language_switcher"]) {
        return CMKeyTypeMultiLanguage;
    }
    
    return CMKeyTypeLetter;
}

+ (int)p_parseKeyCode:(CMKeyType)type {
    int code = 0;
    switch (type) {
        case CMKeyTypeDel:
            code = CODE_DELETE;
            break;
        case CMKeyTypeShift:
            code = CODE_SHIFT;
            break;
        case CMKeyTypeLayoutSwitch:
            code = CODE_SWITCH_ALPHA_SYMBOL;
            break;
        case CMKeyTypeSpace:
            code = CODE_SPACE;
            break;
        case CMKeyTypeEmoji:
            code = CODE_EMOJI;
            break;
        case CMKeyTypeReturn:
            code = CODE_ENTER;
            break;
        case CMKeyTypeMultiLanguage:
            code = CODE_LANGUAGE_SWITCH;
            break;
        default:
            break;
    }
    
    return code;
}


- (BOOL)shouldShowKey {
    return self.keyType == CMKeyTypeLetter
    || self.keyType == CMKeyTypePunctuationSlider
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeLayoutSwitch
    || self.keyType == CMKeyTypeSpace
//    || self.keyType == CMKeyTypeEmoji
    || self.keyType == CMKeyTypeMultiLanguage;
}

- (BOOL)shouldUseBatchInput {
    return self.keyType == CMKeyTypeLetter;
}

- (BOOL)shouldUseFixedBgImageKey {
    return self.keyType == CMKeyTypeLetter
    || self.keyType == CMKeyTypePunctuationSlider
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeLayoutSwitch
    || self.keyType == CMKeyTypeEmoji
    || self.keyType == CMKeyTypeMultiLanguage;
}

- (BOOL)shouldInsetBgImageKey {
    return self.keyType == CMKeyTypeShift
    || self.keyType == CMKeyTypeDel
    || self.keyType == CMKeyTypeReturn;
}

- (BOOL)shouldShowShiftedKey {
    return self.keyType == CMKeyTypeLetter;
}

// 按键按下时响应事件
- (BOOL)shouldUseTouchDownEvent {
    return self.keyType == CMKeyTypeShift
    || self.keyType == CMKeyTypeSymbol
    || self.keyType == CMKeyTypeDel
    || self.keyType == CMKeyTypePunctuationSlider
    || self.keyType == CMKeyTypeEmoji;
}

// 按键在内部抬起时响应事件
- (BOOL)shouldUseTouchUnInsideEvent {
    return self.keyType == CMKeyTypeReturn
    || self.keyType == CMKeyTypeSpace
    || self.keyType == CMKeyTypeLetter
    || self.keyType == CMKeyTypeLayoutSwitch
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeMultiLanguage;
}


- (BOOL)shouldDoubleTapKey {
    return NO;
//    return self.keyType == CMKeyTypeShift;
//    || self.keyType == CMKeyTypeSpace;
}

- (BOOL)shouldLongPressKey {
    BOOL hasInputOptions = self.inputOptionArray != nil && self.inputOptionArray.count > 0;
    return (self.keyType == CMKeyTypeLetter && hasInputOptions)
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeSpace
    || (self.keyType == CMKeyTypePunctuationSlider && hasInputOptions);
}

- (BOOL)shouldShowPreView {
    return self.keyType == CMKeyTypeLetter
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeEmoji
    || self.keyType == CMKeyTypePunctuationSlider;
}

- (BOOL)shouldShowInputOptionsView {
    BOOL hasInputOptions = self.inputOptionArray != nil && self.inputOptionArray.count > 0;
    return (self.keyType == CMKeyTypeLetter && hasInputOptions)
//    || self.keyType == CMKeyTypeSwitchKeyboard // 与shouldShowSwitchView互斥
    || (self.keyType == CMKeyTypeSpace)
    || (self.keyType == CMKeyTypePunctuationSlider && hasInputOptions);
}

- (BOOL)shouldUseFunctionalKeyTextFont {
    return self.keyType == CMKeyTypeDel
    || self.keyType == CMKeyTypeShift
    || self.keyType == CMKeyTypeReturn
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeMultiLanguage
    || self.keyType == CMKeyTypeSymbol
    || self.keyType == CMKeyTypeLayoutSwitch
    || self.keyType == CMKeyTypePunctuationSlider
    || (self.keyType == CMKeyTypeLetter && self.isFuncationnal);
}

- (BOOL)shouldShowSwitchView {
    return self.keyType == CMKeyTypeSwitchKeyboard;
}

- (BOOL)shouldUseFunctionalBackground {
    return self.keyType == CMKeyTypeDel
    || self.keyType == CMKeyTypeShift
    || self.keyType == CMKeyTypeReturn
    || self.keyType == CMKeyTypeSwitchKeyboard
    || self.keyType == CMKeyTypeMultiLanguage
    || self.keyType == CMKeyTypeSymbol
    || self.keyType == CMKeyTypeLayoutSwitch
    || self.keyType == CMKeyTypePunctuationSlider
    || (self.keyType == CMKeyTypeLetter && self.isFuncationnal)
    || self.keyType == CMKeyTypeSpace;
}

- (BOOL)shouldUseLetterKeyBackground {
    return (self.keyType == CMKeyTypeLetter && !self.isFuncationnal)
    || self.keyType == CMKeyTypePunctuationSlider;
}

- (NSString *)key{
    if([self shouldShowShiftedKey] && CMKeyboardTypeLetter == self.parent.keyboardType && CMShiftKeyStateNormal != self.parent.shiftKeyState){
        return _shiftedKey;
    }
    return _key;
}
- (int)mCode{
    if([self shouldShowShiftedKey] && CMKeyboardTypeLetter == self.parent.keyboardType && CMShiftKeyStateNormal != self.parent.shiftKeyState){
        return _mShifteCode;
    }
    return _mCode;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key = %@ , keyType = %ld", self.key, (unsigned long)self.keyType];
}
@end
