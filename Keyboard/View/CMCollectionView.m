//
//  CMCollectionView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCollectionView.h"

@implementation CMCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchDelegate) {
        [self.touchDelegate onCollectionView:self touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.touchDelegate) {
        [self.touchDelegate onCollectionView:self touchesMoved:touches withEvent:event];
    }
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.touchDelegate) {
        [self.touchDelegate onCollectionView:self touchesEnded:touches withEvent:event];
    }
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.touchDelegate) {
        [self.touchDelegate onCollectionView:self touchesCancelled:touches withEvent:event];
    }
    [super touchesCancelled:touches withEvent:event];
}
@end
