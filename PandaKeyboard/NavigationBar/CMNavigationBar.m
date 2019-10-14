//
//  CMNavigationBar.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMNavigationBar.h"
#import "CMBizHelper.h"

@interface CMNavigationBar ()
{
    UIButton * _backButton;
    UILabel  * _titleLabel;
    UIButton * _rightItem;
}
@property (nonatomic, assign)CGFloat centerYOffset;
@end

@implementation CMNavigationBar

- (CMNavigationBar *)initWithNavigationBarType:(CMNavigationBarType)type centerYOffset:(CGFloat)offset
{
   self = [super init];
    if (!self) {
        return nil;
    }
    self.centerYOffset = offset;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOpacity = 0.5;
    self.layer.shouldRasterize = YES;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shadowColor = COLOR_WITH_RGBA(0, 0, 0, 0.18).CGColor;
    
    switch (type) {
        case CMNavigationBarTypeDefault:
            [self initDefultUIWithType:CMNavigationBarTypeDefault];
            break;
        case CMNavigationBarTypeRightItem:
            [self initDefultUIWithType:CMNavigationBarTypeRightItem];
            break;
            
        default:
            break;
    }

    return self;
}

- (void)initDefultUIWithType:(CMNavigationBarType)type
{
    self.backgroundColor = COLOR_WITH_RGBA(27, 31, 55, 1);
    
    _backButton = [[UIButton alloc] init];
    //_backButton.backgroundColor = [UIColor redColor];
    _backButton.titleLabel.font = [CMBizHelper getFontWithSize:(kScreenHeight/36.63)];
    [_backButton addTarget:self action:@selector(backButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImage:[UIImage imageNamed:@"icon_back_normal"] forState:UIControlStateNormal];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(14, 6, 14, 22)];
    [self addSubview:_backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY).offset(self.centerYOffset);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.textColor = COLOR_WITH_RGBA(255, 255, 255, 1);
    _titleLabel.font = [CMBizHelper getFontWithSize:(kScreenHeight/36.63)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    //_titleLabel.backgroundColor = [UIColor greenColor];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(self.centerYOffset);
        make.width.greaterThanOrEqualTo(@0);
        make.leading.equalTo(_backButton.mas_trailing).offset(15);
        make.trailing.equalTo(self.mas_trailing).offset(-74);
    }];
    
    
    if (type == CMNavigationBarTypeRightItem) {
        _rightItem = [[UIButton alloc] init];
        [_rightItem setTitleColor:COLOR_WITH_RGBA(255, 255, 255, 1) forState:UIControlStateNormal];
        [_rightItem setTitleColor:COLOR_WITH_RGBA(255, 255, 255, 1) forState:UIControlStateSelected];
        _rightItem.titleLabel.font = [CMBizHelper getFontWithSize:(kScreenHeight/36.63)];
        [_rightItem addTarget:self action:@selector(rightItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightItem];
        [_rightItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_titleLabel.mas_centerY);
            make.trailing.equalTo(self.mas_trailing).offset(-15);
            make.width.greaterThanOrEqualTo(@0);
            make.height.greaterThanOrEqualTo(@0);
        }];
    }
}

-(void)updateConstraints
{
    
    if (self.superview) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.superview);
            make.trailing.equalTo(self.superview);
            if ([UIDevice isHeight896]){
                 make.top.equalTo(self.superview).offset(20);
            }else {
                 make.top.equalTo(self.superview);
            };
            make.height.equalTo(self.centerYOffset > 0 ? @(CMNavigationBarHeight) : @(CMNavigationBarHeight - 20));
        }];
    }
    [super updateConstraints];
}

- (void)setNavBarBackgroundColor:(UIColor *)navBarBackgroundColor
{
    _navBarBackgroundColor = navBarBackgroundColor;
    self.backgroundColor = navBarBackgroundColor;
}

-(void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.text = title;
}

-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
}

-(void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
}

-(void)setRightItemTitleNormal:(NSString *)rightItemTitleNormal
{
    _rightItemTitleNormal = [rightItemTitleNormal copy];
    [_rightItem setTitle:rightItemTitleNormal forState:UIControlStateNormal];
}

-(void)setRightItemTitleSelected:(NSString *)rightItemTitleSelected
{
    _rightItemTitleSelected = [rightItemTitleSelected copy];
    [_rightItem setTitle:rightItemTitleSelected forState:UIControlStateSelected];
}

#pragma mark - 
- (void)backButtonDidClick:(UIButton *)backButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navBarBackButtonDidClick)]) {
        [self.delegate navBarBackButtonDidClick];
    }
}

- (void)rightItemClick:(UIButton *)rightItem
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(navBarRightItemDidClick:)]) {
        [self.delegate navBarRightItemDidClick:rightItem];
    }
}

- (void)hideBackButton
{
    _backButton.hidden = YES;
}
- (void)showBackButton
{
    _backButton.hidden = NO;
}

- (void)hideRightButton
{
    _rightItem.hidden = YES;
}

- (void)showRightButton
{
    _rightItem.hidden = NO;
}
@end
