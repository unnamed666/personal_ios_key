//
//  ProximityInfo.m
//  test
//
//  Created by wolf on 17/1/13.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "CMProximityInfo.h"
#import <math.h>
#include "defines.h"
//#include "proximity_info.h"
#include "suggest/core/layout/proximity_info.h"
//#import "OCDefines.h"
#import "Constants.h"
#import "NSDictionary+Common.h"
#import "Character.h"


@implementation ProximityInfoKey

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d %@", self.keyCode, NSStringFromCGRect(self.btnSize)];
}

@end

@interface CMProximityInfo(){
    
    int mGridWidth;
    int mGridHeight;
    int mGridSize;
    int mCellWidth;
    int mCellHeight;
    // TODO: Find a proper name for mKeyboardMinWidth
    int mKeyboardMinWidth;
    int mKeyboardHeight;
    int mMostCommonKeyWidth;
    int mMostCommonKeyHeight;
}

@property (nonatomic,assign,readwrite) long long mNativeProximityInfo;

@property (nonatomic,strong) NSArray *mSortedKeys;
@property (nonatomic,strong) NSMutableArray *mGridNeighbors;

@end


using namespace latinime;


/**
 * Number of key widths from current touch point to search for nearest keys.
 */
static float SEARCH_DISTANCE = 1.2f;

@implementation CMProximityInfo

+ (long long)latinime_Keyboard_setProximityInfoWithDisplayWidth:(int)displayWidth
                                                  DisplayHeight:(int)displayHeight
                                                      GridWidth:(int)gridWidth
                                                     GridHeight:(int)gridHeight
                                             MostCommonkeyWidth:(int)mostCommonkeyWidth
                                            MostCommonkeyHeight:(int)mostCommonkeyHeight
                                                 ProximityChars:(int [])proximityChars
                                                       KeyCount:(int)keyCount
                                                KeyXCoordinates:(int[])keyXCoordinates
                                                KeyYCoordinates:(int[])keyYCoordinates
                                                      KeyWidths:(int [])keyWidths
                                                     KeyHeights:(int[])keyHeights
                                                   KeyCharCodes:(int[])keyCharCodes
                                              SweetSpotCenterXs:(float[])sweetSpotCenterXs
                                              SweetSpotCenterYs:(float[])sweetSpotCenterYs
                                                 SweetSpotRadii:(float[])sweetSpotRadii
{
    
    ProximityInfo *proximityInfo = new ProximityInfo(displayWidth,displayHeight,
                                                     gridWidth,gridHeight,
                                                     mostCommonkeyWidth,mostCommonkeyHeight,
                                                     proximityChars,keyCount,
                                                     keyXCoordinates,keyYCoordinates,
                                                     keyWidths,keyHeights,
                                                     keyCharCodes,
                                                     sweetSpotCenterXs,sweetSpotCenterYs,
                                                     sweetSpotRadii);
    return reinterpret_cast<long long>(proximityInfo);
}

+ (void)latinime_BinaryDictionary_close:(long long)proximityInfo{
    ProximityInfo *pi = reinterpret_cast<ProximityInfo *>(proximityInfo);
    delete pi;
}


+ (instancetype)proximityInfo:(NSDictionary *)dimDic{
    CMProximityInfo* info = [[CMProximityInfo alloc] initWithGridWidth:[dimDic intValueForKey:@"EnUS_gridWidth" defaultValue:32]
                                                            GridHeight:[dimDic intValueForKey:@"EnUS_gridHeight" defaultValue:16]
                                                              MinWidth:[dimDic intValueForKey:@"EnUS_minWidth" defaultValue:750]
                                                                Height:[dimDic intValueForKey:@"EnUS_height" defaultValue:446]
                                                    MostCommonKeyWidth:[dimDic intValueForKey:@"EnUS_mostCommonKeyWidth" defaultValue:69]
                                                   MostCommonKeyHeight:[dimDic intValueForKey:@"EnUS_mostCommonKeyHeight" defaultValue:92]
                                                            SortedKeys:[dimDic arrayValueForKey:@"proximityInfoArray"]
                                               TouchPositionCorrection:nil];
    return info;
}

