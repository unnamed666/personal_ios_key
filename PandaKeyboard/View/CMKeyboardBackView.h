//
//  CMKeyboardBackView.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/29.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMKeyboardBackViewDelegate <NSObject>

- (void) keyboardBackViewTouched;

@end

@interface CMKeyboardBackView : UIView

@property (nonatomic, weak) id<CMKeyboardBackViewDelegate> delegate;

@end
