//
//  CMDownProgress.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/7/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDownProgress.h"

@interface CMDownProgress()

@property (nonatomic,strong) UIView *progressView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) MASConstraint * widthConstraint;

@end

@implementation CMDownProgress

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.backView];
        [self addSubview:self.progressView];
        
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self);
         }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.left.bottom.equalTo(self);
            self.widthConstraint = make.width.equalTo(@(0));
        }];
    }
    
    kLog(@"self.backView = %p", self.backView);
    kLog(@"self.progressView = %p", self.progressView);
    return self;
}

- (UIView *)progressView
{
    if (!_progressView)
    {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor grayColor];
    }
    
    return _progressView;
}

- (UIView *)backView
{
    if (!_backView)
    {
        _backView = [[UIView alloc] init];
    }
    
    return _backView;
}

- (void)setBackColor:(UIColor *)backColor
{
    self.backView.backgroundColor = backColor;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    self.progressView.backgroundColor = progressColor;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.widthConstraint.sizeOffset(CGSizeMake(self.bounds.size.width * self.progress, self.bounds.size.height));
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)updateConstraints
{
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make)
    {
        kLog(@"DownProgress = %f", self.progress);
    }];

    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backView.layer.cornerRadius = self.bounds.size.height/2;
    self.progressView.layer.cornerRadius = self.bounds.size.height/2;
    kLogInfo(@"self.view frame(%@), self.progressView frame(%@), self.progressView frame:(%@)", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.progressView.frame), NSStringFromCGRect(self.progressView.frame));
}

@end
