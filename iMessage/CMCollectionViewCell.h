//
//  CMCollectionViewCell.h
//  iMessage
//
//  Created by yanzhao on 2017/9/23.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSSticker;
@class YYAnimatedImageView;
@interface CMCollectionViewTopCell : UICollectionViewCell
@end

@interface CMCollectionViewCell : UICollectionViewCell
//@property (nonatomic, strong)MSSticker *sticker;
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *imageView;

@end
