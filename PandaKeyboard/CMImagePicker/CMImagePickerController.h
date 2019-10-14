//
//  CMImagePickerController.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class CMImagePickerController;
@protocol CMImagePickerControllerDelegate <NSObject>

@optional

//剪裁完成的回调
-(void)cmImagePicker:(CMImagePickerController *)picker didFinishCropPhoto:(UIImage *)photo asset:(PHAsset *)asset isOriginal:(BOOL)isOriginal;

//主动取消的回调
-(void)cmImagePickerCancle:(CMImagePickerController *)picker;

@end

#pragma mark - 图片选择VC
@class CMAssetModel;

@interface CMImagePickerController : UINavigationController

@property (nonatomic, assign) NSInteger maxImagesCount;
@property (nonatomic, assign) NSInteger minImagesCount;
@property (nonatomic, assign) NSInteger columnNumber;

@property (nonatomic, assign) BOOL autoDismiss;  //自动消失,默认yes
@property (nonatomic, assign) BOOL showSelectBtn; //单选模式下,显示选择按钮,默认为NO
@property (nonatomic, assign) BOOL allowCrop;  //允许剪裁，默认为yes
@property (nonatomic, assign) BOOL allowTakePicture; //是否显示拍照按钮
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;//对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;

@property (nonatomic, assign) CGFloat photoWidth;
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;// 默认600像素宽
@property (nonatomic, assign) CGRect cropRect;             // 裁剪框的尺寸

// 用户选中过的图片数组
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<CMAssetModel *> *selectedModels;
@property (nonatomic, copy) void (^cropViewSettingBlock)(UIView *cropView); //自定义剪裁框
@property (nonatomic, weak) id<CMImagePickerControllerDelegate> pickerDelegate;

/*
 *columnNumber : 每行个数,传0时默认为4个
 */
-(instancetype)initWithCropImageColumnNumber:(NSInteger)columnNumber delegate:(id<CMImagePickerControllerDelegate>)delegate pushPhotoPicker:(BOOL)pushPhotoPicker;

@end

#pragma mark - 相册选择VC

@interface CMAlbumPickerController: UIViewController

@property (nonatomic, assign) NSInteger columnNumber;

- (void)configTableView;

@end




