//
//  NSDictionary+Swizzle.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/11/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "NSDictionary+Swizzle.h"
#import <objc/runtime.h>
#import "NSObject+Swizzle.h"

@implementation NSDictionary (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self SwizzlingMethod:@"initWithObjects:forKeys:count:" systemClassString:@"__NSPlaceholderDictionary" toSafeMethodString:@"safe_initWithObjects:forKeys:count:" targetClassString:@"NSDictionary"];
    });
}

#pragma mark - Method Swizzling
- (instancetype)safe_initWithObjects:(id *)objects forKeys:(id<NSCopying> *)keys count:(NSUInteger)count {
    NSUInteger rightCount = 0;
    for (NSUInteger i = 0; i < count; i++) {
        if (!(keys[i] && objects[i])) {
            NSAssert(NO, @"index %@ == nil", @(i));
            break;
        }else{
            rightCount++;
        }
    }
    return [self safe_initWithObjects:objects forKeys:keys count:rightCount];
}

@end
