//
//  CustomCollectionViewLayout.m
//  iMessage
//
//  Created by yanzhao on 2017/9/28.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CustomCollectionViewLayout.h"
#import "UIDevice+Util.h"

@interface CMXorY :NSObject
@property (nonatomic, assign) int value;
- (instancetype)initWithValue:(int)value;
@end
@implementation CMXorY
- (instancetype)initWithValue:(int)value
{
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%d", _value];
}
@end;


@interface CustomCollectionViewLayout ()
@property (nonatomic, strong)NSMutableArray <CMXorY*>* yArray;
@property (nonatomic, strong)NSMutableArray <CMXorY*>* xArray;
//@property (assign, nonatomic) CGFloat leftY; // 左侧起始Y轴
//@property (assign, nonatomic) CGFloat rightY; // 右侧起始Y轴
@property (assign, nonatomic) NSInteger cellCount; // cell个数
@property (assign, nonatomic) CGFloat fixedItemWH; // cell固定的宽度或者高度 根据 scrollDirection判断
//@property (assign, nonatomic) int insert; // 间距
//@property (nonatomic) CGSize size;
@property (nonatomic, assign) int fixedCount;
@property (nonatomic, assign) int flowLayoutStartSection;
@end
@implementation CustomCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scrollDirection = UICollectionViewScrollDirectionVertical;
        _lineSpacing = _interitemSpacing = 10;
    }
    return self;
}

/**
*  初始化layout后自动调动，可以在该方法中初始化一些自定义的变量参数
*/
- (void)prepareLayout {

    [super prepareLayout];
    self.fixedCount = [self.layoutDelegate fixedCount];
//    self.size = [self.layoutDelegate widthHight];
    self.flowLayoutStartSection= [self.layoutDelegate flowLayoutStartSection];

    // 初始化参数
    _cellCount = [self.collectionView numberOfItemsInSection:self.flowLayoutStartSection]; // cell个数，直接从collectionView中获得
    int  insert = self.scrollDirection == UICollectionViewScrollDirectionVertical? _lineSpacing:_interitemSpacing;
    _fixedItemWH = ((self.scrollDirection == UICollectionViewScrollDirectionVertical ? CGRectGetWidth(self.collectionView.bounds) : CGRectGetHeight(self.collectionView.bounds)) - insert*(_fixedCount+1))/_fixedCount ; // cell宽度
    CGSize itemSize = CGSizeMake(0, 0);
    if(_flowLayoutStartSection != 0){
        itemSize = [self.layoutDelegate collectionView:self.collectionView collectionViewLayout:self sizeOfItemAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    self.yArray = [[NSMutableArray alloc] initWithCapacity:_fixedCount+1];
    self.xArray = [[NSMutableArray alloc] initWithCapacity:_fixedCount+1];
    
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        for (int i = 0; i <_fixedCount; i++) {
            CMXorY * y = [[CMXorY alloc]initWithValue:itemSize.height+_lineSpacing];
            [self.yArray addObject:y];
        }
        for (int i = 0; i <_fixedCount; i++) {
            CMXorY * x = [[CMXorY alloc]initWithValue:_interitemSpacing + i*(_fixedItemWH+_interitemSpacing)];
            [self.xArray addObject:x];
        }
    }else{
        for (int i = 0; i <_fixedCount; i++) {
            CMXorY * y = [[CMXorY alloc]initWithValue:_lineSpacing + i*(_fixedItemWH+_lineSpacing)];
            [self.yArray addObject:y];
        }
        for (int i = 0; i <_fixedCount; i++) {
            CMXorY * x = [[CMXorY alloc]initWithValue:itemSize.height+_interitemSpacing];
            [self.xArray addObject:x];
        }
    }

}

/**
 *  设置UICollectionView的内容大小，道理与UIScrollView的contentSize类似
 *
 *  @return 返回设置的UICollectionView的内容大小
 */
- (CGSize)collectionViewContentSize {
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        return CGSizeMake(CGRectGetWidth(self.collectionView.bounds) , [[self.yArray valueForKeyPath:@"@max.value"] intValue]);
    }else{
        return CGSizeMake([[self.xArray valueForKeyPath:@"@max.value"] intValue],CGRectGetHeight(self.collectionView.bounds) );
    }
}

/**
 *  初始Layout外观
 *
 *  @param rect 所有元素的布局属性
 *
 *  @return 所有元素的布局
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    CGSize itemSize = CGSizeMake(0, 0);
    NSIndexPath * section0 = [NSIndexPath indexPathForRow:0 inSection:0];
    if(_flowLayoutStartSection != 0){
        itemSize = [self.layoutDelegate collectionView:self.collectionView collectionViewLayout:self sizeOfItemAtIndexPath: section0];
    }
    
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        for (int i = 0; i <_fixedCount; i++) {
            self.yArray[i].value =itemSize.height + _lineSpacing;
        }
    }else{
        for (int i = 0; i <_fixedCount; i++) {
            self.xArray[i].value =itemSize.width + _interitemSpacing;
        }
    }
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    if(_flowLayoutStartSection != 0){
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:section0];
        attribute.frame = CGRectMake(0, 0, itemSize.width, itemSize.height);
        [attributes addObject:attribute];
    }
    
    for (int i = 0; i < self.cellCount; i ++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:_flowLayoutStartSection];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    return attributes;
}

/**
 *  根据不同的indexPath，给出布局
 *
 *  @param indexPath
 *
 *  @return 布局
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 获取代理中返回的每一个cell的大小
    CGSize itemSize = [self.layoutDelegate collectionView:self.collectionView collectionViewLayout:self sizeOfItemAtIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSArray<CMXorY*>* array = self.scrollDirection == UICollectionViewScrollDirectionVertical ?self.yArray:self.xArray;
    int minXYIndex =0;
    int minXY = array[0].value  ;
    int i=0;
    for (CMXorY * xy in array) {
        if(xy.value<minXY){
            minXYIndex = i;
            minXY = xy.value;
        }
        i++;
    }
    
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        
        // 防止代理中给的size.width大于(或小于)layout中定义的width，所以等比例缩放size
        CGFloat itemHeight = floorf(itemSize.height * self.fixedItemWH / itemSize.width);
        attributes.frame = CGRectMake(self.xArray[minXYIndex].value, minXY, _fixedItemWH, itemHeight);
        array[minXYIndex].value += (itemHeight + _lineSpacing);
    }else{
        
        CGFloat itemWidth = floorf(itemSize.width * self.fixedItemWH / itemSize.height);
        attributes.frame = CGRectMake(minXY, self.yArray[minXYIndex].value,itemWidth , _fixedItemWH);
        array[minXYIndex].value += (itemWidth + _interitemSpacing);
    }

    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (self.collectionView.bounds.size.width != newBounds.size.width) {
        return YES;
    }
    
    return NO;
}
@end
