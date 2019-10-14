//
//  CMFullAccessTipStackView.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/9/15.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTipsViewProtocol.h"
#import "CMFullAccessTipView.h"

@interface CMFullAccessTipStackView : UIView<CMTipsViewProtocol>
@property (nonatomic, assign) CMTipsType tipsType;

@end
