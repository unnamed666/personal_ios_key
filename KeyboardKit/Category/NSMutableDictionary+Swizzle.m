//
//  NSMutableDictionary+Swizzle.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/11/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "NSMutableDictionary+Swizzle.h"
#import <objc/runtime.h>
#import "NSObject+Swizzle.h"

@implementation NSMutableDictionary (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self SwizzlingMethod:@"removeObjectForKey:" systemClassString:@"__NSDictionaryM" toSafeMethodString:@"safe_removeObjectForKey:" targetClassString:@"NSMutableDictionary"];
        [self SwizzlingMethod:@"setObject:forKey:" systemClassString:@"__NSDictionaryM" toSafeMethodString:@"safe_setObject:forKey:" targetClassString:@"NSMutableDictionary"];
    });
}

#pragma mark - Method Swizzling
- (void)safe_removeObjectForKey:(id)key {
    if (!key) {
        NSAssert(NO, @"key is nil");
        return;
    }
    [self safe_removeObjectForKey:key];
}

- (void)safe_setObject:(id)obj forKey:(id <NSCopying>)key {
    if (!obj) {
        NSAssert(NO, @"object is nil");
        return;
    }
    if (!key) {
        NSAssert(NO, @"key is nil");
        return;
    }
    [self safe_setObject:obj forKey:key];
}

@end
