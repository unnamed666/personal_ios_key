//
//  CMDirectoryHelper.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMDirectoryHelper.h"
#import "CMMacro.h"

@implementation CMDirectoryHelper

+ (BOOL)createDirIfNeccesary:(NSString *)dirPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    bool isCreated = false;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return isCreated || existed;
}

// app所在的总的bundle文件夹
+ (NSString*)bundleDir
{
    //get the main bundel
    NSBundle *bundle = [NSBundle mainBundle];
    //get the path of home directory
    NSString *bundlePath = [bundle bundlePath];
    
    return bundlePath;
}

// document文件夹
+ (NSString*)documentDir
{
    /*use following c function to find any directory, just you need to provide the directory type*/
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    //find the actual path
    NSString* docDir = [paths objectAtIndex:0];
    return docDir;
}

// Library文件夹
+ (NSString*)libraryDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDirectory = [paths objectAtIndex:0];
    return libDirectory;
}

// Library/caches
+ (NSString*)cachesDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return cachesDirectory;
}

// Library/applicationSupport itune会保存此文件夹
+ (NSString*)appSupportDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    return dir;
}

// tmp文件夹
+ (NSString*)temporaryDir
{
    return NSTemporaryDirectory();
}


// 业务相关文件夹
// Log文件夹
+ (NSString*)LogDir
{
    NSString* userId = @"";
    NSString* path = [NSString stringWithFormat:@"%@/%@", userId, @""];
    NSString* dirPath = [CMDocumentDir stringByAppendingPathComponent:path];
    BOOL succeed = [CMDirectoryHelper createDirIfNeccesary:dirPath];
    if (succeed) {
        return dirPath;
    }
    return nil;
}

// 主题解压文件夹
+ (NSString*)unzipThemeDir {
    NSString* dirPath = [CMLibraryDir stringByAppendingPathComponent:@"Themes"];
    BOOL succeed = [CMDirectoryHelper createDirIfNeccesary:dirPath];
    if (succeed) {
        return dirPath;
    }
    return nil;
}

// infoc暂存文件夹
+ (NSString*)infocDir {
    NSString* dirPath = [CMLibraryDir stringByAppendingPathComponent:@"infoc"];
    BOOL succeed = [CMDirectoryHelper createDirIfNeccesary:dirPath];
    if (succeed) {
        return dirPath;
    }
    return nil;
}

+ (NSString *)diyBackgroundResourceDir
{
    NSString *dirPath = [CMLibraryDir stringByAppendingPathComponent:@"diyBackground"];
    BOOL succeed = [CMDirectoryHelper createDirIfNeccesary:dirPath];
    if (succeed) {
        return dirPath;
    }
    return nil;
}

+ (NSString *)diyFontsResourceDir
{
    NSString *dirPath = [CMLibraryDir stringByAppendingPathComponent:@"diyFonts"];
    BOOL succeed = [CMDirectoryHelper createDirIfNeccesary:dirPath];
    if (succeed) {
        return dirPath;
    }
    return nil;
}

+(NSString *)diySoundResourceDir{
    NSString *dirPath = [CMLibraryDir stringByAppendingPathComponent:@"diySounds"];
    BOOL succeed = [CMDirectoryHelper createDirIfNeccesary:dirPath];
    if (succeed) {
        return dirPath;
    }
    return nil;
}

+ (BOOL)fileExists:(NSString*)filePath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    return  [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
}


+ (BOOL)directoryExists:(NSString*)filePath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    return  [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
}


+ (BOOL)directoryHaveContent:(NSString*)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL dir = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if(!dir)return NO;
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    return (arr != nil && arr.count>0);
}

+ (void)deleteDirOrFile:(NSString*)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

+ (BOOL)moveDirOrFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * err;
    [fileManager moveItemAtPath:oldPath toPath:newPath error:&err];
    if(err)return NO;
    
    return YES;
}

+ (BOOL)createDir:(NSString*)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        NSError * err;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        if(err)return NO;
    }
    
    return YES;
    
}

+ (int)fielLen:(NSString*)filePath{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return  [attributes[NSFileSize] intValue];
}

+ (NSURL *)getPathCacheScreenshot{
    NSString *shotPathStr = [kPathTemp stringByAppendingPathComponent:@"shotTem"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:shotPathStr]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:shotPathStr withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSURL fileURLWithPath:shotPathStr];
}

+ (void)deleteFileContentName:(NSString *)fileName underPath:(NSString *)path{
    NSError *error = nil;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    NSEnumerator *erator = [content objectEnumerator];
    NSString *objName;
    while (objName = [erator nextObject]) {
        if ([objName containsString:fileName]) {
            [self deleteDirOrFile:[path stringByAppendingPathComponent:objName]];
        }
    }
}


@end
