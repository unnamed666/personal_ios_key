//
//  CMTextInputModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/27.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InputModel;

@interface CMTextInputModel : NSObject <UITextInputTraits>
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
@property(nonatomic) UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
@property(nonatomic) UITextSpellCheckingType spellCheckingType NS_AVAILABLE_IOS(5_0); // default is UITextSpellCheckingTypeDefault;
@property(nonatomic) UIKeyboardType keyboardType;                         // default is UIKeyboardTypeDefault
@property(nonatomic) UIReturnKeyType returnKeyType;                       // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
@property(nonatomic) BOOL enablesReturnKeyAutomatically;                  // default is NO (when YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length

+ (instancetype)modelWithProxy:(id<UITextDocumentProxy>)proxy;
#ifndef HostApp
+ (instancetype)modelWithInputEntity:(InputModel *)entity;
#endif
- (BOOL)isEqualToModel:(CMTextInputModel *)model;

@end
