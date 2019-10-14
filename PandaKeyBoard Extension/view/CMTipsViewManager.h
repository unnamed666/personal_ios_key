//
//  CMTipsViewManager.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/10.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMTipsViewProtocol;

@interface CMTipsViewManager : NSObject

- (void)addTipsView:(id<CMTipsViewProtocol>)tipsView;

- (void)removeTipsView:(id<CMTipsViewProtocol>)tipsView;

- (id<CMTipsViewProtocol>)getTopTipsView;

- (void)removeAllTipsView;

@end
