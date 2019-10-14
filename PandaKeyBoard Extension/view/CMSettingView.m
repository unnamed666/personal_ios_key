//
//  CMSettingView.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/7/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMSettingView.h"
#import "UIImage+Util.h"
#import "CMSettingManager.h"
#import "CMGroupDataManager.h"
#import "CMInfoc.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "UIView+Util.h"
#import "CMNotificationConstants.h"
#import "CMExtensionBizHelper.h"
#import "UIDevice+Util.h"

// SizeScale获取当前设备与iPhone 6Plus的宽度比例 （414.0f代表iPhone 6Plus的宽度尺寸，183.0f代表设置页在横屏状态下的高度尺寸）
#define SizeScale                           ( [UIDevice currentDevice].isScreenPortrait ? self.bounds.size.width / 414.0f : self.bounds.size.height / 183.0f )

#define SizeScaleModel(size)                ((size) * SizeScale)
#define SettingCellWidth                    (76.0f * SizeScale)
#define SettingCellHeight                   (84.0f * SizeScale)
#define SettingSectionLeftRightMargin       (26.0f * SizeScale)

// iPadSizeScale获取当前设备与9.7寸iPad的宽度比例 （768.0f代表9.7寸iPad的宽度尺寸，338.0f代表设置页在横屏状态下的高度尺寸）
#define iPadSizeScale                        ( [UIDevice currentDevice].isScreenPortrait ? self.bounds.size.width / 768.0f : self.bounds.size.height / 338.0f )


#define iPadSizeScaleModel(size)                ((size) * iPadSizeScale)
#define iPadSettingCellWidth                    (76.0f * iPadSizeScale)
#define iPadSettingCellHeight                   (84.0f * iPadSizeScale)
#define iPadSettingSectionLeftRightMargin       (37.0f * iPadSizeScale)

@interface CMSettingCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIColor *settingCellTintColor;

@end


@implementation CMSettingCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0f;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.label];
        self.selectedBackgroundView = [UIView new];
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.width.equalTo(self.contentView).multipliedBy(0.48f);
            make.height.equalTo(self.imageView.mas_width);
            make.centerY.equalTo(self.contentView).multipliedBy(0.78f);
        }];
        [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom);
            make.width.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

#pragma mark - setter/getter
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 2;
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (void)setSettingCellTintColor:(UIColor *)settingCellTintColor
{
    _settingCellTintColor = settingCellTintColor;
    self.label.textColor = settingCellTintColor;
    self.imageView.image = [self.imageView.image imageWithTintColor:settingCellTintColor];
    self.selectedBackgroundView.backgroundColor = [settingCellTintColor colorWithAlphaComponent:0.2f];
}

@end


@interface CMSettingView ()<UICollectionViewDataSource, UICollectionViewDelegate>

//@property (nonatomic, strong) UIImageView* bgImageView;

@property (nonatomic, strong) NSArray<NSString *> *itemsTitle;
@property (nonatomic, strong) NSArray<NSString *> *itemsImage;
@property (nonatomic, strong) UICollectionView *settingCollectionView;

// 音量设置页面相关
@property (nonatomic, strong) UIButton *soundPopDownButton;
@property (nonatomic, strong) UIImageView *soundImageView;
@property (nonatomic, strong) UISlider *soundSlider;

@property (nonatomic, strong)UIStackView* soundBoardView;
@property (nonatomic, strong)UIButton* soundEnableSwitch;
@property (nonatomic, strong)UIButton* vibEnableSwitch;

@end


@implementation CMSettingView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.bgImageView];
        [self addSubview:self.settingCollectionView];
    }
    return self;
}

- (void)dealloc {
    kLogTrace();
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.bgImageView.frame = self.bounds;
    self.settingCollectionView.frame = self.bounds;
    if (_soundBoardView && _soundBoardView.superview) {
        self.soundBoardView.frame = self.bounds;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)didMoveToWindow {
    if (self.window) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:kNotificationOrientationTransit object:nil];
    }
    else {
        kLogInfo(@"移除通知 ThemeUpdateNotification");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - update constraints
- (void)handleOrientationNotification:(NSNotification *)notify {
    id<UIViewControllerTransitionCoordinator> coordinator = [notify object];
    [self setNeedsLayout];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self layoutIfNeeded];
            [self.settingCollectionView reloadData];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        }];
    }
    else {
        [self layoutIfNeeded];
        [self.settingCollectionView reloadData];
    }
}

