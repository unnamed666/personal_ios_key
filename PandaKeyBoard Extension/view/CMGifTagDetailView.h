//
//  CMGifTagDetailView.h
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/11/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBaseKeyboardView.h"
@protocol CMGifTagDetailViewDelegate <CMBaseKeyboardViewDelegate>

- (void)dismiss;
- (void)abcBtn:(CMKeyButton*)keyButton;
- (void)deleteBtn:(CMKeyButton*)keyButton;
@end

@interface CMGifTagDetailView : CMBaseKeyboardView
@property (nonatomic, assign) NSUInteger inSource;

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel  deleteModel:(CMKeyModel *)deleteKeyModel ;
- (void)showToSuperview:(UIView*)superview title:(NSString*)title;
@end

@interface CMGifTagDetailCell:UICollectionViewCell
- (void)setCellSelected:(BOOL)select;
@end

