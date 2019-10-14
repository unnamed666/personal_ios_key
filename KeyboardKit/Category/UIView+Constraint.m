//
//  UIView+Constraint.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "UIView+Constraint.h"
#import "NSLayoutConstraint+Matching.h"

@implementation UIView (Constraint)

// Return an array of all superviews
- (NSArray *) superviews
{
    NSMutableArray *array = [NSMutableArray array];
    UIView *view = self.superview;
    while (view)
    {
        [array addObject:view];
        view = view.superview;
    }
    
    return array;
}

// Returns first constraint with matching name
// Type not checked
- (NSLayoutConstraint *) constraintNamed: (NSString *) aName
{
    if (!aName) return nil;
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.identifier && [constraint.identifier isEqualToString:aName])
            return constraint;
    
    // Recurse up the tree
    if (self.superview)
        return [self.superview constraintNamed:aName];
    
    return nil;
}

// Returns first constraint with matching name and view.
// Type not checked
- (NSLayoutConstraint *) constraintNamed: (NSString *) aName matchingView: (UIView *) theView
{
    if (!aName) return nil;
    
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.identifier && [constraint.identifier isEqualToString:aName])
        {
            if (constraint.firstItem == theView)
                return constraint;
            if (constraint.secondItem && (constraint.secondItem == theView))
                return constraint;
        }
    
    // Recurse up the tree
    if (self.superview)
        return [self.superview constraintNamed:aName matchingView:theView];
    
    return nil;
}

// Returns all matching constraints
// Type not checked
- (NSArray *) constraintsNamed: (NSString *) aName
{
    // For this, all constraints match a nil item
    if (!aName) return self.constraints;
    
    // However, constraints have to have a name to match a non-nil name
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.identifier && [constraint.identifier isEqualToString:aName])
            [array addObject:constraint];
    
    // recurse upwards
    if (self.superview)
        [array addObjectsFromArray:[self.superview constraintsNamed:aName]];
    
    return array;
}

// Returns all matching constraints specific to a given view
// Type not checked
- (NSArray *) constraintsNamed: (NSString *) aName matchingView: (UIView *) theView
{
    // For this, all constraints match a nil item
    if (!aName) return self.constraints;
    
    // However, constraints have to have a name to match a non-nil name
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.identifier && [constraint.identifier isEqualToString:aName])
        {
            if (constraint.firstItem == theView)
                [array addObject:constraint];
            else if (constraint.secondItem && (constraint.secondItem == theView))
                [array addObject:constraint];
        }
    
    // recurse upwards
    if (self.superview)
        [array addObjectsFromArray:[self.superview constraintsNamed:aName matchingView:theView]];
    
    return array;
}

// Find first matching constraint. (Priority, Archiving ignored)
- (NSLayoutConstraint *) constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSArray *views = [@[self] arrayByAddingObjectsFromArray:self.superviews];
    for (UIView *view in views)
        for (NSLayoutConstraint *constraint in view.constraints)
            if ([constraint isEqualToLayoutConstraint:aConstraint])
                return constraint;
    
    return nil;
}


// Return all constraints from self and subviews
// Call on self.window for the entire collection
- (NSArray *) allConstraints
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.constraints];
    for (UIView *view in self.subviews)
        [array addObjectsFromArray:[view allConstraints]];
    return array;
}

// Ancestor constraints pointing to self
- (NSArray *) referencingConstraintsInSuperviews
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.superviews)
    {
        for (NSLayoutConstraint *constraint in view.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint refersToView:self])
                [array addObject:constraint];
        }
    }
    return array;
}

// Ancestor *and* self constraints pointing to self
- (NSArray *) referencingConstraints
{
    NSMutableArray *array = [self.referencingConstraintsInSuperviews mutableCopy];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (![constraint.class isEqual:[NSLayoutConstraint class]])
            continue;
        
        if ([constraint refersToView:self])
            [array addObject:constraint];
    }
    return array;
}

// Find all matching constraints. (Priority, archiving ignored)
// Use with arrays returned by format strings to find installed versions
- (NSArray *) constraintsMatchingConstraints: (NSArray *) constraints
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in constraints)
    {
        NSLayoutConstraint *match = [self constraintMatchingConstraint:constraint];
        if (match)
            [array addObject:match];
    }
    return array;
}

// All constraints matching view in this ascent
// See also: referencingConstraints and referencingConstraintsInSuperviews
- (NSArray *) constraintsReferencingView: (UIView *) theView
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *views = [@[self] arrayByAddingObjectsFromArray:self.superviews];
    
    for (UIView *view in views)
        for (NSLayoutConstraint *constraint in view.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint refersToView:theView])
                [array addObject:constraint];
        }
    
    return array;
}

// Remove constraint
- (void) removeMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSLayoutConstraint *match = [self constraintMatchingConstraint:aConstraint];
    if (match) {
        [NSLayoutConstraint deactivateConstraints:@[match]];
    }
}

// Remove constraints
// Use for removing constraings generated by format
- (void) removeMatchingConstraints: (NSArray *) anArray
{
    for (NSLayoutConstraint *constraint in anArray)
        [self removeMatchingConstraint:constraint];
}

// Remove constraints via name
- (void) removeConstraintsNamed: (NSString *) name
{
    NSArray *array = [self constraintsNamed:name];
    if (array && array.count > 0) {
        [NSLayoutConstraint deactivateConstraints:array];
    }
}

// Remove named constraints matching view
- (void) removeConstraintsNamed: (NSString *) name matchingView: (UIView *) theView
{
    NSArray *array = [self constraintsNamed:name matchingView:theView];
    if (array && array.count > 0) {
        [NSLayoutConstraint deactivateConstraints:array];
    }
}

@end
