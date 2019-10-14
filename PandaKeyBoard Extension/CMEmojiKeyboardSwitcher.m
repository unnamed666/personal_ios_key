//
//  CMEmojiKeyboardSwitcher.m
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMEmojiKeyboardSwitcher.h"

#import "CMEmoticonKeyboardView.h"
#import "CMKeyboardManager.h"
#import "CMGifKeyboardView.h"

@interface CMEmojiKeyboardSwitcher()
@property (nonatomic, weak)UIView * superView;
@property (nonatomic, strong)CMEmojiKeyboardView * emojiKeyboardView;
@property (nonatomic, strong)CMEmoticonKeyboardView * emoticonKeyboardView;
@property (nonatomic, strong)CMGifKeyboardView * gifKeyboardView;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong)CMKeyModel* layoutKeyModel;
@property (nonatomic, strong)CMKeyModel* deleteKeyModel;
@property (nonatomic, strong)CMKeyModel* returnKeyModel;

@end
@implementation CMEmojiKeyboardSwitcher
static int kEmojiIndex = 0;
static int kEmoticonIndex = 2;
static int kGifIndex = 1;

- (instancetype)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _keyboardIndex = kCMKeyboardManager.emoji_emoticon_index;
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    if (_emojiKeyboardView && !_emojiKeyboardView.superview) {
        self.emojiKeyboardView = nil;
    }
    if (_emoticonKeyboardView && !_emoticonKeyboardView.superview) {
        self.emoticonKeyboardView = nil;
    }
    
    if (_gifKeyboardView && !_gifKeyboardView.superview) {
        _gifKeyboardView = nil;
    }
}
- (void)showToParentVeiw:(UIView*)view{
    self.superView = view;
    if(_keyboardIndex == kEmojiIndex){
        [self.emojiKeyboardView removeFromSuperview];
        return [view addSubview:self.emojiKeyboardView];
    }else if(_keyboardIndex == kEmoticonIndex){
        [self.emoticonKeyboardView removeFromSuperview];
        return [view addSubview:self.emoticonKeyboardView];
    }
    else if (_keyboardIndex == kGifIndex)
    {
        [self.gifKeyboardView removeFromSuperview];
        return [view addSubview:self.gifKeyboardView];
    }
}

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel deleteModel:(CMKeyModel *)deleteKeyModel returnModel:(CMKeyModel *)returnKeyModel{
    self.layoutKeyModel = layoutKeyModel;
    self.deleteKeyModel = deleteKeyModel;
    self.returnKeyModel = returnKeyModel;
    
    if(_keyboardIndex == kEmojiIndex){
//        [self.emojiKeyboardView setupWithLayoutModel:layoutKeyModel deleteModel:deleteKeyModel returnModel:returnKeyModel];
    }else if(_keyboardIndex == kEmoticonIndex){
//        [self.emoticonKeyboardView setupWithLayoutModel:layoutKeyModel];
    }
}

- (BOOL)isShowEmojiKeyboard{
    if ((_emojiKeyboardView && _emojiKeyboardView.superview)||(_emoticonKeyboardView && _emoticonKeyboardView.superview)||(_gifKeyboardView && _gifKeyboardView.superview)) {
        return YES;
    }
    return NO;
}
- (void)removeFromSuperview{
    [_emojiKeyboardView removeFromSuperview];
    _emojiKeyboardView = nil;
    [_emoticonKeyboardView removeFromSuperview];
    _emoticonKeyboardView = nil;
    [_gifKeyboardView removeFromSuperview];
    _gifKeyboardView = nil;
}

-(void)dealloc{
    [self removeFromSuperview];
}

#pragma mark - get/set

- (void)setKeyboardIndex:(int)keyboardIndex{
    if(_keyboardIndex == keyboardIndex)return;
    if(keyboardIndex == kEmojiIndex){
        UIView * superView = self.superView;
        if(superView){
            [_emoticonKeyboardView removeFromSuperview];
            [_gifKeyboardView removeFromSuperview];
            [superView addSubview:self.emojiKeyboardView];
            self.emojiKeyboardView.frame = _emoticonKeyboardView.frame;
        }
    }else if(keyboardIndex == kEmoticonIndex){
        UIView * superView = self.superView;
        if(superView){
            [_emojiKeyboardView removeFromSuperview];
            [_gifKeyboardView removeFromSuperview];
            [superView addSubview:self.emoticonKeyboardView];
            self.emoticonKeyboardView.frame = _emojiKeyboardView.frame;
        }
    }
    else if (keyboardIndex == kGifIndex)
    {
        UIView * superView = self.superView;
        if(superView){
            [_emoticonKeyboardView removeFromSuperview];
            [_emojiKeyboardView removeFromSuperview];
            [superView addSubview:self.gifKeyboardView];
            self.gifKeyboardView.frame = self.emojiKeyboardView.frame;
        }
    }
    _keyboardIndex = keyboardIndex;
}

- (CMBaseKeyboardView *)emojiKeyboard{
    if(_keyboardIndex == kEmojiIndex){
        return self.emojiKeyboardView;
    }else if(_keyboardIndex == kEmoticonIndex){
        return self.emoticonKeyboardView;
    }
    else if (_keyboardIndex == kGifIndex)
    {
        return self.gifKeyboardView;
    }
    return nil;
}

- (CMEmojiKeyboardView *)emojiKeyboardView {
    if (!_emojiKeyboardView) {
        _emojiKeyboardView = [CMEmojiKeyboardView new];
        _emojiKeyboardView.translatesAutoresizingMaskIntoConstraints = NO;
        _emojiKeyboardView.delegate = _delegate;
        if(self.layoutKeyModel&&self.returnKeyModel&&self.deleteKeyModel){
            [self.emojiKeyboardView setupWithLayoutModel:self.layoutKeyModel deleteModel:self.deleteKeyModel returnModel:self.returnKeyModel];
        }
        _emojiKeyboardView.inSource = self.inSource;
    }
    return _emojiKeyboardView;
}

- (CMEmoticonKeyboardView *)emoticonKeyboardView{
    if(!_emoticonKeyboardView){
        _emoticonKeyboardView = [[CMEmoticonKeyboardView alloc] init];
        _emoticonKeyboardView.translatesAutoresizingMaskIntoConstraints = NO;
        _emoticonKeyboardView.delegate = _delegate;
        [_emoticonKeyboardView setupWithLayoutModel:self.layoutKeyModel];
        _emoticonKeyboardView.inSource = self.inSource;
    }
    return _emoticonKeyboardView;
}

- (CMGifKeyboardView *)gifKeyboardView{
    if(!_gifKeyboardView){
        _gifKeyboardView = [[CMGifKeyboardView alloc] init];
        _gifKeyboardView.translatesAutoresizingMaskIntoConstraints = NO;
        _gifKeyboardView.delegate = _delegate;
        [_gifKeyboardView setupWithLayoutModel:self.layoutKeyModel deleteModel:self.deleteKeyModel];
        _gifKeyboardView.inSource = self.inSource;
    }
    return _gifKeyboardView;
}

- (CMBaseKeyboardViewModel *)viewModel{
    if(_keyboardIndex == kEmojiIndex){
        return _emojiKeyboardView.viewModel;
    }else if(_keyboardIndex == kEmoticonIndex){
        return _emoticonKeyboardView.viewModel;
    }
    else if (_keyboardIndex == kGifIndex)
    {
        return self.gifKeyboardView.viewModel;
    }
    return nil;
}
@end
