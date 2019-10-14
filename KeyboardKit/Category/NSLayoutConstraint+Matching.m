//
//  NSLayoutConstraint+Matching.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "NSLayoutConstraint+Matching.h"

@implementation NSLayoutConstraint (Matching)


// This ignores any priority, looking only at y (R) mx + b
- (BOOL) isEqualToLayoutConstraint: (NSLayoutConstraint *) constraint
{
    // I'm still wavering on these two checks
    if (![self.class isEqual:[NSLayoutConstraint class]]) return NO;
    if (![self.class isEqual:constraint.class]) return NO;
    
    // Compare properties
    if (self.firstItem != constraint.firstItem) return NO;
    if (self.secondItem != constraint.secondItem) return NO;
    if (self.firstAttribute != constraint.firstAttribute) return NO;
    if (self.secondAttribute != constraint.secondAttribute) return NO;
    if (self.relation != constraint.relation) return NO;
    if (self.multiplier != constraint.multiplier) return NO;
    if (self.constant != constraint.constant) return NO;
    
    return YES;
}

// This looks at priority too
- (BOOL) isEqualToLayoutConstraintConsideringPriority:(NSLayoutConstraint *)constraint
{
    if (![self isEqualToLayoutConstraint:constraint])
        return NO;
    
    return (self.priority == constraint.priority);
}

- (BOOL) refersToView: (UIView *) theView
{
    if (!theView)
        return NO;
    if (!self.firstItem) // shouldn't happen. Illegal
        return NO;
    if (self.firstItem == theView)
        return YES;
    if (!self.secondItem)
        return NO;
    return (self.secondItem == theView);
}

- (BOOL) isHorizontal
{
    return IS_HORIZONTAL_ATTRIBUTE(self.firstAttribute);
}

@end
