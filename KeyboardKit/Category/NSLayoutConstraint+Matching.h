//
//  NSLayoutConstraint+Matching.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_SIZE_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight)] containsObject:@(ATTRIBUTE)]
#define IS_CENTER_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY)] containsObject:@(ATTRIBUTE)]
#define IS_EDGE_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]
#define IS_LOCATION_ATTRIBUTE(ATTRIBUTE) (IS_EDGE_ATTRIBUTE(ATTRIBUTE) || IS_CENTER_ATTRIBUTE(ATTRIBUTE))

#define IS_HORIZONTAL_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeCenterX), @(NSLayoutAttributeWidth)] containsObject:@(ATTRIBUTE)]
#define IS_VERTICAL_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeHeight), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]

#define IS_HORIZONTAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllLeft), @(NSLayoutFormatAlignAllRight), @(NSLayoutFormatAlignAllLeading), @(NSLayoutFormatAlignAllTrailing), @(NSLayoutFormatAlignAllCenterX), ] containsObject:@(ALIGNMENT)]
#define IS_VERTICAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllTop), @(NSLayoutFormatAlignAllBottom), @(NSLayoutFormatAlignAllCenterY), @(NSLayoutFormatAlignAllBaseline), ] containsObject:@(ALIGNMENT)]

@interface NSLayoutConstraint (Matching)

- (BOOL) isEqualToLayoutConstraint: (NSLayoutConstraint *) constraint;
- (BOOL) isEqualToLayoutConstraintConsideringPriority: (NSLayoutConstraint *) constraint;
- (BOOL) refersToView: (UIView *) aView;
@property (nonatomic, readonly) BOOL isHorizontal;

@end
