//
//  CMTabBarButton.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTabBarButton.h"
#import "CMBizHelper.h"
#import "UIColor+HexColors.h"

@implementation CMTabBarButton
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [CMBizHelper getFontWithSize:9];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self setTitleColor:COLOR_WITH_RGBA(255, 255, 255, 1) forState:UIControlStateNormal];
        [self setTitleColor:COLOR_WITH_RGBA(44, 255, 253, 1) forState:UIControlStateSelected];
        
    }
    return self;
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height * 0.5;
    CGFloat titleX = 0;
    CGFloat titleY = contentRect.size.height * 0.5;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * 0.5;
    CGFloat imageX = 0;
    CGFloat imageY = contentRect.size.height * 0.1;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

-(void)setHighlighted:(BOOL)highlighted
{
    
}



@end
