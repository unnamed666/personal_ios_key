//
//  CustomCollectionViewLayout.h
//  iMessage
//
//  Created by yanzhao on 2017/9/28.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
//#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@class CustomCollectionViewLayout;

@protocol CustomCollectionViewLayoutDelegate <NSObject>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView collectionViewLayout:(CustomCollectionViewLayout *)collectionViewLayout sizeOfItemAtIndexPath:(NSIndexPath *)indexPath;

// scrollDirection 为UICollectionViewScrollDirectionHorizontal  , fixedCount为固定行数
// scrollDirection 为UICollectionViewScrollDirectionVertical    , fixedCount为固定列数
- (int) fixedCount;
- (int) flowLayoutStartSection;
@end

@interface CustomCollectionViewLayout : UICollectionViewLayout
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat interitemSpacing;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionVertical
@property (weak, nonatomic) id<CustomCollectionViewLayoutDelegate> layoutDelegate;

@end
