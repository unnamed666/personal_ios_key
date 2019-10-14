//
//  CMPhotoPickeController.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMAlbumModel;

@interface CMPhotoPickeController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) CMAlbumModel *model;

@end

@interface CMPhotoCollectionView: UICollectionView

@end
