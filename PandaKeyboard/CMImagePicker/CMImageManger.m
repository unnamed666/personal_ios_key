//
//  CMImageManger.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMImageManger.h"
#import "UIImage+Util.h"

@implementation CMImageManger

CGSize AssetGridThumbnailSize;
CGFloat TZScreenWidth;
CGFloat TZScreenScale;

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static CMImageManger *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance configTZScreenWidth];
    });
    return sharedInstance;
}
+(void)deallocManger{
    
}

-(void)dealloc{
    kLogTrace();
}

- (void)configTZScreenWidth {
    TZScreenWidth = [UIScreen mainScreen].bounds.size.width;
    // 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
    TZScreenScale = 2.0;
    if (TZScreenWidth > 700) {
        TZScreenScale = 1.5;
    }
    
}

#pragma mark - setter and getter

-(void)setPhotoWidth:(CGFloat)photoWidth{
    _photoWidth = photoWidth;
    TZScreenWidth = photoWidth/2;
}

-(void)setColumnNumber:(NSInteger)columnNumber{
    [self configTZScreenWidth];
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (TZScreenWidth - 2 * margin - 4) / columnNumber - margin;
    AssetGridThumbnailSize = CGSizeMake(itemWH * TZScreenScale, itemWH * TZScreenScale);
}


#pragma mark - 授权相关

-(BOOL)authorizationStatusAuthorized{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    BOOL author = false;
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
            [self requestPhotoAutorizationCompletion:nil];
            break;
        case PHAuthorizationStatusRestricted:
            //授权中
            break;
        case PHAuthorizationStatusDenied:
            [self requestPhotoAutorizationCompletion:nil];
            author = false;
            break;
        case PHAuthorizationStatusAuthorized:
            author = true;
            break;
    }
    return author;
}
-(void)requestPhotoAutorizationCompletion:(void (^)(BOOL author))completion{

    void (^callCompletionBlock)(BOOL author) = ^(BOOL author){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(author);
            }
        });
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            BOOL suc = false;
            if (status == PHAuthorizationStatusAuthorized) {
                suc = true;
            }
            callCompletionBlock(suc);
        }];
    });
}

#pragma mark - 获得相册/相册数组

- (void)getCameraRollAlbumCompletion:(void (^)(CMAlbumModel *model))completion{
    __block CMAlbumModel *model;
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
 
    if (!self.sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];

    }
    PHFetchResult *samrtAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    [samrtAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = (PHAssetCollection *)obj;
        if (![collection isKindOfClass:[PHAssetCollection class]]){
            return;
        }
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if ([self isCameraRollAlbum:collection]) {
            model = [self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:true];
            completion(model);
            *stop = true;
        }
    
    }];
    
    
}

- (void)getAllAlbumsCompletion:(void (^)(NSArray<CMAlbumModel *> *models))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!self.sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    
    // 我的照片流 1.6.10重新加入..
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    
    for (PHFetchResult *feResult in allAlbums) {
        
        [feResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetCollection *collection = (PHAssetCollection *)obj;
            if (![collection isKindOfClass:[PHAssetCollection class]]){
                return;
            };
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1 ) {
                return;
            }
            if ([self isCameraRollAlbum:collection]) {
                [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:true] atIndex:0];
            }else{
                [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:false]];
            }
        }];
        
        
    }
    
    if (completion && albumArr.count > 0) {
        completion(albumArr);
    }
    
}



#pragma mark - 获取图片

- (void)getAssetsFromFetchResult:(PHFetchResult *)result completionBlock:(void (^)(NSArray<CMAssetModel *> *arr))completionBlock {
    NSMutableArray *photoArr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        CMAssetModel *model = [self assetModelWithAsset:asset];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completionBlock){
        completionBlock([photoArr copy]);
    }
    
}

- (void)getPostImageWithAlbumModel:(CMAlbumModel *)model completion:(void (^)(UIImage *postImage))completion{
    PHAsset *asset = [model.result lastObject];
    if (!self.sortAscendingByModificationDate) {
        asset = [model.result firstObject];
    }
    [[CMImageManger sharedInstance]getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo);
        }
    }];
    
}

- (int32_t)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (int32_t)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGFloat fullScreenWidth = TZScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}

- (int32_t)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGSize imageSize;
    if (photoWidth < TZScreenWidth && photoWidth < _photoPreviewMaxWidth) {
        imageSize = AssetGridThumbnailSize;
    } else {
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * TZScreenScale * 1.5;
        // 超宽图片
        if (aspectRatio > 1.8) {
            pixelWidth = pixelWidth * aspectRatio;
        }
        // 超高图片
        if (aspectRatio < 0.2) {
            pixelWidth = pixelWidth * 0.5;
        }
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
    }
    
    __block UIImage *image;
    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    int32_t imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            image = result;
        }
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                resultImage = [UIImage scaleImage:resultImage toSize:imageSize];
                if (!resultImage) {
                    resultImage = image;
                }
                resultImage = [self fixOrientation:resultImage];
                if (completion) completion(resultImage,info,NO);
            }];
        }
    }];
    return imageRequestID;
}

- (CMAssetModel *)assetModelWithAsset:(PHAsset *)asset{
    if (self.hideWhenCanNotSelect) {
        // 过滤掉尺寸不满足要求的图片
        if (![self isPhotoSelectableWithAsset:asset]) {
            return nil;
        }
    }
    CMAssetModel *model = [CMAssetModel modelWithAsset:asset];
    return model;
}

#pragma mark - Private method

- (BOOL)isCameraRollAlbum:(PHAssetCollection *)metadata {
    return metadata.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
}

/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(PHAsset *)asset {
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}

- (CGSize)photoSizeWithAsset:(PHAsset *)asset {
    return CGSizeMake(asset.pixelWidth, asset.pixelHeight);
}


- (CMAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name isCameraRoll:(BOOL)isCameraRoll {
    CMAlbumModel *model = [[CMAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    model.isCameraRoll = isCameraRoll;
    model.count = result.count;
    return model;
}

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



@end
