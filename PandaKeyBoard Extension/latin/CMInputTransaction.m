//
//  CMInputTransaction.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/9.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMInputTransaction.h"

@implementation CMInputTransaction
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}
- (void)reset{
    self.mRequiresUpdateSuggestions = NO;
    _needCommint = YES;
    _didAutoCorrect = _fromeRepeate= NO;
    self.shiftState = 0;
    self.suggestEmoji = nil;
}
@end
