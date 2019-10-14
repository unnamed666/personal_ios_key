//
//  NativeSuggestOptions.h
//  test
//
//  Created by yanzhao on 2017/3/25.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NativeSuggestOptions : NSObject{
    @public
     int mOptions[5];//OPTIONS_SIZE = 5
}


- (void)setIsGesture:(BOOL)value;
- (void)setUseFullEditDistance:(BOOL)value;
- (void)setBlockOffensiveWords:(BOOL)value;
- (void)setWeightForLocale:(float)value;

@end
