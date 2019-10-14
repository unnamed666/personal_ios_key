//
//  CloudPredictionReport.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CloudPredictionReport.h"
#import "NSDictionary+Common.h"
int const REPORT_PREDICTION_TYPE_WORD = 0;
int const REPORT_PREDICTION_TYPE_GIF = 1;
@interface CloudPredictionReport (){
    UInt64 time;
}

@end
@implementation CloudPredictionReport
- (instancetype) initWithUpack:(NSString*)upack predictionType:(Byte)predictionType{
    if(self = [super init]){
        _upack = upack;
        _predictionType = predictionType;
        time = _showTime = 0;
        _selectIndex = -1;
    }
    return self;
}
- (void)beginDuration{
    time = [[NSDate date] timeIntervalSince1970]*1000;
}
- (int)endDuration{
    if(time!=0){
        _showTime = [[NSDate date] timeIntervalSince1970]*1000 - time;
    }else{
        _showTime = 0;
    }
    return _showTime;
}

- (NSDictionary*)toDictionary{
    NSDictionary *dic = @{@"upack":_upack,
                           @"duration":@(_showTime),
                           @"select_index":@(_selectIndex),
                           @"commpletion_type":@(0),
                           @"prediction_type":@(_predictionType)
                          };
    return dic;
}
- (NSString*)toJsonString{
    return [[self toDictionary] toJSonString];
}
@end
