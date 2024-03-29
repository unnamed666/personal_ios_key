//
//  CMUISwitch.m
//  PandaKeyboard
//
//  Created by Alchemist on 2017/6/7.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMUISwitch.h"
#import "TTSwitchSubclass.h"

@interface CMUISwitch ()

@property (nonatomic, strong) UIImageView *trackImageOnView;
@property (nonatomic, strong) UIImageView *trackImageOffView;

@end


@implementation CMUISwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self fadeSwitchCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self fadeSwitchCommonInit];
    }
    return self;
}

- (void)setChangeHandler:(TTSwitchChangeHandler)changeHandler
{
    __weak typeof(self) weakSelf = self;
    [super setChangeHandler:^(BOOL on)
    {
        if (!on)
        {
            [weakSelf.thumbImageView setImage:weakSelf.trackImageOn];
        }
        else
        {
            [weakSelf.thumbImageView setImage:weakSelf.trackImageOff];
            
        }
        
        changeHandler(on);
    }];
}

- (void)fadeSwitchCommonInit
{
    self.maskInLockPosition = @YES;
    
    _trackImageOnView = [[UIImageView alloc] init];
    _trackImageOffView = [[UIImageView alloc] init];
    
    // insert below self.trackImageView because the labels are added to it
    [self.maskedTrackView insertSubview:_trackImageOnView belowSubview:self.trackImageView];
    [self.maskedTrackView insertSubview:_trackImageOffView belowSubview:self.trackImageView];
    
    self.trackImage = nil;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    // Sets the labels positions correctly on track
    self.trackImageView.frame = (CGRect){
        CGPointZero,
        { self.trackMaskImage.size.width * 2.0f - self.thumbImageView.frame.size.width - self.thumbInsetX * 2.0f, self.trackMaskImage.size.height }
    };
    [self updateThumbPositionAnimated:NO];
    
    [super layoutSubviews];
}

#pragma mark - Public Interface

- (void)setTrackImage:(UIImage *)trackImage
{
    // always set the track image to nil and use trackImageOn and trackImageOff.
    [super setTrackImage:nil];
}

- (void)setTrackImageOn:(UIImage *)trackImageOn
{
    if (_trackImageOn != trackImageOn) {
        _trackImageOn = trackImageOn;
        [_trackImageOnView setImage:_trackImageOn];
        [_trackImageOnView setFrame:(CGRect){ CGPointZero, {self.bounds.size.width - 2, self.bounds.size.height}}];
    }
}

- (void)setTrackImageOff:(UIImage *)trackImageOff
{
    if (_trackImageOff != trackImageOff) {
        _trackImageOff = trackImageOff;
        [_trackImageOffView setImage:_trackImageOff];
        [_trackImageOffView setFrame:(CGRect){ CGPointZero, {self.bounds.size.width - 2, self.bounds.size.height}}];
    }
}

#pragma mark - TTSwitch

- (void)moveThumbCenterToX:(CGFloat)newThumbCenterX
{
    [super moveThumbCenterToX:newThumbCenterX];
    [self.trackImageOffView setAlpha:(self.on ? 0.0f : 1.0f)];
}

- (void)didMoveThumbCenterToX:(CGFloat)newThumbCenterX
{
    // no-op
}


#pragma mark - UIGestureRecognizer

- (void)handleThumbPanGesture:(UIPanGestureRecognizer *)gesture
{
    [super handleThumbPanGesture:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        CGFloat minBoundary = self.thumbInsetX + (self.thumbImageView.bounds.size.width / 2.0f);
        CGFloat maxBoundary = self.bounds.size.width - (self.thumbImageView.bounds.size.width / 2.0f) - self.thumbInsetX;
        self.trackImageOffView.alpha = (1.0f - ((self.thumbImageView.center.x - minBoundary)/(maxBoundary - minBoundary)));
    }
}

@end
