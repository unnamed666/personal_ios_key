//
//  CMFullAccessTipStackView.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/9/15.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMFullAccessTipStackView.h"
#import "CMBizHelper.h"
#import "UIColor+HexColors.h"
#import "UIView+Animate.h"
#import "UIButton+Util.h"

@interface CMFullAccessTipStackView()

@property (nonatomic, strong) UIStackView *fullBkStackView;
@property (nonatomic, strong) UIButton *fullAccessCloseBtn;
@property (nonatomic, strong) UILabel *fullAccessLabel;
@property (nonatomic, strong) UIButton *fullAccessConfirmBtn;

@end

@implementation CMFullAccessTipStackView
@synthesize priority = _priority;
@synthesize duration = _duration;
@synthesize tipDelegate = _tipDelegate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR_WITH_RGBA(56, 199, 220, 1);
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    [self addSubview:self.fullBkStackView];
    
    [self.fullBkStackView addArrangedSubview:self.fullAccessCloseBtn];
    [self.fullBkStackView addArrangedSubview:self.fullAccessLabel];
    [self.fullBkStackView addArrangedSubview:self.fullAccessConfirmBtn];
    
    [_fullBkStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, KScalePt(12)));
    }];
    
    [_fullAccessCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(KScalePt(12));
        make.size.mas_equalTo(CGSizeMake(KScalePt(12),KScalePt(12)));
    }];
    
    [_fullAccessConfirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(KScalePt(64), KScalePt(28)));
    }];
    
    // add action
    [_fullAccessCloseBtn addTarget:self action:@selector(handleSwipeFrom) forControlEvents:UIControlEventTouchUpInside];
    
    [_fullAccessConfirmBtn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    
    
//    self.userInteractionEnabled = true;
//
//    UITapGestureRecognizer *tapGestrue = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
//    [self addGestureRecognizer:tapGestrue];
//
//    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
//    [self addGestureRecognizer:recognizer];
 
}


#pragma mark - event response

- (void)tapAction
{
    if (!self.superview) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
    [self removeAllAnimation];
//    self.constaint.offset(0);
    [self removeFromSuperview];
    if (self.tipDelegate && [self.tipDelegate respondsToSelector:@selector(tipsView:onTapped:)]) {
        [self.tipDelegate tipsView:self onTapped:nil];
    }
}


#pragma mark - delegate
     
- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView duration:(CGFloat)duration {
    if (!superView) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
    [superView addSubview:self];
    if (self.tipDelegate) {
        [self.tipDelegate tipsView:self onShowed:nil];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView);
        make.leading.equalTo(superView);
        make.trailing.equalTo(superView);
        make.height.mas_equalTo(KScalePt(40));
    }];
    
    [superView setNeedsLayout];
    [superView layoutIfNeeded];
    
//    self.constaint.offset(30.0f);
    [UIView animateWithDuration:0.3 animations:^{
        [superView layoutIfNeeded];
    }];
    if (duration > 0) {
        [self performSelector:@selector(removeFromView) withObject:nil afterDelay:duration];
    }
}

- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView {
    [self showInView:superView anchorView:anchorView duration:self.duration];
}

- (void)removeFromViewAnimate:(BOOL)animate enableCallBack:(BOOL)enable {
    if (self.superview) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
        [self removeAllAnimation];
//        self.constaint.offset(0);
        if (animate) {
            [UIView animateWithDuration:.25 animations:^{
                [self.superview layoutIfNeeded];
            }completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (self.tipDelegate && enable) {
                    [self.tipDelegate tipsView:self onRemoved:nil];
                }
            }];
        }
        else {
            [self removeFromSuperview];
            if (self.tipDelegate && enable) {
                [self.tipDelegate tipsView:self onRemoved:nil];
            }
        }
    }
}

- (void)removeFromView {
    [self removeFromViewAnimate:YES enableCallBack:YES];
}


- (void)handleSwipeFrom
{
    if (!self.superview) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];
    [self removeAllAnimation];
//    self.constaint.offset(0);
    [self removeFromSuperview];
    if (self.tipDelegate && [self.tipDelegate respondsToSelector:@selector(tipsView:onSwiped:)]) {
        [self.tipDelegate tipsView:self onSwiped:nil];
    }
}


#pragma mark - getters and setters

-(UIStackView *)fullBkStackView
{
    if (!_fullBkStackView) {
        _fullBkStackView = [[UIStackView alloc]init];
        _fullBkStackView.axis = UILayoutConstraintAxisHorizontal;
        _fullBkStackView.alignment = UIStackViewAlignmentCenter;
        _fullBkStackView.distribution = UIStackViewDistributionFill;
        _fullBkStackView.spacing = KScalePt(10);
    }
    
    return _fullBkStackView;
}

-(UIButton *)fullAccessCloseBtn
{
    if (!_fullAccessCloseBtn) {
        _fullAccessCloseBtn = [[UIButton alloc]init];
        UIImage *closeImage = [UIImage imageNamed:@"guide_icon_closed_normal"];
        [_fullAccessCloseBtn setImage:closeImage forState:UIControlStateNormal];
//        _fullAccessCloseBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);
        _fullAccessCloseBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    }
    return _fullAccessCloseBtn;
}

-(UIButton *)fullAccessConfirmBtn
{
    if (!_fullAccessConfirmBtn) {
        _fullAccessConfirmBtn = [[UIButton alloc]init];
        [_fullAccessConfirmBtn setBackgroundColor:[UIColor whiteColor]];
        [_fullAccessConfirmBtn setTitle:CMLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [_fullAccessConfirmBtn setTitleColor:COLOR_WITH_RGBA(47, 198, 220, 1) forState:UIControlStateNormal];
        _fullAccessConfirmBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        _fullAccessConfirmBtn.titleLabel.font = [CMBizHelper getFontWithSize:14];
        [_fullAccessConfirmBtn.titleLabel sizeToFit];
        _fullAccessConfirmBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        _fullAccessConfirmBtn.layer.cornerRadius = KScalePt(14);
        
    }
    return _fullAccessConfirmBtn;
}

-(UILabel *)fullAccessLabel
{
    if (!_fullAccessLabel) {
        _fullAccessLabel = [[UILabel alloc]init];
        _fullAccessLabel.numberOfLines = 0;
//        _fullAccessLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fullAccessLabel.lineBreakMode = NSLineBreakByWordWrapping;
        NSMutableAttributedString *muStrText = [[NSMutableAttributedString alloc]initWithString:CMLocalizedString(@"FullAccess_Tip", nil) attributes:@{NSFontAttributeName:[CMBizHelper getFontWithSize:KScalePt(12)]}];
        NSMutableAttributedString *muStrEmo = [[NSMutableAttributedString alloc]initWithString:@" 👉" attributes:@{NSFontAttributeName:[CMBizHelper getFontWithSize:KScalePt(14)]}];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:muStrText] ;
        [attributedString  appendAttributedString:muStrEmo];
        _fullAccessLabel.attributedText = attributedString;
        [_fullAccessLabel sizeToFit];
        _fullAccessLabel.textColor = rgb(255, 255, 255);
    }
    return _fullAccessLabel;
}

@end





