//
//  CMSuggestionCellViewModel.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMSuggestionCellViewModel.h"
#import "NSDictionary+Common.h"
#ifndef HostApp
#import "SuggestedWordInfo.h"
#endif

@implementation CMSuggestionCellViewModel

+ (instancetype)viewModelWithDictionary:(NSDictionary *)dic {
    CMSuggestionCellViewModel* viewModel = [CMSuggestionCellViewModel new];
    viewModel.titleLabelText = [dic stringValueForKey:@"suggest" defaultValue:@""];
    viewModel.cachedSize = CGSizeZero;
    return viewModel;

}

#ifndef HostApp
+ (instancetype)viewModelWithInfo:(SuggestedWordInfo *)info {
    CMSuggestionCellViewModel* viewModel = [CMSuggestionCellViewModel new];
    viewModel.suggestInfo = info;
    viewModel.titleLabelText = info.word;
    viewModel.cachedSize = CGSizeZero;
    viewModel.isCloudWord = [info isKindOf:KIND_CLOUD_CORRECTION] || [info isKindOf:KIND_CLOUD_PREDICTION];
    return viewModel;
}
#endif
- (BOOL)isEqualToViewModel:(CMSuggestionCellViewModel *)viewModel {
    if (!viewModel) {
        return NO;
    }
    BOOL haveEqualTitle = (!self.titleLabelText && !viewModel.titleLabelText) || [self.titleLabelText isEqualToString:viewModel.titleLabelText];

    return haveEqualTitle;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMSuggestionCellViewModel class]]) {
        return NO;
    }
    
    return [self isEqualToViewModel:(CMSuggestionCellViewModel *)object];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.titleLabelText];
}

@end
