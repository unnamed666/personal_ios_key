//
//  ThemeCollectionViewCell.h
//  KeyboardSplash
//
//  Created by Alchemist on 2017/5/23.
//  Copyright © 2017年 Atom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMThemeCellViewModel.h"
@class ThemeCollectionViewCell;

@protocol ThemeCollectionViewCellDelegate <NSObject>
@optional
- (void)themeCollectionViewCellDeleteButtonClickWithCell:(ThemeCollectionViewCell *)cell;
@end

@interface ThemeCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<ThemeCollectionViewCellDelegate> delegate;

- (void)setThemeCellViewModel:(CMThemeCellViewModel *)themeCellViewModel indexPath:(NSIndexPath *)indexPath;
- (void)setDeleteButtonShouldShow:(BOOL)shouldShowDeleteButton shouldShowMaskView:(BOOL)shouldShowMaskView indexPath:(NSIndexPath *)indexPath;
@end
