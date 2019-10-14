//
//  CMSuggestionViewModel.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMSuggestionViewModel.h"
#import "CMSuggestionCellViewModel.h"
#ifndef HostApp
#import "SuggestedWordInfo.h"
#endif

@interface CMSuggestionViewModel ()
@property (nonatomic, strong)NSMutableArray<CMSuggestionCellViewModel *>* predictArray;

@end

@implementation CMSuggestionViewModel

- (void)dealloc {
    kLogTrace();
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return self.predictArray.count;
}

- (CMSuggestionCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath || indexPath.item >= self.predictArray.count || self.predictArray.count <= 0) {
        return nil;
    }
    return [self.predictArray objectAtIndex:indexPath.item];
}
#ifndef HostApp
+ (instancetype)viewModelWithSuggesteWords:(SuggesteWords*)sugesteWords {
    CMSuggestionViewModel* viewModel = [CMSuggestionViewModel new];
    NSMutableArray<CMSuggestionCellViewModel*>* array = [[NSMutableArray alloc] init];
    
    int hasAutoCorrect = sugesteWords.willAutoCorrect;
    [sugesteWords.suggestionsList enumerateObjectsUsingBlock:^(SuggestedWordInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        CMSuggestionCellViewModel* cellModel = [CMSuggestionCellViewModel viewModelWithInfo:info];
        if(idx == hasAutoCorrect){
            cellModel.isEmphasize = YES;
        }
        if(idx == 0 && [info isKindOf:KIND_PREDICTION]){
            cellModel.isEmphasize = YES;
        }
        [array addObject:cellModel];
    }];
    viewModel.predictArray = array;
    return viewModel;
}
#endif
- (BOOL)containCellViewModel:(CMSuggestionCellViewModel *)cellViewModel {
    return [self.predictArray containsObject:cellViewModel];
}

- (void)insertCellViewModel:(CMSuggestionCellViewModel *)cellViewModel atIndexPath:(NSIndexPath *)indexPath completeBlock:(CMCompletionBlock)block {
    if (!cellViewModel || indexPath.section > 0) {
        block = nil;
        return;
    }
    BOOL isAddObject = NO;
    if (indexPath.item >= self.predictArray.count) {
        [self.predictArray addObject:cellViewModel];
        isAddObject = YES;
    }else {
        [self.predictArray insertObject:cellViewModel atIndex:indexPath.item];
    }
    if (block) {
        if ([NSThread isMainThread]) {
            block(isAddObject?[CMError errorWithCode:CMErrorCodeReservationsSuccess errorMessage:@"Data count less than indexPath"]:nil);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(isAddObject?[CMError errorWithCode:CMErrorCodeReservationsSuccess errorMessage:@"Data count less than indexPath"]:nil);
            });
        }
    }
}
#ifndef HostApp
- (BOOL)isValidSuggestionWords:(SuggesteWords *)words {
    __block BOOL valid = NO;
    if (self.predictArray.count <= 0 || words.suggestionsList.count != self.predictArray.count) {
        valid = YES;
    }
    else {
        [self.predictArray enumerateObjectsUsingBlock:^(CMSuggestionCellViewModel * _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![cellModel.suggestInfo.word isEqualToString:[words.suggestionsList objectAtIndex:idx].word] || cellModel.suggestInfo.kindAndFlags != [words.suggestionsList objectAtIndex:idx].kindAndFlags) {
                valid = YES;
                *stop = YES;
            }
        }];
    }
    return valid;
}

- (void)updateWithSuggestionWords:(SuggesteWords *)words completeBlock:(CMCompletionBlock)block {
    if (!words || !words.suggestionsList || words.suggestionsList.count <= 0) {
        [self.predictArray removeAllObjects];
    }
    else if ([self isValidSuggestionWords:words]) {
        [self.predictArray removeAllObjects];
        int hasAutoCorrect = words.willAutoCorrect;
        [words.suggestionsList enumerateObjectsUsingBlock:^(SuggestedWordInfo * _Nonnull wordInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            CMSuggestionCellViewModel* cellModel = [CMSuggestionCellViewModel viewModelWithInfo:wordInfo];
            if(idx == hasAutoCorrect){
                cellModel.isEmphasize = YES;
            }
            if(idx == 0 && [wordInfo isKindOf:KIND_PREDICTION]){
                cellModel.isEmphasize = YES;
            }
            [self.predictArray addObject:cellModel];
        }];
    }
    if (block) {
        if ([NSThread isMainThread]) {
            block(nil);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        }
    }
}
#else
- (void)updateWithSuggestionWords:(NSArray<NSString*> *)words {
    [self.predictArray removeAllObjects];
    for (NSString* str in words) {
        CMSuggestionCellViewModel * vm = [[CMSuggestionCellViewModel alloc] init];
        vm.titleLabelText = str;
        // 暂不准时选中词
//        if(self.predictArray.count == 1){
//            vm.isEmphasize = YES;
//        }
        [self.predictArray addObject:vm];
    }
}
#endif
- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMSuggestionViewModel class]]) {
        return NO;
    }
    
    return [self isEqualToModel:(CMSuggestionViewModel *)object];
}

- (BOOL)isEqualToModel:(CMSuggestionViewModel *)model {
    if (!model) {
        return NO;
    }
    
    return ([self.predictArray isEqualToArray:model.predictArray]);
}

#pragma mark - setter/getter
- (NSMutableArray<CMSuggestionCellViewModel *> *)predictArray {
    if (!_predictArray) {
        _predictArray = [NSMutableArray new];
    }
    return _predictArray;
}

@end
