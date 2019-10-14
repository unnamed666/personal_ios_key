//
//  CMThemeDetailViewModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMThemeModel;
@class CMThemeManager;

typedef NS_ENUM(NSInteger, CMThemeType)
{
    CMThemeType_Download = 1, // 需要下载
    CMThemeType_Update, // 需要更新
    CMThemeType_None, // 既不需要下载也不需要更新
};

@interface CMThemeDetailViewModel : NSObject

@property (nonatomic, readonly, copy)NSString* themeId;
@property (nonatomic, readonly, copy)NSString* themeName;
@property (nonatomic, readonly, copy)NSString* coverUrlString;
@property (nonatomic, readonly, copy)NSString* downloadUrlString;
@property (nonatomic, readonly, copy)NSString* themeVersion;
@property (nonatomic, readonly, copy)NSString* zipSizeString;
@property (nonatomic, readonly) CMThemeType themeType;
@property (nonatomic, readonly, copy)NSString* themeTitle;
@property (nonatomic, strong)CMThemeModel* viewModel;
@property (nonatomic, readonly) NSInteger themeIndex;

- (instancetype)initWithThemeModel:(CMThemeModel *)model themeManager:(CMThemeManager *)themeManager;
+ (instancetype)viewModelWithThemeModel:(CMThemeModel *)model indexPath:(NSIndexPath *)indexPath themeManager:(CMThemeManager *)themeManager;

@end
