//
//  CMEmojiToolBarView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/22.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import "CMEmojiToolBarView.h"
#import "CMKeyboardManager.h"
#import "UIView+Util.h"
#import "CMThemeManager.h"
#import "UIImage+Util.h"
#import "HMSegmentedControl.h"
#import "UIImage+Util.h"
@interface CMEmojiToolBarView ()
//@property (nonatomic, strong)UIImageView* bgImageView;
//@property (nonatomic, strong)UIButton* emojiBtn;
@property (nonatomic, strong)HMSegmentedControl* segmentedControl;
@end

@implementation CMEmojiToolBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = rgb(0, 42, 67);
//        UIImage* image = kCMKeyboardManager.themeManager.predictViewBgImage;
//        if(image){
//            self.bgImageView = [[UIImageView alloc] initWithImage:image];
//            [self addSubview:self.bgImageView];
//        }else{
//            self.backgroundColor = kCMKeyboardManager.themeManager.predictViewBgColor;
//        }
        [self addSubview:self.segmentedControl];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    _bgImageView.frame = self.bounds;
    self.segmentedControl.frame = self.bounds;
//    self.emojiBtn.centerY = self.centerY;
//    self.emojiBtn.left = self.boundleft + 15.0f;
}


#pragma mark - setting/getting
//- (UIImageView *)bgImageView {
//    if (!_bgImageView) {
//        _bgImageView = [UIImageView new];
//        UIImage* image = kCMKeyboardManager.themeManager.predictViewBgImage;
//        if (image == nil) {
//            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.predictViewBgColor];
//        }
//        else {
//            [_bgImageView setImage:image];
//        }
//    }
//    return _bgImageView;
//}

//- (UIButton *)emojiBtn {
//    if (!_emojiBtn) {
//        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"] || [kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"purple_hologram"]) {
//        [_emojiBtn setImage:kCMKeyboardManager.themeManager.emojiImage forState:UIControlStateNormal];
//        }else{
//            [_emojiBtn setImage:[[UIImage imageNamed:@"toolbar_smiley_icon"] imageWithTintColor:kCMKeyboardManager.themeManager.dismissBtnTintColor] forState:UIControlStateNormal];
//        }
//        [_emojiBtn addTarget:self action:@selector(handleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [_emojiBtn sizeToFit];
//    }
//    return _emojiBtn;
//}
- (HMSegmentedControl *)segmentedControl{
    if(!_segmentedControl){
        UIColor * tintCollor = kCMKeyboardManager.themeManager.dismissBtnTintColor;
        UIColor * tintCollor2 = [tintCollor colorWithAlphaComponent:0.6];
        NSArray * imageArray = @[tintCollor2?[[UIImage imageNamed:@"emoji_EmojiToolBar"] imageWithTintColor:tintCollor2]:[UIImage imageNamed:@"emoji_EmojiToolBar"],
                                 tintCollor2?[[UIImage imageNamed:@"emoji_gif"] imageWithTintColor:tintCollor2]:[UIImage imageNamed:@"emoji_gif"],
                                 tintCollor2?[[UIImage imageNamed:@"emoticonIcon"] imageWithTintColor:tintCollor2]:[UIImage imageNamed:@"emoticonIcon"]];
        
        NSArray * imageSelectedArray = @[tintCollor?[[UIImage imageNamed:@"emoji_EmojiToolBar"] imageWithTintColor:tintCollor]:[UIImage imageNamed:@"emoji_EmojiToolBar"],
                                                          tintCollor?[[UIImage imageNamed:@"emoji_gif"] imageWithTintColor:tintCollor]:[UIImage imageNamed:@"emoji_gif"],
                                                          tintCollor?[[UIImage imageNamed:@"emoticonIcon"] imageWithTintColor:tintCollor]:[UIImage imageNamed:@"emoticonIcon"]];
//        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"One", @"Two"]];
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:imageArray sectionSelectedImages:imageSelectedArray titlesForSections:@[CMLocalizedString(@"Emoji",nil), CMLocalizedString(@"GIF",nil),CMLocalizedString(@"AR-Emoticon",nil)]];
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
        _segmentedControl.textImageSpacing = 8;
        _segmentedControl.imagePosition = HMSegmentedControlImagePositionLeftOfText;
        _segmentedControl.selectionIndicatorHeight = 2.0f;
        _segmentedControl.backgroundColor = [UIColor clearColor];
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : tintCollor2 };
        _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName :tintCollor};
        _segmentedControl.selectionIndicatorColor =  tintCollor;
        _segmentedControl.selectionIndicatorBoxColor = [UIColor clearColor];
        _segmentedControl.selectionIndicatorBoxOpacity = 1.0;
        _segmentedControl.selectedSegmentIndex = kCMKeyboardManager.emoji_emoticon_index;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.shouldAnimateUserSelection = NO;
        _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
        _segmentedControl.stretchSegmentsToScreenSize = YES;
//        [_segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
//            NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
//            return attString;
//        }];
        BOOL emotionClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardEmoticonClick];
        BOOL gifClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardGifSegmentClick];
        
        if(!emotionClick || !gifClick){
            _segmentedControl.redDotIndex = @[[NSNull null],@(!gifClick),@(!emotionClick)];
        }
        
        [_segmentedControl addTarget:self action:@selector(segmentedControlTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
//    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    kCMKeyboardManager.emoji_emoticon_index = segmentedControl.selectedSegmentIndex;
    if(segmentedControl.redDotIndex){
        BOOL emotionClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardEmoticonClick];
        BOOL gifClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardGifSegmentClick];
        if(kCMKeyboardManager.emoji_emoticon_index == 2){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEmojiBoardEmoticonClick];
            emotionClick = YES;
            _segmentedControl.redDotIndex = @[[NSNull null],@(!gifClick),@(!emotionClick)];
        }else if(kCMKeyboardManager.emoji_emoticon_index == 1){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEmojiBoardGifSegmentClick];
            gifClick = YES;
            _segmentedControl.redDotIndex = @[[NSNull null],@(!gifClick),@(!emotionClick)];
        }
        if(emotionClick&& gifClick){
            segmentedControl.redDotIndex = nil;
        }
    }
    [self.delegate onEmojiViewToolBarView:self emojiBtnTapped:@{@"ChangedIndex":@(segmentedControl.selectedSegmentIndex)}];
}
- (void)segmentedControlTouchUpInside:(HMSegmentedControl *)segmentedControl {
    //    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [self.delegate onEmojiViewToolBarView:self emojiBtnTapped:@{@"clickIndex":@(segmentedControl.selectedSegmentIndex)}];
    
}

//- (void)handleBtnTapped:(UIButton *)sender {
//    if (!self.delegate) {
//        return;
//    }
//    if (sender == self.emojiBtn) {
//        [self.delegate onEmojiViewToolBarView:self emojiBtnTapped:nil];
//    }
//}
@end
