//
//  CMCollectionView.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMCollectionViewDelegate <NSObject>

- (void)onCollectionView:(UICollectionView *)collectionView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)onCollectionView:(UICollectionView *)collectionView touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)onCollectionView:(UICollectionView *)collectionView touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)onCollectionView:(UICollectionView *)collectionView touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@interface CMCollectionView : UICollectionView

@property (nonatomic, weak)id<CMCollectionViewDelegate> touchDelegate;

@end
