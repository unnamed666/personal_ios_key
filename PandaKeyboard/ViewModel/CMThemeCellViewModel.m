//
//  CMThemeCellViewModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMThemeCellViewModel.h"
#import "CMThemeModel.h"
#import "CMThemeManager.h"

@implementation CMThemeCellViewModel

- (instancetype)initWithThemeModel:(CMThemeModel *)model themeManager:(CMThemeManager *)themeManager {
    if (self = [super init]) {
        self.coverImageUrlString = model.coverUrlString;
        self.themeName = model.themeName;
        self.themeTitle = model.themeTitle;
        if (model.type == CMThemeModelType_Default) {
            self.themeStatus = CMThemeStatusLocalDefault;
        }
        else if (model.type == CMThemeModelType_Custom){
            self.themeStatus = CMThemeStatusCustom;
        }
        else {
            CMThemeModel * cachedThemeModel = [themeManager cachedThemeModelById:model.themeId];
            if (cachedThemeModel) {//已下载过
                if (![model.themeVersion isEqualToString:cachedThemeModel.themeVersion]) {//有更新
                    self.themeStatus = CMThemeStatusUpdateAvaliable;
                }else{
                    self.themeStatus = CMThemeStatusLocalDownload;
                }
            }else{
                self.themeStatus = CMThemeStatusNeedDownload;
            }
        }
    }
    return self;
}

+ (instancetype)viewModelWithThemeModel:(CMThemeModel *)model themeManager:(CMThemeManager *)themeManager {
    CMThemeCellViewModel* viewModel = [[CMThemeCellViewModel alloc] initWithThemeModel:model themeManager:themeManager];
    return viewModel;
}

@end
