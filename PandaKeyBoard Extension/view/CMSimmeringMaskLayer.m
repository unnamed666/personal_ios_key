//
//  CMSimmeringMaskLayer.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/8/22.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMSimmeringMaskLayer.h"

@implementation CMSimmeringMaskLayer

- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        _fadeLayer = [[CALayer alloc] init];
        [self addSublayer:_fadeLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    CGRect r = self.bounds;
    _fadeLayer.bounds = r;
    _fadeLayer.position = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
    //    _fadeLayer.opacity = 0.0;
    
    //    _fadeLayer.borderColor = [UIColor redColor].CGColor;
    //    _fadeLayer.borderWidth = 1;
}
@end
