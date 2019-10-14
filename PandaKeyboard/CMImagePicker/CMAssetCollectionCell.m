//
//  CMAssetCollectionCell.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMAssetCollectionCell.h"
#import "CMImageManger.h"
@interface CMAssetCollectionCell()

@property (nonatomic, strong) UIImageView *imageView;       // The photo / 照片
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *timeLength;

@property (nonatomic, weak) UIImageView *videoImgView;
//@property (nonatomic, strong) TZProgressView *progressView;
@property (nonatomic, assign) int32_t bigImageRequestID;

@end
@implementation CMAssetCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)setModel:(CMAssetModel *)model{
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[CMImageManger sharedInstance]getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
            
            kLog(@"image 尺寸%@",NSStringFromCGSize(photo.size));
        } else {
            kLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    } networkAccessAllowed:false];
    
    
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[CMImageManger  sharedInstance] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            _selectImageView.hidden = YES;
        }
    }
    // 如果用户选中了该图片，提前获取一下大图
    if (model.isSelected) {
        [self fetchBigImage];
    }
    [self setNeedsLayout];
    
}

- (void)fetchBigImage {
    _bigImageRequestID = [[CMImageManger sharedInstance] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//        if (_progressView) {
//            [self hideProgressView];
//        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (_model.isSelected) {
//            progress = progress > 0.02 ? progress : 0.02;;
//            self.progressView.progress = progress;
//            self.progressView.hidden = NO;
//            self.imageView.alpha = 0.4;
//            if (progress >= 1) {
//                [self hideProgressView];
//            }
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } networkAccessAllowed:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    
}



#pragma mark - Lazy load

//- (UIButton *)selectPhotoButton {
//    if (!_selectImageView) {
//        UIButton *selectPhotoButton = [[UIButton alloc] init];
//        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:selectPhotoButton];
//        _selectPhotoButton = selectPhotoButton;
//    }
//    return _selectPhotoButton;
//}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _imageView = imageView;
        [self.contentView addSubview:_imageView];
        
//        [self.contentView bringSubviewToFront:_selectImageView];
//        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (!_bottomView ) {
        UIView *bottomView = [[UIView alloc] init];
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}



@end

#pragma mark - 添加相机

@implementation CMAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;

}

@end
