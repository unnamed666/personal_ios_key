//
//  CMSuggestionViewModel.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMSuggestionCellViewModel;
@class SuggesteWords;

@interface CMSuggestionViewModel : NSObject

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (CMSuggestionCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)containCellViewModel:(CMSuggestionCellViewModel *)cellViewModel;
- (void)insertCellViewModel:(CMSuggestionCellViewModel *)cellViewModel atIndexPath:(NSIndexPath *)indexPath completeBlock:(CMCompletionBlock)block;

#ifndef HostApp
+ (instancetype)viewModelWithSuggesteWords:(SuggesteWords*)sugesteWords;

- (void)updateWithSuggestionWords:(SuggesteWords *)words completeBlock:(CMCompletionBlock)block;
#else
- (void)updateWithSuggestionWords:(NSArray<NSString*> *)words ;
#endif

@end
