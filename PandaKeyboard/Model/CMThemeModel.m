//
//  CMThemeModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMThemeModel.h"
#import "NSDictionary+Common.h"

@interface CMThemeModel () <NSCoding>
@property (nonatomic, readwrite, assign)CMThemeModelType type;
@property (nonatomic, readwrite, copy)NSString* themeId;
@property (nonatomic, readwrite, copy)NSString* themeVersion;
@property (nonatomic, readwrite, copy)NSString* themeTitle;
@property (nonatomic, readwrite, copy)NSString* coverUrlString;
@property (nonatomic, readwrite, copy)NSString* downloadUrlString;
@property (nonatomic, readwrite, copy)NSString* zipSizeString;

@end

@implementation CMThemeModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _themeId = [[aDecoder decodeObjectForKey:@"themeid"] copy];
        _themeVersion = [[aDecoder decodeObjectForKey:@"themever"] copy];
        _themeTitle = [[aDecoder decodeObjectForKey:@"title"] copy];
        _coverUrlString = [[aDecoder decodeObjectForKey:@"coverurl"] copy];
        _downloadUrlString = [[aDecoder decodeObjectForKey:@"downloadurl"] copy];
        _zipSizeString = [[aDecoder decodeObjectForKey:@"size"] copy];
        _localPathString = [[aDecoder decodeObjectForKey:@"local_path"] copy];
        _themeName = [[aDecoder decodeObjectForKey:@"name"] copy];
        _type = [aDecoder decodeInt32ForKey:@"type"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.themeId forKey:@"themeid"];
    [aCoder encodeObject:self.themeVersion forKey:@"themever"];
    [aCoder encodeObject:self.themeTitle forKey:@"title"];
    [aCoder encodeObject:self.coverUrlString forKey:@"coverurl"];
    [aCoder encodeObject:self.downloadUrlString forKey:@"downloadurl"];
    [aCoder encodeObject:self.zipSizeString forKey:@"size"];
    [aCoder encodeObject:self.localPathString forKey:@"local_path"];
    [aCoder encodeObject:self.themeName forKey:@"name"];
    [aCoder encodeInt32:self.type forKey:@"type"];
}


- (instancetype)initWithFetchedInfoDic:(NSDictionary *)infoDic {
    if (self = [super init]) {
        _type = CMThemeModelType_Fetched;
        _themeId = [[infoDic stringValueForKey:@"themeid"] copy];
        _themeName = [_themeId copy];
        _themeVersion = [[infoDic stringValueForKey:@"themever"] copy];
        _themeTitle = [[infoDic stringValueForKey:@"title"] copy];
        _coverUrlString = [[infoDic stringValueForKey:@"coverurl"] copy];
        _downloadUrlString = [[infoDic stringValueForKey:@"downloadurl"] copy];
        _zipSizeString = [infoDic stringValueForKey:@"size"];
        _localPathString = @"";
    }
    return self;
}

- (instancetype)initWithCustomThemeId:(NSString *)themeId coverImagePath:(NSString*)coverImagePath localPath:(NSString*)localPath{
     if (self = [super init]) {
        _type = CMThemeModelType_Custom;
        _themeId = themeId;
        _themeName = [_themeId copy];
        _themeVersion =@"1";
        _coverUrlString = coverImagePath;
        _localPathString = localPath;
    }
    return self;
}

// 从本地缓存创建
- (instancetype)initWithCachedInfoDic:(NSDictionary *)infoDic {
    if (self = [super init]) {
        _type = CMThemeModelType_Cached;
        _themeId = [[infoDic stringValueForKey:@"themeid"] copy];
        _themeName = [_themeId copy];
        _themeVersion = [[infoDic stringValueForKey:@"themever"] copy];
        _themeTitle = [[infoDic stringValueForKey:@"title"] copy];
        _coverUrlString = [[infoDic stringValueForKey:@"coverurl"] copy];
        _downloadUrlString = [[infoDic stringValueForKey:@"downloadurl"] copy];
        _zipSizeString = [[infoDic stringValueForKey:@"size"] copy];
        _localPathString = @"";
    }
    return self;
}

