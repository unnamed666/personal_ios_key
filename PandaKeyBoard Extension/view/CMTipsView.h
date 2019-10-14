//
//  CMTipsView.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/10/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTipsViewProtocol.h"

@interface CMTipsView : UIView <CMTipsViewProtocol>
@property (nonatomic, strong) UILabel * label;
@end
