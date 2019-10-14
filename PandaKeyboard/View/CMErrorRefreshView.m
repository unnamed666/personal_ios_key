//
//  CMErrorRefreshView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/7/27.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMErrorRefreshView.h"
#import "CMBizHelper.h"
#import "UIColor+HexColors.h"

@interface CMErrorRefreshView ()
@property (nonatomic, strong) UIButton * refreshButton;
@property (nonatomic, strong) UILabel * errorLabel;
@end

@implementation CMErrorRefreshView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //self.backgroundColor = [UIColor orangeColor];
        
        _refreshButton = [[UIButton alloc] init];
        [_refreshButton setImage:[UIImage imageNamed:@"icon_refresh_normal"] forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_refreshButton];
        [_refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.font = [CMBizHelper getFontWithSize:11];
        _errorLabel.textColor = COLOR_WITH_RGBA(132, 146, 167, 1);
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.text = CMLocalizedString(@"Error_Refresh", nil);
        _errorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_errorLabel];
        [_errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.mas_leading).offset(5);
            make.trailing.equalTo(self.mas_trailing).offset(-5);
            make.top.equalTo(_refreshButton.mas_bottom).offset(13);
            make.height.greaterThanOrEqualTo(@0);
        }];
    }
    return self;
}

- (void)refreshButtonDidClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshDidClick)]) {
        [self.delegate refreshDidClick];
    }
}
@end
