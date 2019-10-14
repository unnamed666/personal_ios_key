//
//  CMPlayerView.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/8/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMPlayerViewDelegate <NSObject>
@optional
- (void)playButtonDidClick;
@end

@interface CMPlayerView : UIView
@property (nonatomic, weak) id<CMPlayerViewDelegate>delegate;
@property (nonatomic, copy) NSString * coverImageString;

- (void)setupPlayerWithSourceString:(NSString *)sourceString;
- (void)play;
- (void)pause;
@end
