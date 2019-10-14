//
//  CMEmojiSuggestManager.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/26.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMEmojiSuggest.h"
#import "CmposedData.h"
#import <sqlite3.h>
#import "CMCommUtil.h"
#import "CMSettingManager.h"

#ifndef kDatabaseName

#define kDatabaseName @"emoji.db"
#define kDatabaseTablePreName @"emoji_"

#endif

@interface CMEmojiSuggest()

@property (nonatomic) sqlite3 *database;
@property (nonatomic, strong) NSMutableArray* emojiDataTableArray;

@end

@implementation CMEmojiSuggest

- (instancetype)init
{
    if (self = [super init]) {
        [self openDb];
        [self emojiDataTableArray];
    }
    return self;
}

-(NSString *)getDatabasePath
{
    NSArray *fullPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [fullPath objectAtIndex:0];
    NSString *currentPath;
    currentPath = [documentDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isExist = [fm fileExistsAtPath:currentPath];
    NSString* projectPath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"db"];
    if (!isExist)
    {
        [fm copyItemAtPath:projectPath toPath:currentPath error:nil];
    }
    
    return projectPath;
}

-(void)openDb
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"db"];
    if (SQLITE_OK ==sqlite3_open(filePath.UTF8String, &_database))
    {
        kLogInfo(@"数据库打开成功!");
    }
    else
    {
        kLogInfo(@"数据库打开失败!");
    }
}

- (NSArray *)getSuggestEmojiList:(NSString *)dataToGetEmoji
{
    if (![self isSuitableDataTable])
    {
        return nil;
    }
    if(dataToGetEmoji.length<=0)return nil;
    
    NSString * languageMark = [CMCommUtil keyboardLanguageTypeToLang:kCMSettingManager.languageType];
    NSString* strSql = @"select emoji from emoji_%@ where keyword = '%@' order by frequency DESC";
    
    NSString* typeWord = dataToGetEmoji;
    typeWord = [typeWord lowercaseString];
    strSql = [[NSString alloc] initWithFormat:strSql, languageMark, typeWord];
    
    sqlite3_stmt *stmt = NULL;
    NSMutableArray* emojiArray = [[NSMutableArray alloc] init];
    int result = sqlite3_prepare_v2(_database, strSql.UTF8String, -1, &stmt, nil);
    if (result == SQLITE_OK)
    {
        kLogInfo(@"查询语句合法");
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const unsigned char *sname = sqlite3_column_text(stmt, 0);
            [emojiArray addObject:[NSString stringWithUTF8String:(const char *)sname]];
        }
    }
    else
    {
        kLogInfo(@"查询语句非法");
    }
    
    return [emojiArray copy];
}


- (NSMutableArray *)emojiDataTableArray
{
    if (!_emojiDataTableArray)
    {
        _emojiDataTableArray = [[NSMutableArray alloc] init];
        const char* sql = "select name from sqlite_master WHERE type = 'table'";
        sqlite3_stmt *stmt = NULL;
        int result = sqlite3_prepare_v2(_database, sql, -1, &stmt, nil);
        if (result == SQLITE_OK)
        {
            kLogInfo(@"查询语句合法");
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                const unsigned char *sname = sqlite3_column_text(stmt, 0);
                [_emojiDataTableArray addObject:[NSString stringWithUTF8String:(const char *)sname]];
            }
        }
    }
    
    return _emojiDataTableArray;
}

- (BOOL) isSuitableDataTable
{
    NSString * lang = [CMCommUtil keyboardLanguageTypeToLang:kCMSettingManager.languageType];
    for (int i = 0; i < self.emojiDataTableArray.count; i++)
    {
        NSString* tableName = [self.emojiDataTableArray objectAtIndex:i];
        NSString* strLanguageMark = [tableName substringFromIndex:kDatabaseTablePreName.length];
        if ([strLanguageMark isEqualToString:lang])
        {
            return YES;
        }
    }
    
    return NO;
}

@end
