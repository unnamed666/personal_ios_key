
#import "VideoPlayerView.h"

@interface VideoPlayerView();

@property(weak,nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIImageView* videoPlayBackImage;

@end


@implementation VideoPlayerView

+(instancetype)videoPlayView{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [audioSession setActive:YES error:nil];
    
    return [[[NSBundle mainBundle]loadNibNamed:@"VideoPlayerView"owner:nil options:nil] firstObject];
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    self.player= [[AVPlayer alloc]init];
    self.playerLayer = [ AVPlayerLayer playerLayerWithPlayer:self.player ];
    
    [self addSubview:self.videoPlayBackImage];
    [self.videoPlayBackImage mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(self);
     }];
    [self.videoPlayBackImage.layer addSublayer:self.playerLayer];
}

- (UIImageView *)videoPlayBackImage
{
    if (!_videoPlayBackImage)
    {
        _videoPlayBackImage = [[UIImageView alloc] init];
    }
    
    return _videoPlayBackImage;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
}

#pragma mark - 设置播放的视频
-(void)setPlayerItem:(AVPlayerItem *)playerItem{
    
    _playerItem = playerItem;
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self.player play];
}

@end
