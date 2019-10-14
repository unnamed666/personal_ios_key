//
//  CMThemeModel.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMThemeModelType) {
    CMThemeModelType_Default = 0,
    CMThemeModelType_Cached,
    CMThemeModelType_Fetched,
    CMThemeModelType_Custom
};

@interface CMThemeModel : NSObject
@property (nonatomic, readonly, assign)CMThemeModelType type;
@property (nonatomic, readonly, copy)NSString* themeId;
@property (nonatomic, readonly, copy)NSString* themeVersion;
@property (nonatomic, readonly, copy)NSString* themeTitle;
@property (nonatomic, readonly, copy)NSString* coverUrlString;
@property (nonatomic, readonly, copy)NSString* downloadUrlString;
@property (nonatomic, readonly, copy)NSString* zipSizeString;
@property (nonatomic, readwrite, copy)NSString* localPathString;
@property (nonatomic, readwrite, copy)NSString* themeName;


- (instancetype)initWithCustomThemeId:(NSString *)themeId coverImagePath:(NSString*)coverImagePath localPath:(NSString*)localPath;
// 从本地缓存创建
- (instancetype)initWithCachedInfoDic:(NSDictionary *)infoDic;

// 从网络请求创建
- (instancetype)initWithFetchedInfoDic:(NSDictionary *)infoDic;

// 从本地默认plist创建
- (instancetype)initWithDefaultInfoDic:(NSDictionary *)infoDic;

+ (CMThemeModel *)modelWithCachedInfoDic:(NSDictionary *)infoDic;

+ (CMThemeModel *)modelWithFetchedInfoDic:(NSDictionary *)infoDic;

+ (CMThemeModel *)modelWithDefaultInfoDic:(NSDictionary *)infoDic;

+ (CMThemeModel *)modelWithCustomInfoDic:(NSDictionary *)infoDic;

//+ (CMThemeModel *)modifyModelWithModel:(CMThemeModel *)model;

@end
