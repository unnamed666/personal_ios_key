//
//  CMImageManger.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "CMAssetModel.h"

@interface CMImageManger : NSObject

+ (instancetype)sharedInstance;
+ (void)deallocManger;
// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
@property (nonatomic, assign) BOOL shouldFixOrientation; //修正转向

@property (nonatomic, assign) CGFloat photoPreviewMaxWidth; //默认600px
@property (nonatomic, assign) CGFloat photoWidth; //导出宽度,默认828px
@property (nonatomic, assign) NSInteger columnNumber;

// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

#pragma mark - 授权相关
-(BOOL)authorizationStatusAuthorized;
-(void)requestPhotoAutorizationCompletion:(void (^)(BOOL author))completion;
- (UIImage *)fixOrientation:(UIImage *)aImage;

- (BOOL)isPhotoSelectableWithAsset:(PHAsset *)asset;

#pragma mark - 获得Album 相册/相册数组
- (void)getCameraRollAlbumCompletion:(void (^)(CMAlbumModel *model))completion;

- (void)getAllAlbumsCompletion:(void (^)(NSArray<CMAlbumModel *> *models))completion;


/// Get Assets 获得Asset数组
- (void)getAssetsFromFetchResult:(PHFetchResult *)result completionBlock:(void (^)(NSArray<CMAssetModel *> *arr))completionBlock;

//获取照片
- (void)getPostImageWithAlbumModel:(CMAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

- (int32_t)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (int32_t)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;


@end
