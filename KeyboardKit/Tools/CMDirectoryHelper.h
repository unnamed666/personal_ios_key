//
//  CMDirectoryHelper.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

// 系统文件夹宏定义
#define CMDocumentDir [CMDirectoryHelper documentDir]
#define CMLibraryDir [CMDirectoryHelper libraryDir]
#define CMCachesDir [CMDirectoryHelper cachesDir]
#define CMAppSupportDir [CMDirectoryHelper appSupportDir]
#define CMTemporaryDir [CMDirectoryHelper temporaryDir]

// 业务文件夹宏定义
#define kLogDir [CMDirectoryHelper LogDir]
#define CMUzipDir [CMDirectoryHelper unzipThemeDir]

@interface CMDirectoryHelper : NSObject

// app所在的总的bundle文件夹
+ (NSString*)bundleDir;

// document文件夹
+ (NSString*)documentDir;

// Library文件夹
+ (NSString*)libraryDir;

// Library/caches
+ (NSString*)cachesDir;

// Library/applicationSupport
+ (NSString*)appSupportDir;

// tmp文件夹
+ (NSString*)temporaryDir;


// 业务相关文件夹
// Log文件夹
+ (NSString*)LogDir;

// 主题解压文件夹
+ (NSString*)unzipThemeDir;

// infoc暂存文件夹
+ (NSString*)infocDir;

+ (NSString *)diyBackgroundResourceDir;

+ (NSString *)diyFontsResourceDir;

+ (NSString *)diySoundResourceDir;

+ (BOOL)directoryHaveContent:(NSString*)filePath;//判断是否是目录,同时目录下有文件
+ (BOOL)fileExists:(NSString*)filePath;//判断文件是否存在
+ (void)deleteDirOrFile:(NSString*)path;//删除目录或文件
+ (BOOL)createDir:(NSString*)path;//创建目录
+ (BOOL)moveDirOrFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath;//移动目录/文件 或改名
+ (int)fielLen:(NSString*)filePath;//获取文件大小

+ (NSURL *)getPathCacheScreenshot; //获取截屏临时图片路径

+ (void)deleteFileContentName:(NSString *)fileName underPath:(NSString *)path;//删除目录下包含某个名字的文件

@end
