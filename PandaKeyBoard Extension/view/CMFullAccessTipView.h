//
//  CMFullAccessTipView.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTipsView.h"

typedef NS_ENUM(NSUInteger, CMTipsType) {
    CMTipsTypeCloudPrediction = 1,// 提示用户开启完全访问以使用云预测
    CMTipsTypeKeyboardSound = 2,// 提示用户若使用按键音请开启完全访问
    CMTipsTypeCursorMove = 3, // 提示用户若使用光标移动功能请开启完全访问
    CMTipsTypeEmoticons = 4, // 提示用户若使用emoticons功能请开启完全访问
    CMTipsTypeGif = 5, //提示用户开启完全访问以使用Gif
};


@interface CMFullAccessTipView : CMTipsView <CMTipsViewProtocol>
@property (nonatomic, assign) CMTipsType tipsType;

@end
