//
//  CMAssetCollectionCell.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMAssetModel;

@interface CMAssetCollectionCell : UICollectionViewCell

@property (nonatomic, strong) CMAssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, assign) BOOL showSelectBtn;
@property (nonatomic, assign) BOOL allowPreview;

@end

@interface CMAssetCameraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

