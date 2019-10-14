//
//  kLogger.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/10/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMLogger.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

#define yaozongchao

#ifndef LOG_OFF
#if DEBUG && defined(yaozongchao)
static const DDLogLevel ddLogLevel = DDLogLevelVerbose; // Log level for yaozongchao (debug)
#elif DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelInfo; // Log level for other team members (debug)
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning; // Log level for release build
#endif
#else
static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif

@implementation kLogger

+ (void)setupLogger {
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
//    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
}

+ (void)logTrace:(const char *)file method:(SEL)method {
    DDLogVerbose(@"👣[TRACE] %@,%@", DDExtractFileNameWithoutExtension(file, NO), NSStringFromSelector(method));
}


+ (void)log:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagVerbose context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"🙏[DEFAULT] %@,%@ %@", DDExtractFileNameWithoutExtension(file, NO), NSStringFromSelector(method), message];
        va_end(args);
    }
}

+ (void)logInfo:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;

    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagInfo context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"💧[INFO] %@,%@ %@", DDExtractFileNameWithoutExtension(file, NO), NSStringFromSelector(method), message];
        va_end(args);
    }
    else {
        [kLogger logTrace:file method:method];
    }
}

+ (void)logCInfo:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagInfo context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"💧[CINFO] %@", message];
        va_end(args);
    }
    else {
        [kLogger logTrace:file method:method];
    }
}

+ (void)logWarn:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagWarning context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"❓[WARN] %@,%@ %@", DDExtractFileNameWithoutExtension(file, NO), NSStringFromSelector(method), message];
        va_end(args);
    }
    else {
        [kLogger logTrace:file method:method];
    }
}

+ (void)logCWarn:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagWarning context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"❓[CWARN] %@", message];
        va_end(args);
    }
    else {
        [kLogger logTrace:file method:method];
    }
}

+ (void)logError:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagError context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"❗️[ERROR] %@,%@ %@", DDExtractFileNameWithoutExtension(file, NO), NSStringFromSelector(method), message];
        va_end(args);
    }
    else {
        [kLogger logTrace:file method:method];
    }
}

+ (void)logCError:(const char *)file method:(SEL)method format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        va_start(args, format);
        [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:DDLogFlagError context:0 file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ tag:nil format:@"❗️[ERROR] %@", message];
        va_end(args);
    }
    else {
        [kLogger logTrace:file method:method];
    }
}

@end
