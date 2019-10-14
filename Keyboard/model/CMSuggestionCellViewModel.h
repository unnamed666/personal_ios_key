//
//  CMSuggestionCellViewModel.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SuggestedWordInfo;

@interface CMSuggestionCellViewModel : NSObject
@property (nonatomic, strong) SuggestedWordInfo *suggestInfo;
@property (nonatomic, copy)NSString* titleLabelText;
@property (nonatomic, assign)BOOL isEmphasize;
@property (nonatomic, assign)BOOL isCloudWord;

@property (nonatomic, assign)CGSize cachedSize;

+ (instancetype)viewModelWithDictionary:(NSDictionary *)dic;

#ifndef HostApp
+ (instancetype)viewModelWithInfo:(SuggestedWordInfo *)info;
#endif

- (BOOL)isEqualToViewModel:(CMSuggestionCellViewModel *)viewModel;

@end