#pragma mark - getter/setter
//- (UIImageView *)bgImageView {
//    if (!_bgImageView) {
//        _bgImageView = [UIImageView new];
//        UIImage* image = kCMKeyboardManager.themeManager.keyboardViewBgImage;
//        if (image == nil) {
//            [_bgImageView setBackgroundColor:kCMKeyboardManager.themeManager.keyboardViewBgColor];
//        }
//        else {
//            [_bgImageView setImage:image];
//        }
//    }
//    return _bgImageView;
//}

- (NSArray<NSString *> *)itemsTitle
{
    if (!_itemsTitle) {
        _itemsTitle = @[@"DIY",@"Gesture\ntyping", @"Languages", @"Feedback", @"Sound", @"Rate_us", @"Settings"];
    }
    return _itemsTitle;
}

- (NSArray<NSString *> *)itemsImage
{
    if (!_itemsImage) {
        _itemsImage = @[@"diyIcon_setting", @"gesture_typing_", @"language", @"feedback", @"sound",  @"rate_us", @"setting"];
    }
    return _itemsImage;
}

- (UICollectionView *)settingCollectionView
{
    if (!_settingCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _settingCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_settingCollectionView registerClass:[CMSettingCell class] forCellWithReuseIdentifier:NSStringFromClass([CMSettingCell class])];
        _settingCollectionView.backgroundColor = kCMKeyboardManager.themeManager.settingViewBgColor;
        _settingCollectionView.dataSource = self;
        _settingCollectionView.delegate = self;
        _settingCollectionView.decelerationRate = 0.4f;
    }
    return _settingCollectionView;
}

- (UIStackView *)soundBoardView {
    if (!_soundBoardView) {
        _soundBoardView = [UIStackView new];
        _soundBoardView.backgroundColor = self.settingCollectionView.backgroundColor;
        _soundBoardView.axis = UILayoutConstraintAxisVertical;
        _soundBoardView.distribution = UIStackViewDistributionEqualCentering;
        _soundBoardView.layoutMargins = UIEdgeInsetsMake(20, 10, 20, 30);
        [_soundBoardView setLayoutMarginsRelativeArrangement:YES];
        _soundBoardView.spacing = 20.0f;

        UIStackView* soundStack = [UIStackView new];
        soundStack.axis = UILayoutConstraintAxisHorizontal;
        soundStack.distribution = UIStackViewDistributionFill;
        soundStack.alignment = UIStackViewAlignmentCenter;
        
        UILabel* soundLabel = [[UILabel alloc] init];
        soundLabel.text = CMLocalizedString(@"keypress sound volume", nil);
        soundLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:16.0f];
        soundLabel.textColor = kCMKeyboardManager.themeManager.settingCellTintColor;
        [soundStack addArrangedSubview:soundLabel];
        [soundStack addArrangedSubview:self.soundEnableSwitch];
        
        UIStackView* slideStack = [UIStackView new];
        slideStack.axis = UILayoutConstraintAxisHorizontal;
        slideStack.alignment = UIStackViewAlignmentCenter;
        slideStack.spacing = 26.0f;
        [slideStack addArrangedSubview:self.soundImageView];
        [slideStack addArrangedSubview:self.soundSlider];

        UIStackView* vibStack = [UIStackView new];
        vibStack.axis = UILayoutConstraintAxisHorizontal;
        vibStack.distribution = UIStackViewDistributionFill;
        vibStack.alignment = UIStackViewAlignmentCenter;

        UILabel* vibLabel = [[UILabel alloc] init];
        vibLabel.text = CMLocalizedString(@"keypress vibration", nil);
        vibLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:16.0f];
        vibLabel.textColor = kCMKeyboardManager.themeManager.settingCellTintColor;
        [vibStack addArrangedSubview:vibLabel];
        [vibStack addArrangedSubview:self.vibEnableSwitch];
        
        [_soundBoardView addArrangedSubview:self.soundPopDownButton];
        [_soundBoardView addArrangedSubview:soundStack];
        [_soundBoardView addArrangedSubview:slideStack];
        if (![UIDevice isIpadPro])
        {
            [_soundBoardView addArrangedSubview:vibStack];
        }
    }
    return _soundBoardView;
}

