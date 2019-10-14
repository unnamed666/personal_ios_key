//
//  UIView+Constraint.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Constraint)
@property (nonatomic, readonly) NSArray *superviews;
@property (nonatomic, readonly) NSArray *allConstraints;
@property (nonatomic, readonly) NSArray *referencingConstraintsInSuperviews;
@property (nonatomic, readonly) NSArray *referencingConstraints;

// Single
- (NSLayoutConstraint *) constraintNamed: (NSString *) aName;
- (NSLayoutConstraint *) constraintNamed: (NSString *) aName matchingView: (UIView *) view;

// Multiple
- (NSArray *) constraintsNamed: (NSString *) aName;
- (NSArray *) constraintsNamed: (NSString *) aName matchingView: (UIView *) view;


// Retrieving constraints
- (NSLayoutConstraint *) constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (NSArray *) constraintsMatchingConstraints: (NSArray *) constraints;

// Constraints referencing a given view
- (NSArray *) constraintsReferencingView: (UIView *) view;

// Removing matching constraints
- (void) removeMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (void) removeMatchingConstraints: (NSArray *) anArray;

// Removing named constraints
- (void) removeConstraintsNamed: (NSString *) name;
- (void) removeConstraintsNamed: (NSString *) name matchingView: (UIView *) view;

@end
