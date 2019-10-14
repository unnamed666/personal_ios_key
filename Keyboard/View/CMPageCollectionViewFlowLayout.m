//
//  CMPageCollectionViewFlowLayout.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMPageCollectionViewFlowLayout.h"
@interface CMPageCollectionViewFlowLayout()
@property (nonatomic,strong) NSMutableSet<NSIndexPath *>* insertedItemsToAnimate;
@end
@implementation CMPageCollectionViewFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        _offset = 10.0f;
        _useVelocity = YES;
        _insertedItemsToAnimate = [NSMutableSet new];
    }
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (ABS(velocity.x) > 0.5 && self.useVelocity) {
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }
    //1.计算scrollview最后停留的范围
    CGRect lastRect ;
    lastRect.origin = proposedContentOffset;
    lastRect.size = self.collectionView.frame.size;
    
    //2.取出这个范围内的所有属性
    NSArray *array = [self layoutAttributesForElementsInRect:lastRect];
    
    //起始的x值，也即默认情况下要停下来的x值
    CGFloat startX = proposedContentOffset.x;
    
    //3.遍历所有的属性
    CGFloat adjustOffsetX = MAXFLOAT;
    
    UICollectionViewLayoutAttributes *attrs = (UICollectionViewLayoutAttributes *)[array firstObject];
    CGFloat attrsX = CGRectGetMinX(attrs.frame);
    CGFloat attrsW = CGRectGetWidth(attrs.frame) ;
    
    if (startX - attrsX  < attrsW/2) {
        adjustOffsetX = -(startX - attrsX + self.offset);
    }else{
        adjustOffsetX = attrsW - (startX - attrsX);
    }
    return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems{
    [super prepareForCollectionViewUpdates:updateItems];
    for (UICollectionViewUpdateItem* updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                if(updateItem.indexPathAfterUpdate){
                    [self.insertedItemsToAnimate addObject:updateItem.indexPathAfterUpdate];
                }
                break;
            default:
                break;
        }
    }
}

//- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    if ([self.insertedItemsToAnimate containsObject:itemIndexPath]) {
//        attr.transform = CGAffineTransformMakeTranslation(-attr.size.width, 0);
//        attr.alpha = 0.0f;
//    }
//    
//    return attr;
//}


- (void)finalizeCollectionViewUpdates{
    [super finalizeCollectionViewUpdates];
    if (self.insertedItemsToAnimate.count <= 0) {
        return;
    }
    
    NSIndexPath *itemIndexPath =[self.insertedItemsToAnimate anyObject];
    
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    UICollectionViewCell * cell =  [self.collectionView cellForItemAtIndexPath:itemIndexPath];
    CAShapeLayer* _maskLayer = [CAShapeLayer layer];
    cell.layer.mask = _maskLayer;
    UIBezierPath * starMaskBP = [UIBezierPath bezierPathWithRect:CGRectMake(attr.frame.size.width,0, 0,  attr.frame.size.height)];
    UIBezierPath * endMaskBP = [UIBezierPath bezierPathWithRect:CGRectMake(0,0, attr.frame.size.width,  attr.frame.size.height)];
    _maskLayer.path = starMaskBP.CGPath;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(starMaskBP.CGPath);
    animation.toValue =(__bridge id _Nullable)(endMaskBP.CGPath);

    [CATransaction begin];
    {
        [CATransaction setCompletionBlock:^{
            [UIView performWithoutAnimation:^{
                cell.layer.mask = nil;
            }];
        }];
        [_maskLayer addAnimation:animation forKey:@"animation"];
    }
    [CATransaction commit];

    
    [self.insertedItemsToAnimate removeAllObjects];
    self.insertedItemsToAnimate = nil;
}
@end
