//
//  CMThemeDetailViewModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMThemeDetailViewModel.h"
#import "CMThemeModel.h"
#import "CMThemeManager.h"

@interface CMThemeDetailViewModel ()

@property (nonatomic, readwrite, copy)NSString* themeId;
@property (nonatomic, readwrite, copy)NSString* themeName;
@property (nonatomic, readwrite, copy)NSString* coverUrlString;
@property (nonatomic, readwrite, copy)NSString* downloadUrlString;
@property (nonatomic, readwrite, copy)NSString* themeVersion;
@property (nonatomic, readwrite, copy)NSString* zipSizeString;
@property (nonatomic, readwrite) CMThemeType themeType;
@property (nonatomic, readwrite, copy)NSString* themeTitle;
@property (nonatomic, readwrite) NSInteger themeIndex;

@end

@implementation CMThemeDetailViewModel

+ (instancetype)viewModelWithThemeModel:(CMThemeModel *)model indexPath:(NSIndexPath *)indexPath themeManager:(CMThemeManager *)themeManager {
    CMThemeDetailViewModel* viewModel = [[CMThemeDetailViewModel alloc] initWithThemeModel:model themeManager:themeManager];
    viewModel.themeIndex = indexPath.item;
    return viewModel;
}


- (instancetype)initWithThemeModel:(CMThemeModel *)model themeManager:(CMThemeManager *)themeManager {
    if (self = [super init])
    {
        self.themeId = model.themeId;
        self.themeName = model.themeName;
        self.coverUrlString = model.coverUrlString;
        self.downloadUrlString = model.downloadUrlString;
        self.themeVersion = model.themeVersion;
        self.zipSizeString = model.zipSizeString;
        self.themeTitle = model.themeTitle;
        self.viewModel = model;
    
        CMThemeModel* cachedModel = [themeManager cachedThemeModelById:self.themeId];
        if (cachedModel)
        {
            if (![self.themeVersion isEqualToString:cachedModel.themeVersion])
            {
                self.themeType = CMThemeType_Update;
            }
            else
            {
                self.themeType = CMThemeType_None;
            }
        }
        else if (self.viewModel.type == CMThemeModelType_Default || self.viewModel.type == CMThemeModelType_Custom)
        {
            self.themeType = CMThemeType_None;
        }
        else
        {
            self.themeType = CMThemeType_Download;
        }
    }

    return self;
}

@end
