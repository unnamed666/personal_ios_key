//
//  kLogger.h
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/10/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

// 方法跟踪
#define kLogTrace()  [kLogger logTrace:__FILE__ method:_cmd]

// 基本Log
#define kLog(frmt, ...) [kLogger log:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]

// Info型Log
#define kLogInfo(frmt, ...)  [kLogger logInfo:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]
#define kLogCInfo(frmt, ...)  [kLogger logCInfo:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]

// Warn型Log
#define kLogWarn(frmt, ...)  [kLogger logWarn:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]
#define kLogCWarn(frmt, ...)  [kLogger logCWarn:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]

// Error型Log
#define kLogError(frmt, ...)  [kLogger logError:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]
#define kLogCError(frmt, ...)  [kLogger logCError:__FILE__ method:_cmd format:(frmt), ## __VA_ARGS__]

@interface kLogger : NSObject

+ (void)setupLogger;

+ (void)logTrace:(const char *)file method:(SEL)method;

+ (void)log:(const char *)file method:(SEL)method format:(NSString *)format, ...;

+ (void)logInfo:(const char *)file method:(SEL)method format:(NSString *)format, ...;

+ (void)logCInfo:(const char *)file method:(SEL)method format:(NSString *)format, ...;

+ (void)logWarn:(const char *)file method:(SEL)method format:(NSString *)format, ...;

+ (void)logCWarn:(const char *)file method:(SEL)method format:(NSString *)format, ...;

+ (void)logError:(const char *)file method:(SEL)method format:(NSString *)format, ...;

+ (void)logCError:(const char *)file method:(SEL)method format:(NSString *)format, ...;


@end