- (BOOL)isEqual:(NSDictionary *)dimDic{
    NSArray* sortedKeys = [dimDic arrayValueForKey:@"proximityInfoArray"];
    if(sortedKeys.count != self.mSortedKeys.count) return NO;
    
    BOOL b = mGridWidth == [dimDic intValueForKey:@"EnUS_gridWidth" defaultValue:32] &&
    mGridHeight == [dimDic intValueForKey:@"EnUS_gridHeight" defaultValue:16] &&
    mKeyboardMinWidth == [dimDic intValueForKey:@"EnUS_minWidth" defaultValue:750]&&
    mKeyboardHeight == [dimDic intValueForKey:@"EnUS_height" defaultValue:446] &&
    mMostCommonKeyWidth == [dimDic intValueForKey:@"EnUS_mostCommonKeyWidth" defaultValue:69] && mMostCommonKeyHeight == [dimDic intValueForKey:@"EnUS_mostCommonKeyHeight" defaultValue:92];
    if(!b) return NO;
    
    __block BOOL keyEqual = YES;
    [self.mSortedKeys enumerateObjectsUsingBlock:^(ProximityInfoKey * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProximityInfoKey * pinfoKey = sortedKeys[idx];
        int keyX = pinfoKey.btnSize.origin.x;
        int keyY = pinfoKey.btnSize.origin.y;
        
        if( (int)obj.btnSize.origin.x != keyX || (int)obj.btnSize.origin.y != keyY){
            
            keyEqual = NO;
            *stop = YES;
        }
        if(pinfoKey.keyCode != obj.keyCode){
            if([Character toLowerCase:pinfoKey.keyCode] !=  [Character toLowerCase:obj.keyCode]){
                keyEqual = NO;
                *stop = YES;
              }
        }
    }];
    
    return keyEqual;
    
}
- (instancetype)initWithGridWidth:(int)gridWidth GridHeight:(int)gridHeight MinWidth:(int)minWidth Height:(int)height MostCommonKeyWidth:(int)mostCommonKeyWidth MostCommonKeyHeight:(int)mostCommonKeyHeight SortedKeys:(NSArray*)sortedKeys TouchPositionCorrection:(id)touchPositionCorrection
{
    self = [super init];
    if (self) {
        mGridWidth = gridWidth;
        mGridHeight = gridHeight;
        mGridSize = mGridWidth * mGridHeight;
        mCellWidth = (minWidth + mGridWidth - 1) / mGridWidth;
        mCellHeight = (height + mGridHeight - 1) / mGridHeight;
        mKeyboardMinWidth = minWidth;
        mKeyboardHeight = height;
        mMostCommonKeyHeight = mostCommonKeyHeight;
        mMostCommonKeyWidth = mostCommonKeyWidth;
        
        self.mSortedKeys =sortedKeys;
        
        self.mGridNeighbors = [NSMutableArray arrayWithCapacity:mGridSize];
        
        if (minWidth == 0 || height == 0) {
            // No proximity required. Keyboard might be more keys keyboard.
            
        }else{
            [self computeNearestNeighbors];
            _mNativeProximityInfo = [self createNativeProximityInfo:touchPositionCorrection];
        }
    }
    return self;
}

- (void)computeNearestNeighbors{
    int defaultWidth = mMostCommonKeyWidth;
    //     int keyCount = (int)self.mSortedKeys.count;
    int gridSize = mGridSize;
    int threshold = (int) (defaultWidth * SEARCH_DISTANCE);
    int thresholdSquared = threshold * threshold;
    // Round-up so we don't have any pixels outside the grid
    int lastPixelXCoordinate = mGridWidth * mCellWidth - 1;
    int lastPixelYCoordinate = mGridHeight * mCellHeight - 1;
    //    ProximityInfoKey  *neighborsFlatBuffer = new ProximityInfoKey[gridSize * keyCount];
    
    for (int i=0; i<gridSize; i++) {
        NSMutableArray<ProximityInfoKey*> *neighbors = [[NSMutableArray alloc] init];
        [self.mGridNeighbors addObject:neighbors];
    }
    
    int halfCellWidth = mCellWidth / 2;
    int halfCellHeight = mCellHeight / 2;
    
    for (ProximityInfoKey * pinfoKey in self.mSortedKeys) {
        
        int keyX = pinfoKey.btnSize.origin.x;
        int keyY = pinfoKey.btnSize.origin.y;
        int topPixelWithinThreshold = keyY - threshold;
        int yDeltaToGrid = topPixelWithinThreshold % mCellHeight;
        int yMiddleOfTopCell = topPixelWithinThreshold - yDeltaToGrid + halfCellHeight;
        int yStart = MAX(halfCellHeight,
                         yMiddleOfTopCell + (yDeltaToGrid <= halfCellHeight ? 0 : mCellHeight));
        int yEnd = MIN(lastPixelYCoordinate, keyY + pinfoKey.btnSize.size.height + threshold);
        
        int leftPixelWithinThreshold = keyX - threshold;
        int xDeltaToGrid = leftPixelWithinThreshold % mCellWidth;
        int xMiddleOfLeftCell = leftPixelWithinThreshold - xDeltaToGrid + halfCellWidth;
        int xStart = MAX(halfCellWidth,
                         xMiddleOfLeftCell + (xDeltaToGrid <= halfCellWidth ? 0 : mCellWidth));
        int xEnd = MIN(lastPixelXCoordinate, keyX + pinfoKey.btnSize.size.width + threshold);
        
        int baseIndexOfCurrentRow = (yStart / mCellHeight) * mGridWidth + (xStart / mCellWidth);
        
        for (int centerY = yStart; centerY <= yEnd; centerY += mCellHeight) {
            int index = baseIndexOfCurrentRow;
            for (int centerX = xStart; centerX <= xEnd; centerX += mCellWidth) {

                if([CMProximityInfo squaredDistanceToEdge:centerX y:centerY btnSize:pinfoKey.btnSize] < thresholdSquared){
                    [self.mGridNeighbors[index] addObject:pinfoKey];
                }
                ++index;
            }
            baseIndexOfCurrentRow += mGridWidth;
        }
        
    }
    //    kLog(@"%@",self.mGridNeighbors);
    
}

