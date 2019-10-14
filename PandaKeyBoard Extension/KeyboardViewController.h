//
//  KeyboardViewController.h
//  PandaKeyBoard Extension
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMEvent;
@class CMTextInputModel;

@interface KeyboardViewController : UIInputViewController
@property (nonatomic, strong)CMTextInputModel* currentInputModel;
@property (nonatomic, strong)UIView* currentToolBar;

- (void)coordinateWithString:(NSString*)str xArr:(NSMutableArray*)xArr yArr:(NSMutableArray*)yArr;

- (void)commit:(CMEvent *)event;

- (void)resetKeyboardTopView;

@end

