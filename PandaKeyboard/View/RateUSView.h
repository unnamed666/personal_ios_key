//
//  RateUSView.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/24.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RateUsDelegate <NSObject>

- (void) rateUsViewIsHidden;

@end

@interface RateUSView : UIView
@property(nonatomic, weak) id<RateUsDelegate> delegate;
@end
