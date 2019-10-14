//
//  UITouch+property.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/20.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITouch (property)
@property (nonatomic, assign)BOOL onScreen;//touchesBegan和touchesEnded之间使用,默认 NO, touchesEnded结束后必须为 NO.
@end
