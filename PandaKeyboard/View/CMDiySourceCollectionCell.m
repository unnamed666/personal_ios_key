//
//  CMDiySourceCollectionCell.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDiySourceCollectionCell.h"
#import <YYWebImage/YYWebImage.h>
#import "CMDiySourceModel.h"

@interface CMDiySourceCollectionCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *selectedMarkImageView;

@end


@implementation CMDiySourceCollectionCell

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.coverImageView];
        [self.contentView addSubview:self.selectedMarkImageView];
        
        self.coverImageView.frame = CGRectMake(4.0f, 4.0f, CGRectGetWidth(self.contentView.bounds) - 8.0f, CGRectGetHeight(self.contentView.bounds) - 8.0f);
        self.selectedMarkImageView.frame = self.contentView.bounds;
        
        self.progressLayer.frame = self.coverImageView.bounds;
        [self.coverImageView.layer addSublayer:self.progressLayer];
    }
    return self;
}

#pragma mark - setter/getter
- (UIImageView *)coverImageView
{
    if (!_coverImageView) {
        _coverImageView = [UIImageView new];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.masksToBounds = YES;
        _coverImageView.layer.cornerRadius = 10.0f;
        _coverImageView.backgroundColor = rgb(34, 39, 64);
    }
    return _coverImageView;
}

- (UIImageView *)selectedMarkImageView
{
    if (!_selectedMarkImageView) {
        _selectedMarkImageView = [UIImageView new];
        _selectedMarkImageView.image = [UIImage imageNamed:@"diy_source_selected_mark"];
        _selectedMarkImageView.contentMode = UIViewContentModeScaleAspectFit;
        _selectedMarkImageView.hidden = YES;
    }
    return _selectedMarkImageView;
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineWidth = 2.8f;
        _progressLayer.lineCap = kCALineCapRound;
    }
    return _progressLayer;
}

#pragma mark -
- (void)bindingDiySourceModel:(CMDiySourceModel *)diySourceModel
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.progressLayer.bounds.size.width / 2, self.progressLayer.bounds.size.height / 2) radius:self.progressLayer.bounds.size.width / 2 - 8.0f startAngle:(M_PI * (-90) / 180.0) endAngle:(M_PI * -90 / 180.0) clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    if (!diySourceModel) {
        return;
    }
    
    [self.coverImageView yy_setImageWithURL:[NSURL URLWithString:diySourceModel.cover_url] placeholder:nil options:(YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        
        
    }];
}

- (void)setCoverImage:(UIImage *)image
{
    if (image) {
        [self.coverImageView yy_cancelCurrentImageRequest];
        self.coverImageView.image = image;
    }
}

#pragma mark - selected
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setSelectedCell:selected];
}

- (void)setSelectedCell:(BOOL)selected
{
    if (selected) {
        self.selectedMarkImageView.hidden = NO;
    }else{
        self.selectedMarkImageView.hidden = YES;
    }
}

@end
