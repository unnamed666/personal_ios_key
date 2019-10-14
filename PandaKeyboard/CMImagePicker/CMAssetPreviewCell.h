//
//  CMAssetPreviewCell.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class CMAssetModel;

@interface CMAssetPreviewCell : UICollectionViewCell
@property (nonatomic, strong) CMAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
- (void)configSubviews;
- (void)photoPreviewCollectionViewDidScroll;

@end


@class CMPhotoPreviewView;
@interface CMPhotoPreviewCell: CMAssetPreviewCell

@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, strong) CMPhotoPreviewView *previewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

- (void)recoverSubviews;
@end

@interface CMPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
//@property (nonatomic, strong) TZProgressView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) CMAssetModel *model;
@property (nonatomic, strong) PHAsset * asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubviews;
@end
