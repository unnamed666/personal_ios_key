//
//  CMTabBar.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/10/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMTabBar.h"
#import "CMTabBarButton.h"
#import "Lottie/Lottie.h"

@interface CMTabBar ()

@property (nonatomic, strong) UIButton * selectedBtn;
@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) LOTAnimationView * animationView;
@property (nonatomic, strong) UIView * lineView;
@property (nonatomic, strong) NSMutableArray * itemArray;
@end

@implementation CMTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.effectView];
        [self.effectView.contentView addSubview:self.lineView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (NSMutableArray *)itemArray
{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    if (_itemArray.count > selectIndex) {
        CMTabBarButton *barBtn = _itemArray[selectIndex];
        self.selectedBtn.selected = NO;
        barBtn.selected = YES;
        self.selectedBtn = barBtn;
    }
}

- (void)setupItemWithTitle:(NSString *)title normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage
{
    
    CMTabBarButton * btn = [[CMTabBarButton alloc]init];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[[UIImage imageNamed:normalImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btn setImage:[[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    [self.itemArray addObject:btn];
    btn.tag = self.itemArray.count - 1;
    if (btn.tag == 0) {
        [self btnClick:btn];
    }
    [self addSubview:btn];
    
    
    
}

- (void)setIsClickEnable:(BOOL)isClickEnable
{
    for (int i = 0; i < self.itemArray.count; i++)
    {
        [[self.itemArray objectAtIndex:i] setUserInteractionEnabled:isClickEnable];
    }
    kLog(@"");
}

- (void)btnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabbarDidSlected:from:to:)]) {
        
        [self.delegate tabbarDidSlected:self from:self.selectedBtn.tag to:btn.tag];
    }
    self.selectedBtn.selected = NO;
    btn.selected = YES;
    self.selectedBtn = btn;
    
    _animationView = [LOTAnimationView animationNamed:@"HostTabLottie"];
    _animationView.contentMode = UIViewContentModeScaleAspectFill;
//    _animationView.backgroundColor = [UIColor redColor];
    _animationView.userInteractionEnabled = NO;
    [btn addSubview:_animationView];
    _animationView.frame = CGRectMake(btn.titleLabel.frame.size.width * 0.25, btn.frame.origin.y - 25, btn.titleLabel.frame.size.width * 0.5, 50);
    LOTAnimationView *strongAnimationView = _animationView;
    [_animationView playWithCompletion:^(BOOL animationFinished) {
        [strongAnimationView removeFromSuperview];
    }];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.effectView.frame = self.bounds;
    self.lineView.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
    
    CGFloat btnW = self.bounds.size.width/self.itemArray.count;
    CGFloat btnH;
    if ([UIDevice isHeight896]) {
        btnH = self.bounds.size.height - 20;
    } else {
        btnH = self.bounds.size.height;
    }
    
    CGFloat btnY = 0;
    
    for (int i = 0; i<self.itemArray.count; i++) {
        UIButton * btn = self.itemArray[i];
        CGFloat btnX = i * btnW;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        for (UIView *view in _effectView.subviews) {
            kLog(@"UIVisualEffectView subview类型%@", NSStringFromClass([view class]));
            if ([view isMemberOfClass:NSClassFromString(@"_UIVisualEffectFilterView")]|| [view isMemberOfClass:NSClassFromString(@"_UIVisualEffectSubview")] ) {
                // iOS 11 需要 _UIVisualEffectSubview
                view.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:17/255.0 blue:41/255.0 alpha:0.91];
                break;
            }
        }
    }
    return _effectView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_WITH_RGBA(38, 42, 64, 1);
    }
    return _lineView;
}
@end
