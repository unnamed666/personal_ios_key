//
//  CMTextInputModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/27.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTextInputModel.h"

#ifndef HostApp
#import "InputModel+CoreDataClass.h"
#endif

@interface CMTextInputModel () <NSCopying>

@end

@implementation CMTextInputModel

- (id)copyWithZone:(NSZone *)zone {
    CMTextInputModel* model = [[[self class] allocWithZone:zone] init];
    model.keyboardType = _keyboardType;
    model.autocorrectionType = _autocorrectionType;
    model.autocapitalizationType = _autocapitalizationType;
    model.spellCheckingType = _spellCheckingType;
    model.returnKeyType = _returnKeyType;
    model.enablesReturnKeyAutomatically = _enablesReturnKeyAutomatically;
    return model;
}

+ (instancetype)modelWithProxy:(id<UITextDocumentProxy>)proxy {
    CMTextInputModel* model = [CMTextInputModel new];
    model.keyboardType = proxy.keyboardType;
    model.autocorrectionType = proxy.autocorrectionType;
    model.autocapitalizationType = proxy.autocapitalizationType;
    model.spellCheckingType = proxy.spellCheckingType;
    model.returnKeyType = proxy.returnKeyType;
    model.enablesReturnKeyAutomatically = proxy.enablesReturnKeyAutomatically;
    return model;
}

#ifndef HostApp
+ (instancetype)modelWithInputEntity:(InputModel *)entity {
    CMTextInputModel* model = [CMTextInputModel new];
    model.keyboardType = entity.keyboardType;
    model.returnKeyType = entity.returnType;
    model.autocorrectionType = UITextAutocorrectionTypeDefault;
    model.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    model.spellCheckingType = UITextSpellCheckingTypeDefault;
    model.enablesReturnKeyAutomatically = NO;
    return model;
}

#endif
- (BOOL)isEqualToModel:(CMTextInputModel *)model {
    if (!model) {
        return NO;
    }
    return self.keyboardType==model.keyboardType
    && self.autocorrectionType==model.autocorrectionType
    && self.spellCheckingType==model.spellCheckingType
    && self.returnKeyType==model.returnKeyType
    && self.enablesReturnKeyAutomatically==model.enablesReturnKeyAutomatically
    && self.autocapitalizationType==model.autocapitalizationType;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMTextInputModel class]]) {
        return NO;
    }
    
    return [self isEqualToModel:(CMTextInputModel *)object];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<keyboardType=%ld, autocorrectionType=%ld, autocapitalizationTyp=%ld, spellCheckingType=%ld, returnKeyType=%ld, enablesReturnKeyAutomatically=%d>", (long)self.keyboardType, (long)self.autocorrectionType, (long)self.autocapitalizationType, (long)self.spellCheckingType, (long)self.returnKeyType, self.enablesReturnKeyAutomatically];
}


@end
