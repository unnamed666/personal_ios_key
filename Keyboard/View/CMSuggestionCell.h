//
//  CMSuggestionCell.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMSuggestionCellViewModel;

@interface CMSuggestionCell : UICollectionViewCell

- (void)bindData:(CMSuggestionCellViewModel *)viewModel;

- (void)setTitleColor:(UIColor *)titleColor;

- (void)cloudPredictionImageViewTintColor:(UIColor*)tintColor;
@end
