//
//  CMMacro.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#ifndef CMMacro_h
#define CMMacro_h

// block retain cycle
#ifndef    weakify
#if __has_feature(objc_arc)
#define weakify( x )    autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x;
#else    // #if __has_feature(objc_arc)
#define weakify( x )    autoreleasepool{} __block __typeof__(x) __block_##x##__ = x;
#endif    // #if __has_feature(objc_arc)
#endif    // #ifndef    weakify

#ifndef    stronglize
#if __has_feature(objc_arc)
#define stronglize( x )    try{} @finally{} __typeof__(x) x = __weak_##x##__;
#else    // #if __has_feature(objc_arc)
#define stronglize( x )    try{} @finally{} __typeof__(x) x = __block_##x##__;
#endif    // #if __has_feature(objc_arc)
#endif    // #ifndef    @stronglize

//#ifdef DEBUG
//#define kLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
//#else
//#define kLog(...)
//#endif


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define KWidth_Scale    kScreenWidth/375.0f
//#define KScalePt(pt)    pt*kScreenWidth/375.0f
#define KScalePt(pt)    [CMBizHelper getRatioPoint:pt]
#define KScaleKeyboard(pt) [CMBizHelper getKeyboardRatioPoint:pt]



#define rgba(r, g, b, a) [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:a]
#define rgb(r, g, b) rgba(r, g, b, 1.f)
#define kNativeScale [[UIScreen mainScreen] nativeScale]

#endif /* CMMacro_h */

// 定义单例的宏
//#undef	AS_SINGLETON
//#define AS_SINGLETON( __class ) \
//+ (__class *)sharedInstance;
//
//#undef	DEF_SINGLETON
//#define DEF_SINGLETON( __class ) \
//+ (__class *)sharedInstance \
//{ \
//static dispatch_once_t once; \
//static __class * __singleton__; \
//dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
//return __singleton__; \
//}

//获取temp
#define kPathTemp NSTemporaryDirectory()
//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

#define kPathEmoticonGif [kPathDocument stringByAppendingPathComponent:@"EmoGif"]

#define PD_ERROR_DOMAIN   @"PD_ERROR_DOMAIN"

//Userdefault
#define kHasReportTheInstalledAppListDate  @"has_report_the_installed_app_list_date"