- (UIButton *)soundPopDownButton {
    if (!_soundPopDownButton) {
        _soundPopDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_soundPopDownButton setImage:[[UIImage imageNamed:@"up_arrow"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateNormal];
        [_soundPopDownButton addTarget:self action:@selector(removeSoundSettingView) forControlEvents:UIControlEventTouchUpInside];
        [_soundPopDownButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _soundPopDownButton;
}

- (UIButton *)soundEnableSwitch {
    if (!_soundEnableSwitch) {
        _soundEnableSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
        [self soundVolumeIsAvailable:kCMSettingManager.openKeyboardSound && kCMKeyboardManager.isFullAccessAllowed];
        [_soundEnableSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_soundEnableSwitch setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _soundEnableSwitch;
}

- (UIButton *)vibEnableSwitch {
    if (!_vibEnableSwitch) {
        _vibEnableSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
        [_vibEnableSwitch setImage:[[UIImage imageNamed:@"sound_switch_on"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateHighlighted];
        [_vibEnableSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_vibEnableSwitch setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        if (kCMKeyboardManager.isFullAccessAllowed) {
            UIImage* image = kCMGroupDataManager.vibrationEnable ? [[UIImage imageNamed:@"sound_switch_on"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] : [[UIImage imageNamed:@"sound_switch_off"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor];
            [_vibEnableSwitch setImage:image forState:UIControlStateNormal];
        }
        else {
            [_vibEnableSwitch setImage:[[UIImage imageNamed:@"sound_switch_off"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateNormal];
        }
    }
    return _vibEnableSwitch;
}

- (UISlider *)soundSlider {
    if (!_soundSlider) {
        _soundSlider = [[UISlider alloc] init];
        _soundSlider.minimumValue = 0.0f;
        _soundSlider.maximumValue = 1.0f;
        _soundSlider.minimumTrackTintColor = kCMKeyboardManager.themeManager.settingCellTintColor;
        _soundSlider.maximumTrackTintColor = [kCMKeyboardManager.themeManager.settingCellTintColor colorWithAlphaComponent:0.5];
        _soundSlider.value = kCMSettingManager.volume;
        [_soundSlider setThumbImage:[[UIImage imageNamed:@"sound_slider_image"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateNormal];
        [_soundSlider addTarget:self action:@selector(volumeChangedEnd:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    }
    return _soundSlider;
}

- (UIImageView *)soundImageView {
    if (!_soundImageView) {
        _soundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sound"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor]];
        _soundImageView.size = CGSizeMake(22.0f, 22.0f);
        [_soundImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _soundImageView;
}

#pragma mark - Sound View
- (void)displaySoundSettingView
{
    self.settingCollectionView.hidden = YES;
    [self addSubview:self.soundBoardView];
//    [self.soundBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.leading.trailing.equalTo(self);
//        make.bottom.lessThanOrEqualTo(self.mas_bottom).offset(0);
//    }];
}

- (void)removeSoundSettingView
{
    [CMExtensionBizHelper playVibration:YES];
    [self.soundBoardView removeFromSuperview];
    self.settingCollectionView.hidden = NO;
}

#pragma mark - Sound
- (void)switchValueChanged:(UIButton *)control {
    [CMExtensionBizHelper playVibration:YES];
    if (control == self.soundEnableSwitch) {
        if (!self.pDelegate) {
            return;
        }
        [self.pDelegate onSettingViewSoundBtnTapped:self openKeyboardSound:!kCMSettingManager.openKeyboardSound];
        [self soundVolumeIsAvailable:(kCMSettingManager.openKeyboardSound && kCMKeyboardManager.isFullAccessAllowed)];
    }
    else if (control == self.vibEnableSwitch) {
        if (!kCMSettingManager.isAllowFullAccess) {
            [self.vibEnableSwitch setImage:[[UIImage imageNamed:@"sound_switch_off"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateNormal];
        }
        else {
            kCMGroupDataManager.vibrationEnable = !kCMGroupDataManager.vibrationEnable;
            UIImage* image = kCMGroupDataManager.vibrationEnable ? [[UIImage imageNamed:@"sound_switch_on"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] : [[UIImage imageNamed:@"sound_switch_off"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor];
            [self.vibEnableSwitch setImage:image forState:UIControlStateNormal];
        }
        [self.pDelegate onSettingView:self vibrationBtnTapped:kCMGroupDataManager.vibrationEnable];
    }
}

- (void)soundVolumeIsAvailable:(BOOL)isAvailable
{
    if (isAvailable) {
        self.soundImageView.alpha = 1.0f;
        self.soundSlider.alpha = 1.0f;
        self.soundSlider.userInteractionEnabled = YES;
        [self.soundEnableSwitch setImage:[[UIImage imageNamed:@"sound_switch_on"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateNormal];
    }else{
        self.soundImageView.alpha = 0.3f;
        self.soundSlider.alpha = 0.3f;
        self.soundSlider.userInteractionEnabled = NO;
        [self.soundEnableSwitch setImage:[[UIImage imageNamed:@"sound_switch_off"] imageWithTintColor:kCMKeyboardManager.themeManager.settingCellTintColor] forState:UIControlStateNormal];
    }
}


- (void)volumeChangedEnd:(UISlider *)sender
{
    if (self.pDelegate) {
        [self.pDelegate onSettingViewSoundVolumeChanged:self volume:sender.value];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemsTitle.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMSettingCell class]) forIndexPath:indexPath];
    float fontSize = [CMBizHelper isiPhone] ? SizeScaleModel(12.0f) : iPadSizeScaleModel(12.0f);
    cell.label.font = [UIFont fontWithName:@"Montserrat-Regular" size:fontSize];
    NSString *itemTitle = self.itemsTitle[indexPath.row];
    cell.label.text = CMLocalizedString(itemTitle, nil);
    NSString *imageName = self.itemsImage[indexPath.row];
    if ([itemTitle isEqualToString:@"Gesture\ntyping"]) {
        // 滑动输入
        imageName = [NSString stringWithFormat:@"%@%@", imageName, kCMSettingManager.slideInputEnable ? @"on" : @"off"];
    }else if ([itemTitle isEqualToString:@"Auto_caps"]) {
        // 自动大小写
        imageName = [NSString stringWithFormat:@"%@%@", imageName, kCMSettingManager.autoCapitalization ? @"on" : @"off"];
    }
    else if ([itemTitle isEqualToString:@"DIY"])
    {
        if ([kCMGroupDataManager isShowRedRoundMarkOnCustomThemeButton])
        {
            UIView* redRoundMark = [[UIView alloc] initWithFrame:CGRectMake(cell.width - 6, 0, 6, 6)];
            redRoundMark.tag = 100;
            redRoundMark.backgroundColor = [UIColor redColor];
            redRoundMark.layer.cornerRadius = 3;
            
            [cell addSubview:redRoundMark];
        }
    }
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.settingCellTintColor = kCMKeyboardManager.themeManager.settingCellTintColor;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([CMBizHelper isiPhone]) {
        return UIEdgeInsetsMake(SizeScaleModel(25.0f), SettingSectionLeftRightMargin, SizeScaleModel(25.0f), SettingSectionLeftRightMargin);
    }else{
        return UIEdgeInsetsMake(iPadSizeScaleModel(85.0f), iPadSettingSectionLeftRightMargin, iPadSizeScaleModel(85.0f), iPadSettingSectionLeftRightMargin);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([CMBizHelper isiPhone]) {
        return CGSizeMake(SettingCellWidth, SettingCellHeight);
    }else{
        return CGSizeMake(iPadSettingCellWidth, iPadSettingCellHeight);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([CMBizHelper isiPhone]) {
        if ([UIDevice currentDevice].isScreenPortrait) {
            return ( CGRectGetWidth(self.bounds) - SettingSectionLeftRightMargin * 2 - SettingCellWidth * 4 ) / 3;
        }else{
            return ( CGRectGetWidth(self.bounds) - SettingSectionLeftRightMargin * 2 - SettingCellWidth * 7 ) / 6;
        }
    }else{
        if ([UIDevice currentDevice].isScreenPortrait) {
            return ( CGRectGetWidth(self.bounds) - iPadSettingSectionLeftRightMargin * 2 - iPadSettingCellWidth * 7 ) / 6;
        }else{
            return ( CGRectGetWidth(self.bounds) - iPadSettingSectionLeftRightMargin * 2 - iPadSettingCellWidth * 7 ) / 6;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    CMSettingCell* settingCell = (CMSettingCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [CMExtensionBizHelper playVibration:YES];
    if (!self.pDelegate) {
        return;
    }
    switch (indexPath.row) {
        case 0:
        {
            UIView * redRoundMark =  [settingCell viewWithTag:100];
            if(redRoundMark)
            {
                [redRoundMark removeFromSuperview];
                [kCMGroupDataManager setIsShowRedRoundMarkOnCustomThemeButton:NO];
            }
            [self.pDelegate onSettingViewDiyBtnTapped:self];
        }
            break;
            
        case 1:
            [self.pDelegate onSettingViewGesureTypingBtnTapped:self];
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            break;
        
        case 2:
            [self.pDelegate onSettingViewLanguageBtnTapped:self];
            break;
            
        case 3:
            [self.pDelegate onSettingViewFeedbackBtnTapped:self];
            break;
            
        case 4:
            [self.pDelegate onSettingViewSoundBtnTapped:self];
            [self displaySoundSettingView];
            break;
            
        case 5:
            [self.pDelegate onSettingViewRateUsBtnTapped:self];
            break;
            
        case 6:
            [self.pDelegate onSettingViewSettingBtnTapped:self];
//            [self.pDelegate onSettingViewAutoCapsBtnTapped:self];
//            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            break;
        
        case 7:
            [self.pDelegate onSettingViewSettingBtnTapped:self];
            break;
            
        default:
            break;
    }
}

@end
