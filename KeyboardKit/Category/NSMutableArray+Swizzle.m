//
//  NSMutableArray+Swizzle.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/11/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "NSMutableArray+Swizzle.h"
#import <objc/runtime.h>
#import "NSObject+Swizzle.h"

@implementation NSMutableArray (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self SwizzlingMethod:@"addObject:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_addObject:" targetClassString:@"NSMutableArray"];
        [self SwizzlingMethod:@"insertObject:atIndex:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_insertObject:atIndex:" targetClassString:@"NSMutableArray"];
        [self SwizzlingMethod:@"removeObjectAtIndex:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_removeObjectAtIndex:" targetClassString:@"NSMutableArray"];
        [self SwizzlingMethod:@"replaceObjectAtIndex:withObject:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_replaceObjectAtIndex:withObject:" targetClassString:@"NSMutableArray"];
        [self SwizzlingMethod:@"removeObjectsAtIndexes:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_removeObjectsAtIndexes:" targetClassString:@"NSMutableArray"];
        [self SwizzlingMethod:@"removeObjectsInRange:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_removeObjectsInRange:" targetClassString:@"NSMutableArray"];
//        [self SwizzlingMethod:@"objectAtIndex:" systemClassString:@"__NSArrayM" toSafeMethodString:@"safe_objectAtIndex:" targetClassString:@"NSMutableArray"];
    });
}

#pragma mark - Method Swizzling

- (void)safe_addObject:(id)anObject{
    if (!anObject) {
        NSAssert(NO, @"object is nil");
        return;
    }
    [self safe_addObject:anObject];
}

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (index > [self count]) {
        NSAssert(NO, @"index %@ > count %@", @(index), @(self.count));
        return;
    }
    if (!anObject) {
        NSAssert(NO, @"object is nil");
        return;
    }
    [self safe_insertObject:anObject atIndex:index];
}

- (void)safe_removeObjectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        NSAssert(NO, @"index %@ >= count %@", @(index), @(self.count));
        return;
    }
    
    return [self safe_removeObjectAtIndex:index];
}

- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index >= [self count]) {
        NSAssert(NO, @"index %@ >= count %@", @(index), @(self.count));
        return;
    }
    if (!anObject) {
        NSAssert(NO, @"object is nil");
        return;
    }
    [self safe_replaceObjectAtIndex:index withObject:anObject];
}

- (void)safe_removeObjectsAtIndexes:(NSIndexSet *)indexes{
    NSMutableIndexSet * mutableSet = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < [self count]) {
            [mutableSet addIndex:idx];
        }
    }];
    [self safe_removeObjectsAtIndexes:mutableSet];
}

- (void)safe_removeObjectsInRange:(NSRange)range{
    //获取最大索引
    if (range.location + range.length - 1 < [self count]) {
        [self safe_removeObjectsInRange:range];
        return;
    }
    if (range.location >= [self count]) {
        NSAssert(NO, @"range.location %@ >= count %@", @(range.location), @(self.count));
        return;
    }
    NSInteger tempInteger = range.location + range.length - 1;
    while (tempInteger >= [self count]) {
        tempInteger -= 1;
    }
    NSRange tempRange = NSMakeRange(range.location, tempInteger + 1 -range.location);
    [self safe_removeObjectsInRange:tempRange];
}

- (id)safe_objectAtIndex:(NSUInteger)index{
    //判断数组是否越界
    if (index >= [self count]) {
        NSAssert(NO, @"index %@ > count %@", @(index), @(self.count));
        return nil;
    }
    return [self safe_objectAtIndex:index];
}

@end
