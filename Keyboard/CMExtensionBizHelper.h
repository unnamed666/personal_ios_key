//
//  CMExtensionBizHelper.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMKeyButton;

@interface CMExtensionBizHelper : NSObject

+ (void)playVibration:(BOOL)cancelPre;

+ (BOOL)shouldUseTensorFlow;

+ (CMKeyButton *)findNearestKeyButtonInView:(UIView *)keyboardView point:(CGPoint)point;

@end
