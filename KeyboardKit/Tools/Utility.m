//
//  Utility.m
//  PhotoGrid
//
//  Created by yang xueya on 12/14/12.
//
//

#import "Utility.h"

static inline NSString *searchPathForDirectoriesInUserDomain(NSSearchPathDirectory search)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(search, NSUserDomainMask, YES);
    assert(paths && paths.count > 0);
    
    if (paths.count > 0) {
        return paths[0];
    }
    
    return nil;
}

@implementation Utility

+ (NSString*)subPathForCacheDirectory:(NSString *)pathComponent
{
    return [self subPathForDirectory:NSCachesDirectory subPath:pathComponent];
}
+ (NSString*)subPathForDirectory:(NSSearchPathDirectory)searchPathDirectory subPath:(NSString*)pathComponent
{
    NSString *base = searchPathForDirectoriesInUserDomain(searchPathDirectory);
    NSString *fullPath = [base stringByAppendingPathComponent:pathComponent];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL folderExists = [manager fileExistsAtPath:fullPath isDirectory:&isDirectory];
    
    if (!(folderExists && isDirectory))
    {
        @synchronized(self) {
            folderExists = [manager fileExistsAtPath:fullPath isDirectory:&isDirectory];
            if (folderExists && isDirectory) {
                return fullPath;
            }
            
            NSError *error = nil;
            if (!isDirectory) {
                [manager removeItemAtPath:fullPath error:&error];
            }
            
            if (error) {
                return nil;
            }
            
            [manager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                return nil;
            }
        }
    }
    
    return fullPath;
}
@end