- (instancetype)initWithDefaultInfoDic:(NSDictionary *)infoDic {
    if (self = [super init]) {
        _type = CMThemeModelType_Default;
        _themeId = [[infoDic stringValueForKey:@"themeid"] copy];
        _themeVersion = [[infoDic stringValueForKey:@"themever"] copy];
        _themeTitle = [[infoDic stringValueForKey:@"title"] copy];
        _themeName = [[infoDic stringValueForKey:@"name" defaultValue:@"default"] copy];
        _coverUrlString = [[infoDic stringValueForKey:@"coverurl"] copy];
        _downloadUrlString = [[infoDic stringValueForKey:@"downloadurl"] copy];
        _zipSizeString = [[infoDic stringValueForKey:@"size"] copy];
        _localPathString = @"";
    }
    return self;
}

+ (CMThemeModel *)modelWithFetchedInfoDic:(NSDictionary *)infoDic {
    CMThemeModel* model = [CMThemeModel new];
    model.type = CMThemeModelType_Fetched;
    model.themeId = [infoDic stringValueForKey:@"themeid"];
    model.themeName = [infoDic stringValueForKey:@"themeid"];
    model.themeVersion = [infoDic stringValueForKey:@"themever"];
    model.themeTitle = [infoDic stringValueForKey:@"title"];
    model.coverUrlString = [infoDic stringValueForKey:@"coverurl"];
    model.downloadUrlString = [infoDic stringValueForKey:@"downloadurl"];
    model.zipSizeString = [infoDic stringValueForKey:@"size"];
    model.localPathString = @"";
    return model;
}

+ (CMThemeModel *)modelWithCachedInfoDic:(NSDictionary *)infoDic {
    CMThemeModel* model = [CMThemeModel new];
    model.type = CMThemeModelType_Cached;
    model.themeId = [infoDic stringValueForKey:@"themeid"];
    model.themeName = [infoDic stringValueForKey:@"themeid"];
    model.themeVersion = [infoDic stringValueForKey:@"themever"];
    model.themeTitle = [infoDic stringValueForKey:@"title"];
    model.coverUrlString = [infoDic stringValueForKey:@"coverurl"];
    model.downloadUrlString = [infoDic stringValueForKey:@"downloadurl"];
    model.zipSizeString = [infoDic stringValueForKey:@"size"];
    model.localPathString = @"";
    return model;
}

+ (CMThemeModel *)modelWithDefaultInfoDic:(NSDictionary *)infoDic {
    CMThemeModel* model = [CMThemeModel new];
    model.type = CMThemeModelType_Default;
    model.themeId = [infoDic stringValueForKey:@"themeid"];
    model.themeVersion = [infoDic stringValueForKey:@"themever"];
    model.themeTitle = [infoDic stringValueForKey:@"title"];
    model.themeName = [infoDic stringValueForKey:@"name" defaultValue:@"default"];
    model.coverUrlString = [infoDic stringValueForKey:@"coverurl"];
    model.downloadUrlString = [infoDic stringValueForKey:@"downloadurl"];
    model.zipSizeString = [infoDic stringValueForKey:@"size"];
    model.localPathString = @"";
    return model;
}

+ (CMThemeModel *)modelWithCustomInfoDic:(NSDictionary *)infoDic
{
    CMThemeModel* model = [CMThemeModel new];
    model.type = CMThemeModelType_Custom;
    if ([infoDic.allKeys containsObject:@"coverurl"]) {
        model.coverUrlString = [infoDic stringValueForKey:@"coverurl"];
    }else{
        model.coverUrlString = @"";
    }
    
    return model;
}

////假数据使用
//+ (CMThemeModel *)modifyModelWithModel:(CMThemeModel *)model
//{
//    CMThemeModel * themeModel = model;
//    model.type = CMThemeModelType_Custom;
//    return themeModel;
//}
@end
