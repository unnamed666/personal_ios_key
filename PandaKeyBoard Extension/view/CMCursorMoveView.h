//
//  CMCursorMoveView.h
//  PandaKeyboard
//
//  Created by duwenyan on 2017/9/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMCursorMoveView;

@protocol CMCursorMoveViewDelegate <NSObject>

@required

- (void)onCursorMoveViewMove:(CMCursorMoveView *)cursorMoveView characterOffset:(NSInteger)characterOffset;

@end

@interface CMCursorMoveView : UIView

@property (nonatomic, readonly, assign) NSInteger cursorMoveUseCount;

@property (nonatomic, weak) id<CMCursorMoveViewDelegate> delegate;

@end
