//
//  CMDIVThemeViewController.h
//  PandaKeyboard
//
//  Created by duwenyan on 2017/10/31.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseViewController.h"
#import "CMThemeModel.h"
@protocol CMDIVThemeViewControllerDelegate <NSObject>
@optional
- (void)doneButtonClickWith:(CMThemeModel *)model;
@end


typedef NS_ENUM(NSUInteger, CMDiyType) {
    CMDiyTypeDefault    = 0, // 对默认的diyTheme主题进行diy
    CMDiyTypeOfficial, // 对官方主题进行diy
    CMDiyTypeDiy        // 对自定义主题进行重新diy
};

@interface CMDIYThemeViewController : CMBaseViewController

@property (nonatomic, weak) id<CMDIVThemeViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger inway;

- (instancetype)initWithDiyThemeName:(NSString *)themeName diyType:(CMDiyType)diyType;

@end
