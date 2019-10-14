//
//  CMThemeCellViewModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMThemeModel;
@class CMThemeManager;

typedef NS_ENUM(NSUInteger, CMThemeStatus) {
    CMThemeStatusLocalDefault = 0,
    CMThemeStatusLocalDownload,
    CMThemeStatusUpdateAvaliable,
    CMThemeStatusNeedDownload,
    CMThemeStatusCustom
};

@interface CMThemeCellViewModel : NSObject

@property (nonatomic, copy) NSString * coverImageUrlString;
@property (nonatomic, copy) NSString * themeName;
@property (nonatomic, copy) NSString * themeTitle;

@property (nonatomic, assign)CMThemeStatus themeStatus;

- (instancetype)initWithThemeModel:(CMThemeModel *)model themeManager:(CMThemeManager *)themeManager;

+ (instancetype)viewModelWithThemeModel:(CMThemeModel *)model themeManager:(CMThemeManager *)themeManager;

@end
