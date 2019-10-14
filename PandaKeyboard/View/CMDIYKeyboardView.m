//
//  CMDIYKeyboardView.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDIYKeyboardView.h"
#import "CMkeyboardView.h"
#import "CMKeyboardManager.h"
#import "CMTextInputModel.h"
#import "CMKeyboardViewModel.h"
#import "CMThemeManager.h"
#import "CMToolBarView.h"
#import "CMKeyModel.h"
#import <AVFoundation/AVFoundation.h>


#import "CMSuggestionStripView.h"
@interface CMDIYKeyboardView()<CMBaseKeyboardViewDelegate>
@property (nonatomic, strong)UIImageView * toolbarBackImageView;
@property (nonatomic, strong)UIImageView * keyboardBackImageView;
@property (nonatomic, strong)CMKeyboardView* keyboardView;
@property (nonatomic, strong)CMToolBarView * toolBarView;
@property (nonatomic, strong)CMSuggestionStripView* suggestionView;
@property (nonatomic, strong)dispatch_queue_t audioSerialQueue;
@property (nonatomic, strong)AVAudioPlayer *player;


@end
@implementation CMDIYKeyboardView

- (instancetype)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage* bgImage = kCMKeyboardManager.themeManager.wholeBoardBgImage;
        
        if (bgImage) {
            self.layer.contents = (id)bgImage.CGImage;
        }
        else {
            self.backgroundColor = kCMKeyboardManager.themeManager.wholeBoardBgColor;
        }
        
        self.toolBarView = [CMToolBarView new];
        self.keyboardView = [CMKeyboardView new];
        self.keyboardView.delegate = self;
        self.keyboardView.keyboardViewType = CMKeyboardViewTypeDiy;

        [self addSubview:self.toolbarBackImageView];
        [self addSubview:self.keyboardBackImageView];
        [self addSubview:self.toolBarView];
        [self addSubview:self.keyboardView];
        CMTextInputModel* model = [CMTextInputModel new];
        model.keyboardType =0;
        model.autocorrectionType = 0;
        model.autocapitalizationType = 0;
        model.spellCheckingType = 0;
        model.returnKeyType = 0;
        model.enablesReturnKeyAutomatically = 0;
        
        
        [[CMKeyboardManager sharedInstance] loadKeyboardByLayoutType:CMKeyboardTypeLetter inputModel:model completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
            
            if (viewModel && error == nil) {
                self.keyboardView.isLayoutFinish = NO;
                [self.keyboardView bindData:viewModel];
                CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
                [theViewModel shiftStateUnSelected];
            }}];
    }
    return self;
}

-(void)dealloc{
    _player = nil;
}

- (void)bindData:(NSArray<NSString*> *)words{
    if(!_suggestionView){
        _suggestionView = [CMSuggestionStripView new];
    }
    if(words == nil || words.count ==0){
        _toolBarView.hidden = NO;
        [_suggestionView removeFromSuperview];
    }else{
        _toolBarView.hidden = YES;
        [_suggestionView removeFromSuperview];
        [self addSubview:_suggestionView];
        [_suggestionView bindData:words];
    }
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    int toolHeight =  [CMKeyboardManager toolbarHeight];
    self.keyboardView.frame = CGRectMake(0, toolHeight, CGRectGetWidth(self.bounds), [CMKeyboardManager keyboardHeight]);
    _toolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), toolHeight);
    _suggestionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), toolHeight);
    
    self.keyboardBackImageView.frame = CGRectMake(0, toolHeight, CGRectGetWidth(self.bounds), [CMKeyboardManager keyboardHeight]);
    self.toolbarBackImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), toolHeight);
}

- (void)switchTheme{
    UIImage* image = kCMKeyboardManager.themeManager.predictViewBgImage;
    if (image == nil)
    {
        [_toolbarBackImageView setImage:nil];
        [_toolbarBackImageView setBackgroundColor:kCMKeyboardManager.themeManager.predictViewBgColor];
    }else
    {
        [_toolbarBackImageView setImage:image];
    }
    
    UIImage* image1 = kCMKeyboardManager.themeManager.keyboardViewBgImage;
    if (image1 == nil) {
        [_keyboardBackImageView setImage:nil];
        [_keyboardBackImageView setBackgroundColor:kCMKeyboardManager.themeManager.keyboardViewBgColor];
    }
    else
    {
        [_keyboardBackImageView setImage:image1];
    }
    
    UIImage* bgImage = kCMKeyboardManager.themeManager.wholeBoardBgImage;
    
    if (bgImage) {
        self.layer.contents = (id)bgImage.CGImage;
    }
    else {
        self.backgroundColor = kCMKeyboardManager.themeManager.wholeBoardBgColor;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(switchTheme)]){
            [obj performSelector:@selector(switchTheme)];
        }
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIImageView *)toolbarBackImageView
{
    if (!_toolbarBackImageView)
    {
        _toolbarBackImageView = [[UIImageView alloc] init];
        UIImage* image = kCMKeyboardManager.themeManager.predictViewBgImage;
        if (image == nil)
        {
            [_toolbarBackImageView setBackgroundColor:kCMKeyboardManager.themeManager.predictViewBgColor];
        }
        else
        {
            [_toolbarBackImageView setImage:image];
        }
    }
    
    return _toolbarBackImageView;
}

