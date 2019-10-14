//
//  CMEvent.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/11.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CMKeyModel;

typedef NS_ENUM(int, CMEventCode) {
    CMEventCodeInput = 1,
    CMEventCodeThemeBoard ,
    CMEventCodeTheme,
    CMEventCodeGoThemeCenter,
    CMEventCodeAdvanceToNextInputMode,
    
};


@interface CMEvent : NSObject
@property (nonatomic , strong) CMKeyModel* key;
@property (nonatomic , assign) CMEventCode code;
@property (nonatomic , assign) CGPoint origin;//按键控件的左上角点，用与preview等显示的位置用
@property (nonatomic , assign) CGPoint touchPoint;//手指点按的位置，xy值相对于主键盘，用于获取Suggestions
@property (nonatomic , strong) NSObject* object;

+(instancetype)obtainEvent;
-(void)recycle;

+ (instancetype)obtainEventByCMKeyModel:(CMKeyModel *)keyModel;
+ (instancetype)obtainEventByLetter:(NSString *)letter ;
@end
