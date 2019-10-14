//
//  CMPlayerView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/8/17.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMPlayerView.h"
#import <AVFoundation/AVfoundation.h>

@interface CMPlayerView ()
@property (nonatomic, strong) UIImageView * coverImageView;
@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UIButton * playButton;

@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@end

@implementation CMPlayerView

#pragma mark - Life Circle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        [self addSubview:_coverImageView];
        
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [self addSubview:_maskView];
        [self bringSubviewToFront:_maskView];
        
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"videoPlayIcon"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"videoPlayIcon"] forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_maskView addSubview:_playButton];
        

        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_maskView);
            make.size.mas_equalTo(CGSizeMake(57, 57));
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayFinish) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - set method
-(void)setCoverImageString:(NSString *)coverImageString
{
    _coverImageString = [coverImageString copy];
    _coverImageView.image = [UIImage imageNamed:coverImageString];
}

#pragma mark - Custom Methods
- (void)setupPlayerWithSourceString:(NSString *)sourceString
{
    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:sourceString]];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.bounds;
    [self.layer addSublayer:_playerLayer];
    
}

- (void)play
{
    [_player play];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _coverImageView.hidden = YES;
        //[_coverImageView removeFromSuperview];
        _maskView.hidden = YES;
        _playButton.hidden = YES;
    });
}

- (void)pause
{
    [_player pause];
}

#pragma mark - CMPlayerViewDelegate Method
- (void)playButtonDidClick:(UIButton *)playButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playButtonDidClick)]) {
        [self.delegate playButtonDidClick];
    }
}

#pragma mark - Notification Methods
- (void)videoDidPlayFinish
{
    _maskView.hidden = NO;
    _playButton.hidden = NO;
    [_player seekToTime:kCMTimeZero];
    [self pause];
    [self bringSubviewToFront:_maskView];
}

@end