- (UIImageView *)keyboardBackImageView
{
    if (!_keyboardBackImageView)
    {
        _keyboardBackImageView = [[UIImageView alloc] init];
        UIImage* image = kCMKeyboardManager.themeManager.keyboardViewBgImage;
        
        if (image == nil) {
            [_keyboardBackImageView setBackgroundColor:kCMKeyboardManager.themeManager.keyboardViewBgColor];
        }
        else
        {
            [_keyboardBackImageView setImage:image];
        }
    }
    
    return _keyboardBackImageView;
}



#pragma mark - play sound

- (dispatch_queue_t)audioSerialQueue {
    if (!_audioSerialQueue) {
        _audioSerialQueue = dispatch_queue_create("audio_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _audioSerialQueue;
}


- (void)playSoundWithSoundData:(NSData *)data
{
    if (!data) {
        return;
    }
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    });
    dispatch_async(self.audioSerialQueue, ^{
        if (self.player) {
            [self.player stop];
            self.player = nil;
        }
        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        self.player.volume = kCMGroupDataManager.volume;
        [self.player prepareToPlay];
        [self.player play];
    });
}

- (void)playSoundWithKeyType:(CMKeyType)keyType
{
    
    if (keyType == CMKeyTypeDel) {
        [self playSoundWithSoundData:kCMKeyboardManager.themeManager.delSoundData];
    }
    else if (keyType == CMKeyTypeSpace) {
        [self playSoundWithSoundData:kCMKeyboardManager.themeManager.spaceSoundData];
    }
    else if (keyType == CMKeyTypeReturn) {
        [self playSoundWithSoundData:kCMKeyboardManager.themeManager.returnSoundData];
    }
    else {
        [self playSoundWithSoundData:kCMKeyboardManager.themeManager.defaultSoundData];
    }
}


#pragma mark - CMBaseKeyboardViewDelegate
- (void)onKeyboard:(CMBaseKeyboardView *)keyboard touchDownKeyModel:(CMKeyModel *)keyModel touchPt:(CGPoint)touchPt fromeRepeate:(BOOL)fromRepeate{
   
        if (!fromRepeate) {
            [self playSoundWithKeyType:keyModel.keyType];
//            [CMExtensionBizHelper playVibration:YES];
        }
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard touchUpInsideKeyModel:(CMKeyModel *)keyModel touchPt:(CGPoint)touchPt fromeRepeate:(BOOL)fromRepeate{
    
    if (![keyModel shouldUseTouchUnInsideEvent]) {
        return;
    }
    
//    if (keyboard == self.keyboardView) {
        if (keyModel.keyType == CMKeyTypeLayoutSwitch) {
            CMTextInputModel* model = [CMTextInputModel new];
            model.keyboardType =0;
            model.autocorrectionType = 0;
            model.autocapitalizationType = 0;
            model.spellCheckingType = 0;
            model.returnKeyType = 0;
            model.enablesReturnKeyAutomatically = 0;
            @weakify(self)
            [[CMKeyboardManager sharedInstance] loadKeyboardByLayoutId:keyModel.layoutId inputModel:model completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
                @stronglize(self)
                if (viewModel && error == nil) {
                    if (viewModel && error == nil) {
                        self.keyboardView.isLayoutFinish = NO;
                        [self.keyboardView bindData:viewModel];
                        CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
                        [theViewModel shiftStateUnSelected];
                    }
                    
                }
            }];
            return;
        }
//    }
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard layoutFinished:(NSDictionary *)dimDic{
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard doubleTappedKeyModel:(CMKeyModel *)keyModel{
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard longPressedKeyModel:(CMKeyModel *)keyModel{
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard selectedInputOption:(NSString *)optionTitle{
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard upateBatchInputPointerModel:(InputPointers *)inputPointerModel{
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard startbatchInput:(NSDictionary *)infoDic{
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard endBatchInputPointerModel:(InputPointers *)inputPointerModel{
    
}
@end
