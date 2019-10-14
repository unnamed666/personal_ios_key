//
//  CMCustomPageControl.m
//  PandaKeyboard
//
//  Created by zhoujing on 2017/11/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCustomPageControl.h"

@implementation CMCustomPageControl
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat dotWidth = 11;
    CGFloat dotHeight = 11;
    CGFloat currentDotWidth = 12;
    CGFloat currentDotHeight = 12;
    CGFloat gapWidth = currentDotWidth - dotWidth;
    CGFloat magrin = 28;
    CGFloat marginX = dotWidth + magrin;

    CGFloat newW = (self.subviews.count - 1) * marginX + currentDotWidth;

    //设置新frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newW, self.frame.size.height);

    //设置居中
    CGPoint center = self.center;
    center.x = self.superview.center.x;
    self.center = center;

    for (int i=0; i<[self.subviews count]; i++) {
        UIView* dot = [self.subviews objectAtIndex:i];

        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, currentDotWidth, currentDotHeight)];
        }else {
            if (i > self.currentPage) {
                [dot setFrame:CGRectMake(i * marginX+gapWidth, dot.frame.origin.y, dotWidth, dotHeight)];
            }else {
                [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, dotWidth, dotHeight)];
            }

        }
    }
}
- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    for (int i=0; i<[self.subviews count]; i++) {
        UIView* dot = [self.subviews objectAtIndex:i];
        
        if (i == self.currentPage) {
            dot.layer.borderWidth = 0;
            dot.layer.cornerRadius = 6;
        }else {
            dot.layer.borderWidth = 1;
            dot.layer.borderColor = COLOR_WITH_RGBA(84, 243, 238, 1).CGColor;
            dot.layer.cornerRadius = 5.5;
        }
    }
}
@end
