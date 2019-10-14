//
//  CMDiySourceCollectionCell.h
//  PandaKeyboard
//
//  Created by duwenyan on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMDiySourceModel;

@interface CMDiySourceCollectionCell : UICollectionViewCell

@property (nonatomic, readwrite, strong) CAShapeLayer *progressLayer;

- (void)bindingDiySourceModel:(CMDiySourceModel *)diySourceModel;

- (void)setCoverImage:(UIImage *)image;

@end
