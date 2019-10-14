/*
 *  CommonKit.h
 *
 *  Created by Xueya Yang on 10-9-29.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */



//DLOG
#ifdef DEBUG

#define DLOG(...) do { \
    NSLog(@"[D] %s:%d %s\n", __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]); \
} while (0)

#define INFO(...) do { \
    time_t __now = time(NULL); \
    struct tm *__local = localtime(&__now); \
    printf("\033[fg0,255,0;[I] %02d:%02d:%02d\033[; \033[fg255,0,255;%s:%d\033[; \033[fg0,255,0;%s\n\033[;", __local->tm_hour, __local->tm_min, __local->tm_sec, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]); \
} while (0)

#define WARN(...) do { \
    time_t __now = time(NULL); \
    struct tm *__local = localtime(&__now); \
    printf("\033[fg255,127,0;[W] %02d:%02d:%02d\033[; \033[fg255,0,255;%s:%d\033[; \033[fg255,127,0;%s\n\033[;", __local->tm_hour, __local->tm_min, __local->tm_sec, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]); \
} while (0)

#define ERROR(...) do { \
    time_t __now = time(NULL); \
    struct tm *__local = localtime(&__now); \
    printf("\033[fg255,0,0;[E] %02d:%02d:%02d\033[; \033[fg255,0,255;%s:%d\033[; \033[fg255,0,0;%s\n\033[;", __local->tm_hour, __local->tm_min, __local->tm_sec, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]); \
} while (0)

#else
#define DLOG(...) do {} while(0)
#define INFO(...) do {} while(0)
#define WARN(...) do {} while(0)
#define ERROR(...) do {} while(0)
#endif

