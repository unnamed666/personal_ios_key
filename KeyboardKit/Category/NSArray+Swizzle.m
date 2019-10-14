//
//  NSArray+Swizzle.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/11/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "NSArray+Swizzle.h"
#import <objc/runtime.h>
#import "NSObject+Swizzle.h"

@implementation NSArray (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        [self SwizzlingMethod:@"objectAtIndex:" systemClassString:@"__NSArrayI" toSafeMethodString:@"safe_objectAtIndex:" targetClassString:@"NSArray"];
        [self SwizzlingMethod:@"initWithObjects:count:" systemClassString:@"__NSPlaceholderArray" toSafeMethodString:@"safe_initWithObjects:count:" targetClassString:@"NSArray"];
        [self SwizzlingMethod:@"arrayByAddingObject:" systemClassString:@"__NSArrayI" toSafeMethodString:@"safe_arrayByAddingObject:" targetClassString:@"NSArray"];
    });
}

#pragma mark - Method Swizzling

- (id)safe_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self safe_objectAtIndex:index];
    } else {
        NSAssert(NO, @"index %@ > count %@", @(index), @(self.count));
        return nil;
    }
}

- (NSArray *)safe_arrayByAddingObject:(id)anObject {
    if (!anObject) {
        NSAssert(NO, @"object is nil");
        return self;
    }
    return [self safe_arrayByAddingObject:anObject];
}

- (instancetype)safe_initWithObjects:(id *)objects count:(NSUInteger)count {
    NSUInteger newCount = 0;
    for (NSUInteger i = 0; i < count; i++) {
        if (!objects[i]) {
            NSAssert(NO, @"index %@ == nil", @(i));
            break;
        }
        newCount++;
    }
    return [self safe_initWithObjects:objects count:newCount];
}


@end
