//
//  NSObject+Swizzle.m
//  KeyboardKit
//
//  Created by 姚宗超 on 2017/11/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

+ (void)SwizzlingMethod:(NSString *)systemMethodString systemClassString:(NSString *)systemClassString toSafeMethodString:(NSString *)safeMethodString targetClassString:(NSString *)targetClassString{
    //获取系统方法IMP
    Method sysMethod = class_getInstanceMethod(NSClassFromString(systemClassString), NSSelectorFromString(systemMethodString));
    //自定义方法的IMP
    Method safeMethod = class_getInstanceMethod(NSClassFromString(targetClassString), NSSelectorFromString(safeMethodString));
    
    BOOL didAddMethod =
    class_addMethod(NSClassFromString(systemClassString),
                    NSSelectorFromString(systemMethodString),
                    method_getImplementation(safeMethod),
                    method_getTypeEncoding(safeMethod));
    
    if (didAddMethod) {
        class_replaceMethod(NSClassFromString(systemClassString),
                            NSSelectorFromString(safeMethodString),
                            method_getImplementation(sysMethod),
                            method_getTypeEncoding(sysMethod));
    } else {
        method_exchangeImplementations(sysMethod, safeMethod);
    }
}

@end
