//
//  CMKeyboardView.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMKeyboardModel.h"
#import "CMBaseKeyboardView.h"

@class CMKeyboardViewModel;
@class CMKeyboardView;
@class CMKeyModel;

typedef NS_ENUM(NSUInteger, CMKeyboardViewType) {
    CMKeyboardViewTypeMain,
    CMKeyboardViewTypeDiy
};

@protocol CMKeyboardViewDelegate <CMBaseKeyboardViewDelegate>

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard selectedSwitchOptionIndex:(NSUInteger)index keyModel:(CMKeyModel *)keyModel;

@end


@interface CMKeyboardView : CMBaseKeyboardView
@property (nonatomic, assign)BOOL isKVO;
@property (nonatomic, assign)BOOL isLayoutFinish;

@property (nonatomic, assign)CMKeyboardViewType keyboardViewType;

- (NSDictionary *)measureSubviews;

- (CMKeyboardType)keyboardType;

@end
