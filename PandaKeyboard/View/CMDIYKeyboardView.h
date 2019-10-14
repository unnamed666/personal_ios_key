//
//  CMDIYKeyboardView.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMDIYKeyboardView : UIView

- (void)switchTheme;
- (void)bindData:(NSArray<NSString*> *)words;
@end
