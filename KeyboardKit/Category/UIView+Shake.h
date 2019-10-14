//
//  UIView+Shake.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/9/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shake)

- (void)shakeWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^ __nullable)(BOOL finished))completion;

@end
