//
//  SettingData.h
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/10.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingData : NSObject

@property(nonatomic) NSArray* languageArray;
@property(nonatomic) BOOL autoCapital;
@property(nonatomic) BOOL doubleSpacePeriod;
@property(nonatomic) BOOL showCorrectionSuggestions;
@property(nonatomic) BOOL autoCorrectionSuggestions;
@property(nonatomic) BOOL nextWordSuggestions;
@property(nonatomic) BOOL historySuggestions;

// 滑动输入
@property (nonatomic, assign, getter=isSlideInputEnable)BOOL slideInputEnable;

#ifdef DEBUG
@property (nonatomic, assign, getter=isTensorFlowABTestEnable)BOOL tensorFlowABTestEnable;
@property (nonatomic, copy) NSString * mccTestString;
#endif

@property(nonatomic, assign) BOOL openKeyboardSound;

@property(nonatomic, assign) BOOL vibrationEnable;

@end
