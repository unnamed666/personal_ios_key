//
//  CMEmojiCell.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMKeyButton;
@class CMKeyModel;
@class CMEmojiCell;

@protocol CMEmojiCellDelegate <NSObject>

- (void)onEmojiCellTouchDown:(CMEmojiCell *)cell keyButton:(CMKeyButton*)keyButton touchPt:(CGPoint)touchPt;
- (void)onEmojiCellTapped:(CMEmojiCell *)cell keyButton:(CMKeyButton*)keyButton touchPt:(CGPoint)touchPt;
- (void)onEmojiCellCancel:(CMEmojiCell *)cell keyButton:(CMKeyButton*)keyButton touchPt:(CGPoint)touchPt;
- (void)onDelCellTouchDown:(CMKeyButton *)keyButton touchPt:(CGPoint)touchPt;
- (void)onDelCellTapped:(CMKeyButton *)keyButton;
- (void)onDelCellCancel:(CMKeyButton *)keyButton;

@end

@interface CMEmojiCell : UICollectionViewCell
@property (nonatomic, strong)UILabel* emojiLabel;

@property (nonatomic, strong)CMKeyButton* keyBtn;

@property (nonatomic, weak)id<CMEmojiCellDelegate> delegate;

- (void)bindKeyModel:(CMKeyModel *)model delegate:(id<CMEmojiCellDelegate>)delegate;

@end
