//
//  CMRemindTipView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/8/2.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRemindTipView.h"
#import "CMBizHelper.h"
#import "UIColor+HexColors.h"
#import "UIView+Util.h"
#import "UIView+Animate.h"

#define kBackgroundColor [UIColor colorWithRed:121/255.0 green:252/255.0 blue:252/255.0 alpha:1]

@interface CMRemindTipView ()
@property (nonatomic, strong) UILabel * tipLabel;
@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) UIView * tipContentView;

@property (nonatomic, weak) UIView * anchorView;

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) CAShapeLayer * singleton;
@property (nonatomic, assign) CMSingleDirection singleDirection;
@property (nonatomic, assign) CGFloat percent;

@end

@implementation CMRemindTipView
@synthesize priority = _priority;
@synthesize duration = _duration;
@synthesize tipDelegate = _tipDelegate;

- (instancetype)initWithImageName:(NSString *)imageName tipString:(NSString *)tipString singleDirection:(CMSingleDirection)direction percent:(CGFloat)percent
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        
        _imageName = imageName;
        _singleDirection = direction;
        _percent = percent;
        [self addSubview:self.backgroundView];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.tipContentView];
        self.tipLabel.text = tipString;
        [self.tipContentView addSubview:self.tipLabel];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipContentView).offset(14);
            make.bottom.equalTo(self.tipContentView).offset(-14);
            make.leading.equalTo(self.tipContentView).offset(8);
            make.trailing.equalTo(self.tipContentView).offset(-8).priority(999);
        }];
        
        
//        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.font = [CMBizHelper getFontWithSize:12];
        _tipLabel.textColor = COLOR_WITH_RGBA(10, 9, 31, 1);
    }
    return _tipLabel;
}

- (CAShapeLayer *)singleton {
    if (!_singleton) {
        _singleton = [CAShapeLayer layer];
    }
    return _singleton;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.2f;
    }
    return _backgroundView;
}

- (UIView *)tipContentView {
    if (!_tipContentView) {
        _tipContentView = [UIView new];
        _tipContentView.layer.shadowColor = [UIColor blackColor].CGColor;
        _tipContentView.layer.shadowOpacity = .8f;
        _tipContentView.layer.shadowRadius = 4;
        _tipContentView.layer.shadowOffset = CGSizeMake(0, 5);
        _tipContentView.backgroundColor = kBackgroundColor;
        _tipContentView.layer.cornerRadius = 8;
    }
    return _tipContentView;
}

- (void)showInView:(UIView *)superView anchorView:(UIView *)anchorView duration:(CGFloat)duration {
    if (!superView) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeFromView) object:nil];

    [self.layer addSublayer:self.singleton];
    self.anchorView = anchorView;
    [superView addSubview:self];
    
    if (self.tipDelegate &&  [self.tipDelegate respondsToSelector:@selector(tipsView:onShowed:)])  {
        [self.tipDelegate tipsView:self onShowed:nil];
    }
    
    if (anchorView) {
        [self.tipContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self).mas_offset(10).priority(999);
            make.trailing.lessThanOrEqualTo(self).offset(-10).priority(999);
            make.centerX.equalTo(self.anchorView).priority(700);
            
            if (self.singleDirection == CMSingleDirectionTop) {
                make.top.equalTo(self.anchorView.mas_bottom).offset(3);
            }else if(self.singleDirection == CMSingleDirectionBottom){
                make.bottom.equalTo(self.anchorView.mas_top).offset(-3);
            }
        }];
    }
    else {
        [self.tipContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(superView);
        }];
    }
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
        [self.singleton removeFromSuperlayer];
        self.singleton = nil;
        [self removeFromSuperview];
        if (self.tipDelegate && enable &&  [self.tipDelegate respondsToSelector:@selector(tipsView:onRemoved:)]) {
            [self.tipDelegate tipsView:self onRemoved:nil];
        }
    }
}

- (void)removeFromView {
    [self removeFromViewAnimate:NO enableCallBack:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.superview) {
        return;
    }
    self.tipLabel.preferredMaxLayoutWidth = self.tipLabel.frame.size.width;

//    self.tipLabel.preferredMaxLayoutWidth = self.tipContentView.width - 16;
    [super layoutSubviews];

    CGPoint start = CGPointZero;
    CGFloat yOffset = 10;
    
    switch (_singleDirection) {
        case CMSingleDirectionTop:
        {
            start.x = self.anchorView ? self.anchorView.centerX : self.bounds.size.width * _percent;
            start.y = self.tipContentView.top + 2;
            yOffset = -10;
        }
            break;
        case CMSingleDirectionBottom:
        {
            start.x = self.anchorView ? self.anchorView.centerX : self.bounds.size.width * _percent;
            start.y = self.tipContentView.bottom - 2;
        }
            break;
        default:
            break;
    }
    UIBezierPath *singletonPath = [UIBezierPath bezierPath];
    [singletonPath moveToPoint:CGPointMake(start.x - 8.8, start.y)];
    [singletonPath addLineToPoint:CGPointMake(start.x + 8.8, start.y)];
    [singletonPath addLineToPoint:CGPointMake(start.x, start.y + yOffset)];
    [singletonPath closePath];
    self.singleton.path = singletonPath.CGPath;
    self.singleton.lineJoin = kCALineJoinRound;
    self.singleton.lineWidth = 4;
    self.singleton.strokeColor = kBackgroundColor.CGColor;
    self.singleton.fillColor = kBackgroundColor.CGColor;
}

//- (void)tapAction:(UITapGestureRecognizer *)tapGestureRecognizer
//{
//    [self removeFromView];
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromView];
    if (!self.tipDelegate || ![self.tipDelegate respondsToSelector:@selector(tipsView:onTapped:)] ) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch* touch = [touches anyObject];
    if (touch) {
        CGPoint pt = [touch locationInView:self];
        if (CGRectContainsPoint(self.tipContentView.frame, pt)) {
            [self.tipDelegate tipsView:self onTapped:@{@"type": @(1)}];
        }
        else {
            [self.tipDelegate tipsView:self onTapped:@{@"type": @(2)}];
        }
    }
}

- (UIImage *)stretchLeftAndRightWithContainerSize:(CGSize)size stretchImage:(UIImage *)stretchImage
{
    CGSize imageSize = stretchImage.size;
    CGSize bgSize = CGSizeMake(floorf(size.width), floorf(size.height));
    //1.第一次拉伸右边 保护左边
    UIImage *image = [stretchImage stretchableImageWithLeftCapWidth:imageSize.width *0.8 topCapHeight:imageSize.height * 0.5];
    //第一次拉伸的距离之后图片总宽度
    CGFloat tempWidth = (bgSize.width)/2 + imageSize.width/2;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, imageSize.height), NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, tempWidth, bgSize.height)];
    //拿到拉伸过的图片
    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //2.第二次拉伸左边 保护右边
    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:firstStrechImage.size.width *0.1 topCapHeight:firstStrechImage.size.height*0.5];
    return secondStrechImage;
}
@end
