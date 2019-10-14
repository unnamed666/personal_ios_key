//
//  CMSuggestionView.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMInputLogic.h"
#import "CMBaseToolBarView.h"

@class CMSuggestionViewModel;
@class CMSuggestionStripView;
@class CMSuggestionCellViewModel;
@class SuggestedWordInfo;
@class SuggesteWords;
@class CMCollectionView;

@protocol CMSuggestionViewDelegate <NSObject>

@required
- (void)onPredictView:(CMSuggestionStripView *)predictView tappedSuggestion:(SuggestedWordInfo *)wordInfo;

- (void)onPredictView:(CMSuggestionStripView *)predictView emojiBtnTapped:(NSDictionary *)infoDic;

@optional
- (void)onPredictView:(CMSuggestionStripView *)predictView emojiBtnMoreTapped:(NSDictionary *)infoDic;
- (void)onPredictView:(CMSuggestionStripView *)predictView deleteAllSuggestTapped:(NSDictionary *)infoDic;

@end


@interface CMSuggestionStripView : CMBaseToolBarView
@property (nonatomic, strong)CMCollectionView* collectionView;
@property (nonatomic, readonly)CMSuggestionViewModel* viewModel;
@property (nonatomic, assign) BOOL shouldShowDeleteAllButton;

@property (nonatomic, weak)id<CMSuggestionViewDelegate> delegate;

#ifndef HostApp
- (void)bindData:(SuggesteWords *)words completeBlock:(CMCompletionBlock)block;

- (void)insertCloudPrediction:(SuggestedWordInfo *)word completeBlock:(CMCompletionBlock)block;
#else
- (void)bindData:(NSArray<NSString*> *)words;
#endif

@end
