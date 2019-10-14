//
//  CMRemindTipView.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/8/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTipsViewProtocol.h"

typedef enum : NSUInteger {
    CMSingleDirectionTop,
    CMSingleDirectionBottom,
    CMSingleDirectionLeft,//未实现
    CMSingleDirectionRight//未实现
} CMSingleDirection;

@interface CMRemindTipView : UIView <CMTipsViewProtocol>

- (instancetype)initWithImageName:(NSString *)imageName tipString:(NSString *)tipString singleDirection:(CMSingleDirection)direction percent:(CGFloat)percent;

@end
