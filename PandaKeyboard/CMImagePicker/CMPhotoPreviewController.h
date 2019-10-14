//
//  CMPhotoPreviewController.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface CMPhotoPreviewController : UIViewController

@property (nonatomic, strong) NSMutableArray *models; // 所有图片模型数组
@property (nonatomic, strong) NSMutableArray *photos; // 所有图片数组
@property (nonatomic, assign) NSInteger currentIndex; //用户点击的图片的索引
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;  //是否返回原图
@property (nonatomic, assign) BOOL isCropImage; //是否剪裁图片

// 返回最新的选中图片数组
@property (nonatomic, copy) void (^backButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode)(UIImage *cropedImage,PHAsset *asset);
@property (nonatomic, copy) void (^doneButtonClickBlockWithPreviewType)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);

@end
