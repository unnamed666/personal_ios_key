//
//  NSString.h
//  Meng800
//
//  Created by 猎豹 on 14/7/19.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

// 字符串判空
+ (BOOL)stringIsEmpty:(NSString *)aString;
+ (BOOL)stringIsEmpty:(NSString *)aString shouldCleanWhiteSpace:(BOOL)cleanWhiteSpace;

- (NSNumber*)stringToNumber;

- (NSString*)lastLetterByLowercase;

+ (NSString*)firstLetterOfStringByLowercase:(NSString *)aString;

- (NSString*)md5;

- (NSString*)sha1;


//NSstring 转化为char类型
- (const char *)stringChangeToChar;

#pragma mark - REGEX
/**
 Takes in a regular expression string to determine whether self evaluates with it or not.
 @param regexString - NSString of the regular expression
 @returns BOOL
 */
- (BOOL)matchesRegex:(NSString *)regexString;

#pragma mark - Validation
- (BOOL)isChineseCharacter; // 是否为中文
- (BOOL)isEnglishCharacter; // 是否为英文

- (BOOL)isNormal;		// thanks to @uxyheaven
- (BOOL)isTelephone;
- (BOOL)isUserName;
- (BOOL)isChineseUserName;
- (BOOL)isPassword;
- (BOOL)isEmail;
- (BOOL)isUrl;
- (BOOL)isIPAddress;

/**
 nil, @"", @"  ", @"\n" will Returns NO; otherwise Returns YES.
 */
- (BOOL)isNotBlank;

/**
 Trim blank characters (space and newline) in head and tail.
 @return the trimmed string.
 */
- (NSString *)stringByTrim;


/**
 十进制转换十六进制
 
 @param decimal 十进制数
 @return 十六进制数
 */
+ (NSString *)getHexByDecimal:(long)decimal;

@end
