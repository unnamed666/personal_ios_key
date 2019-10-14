//
//  CMCloudPrediction.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SuggestedWordInfo;

@protocol CMCloudPredictionDelegate <NSObject>

- (void)onGetCloudPredictionWord:(SuggestedWordInfo*)suggestWord;
- (BOOL)isComposingWord;//判断是否是 correction
@end

@interface CMCloudPrediction : NSObject
@property (nonatomic , weak) id<CMCloudPredictionDelegate> delegate;

- (void)swichLanguage;
- (void)connectPredictionService;
- (void)closeWebSocket;

- (void)updateSendId;
- (void)cloudReport;
- (NSUInteger)sendWord:(NSString*)word;//调用 sendWord 前必须调用  updateSendId

- (void)clickCloudPredictionIndex:(int)index upack:(NSString*)upack;

@end