+ (int)squaredDistanceToEdge:(int)x y:(int)y btnSize:(CGRect) btnSize{
    int left = btnSize.origin.x;
    int right = left + btnSize.size.width;
    int top = btnSize.origin.y;
    int bottom = top + btnSize.size.height;
    int edgeX = x<left?left:(x>right?right:x);
    int edgeY = y<top?top:(y>bottom?bottom:y);
    int dx = x-edgeX;
    int dy = y- edgeY;
    return dx*dx+dy*dy;
}

- (long long)createNativeProximityInfo:(id)touchPositionCorrection{
    
    int proximityCharsArray[mGridSize * MAX_PROXIMITY_CHARS_SIZE];
    memset(proximityCharsArray, -1, mGridSize * MAX_PROXIMITY_CHARS_SIZE *sizeof(int));
    
    for (int i=0; i< mGridSize; i++) {
        NSArray * neighborKeys = self.mGridNeighbors[i];
        
        int infoIndex = i*MAX_PROXIMITY_CHARS_SIZE;
        NSMutableString *str = [NSMutableString new];
        for (ProximityInfoKey * neighborKey in neighborKeys) {
            
            if(neighborKey.keyCode >= CODE_SPACE){
                proximityCharsArray[infoIndex] = neighborKey.keyCode;
                if (neighborKey.key && neighborKey.key.length > 0) {
                    [str appendString:neighborKey.key];
                    [str appendString:@" "];
                }
            }
            infoIndex++;
        }
        //        kLog(@"%d   %@",i,str);
//        printf("%d %s\n",i,[str UTF8String]);
    }

    int keyCount =0;
    for (ProximityInfoKey* infoKey in self.mSortedKeys) {
        
//        printf("%d\n",infoKey.keyCode);
        if(infoKey.keyCode < CODE_SPACE)continue;
        keyCount++;
    }
    int keyXCoordinates[keyCount];
    int keyYCoordinates[keyCount];
    int keyWidths[keyCount];
    int keyHeights[keyCount];
    int keyCharCodes[keyCount];
    int infoIndex=0;
    for (ProximityInfoKey* infoKey in self.mSortedKeys) {
        if(infoKey.keyCode < CODE_SPACE)continue;
        keyXCoordinates[infoIndex] = infoKey.btnSize.origin.x;
        keyYCoordinates[infoIndex] = infoKey.btnSize.origin.y;
        keyWidths[infoIndex] = infoKey.btnSize.size.width;
        keyHeights[infoIndex] = infoKey.btnSize.size.height;
        keyCharCodes[infoIndex] = infoKey.keyCode;
        infoIndex++;
    }
    
    
//    float sweetSpotCenterXs[] = {54.5,162.5,270.5,378.5,486.5,594.5,702.5,810.5,918.5,1026.0,81.5,216.5,324.5,432.5,540.5,648.5,756.5,864.5,999.0,216.5,324.5,432.5,540.5,648.5,756.5,864.5,216.5,540.5,864.5};
//    float sweetSpotCenterYs[] = {97.40633,97.40633,97.40633,97.40633,97.40633,97.40633,97.40633,97.40633,97.40633,97.40633,268.79855,268.79855,268.79855,268.79855,268.79855,268.79855,268.79855,268.79855,268.79855,442.03397,442.03397,442.03397,442.03397,442.03397,442.03397,442.03397,592.5,592.5,592.5};
//    float sweetSpotRadii[] = {31.186062,31.186062,31.186062,31.186062,31.186062,31.186062,31.186062,31.186062,31.186062,31.099415,35.485455,30.255558,30.255558,30.255558,30.255558,30.255558,30.255558,30.255558,35.378098,30.114105,30.114105,30.114105,30.114105,30.114105,30.114105,30.114105,29.580442,29.580442,29.580442};
    
    return [CMProximityInfo latinime_Keyboard_setProximityInfoWithDisplayWidth:mKeyboardMinWidth DisplayHeight:mKeyboardHeight GridWidth:mGridWidth GridHeight:mGridHeight MostCommonkeyWidth:mMostCommonKeyWidth MostCommonkeyHeight:mMostCommonKeyHeight ProximityChars:proximityCharsArray KeyCount:keyCount KeyXCoordinates:keyXCoordinates KeyYCoordinates:keyYCoordinates KeyWidths:keyWidths KeyHeights:keyHeights KeyCharCodes:keyCharCodes SweetSpotCenterXs:0 SweetSpotCenterYs:0 SweetSpotRadii:0];
    
}

- (void)close{
    if (_mNativeProximityInfo != 0) {
        [CMProximityInfo latinime_BinaryDictionary_close:_mNativeProximityInfo];
        _mNativeProximityInfo = 0;
    }
}

- (void)dealloc
{
    if (_mNativeProximityInfo != 0) {
        [CMProximityInfo latinime_BinaryDictionary_close:_mNativeProximityInfo];
        _mNativeProximityInfo = 0;
    }
}

@end
