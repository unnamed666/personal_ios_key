//
//  CloudPredictionReport.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>


UIKIT_EXTERN int const REPORT_PREDICTION_TYPE_WORD;
UIKIT_EXTERN int const REPORT_PREDICTION_TYPE_GIF;

@interface CloudPredictionReport : NSObject
@property (nonatomic ,readonly,strong) NSString* upack;
@property (nonatomic ,assign) short  selectIndex;
@property (nonatomic ,readonly,assign) Byte  predictionType;
@property (nonatomic ,readonly,assign) int  showTime; //ms

- (instancetype) initWithUpack:(NSString*)upack predictionType:(Byte)predictionType;
- (void)beginDuration;
- (int)endDuration;
- (NSString*)toJsonString;
- (NSDictionary*)toDictionary;
@end
