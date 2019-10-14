//
//  CMEmojiCell.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import "CMEmojiCell.h"
#import "CMKeyButton.h"
#import "CMKeyModel.h"
#import "UIView+Util.h"

@interface CMEmojiCell ()
@property (nonatomic, strong)CMKeyModel* keyModel;

@end

@implementation CMEmojiCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        self.userInteractionEnabled = NO;
        
        [self.contentView addSubview:self.keyBtn];
        self.keyBtn.width = self.width;
        self.keyBtn.height = self.height;
        
//        [self.contentView addSubview:self.emojiLabel];
//        self.emojiLabel.width = self.width;
//        self.emojiLabel.height = self.height;
    }
    return self;
}

#pragma mark - getter/setter
//- (UILabel *)emojiLabel {
//    if (!_emojiLabel) {
//        _emojiLabel = [UILabel new];
//        _emojiLabel.textAlignment = NSTextAlignmentCenter;
//    }
//    return _emojiLabel;
//}

- (CMKeyButton *)keyBtn {
    if (!_keyBtn) {
        _keyBtn = [[CMKeyButton alloc] initWithKeyModel:nil];
    }
    return _keyBtn;
}

- (void)bindKeyModel:(CMKeyModel *)model delegate:(id<CMEmojiCellDelegate>)delegate {
    if (self.keyModel != model || model == nil) {
        self.keyModel = model;
        self.delegate = delegate;
        
        [self.keyBtn emojiBindKeyModel:model];
        @weakify(self);
        if (model == nil) {
            self.keyBtn.tag = 0;
            [self.keyBtn setKeyTouchDownHandler:nil];
            [self.keyBtn setKeyTouchUpInsideHandler:nil];
            [self.keyBtn setKeyTouchCancelHandler:nil];
        }else if (model.keyType == CMKeyTypeEmoji) {
            self.keyBtn.tag = 0;
            [self.keyBtn setKeyTouchDownHandler:^(CMKeyButton* keyButton, CGPoint touchPt) {
                @stronglize(self);
                if (self.delegate) {
                    [self.delegate onEmojiCellTouchDown:self keyButton:keyButton touchPt:CGPointMake(-1, -1)];
                }
            }];
            [self.keyBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
                @stronglize(self);
                if (self.delegate) {
                    [self.delegate onEmojiCellTapped:self keyButton:keyButton touchPt:CGPointMake(-1, -1)];
                }
            }];
            [self.keyBtn setKeyTouchCancelHandler:^(CMKeyButton* keyButton) {
                @stronglize(self);
                if (self.delegate) {
                    [self.delegate onEmojiCellCancel:self keyButton:keyButton touchPt:CGPointMake(-1, -1)];
                }
            }];
        }else if (model.keyType == CMKeyTypeDel) {
            self.keyBtn.tag = EmojiDeleteKeyButtonTag;
            self.keyBtn.userInteractionEnabled = YES;
            [self.keyBtn setKeyTouchDownHandler:^(CMKeyButton* keyButton, CGPoint touchPt)
             {
                 @stronglize(self);
                 if (self.delegate) {
                     [self.delegate onDelCellTouchDown:keyButton touchPt:touchPt];
                 }
             }];
            [self.keyBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
                @stronglize(self);
                if (self.delegate) {
                    [self.delegate onDelCellTapped:keyButton];
                }
            }];
            [self.keyBtn setKeyTouchCancelHandler:^(CMKeyButton* keyButton) {
                @stronglize(self);
                if (self.delegate) {
                    [self.delegate onDelCellCancel:keyButton];
                }
            }];
        }
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

@end
