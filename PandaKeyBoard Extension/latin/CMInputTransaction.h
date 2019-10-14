//
//  CMInputTransaction.h
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/9.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMInputTransaction : NSObject

@property (nonatomic,assign)  int mSpaceState;
@property (nonatomic, assign) BOOL mRequiresUpdateSuggestions;

@property (nonatomic, assign) BOOL didAutoCorrect;

@property (nonatomic, assign) BOOL needCommint;
@property (nonatomic, assign) KeyboardShiftState shiftState;
@property (nonatomic, strong) NSArray *suggestEmoji;


@property (nonatomic, assign) BOOL  fromeRepeate;
- (void)reset;
@end
