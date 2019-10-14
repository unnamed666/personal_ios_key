//
//  CMTipsViewManager.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/10.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTipsViewManager.h"
#import "CMTipsViewProtocol.h"

@interface CMTipsViewManager ()
@property (nonatomic, strong)NSMutableArray<id<CMTipsViewProtocol>>* tipsViewArray;

@end

@implementation CMTipsViewManager

- (void)dealloc {
    kLogTrace();
}

- (void)addTipsView:(id<CMTipsViewProtocol>)tipsView {
    __block NSUInteger index = NSNotFound;
    [self.tipsViewArray enumerateObjectsUsingBlock:^(id<CMTipsViewProtocol>  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.priority == tipsView.priority) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index == NSNotFound) {
        [self.tipsViewArray addObject:tipsView];
    }
    else {
        [self.tipsViewArray replaceObjectAtIndex:index withObject:tipsView];
    }
    
    [self.tipsViewArray sortUsingComparator:^NSComparisonResult(id<CMTipsViewProtocol>  _Nonnull obj1, id<CMTipsViewProtocol>  _Nonnull obj2) {
        return obj1.priority >= obj2.priority;
    }];
}

- (void)removeTipsView:(id<CMTipsViewProtocol>)tipsView {
    __block NSUInteger index = NSNotFound;
    [self.tipsViewArray enumerateObjectsUsingBlock:^(id<CMTipsViewProtocol>  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.priority == tipsView.priority) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index != NSNotFound) {
        [self.tipsViewArray removeObjectAtIndex:index];
    }
}

- (void)removeAllTipsView {
    [self.tipsViewArray enumerateObjectsUsingBlock:^(id<CMTipsViewProtocol>  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        [view removeFromViewAnimate:NO enableCallBack:NO];
    }];

    [self.tipsViewArray removeAllObjects];
}

- (id<CMTipsViewProtocol>)getTopTipsView {
    return self.tipsViewArray.count <= 0 ? nil : [self.tipsViewArray firstObject];
}

#pragma mark - setter/getter
- (NSMutableArray<id<CMTipsViewProtocol>> *)tipsViewArray {
    if (!_tipsViewArray) {
        _tipsViewArray = [NSMutableArray array];
    }
    return _tipsViewArray;
}

@end
