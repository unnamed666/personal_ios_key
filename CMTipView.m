//
//  CMTipView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTipView.h"
#import "UIColor+HexColors.h"
#import "CMBizHelper.h"
@interface CMTipView ()
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * messageLabel;

@end

@implementation CMTipView

- (instancetype)initWithIcon:(NSString *)iconString message:(NSString *)message
{
    
    if (self = [super init]) {
    
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = message;
        _messageLabel.text = message;
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageLabel.textColor = COLOR_WITH_RGBA(255, 255, 255, 1);
        _messageLabel.font = [CMBizHelper getFontWithSize:11];
        [self addSubview:_messageLabel];
        
        if (iconString.length > 0) {
             _iconView.image = [UIImage imageNamed:iconString];
            [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.mas_leading);
                make.centerY.equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(13, 13));
            }];
            [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_iconView.mas_trailing).offset(10);
                make.centerY.equalTo(self.mas_centerY);
                make.trailing.equalTo(self.mas_trailing);
                make.height.greaterThanOrEqualTo(@0);
            }];
        }else{
            [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.mas_leading);
                make.centerY.equalTo(self.mas_centerY);
                make.trailing.equalTo(self.mas_trailing);
                make.height.greaterThanOrEqualTo(@0);
            }];
        }

    }
    return self;
}

@end
