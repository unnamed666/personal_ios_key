//
//  CMRowView.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/16.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMKeyButton;

@interface CMRowView : UIView

@property (nonatomic, assign)BOOL isTopMost;
@property (nonatomic, assign)BOOL isBottomMost;

@property (nonatomic, assign)CGFloat topPaddingRatio;
@property (nonatomic, assign)CGFloat bottomPaddingRatio;
@property (nonatomic, assign)CGFloat leftPaddingRatio;
@property (nonatomic, assign)CGFloat rightPaddingRatio;


@property (nonatomic, copy)NSArray<CMKeyButton*>* buttonArray;

@property (nonatomic, assign)CGFloat rowMargin;

@end
