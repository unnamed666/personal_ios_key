//
//  ProximityInfo.h
//  test
//
//  Created by wolf on 17/1/13.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProximityInfoKey : NSObject
@property (nonatomic, assign) int keyCode;
@property (nonatomic, copy)NSString* key;
@property (nonatomic,assign) CGRect btnSize;
@end

@interface CMProximityInfo : NSObject

@property (nonatomic,assign,readonly) long long mNativeProximityInfo;
@property (nonatomic,strong,readonly) NSArray *mSortedKeys;

+ (instancetype)proximityInfo:(NSDictionary *)dimDic;

- (instancetype)initWithGridWidth:(int)gridWidth GridHeight:(int)gridHeight MinWidth:(int)minWidth Height:(int)height MostCommonKeyWidth:(int)mostCommonKeyWidth MostCommonKeyHeight:(int)mostCommonKeyHeight SortedKeys:(NSArray*)sortedKeys TouchPositionCorrection:(id)touchPositionCorrection;

- (BOOL)isEqual:(NSDictionary *)dimDic;

- (void)close;
@end
