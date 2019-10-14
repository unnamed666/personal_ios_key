//
//  CMAssetModel.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface CMAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;             ///< PHAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
+ (instancetype)modelWithAsset:(PHAsset *)asset;

@end

@interface CMAlbumModel: NSObject
@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) PHFetchResult *result;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;
@property (nonatomic, assign) BOOL isCameraRoll;

@end

@interface CMAlbumCell : UITableViewCell

@property (nonatomic, strong) CMAlbumModel *model;
@property (nonatomic, strong) UIButton *selectedCountButton;

@end


