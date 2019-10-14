//
//  CMUISwitch.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "TTSwitch.h"

@interface CMUISwitch : TTSwitch

@property (nonatomic, strong) UIImage *trackImageOn UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *trackImageOff UI_APPEARANCE_SELECTOR;

@end
