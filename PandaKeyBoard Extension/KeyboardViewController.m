//
//  KeyboardViewController.m
//  PandaKeyBoard Extension
//
//  Created by 猎豹 on 2017/4/28.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "KeyboardViewController.h"
#import "CMKeyboardViewModel.h"
#import "CMKeyboardModel.h"
#import "CMKeyboardView.h"
#import "CMSuggestionStripView.h"
#import "CMKeyboardManager.h"
#import "NSString+Common.h"
#import "CMKeyModel.h"
#import "CMError.h"
#import "CMKeyboardManager.h"
#import "CMToolBarView.h"
#import "CMSuggestionViewModel.h"
#import "CMProximityInfo.h"
#import "CMEmojiKeyboardSwitcher.h"
//#import "CMEmojiKeyboardView.h"
#import "CMEmojiKeyboardViewModel.h"
#import "CMBaseKeyboardViewModel.h"
#import "CMSettingView.h"
#import "CMCursorMoveView.h"

#import "CMEmojiToolBarView.h"
#import "UIView+Util.h"
#import "UIView+Toast.h"

#import "CMTextInputModel.h"

#import "CMGroupDataManager.h"
#import "CMBizHelper.h"
#import "UIView+Constraint.h"
#import "NSDictionary+Common.h"

#import "CMSettingManager.h"
#import "CMOReachability.h"
#import "CMInfoc.h"
#import "CMCommUtil.h"

#import "CMKeyboardShiftState.h"

#import "DictionaryFacilitatorImpl.h"
// Fabric
#import "CMAppConfig.h"

//兼容core
#import "CMEvent.h"
#import "CMInputLogic.h"
#import "CMInputTransaction.h"
#import "Constants.h"

#import <AVFoundation/AVFoundation.h>

#import "CMSpacingAndPunctuations.h"

#import "CMInfoc.h"
#import "CMBlackThemeTopView.h"
#import "CMBlackThemeKeyboardView.h"
// 魔方
#import "CMAppConfig.h"

// 滑动输入
#import "CMKeyboardManager.h"
//
#import "CMKeyButton.h"
#import "CMRemindTipView.h"
#import "SuggestedWordInfo.h"
#import "CMCollectionView.h"
#import "CMSuggestionCell.h"

#import "CMTipsViewManager.h"
#import "CMTipsViewProtocol.h"

#ifndef SCHEME
#import "CMFullAccessTipView.h"
//云预测
#import "CMCloudPrediction.h"
#endif

#ifdef DEBUG
#import "CMFPSLabel.h"
#import "CMSandboxFileShare.h"
#endif

#import "CMCloudConfig.h"

#import "NSString+Common.h"

//#import <MagicalRecord/MagicalRecord.h>
//#import <MagicalRecord/MagicalRecord+ShorthandMethods.h>
//#import "InputModel+CoreDataClass.h"

#import "CMNotificationConstants.h"
#import "CMExtensionBizHelper.h"
#import "UIDevice+Util.h"

#import "CMThemeManager.h"
#import "CMRibbonView.h"

#import "CMFullAccessTipStackView.h"

#ifndef SCHEME
@interface KeyboardViewController () <CMKeyboardViewDelegate, CMBaseKeyboardViewDataSource, CMSuggestionViewDelegate, CMToolBarViewDelegate,CMKeyboardShiftStateDelegate, CMEmojiToolBarViewDelegate, CMEmojiKeyboardViewDelegate,CMCloudPredictionDelegate, CMSettingViewDelegate, CMCursorMoveViewDelegate, CMTipsViewDelegate>
#else
@interface KeyboardViewController () <CMBaseKeyboardViewDelegate, CMBaseKeyboardViewDataSource, CMSuggestionViewDelegate, CMToolBarViewDelegate,CMKeyboardShiftStateDelegate, CMEmojiToolBarViewDelegate, CMEmojiKeyboardViewDelegate, CMSettingViewDelegate>
#endif

@property (nonatomic,strong)CMInputTransaction* completeInputTransaction;

@property (nonatomic, strong)CMKeyboardView* keyboardView;
@property (nonatomic, strong)UIImageView* keyboardBackImageView;
@property (nonatomic, strong)CMSuggestionStripView* predictView;
@property (nonatomic, strong)CMToolBarView* toolBarView;
@property (nonatomic, strong)UIImageView* toolbarBackImageView;
@property (nonatomic, strong)CMBlackThemeTopView* waveToolbarBgView;
@property (nonatomic, strong)CMBlackThemeKeyboardView * lightKeyboardBgView;

@property (nonatomic, strong) UIVisualEffectView* wholeKeyboardBgEffectView;

@property (nonatomic, assign)CGFloat keyboardWholeHeight;
@property (nonatomic, assign)CGFloat keyboardReminderHeight;
@property (nonatomic, assign)CGFloat keyboardHeight;
@property (nonatomic, assign)CGFloat toolbarHeight;


@property (nonatomic, strong)CMBaseKeyboardView* currentKeyboardView;

@property (nonatomic, copy) NSArray* languages;

@property (nonatomic, strong)CMSettingView* settingView;// 设置面板
@property (nonatomic, strong)CMCursorMoveView* cursorMoveView;// 光标移动面板
@property (nonatomic, strong)CMEmojiKeyboardSwitcher *emojiKeyboardSwitcher;
//@property (nonatomic, strong)CMEmojiKeyboardView* emojiKeyboardView;
@property (nonatomic, strong)CMEmojiToolBarView* emojiToolBarView;

@property (nonatomic, strong)NSLayoutConstraint* keyboardHeightConstraints;

// test theme change
@property (nonatomic, copy)NSString* currentThemeName;

@property (nonatomic ,assign) BOOL activeReport;

@property (nonatomic ,strong)CMKeyboardShiftState * shiftState;

@property (nonatomic, strong)NSDate* startData;

@property (nonatomic, strong)AVAudioPlayer *player;

@property (nonatomic, strong) CMRemindTipView * longPressSpaceTipView;
@property (nonatomic, strong) CMRemindTipView * cloudPredictTipView;
@property (nonatomic, strong) CMKeyButton * spaceButton;
@property (nonatomic, strong) NSArray<SuggestedWordInfo*> * forceSuggestionsArray;
@property (nonatomic, copy) NSString * forceInputStr;
@property (nonatomic, assign) NSUInteger longPressSpaceTipCloseType;
@property (nonatomic, assign) NSUInteger cloudPredictTipCloseType;

@property (nonatomic, assign)BOOL isNewInstall;

//@property (nonatomic, strong)NSManagedObjectContext* coreDataContext;

@property (nonatomic, strong)dispatch_queue_t audioSerialQueue;

@property (nonatomic, strong)dispatch_queue_t inputLogicSerialQueue;
@property (nonatomic, strong)dispatch_block_t nonBatchInputBlock;
@property (nonatomic, strong)dispatch_block_t batchInputBlock;


#ifndef SCHEME

@property (nonatomic, strong)CMFullAccessTipView *fullAccessCloudView;
@property (nonatomic, strong)CMFullAccessTipStackView *fullAccessCloudStackView;
@property (nonatomic, strong)CMFullAccessTipView *fullAccessSoundView;
@property (nonatomic, strong)CMFullAccessTipView *fullAccessCursorMoveView;
@property (nonatomic, strong)MASConstraint* constaint;
@property (nonatomic, assign)NSInteger fullAccessViewCloseType; // 1:4s之后自动消失 2:代表上滑消失  3:点击消失
#endif

#ifdef DEBUG
@property (nonatomic, strong)CMFPSLabel *fpsLabel;
//@property (nonatomic, strong)DDFileLogger *fileLogger;
#endif

@property (nonatomic, strong)CMTipsViewManager* tipsManager;

@property (nonatomic, assign)BOOL isRibbonViewAdded;

@property (nonatomic, strong)CMRibbonView * ribbonView;

@property (nonatomic, strong)CMProximityInfo *proximityInfo;

@end

@implementation KeyboardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        @autoreleasepool {
            [kLogger setupLogger];
            kLogTrace();
            
            [[NSUserDefaults standardUserDefaults] setObject:[CMAppConfig appVersion] forKey:kCurrentAppVersion];
            
            if([self isFullAccessAllowed]){
                [CMAppConfig setupFabric];
                [kCMKeyboardManager initCloudConfigIfNeeded];
            }

//            CFTimeInterval startTime = CACurrentMediaTime();
            
//            [MagicalRecord enableShorthandMethods];
//            [MagicalRecord setupCoreDataStack];
            
            self.activeReport = YES;
            self.currentThemeName = kCMSettingManager.currentThemeName;
            self.languages = kCMSettingManager.languages;
            [self setupCurrentLanguageType];
            
            CMTextInputModel* model = [CMTextInputModel modelWithProxy:self.textDocumentProxy];
//            InputModel* inputModel = [InputModel MR_findFirstOrderedByAttribute:@"count" ascending:NO inContext:self.coreDataContext];
//            if (inputModel) {
//                model = [CMTextInputModel modelWithInputEntity:inputModel];
//                kLogInfo(@"[LoadKeyboard]取出弹起次数最多的键盘类型(%@), 次数(%lld)", model, inputModel.count);
//            }
//            else {
//                kLogInfo(@"[LoadKeyboard]未查询到弹起次数最多的键盘类型，使用用默认值(%@)", model);
//            }
//            CFTimeInterval endTime = CACurrentMediaTime();
//            kLogInfo(@"[TRACE] TimeInterval = %f", endTime - startTime);

            [[CMKeyboardManager sharedInstance] preCacheKeyboardLayoutsByInputModel:model completionBlock:^(CMKeyboardViewModel *viewModel, CMError *error) {
                if (error) {
                    kLogError(@"[LoadKeyboard]预加载键盘 失败 error(%@)", error);
                }
                else {
                    kLogInfo(@"[LoadKeyboard]预加载键盘 完毕");
                }
            }];
            model = nil;
//            inputModel = nil;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    kLogTrace();
//    kLogInfo(@"[TRACE1] %@", self);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];

    [self setupNeedKeyboardExpandAnimation];

    if([self isFullAccessAllowed]){
        [CMOReachability start];
#ifndef SCHEME
        [kCMKeyboardManager.cloudManager connectPredictionService];
#endif
    }

    if ([self shouldShowFullAccessTip]) {
        [self.tipsManager addTipsView:self.fullAccessCloudStackView];
    }

    if ([self shouldShowSpaceLongPressTip]) {
        [self.tipsManager addTipsView:self.longPressSpaceTipView];
    }

    if ([self shouldShowCloudSuggestionTip]) {
        self.forceInputStr = @"Everything happens for a ";
        [self.tipsManager addTipsView:self.cloudPredictTipView];
        [CMGroupDataManager shareInstance].isShowingCloudPredictTip = YES;
    }else{
        [CMGroupDataManager shareInstance].isShowingCloudPredictTip = NO;
    }
    
    // 在下一个runloop循环期间以及一个延迟时间之后，在当前线程执行一个指定的selector。由于它等待直到下一个runloop循环才去执行，这些方法也提供了一个距离当前正在执行的代码的延迟时间(延迟时间过完执行selector)。多个被队列化的selector按照入队的顺序一个一个被执行。
//    [self performSelector:@selector(setupUI) withObject:nil afterDelay:0];
    
    [self performSelectorOnMainThread:@selector(setupUI) withObject:nil waitUntilDone:YES];
}

- (void)handleWillResignActiveNotification:(NSNotification *)notif {
    kLogTrace();
//    kLogInfo(@"[TRACE1] %@", self);
    if([kCMKeyboardManager isDefaultTheme] && IOS10_OR_LATER) {
        if (_ribbonView && _ribbonView.superview) {
            [self.ribbonView pausePlay];
        }
    }
}

- (void)setupUI {
    kLogTrace();

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^{
        kLogInfo(@"[TRACE] setupUI完成");
    }];
    // 对整张背景图的支持
    UIImage* bgImage = kCMKeyboardManager.themeManager.wholeBoardBgImage;
    
    if (bgImage) {
        self.view.layer.contents = (id)bgImage.CGImage;
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    }
    else {
        self.view.backgroundColor = kCMKeyboardManager.themeManager.wholeBoardBgColor;
    }
    
    [self.view addSubview:self.toolbarBackImageView];
    [self.view addSubview:self.keyboardBackImageView];
    [self.view addSubview:self.wholeKeyboardBgEffectView];
    [self.view addSubview:self.keyboardView];
    [self.view addSubview:self.toolBarView];
    self.currentToolBar = self.toolBarView;
    self.currentKeyboardView = self.keyboardView;
#ifdef DEBUG
    [self.view addSubview:self.fpsLabel];
#endif
    
    if ([kCMKeyboardManager isDefaultTheme]) {
        if (!_waveToolbarBgView) {
            self.waveToolbarBgView = [[CMBlackThemeTopView alloc] init];
            [self.view addSubview:self.waveToolbarBgView];
            [self.view sendSubviewToBack:self.waveToolbarBgView];
        }
        if (IOS10_OR_LATER && ![UIDevice isHeight1366]) {
            [self.view addSubview:self.ribbonView];
            [self.view sendSubviewToBack:self.ribbonView];
        }
        else {
            if (!_lightKeyboardBgView) {
                [self.view addSubview:self.lightKeyboardBgView];
                [self.view sendSubviewToBack:self.lightKeyboardBgView];
            }
        }
    }
    else {
        if ([self.currentThemeName isEqualToString:@"purple_hologram"] && !_waveToolbarBgView && !_lightKeyboardBgView){
            [self.view addSubview:self.lightKeyboardBgView];
            [self.view sendSubviewToBack:self.lightKeyboardBgView];
        }
    }
    
    // 键盘高度约束要生效，必须有一个使用autolayout的view，可以将其隐藏 https://stackoverflow.com/questions/24167909/ios-8-custom-keyboard-changing-the-height Chris Vasselli
    UIView* hikeView = [[UIView alloc] initWithFrame:CGRectZero];
    hikeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hikeView];
    [hikeView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [hikeView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    kCMKeyboardManager.keyboardViewController = self; // 为了避免执行了Init方法，但并未展示出来的KeyboardViewController实例成为上屏对象，出现输入词无法上屏的情况，这个赋值从init中拿出来，延后到此处执行。
    [CATransaction commit];
}

- (void)viewWillAppear:(BOOL)animated {
    kLogTrace();
    [self setShowLanguageType];
//    kLogInfo(@"[TRACE1] %@", self);
    [super viewWillAppear:animated];
    
    // 键盘高度约束要生效，增加约束的时机不可早于viewWillAppear
    [self updateCurrentConstraintsToSize:CGSizeZero withTransitionCoordinator:nil];
    
#ifndef SCHEME
    kCMKeyboardManager.cloudManager.delegate = self;
#endif
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadKeyboard) object:nil];
    [self loadKeyboard];
}

- (void)viewDidAppear:(BOOL)animated
{
    kLogTrace();
//    kLogInfo(@"[TRACE1] %@", self);
    [super viewDidAppear:animated];
    
    kCMKeyboardManager.keyboardViewController = self; // 为了避免执行了Init方法，但并未展示出来的KeyboardViewController实例成为上屏对象，出现输入词无法上屏的情况，这个赋值从init中拿出来，延后到此处执行。

    if([kCMKeyboardManager isDefaultTheme] && IOS10_OR_LATER && _ribbonView && _ribbonView.superview) {
        [self.ribbonView startPlay];
    }
    
    if (_waveToolbarBgView && _waveToolbarBgView.superview) {
        [self.waveToolbarBgView defaultConfig:self.toolbarHeight];
    }
    if (_lightKeyboardBgView && _lightKeyboardBgView.superview) {
        [self.lightKeyboardBgView defaultConfig:CGSizeMake([CMBizHelper adapterScreenWidth]*2, self.keyboardHeight*3.5)];
        self.lightKeyboardBgView.center = CGPointMake(self.currentKeyboardView.center.x, self.currentKeyboardView.center.y-self.keyboardHeight);
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    kLogTrace();
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupUI) object:nil];

//    kLogInfo(@"[TRACE1] %@", self);
    if([kCMKeyboardManager isDefaultTheme] && IOS10_OR_LATER) {
        if (_ribbonView && _ribbonView.superview) {
            [self.ribbonView pausePlay];
        }
    }
    
    [kCMKeyboardManager.inputLogic saveUserDictionary];
    [super viewWillDisappear:animated];
    [self.tipsManager removeAllTipsView];
    if (![NSString stringIsEmpty:self.forceInputStr] && [[self.textDocumentProxy documentContextBeforeInput] isEqualToString:self.forceInputStr]) {
        for (int i=0; i < self.forceInputStr.length; i++) {
            [self.textDocumentProxy deleteBackward];
        }
        [self resetKeyboardTopView];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    kLogTrace();
//    kLogInfo(@"[TRACE1] %@", self);
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupUI) object:nil];

    if([kCMKeyboardManager isDefaultTheme] && IOS10_OR_LATER) {
        if (_ribbonView && _ribbonView.superview) {
            [self.ribbonView pausePlay];
        }
    }

    if (_waveToolbarBgView && _waveToolbarBgView.superview) {
        [_waveToolbarBgView stopWave];
    }
    if (_lightKeyboardBgView && _lightKeyboardBgView.superview) {
        [_lightKeyboardBgView stopAnimtion];
    }
    
    if (_nonBatchInputBlock) {
        dispatch_cancel(_nonBatchInputBlock);
        _nonBatchInputBlock = nil;
    }

#ifndef SCHEME
    [kCMKeyboardManager.cloudManager cloudReport];
#endif
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self.view];
    [_waveToolbarBgView toucheBeganX:p.x];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint p = [[touches anyObject] locationInView:self.view];
    CGPoint pr = [[touches anyObject] previousLocationInView:self.view];
    int a =  p.x - pr.x;
    [_waveToolbarBgView toucheMoveDistanceX:a];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_waveToolbarBgView toucheEnded];
    [_lightKeyboardBgView myTouchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_waveToolbarBgView toucheEnded];
}

- (void)dealloc
{
    kLogInfo(@"[TRACE1] %@", self);
    [[CMKeyboardManager sharedInstance] cancelAllTasks];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupUI) object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [MagicalRecord cleanUp];
    _currentInputModel = nil;
    
    _completeInputTransaction = nil;
    _waveToolbarBgView = nil;
    _lightKeyboardBgView = nil;
    _ribbonView = nil;
    _wholeKeyboardBgEffectView = nil;

    if (_tipsManager) {
        [_tipsManager removeAllTipsView];
        _tipsManager = nil;
    }
    
    _keyboardView = nil;
    _keyboardBackImageView = nil;
    _predictView = nil;
    _toolBarView = nil;
    _toolbarBackImageView = nil;
    _currentToolBar = nil;
    _currentKeyboardView = nil;
    _languages = nil;
    _settingView = nil;
    _cursorMoveView = nil;
    _emojiKeyboardSwitcher = nil;
    _emojiToolBarView = nil;
    _keyboardHeightConstraints = nil;
    _player = nil;
    _longPressSpaceTipView = nil;
    _cloudPredictTipView = nil;
    _spaceButton = nil;
    _forceSuggestionsArray = nil;
//    _coreDataContext = nil;
    _audioSerialQueue = nil;
    
    for (CALayer* layer in [self.view.layer sublayers]) {
        [layer removeAllAnimations];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.view.bounds.size.width == 0 || self.view.bounds.size.height == 0 || self.keyboardWholeHeight == 0) {
        return;
    }
    kCMKeyboardManager.themeManager.keyboardViewControllerWidth = CGRectGetWidth(self.view.bounds);
    
    if (_currentToolBar && _currentToolBar.superview) {
        int y =0;
        if (_fullAccessCloudStackView && _fullAccessCloudStackView.superview){
            y = [CMKeyboardManager keyBoardTipStackHeight];
        }
        _currentToolBar.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), self.toolbarHeight);
    }
    
    if (_currentKeyboardView && _currentKeyboardView.superview) {
        _currentKeyboardView.frame = CGRectMake(0, self.currentToolBar.bottom, CGRectGetWidth(self.view.bounds), self.keyboardHeight);
    }
    
    if (_waveToolbarBgView && _waveToolbarBgView.superview) {
        _waveToolbarBgView.width = CGRectGetWidth(self.view.bounds);
        _waveToolbarBgView.height = self.toolbarHeight;
        _waveToolbarBgView.top = self.view.boundTop;
        _waveToolbarBgView.left = self.view.boundleft;
    }
    
    if (_lightKeyboardBgView && _lightKeyboardBgView.superview) {
        _lightKeyboardBgView.width = CGRectGetWidth(self.view.bounds) *2;
        _lightKeyboardBgView.height = self.keyboardHeight *3.5;
        _lightKeyboardBgView.center = CGPointMake(self.currentKeyboardView.center.x, self.currentKeyboardView.center.y+ self.keyboardHeight/2 );
    }
    
#ifdef DEBUG
    if (_fpsLabel && _fpsLabel.superview) {
        _fpsLabel.left = self.view.boundleft;
        _fpsLabel.bottom = self.view.boundBottom;
    }
#endif
    self.toolbarBackImageView.frame =_currentToolBar.frame;
    self.keyboardBackImageView.frame = self.currentKeyboardView.frame;
    self.wholeKeyboardBgEffectView.frame = self.view.bounds;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    kLogTrace();
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateCurrentConstraintsToSize:size withTransitionCoordinator:coordinator];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationTransit object:coordinator];
}

- (void)updateCurrentConstraintsToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
//    kLogTrace();
    self.keyboardHeight = [CMKeyboardManager keyboardHeight];
    
    if (_fullAccessCloudStackView && _fullAccessCloudStackView.superview) {
        self.keyboardWholeHeight = [CMKeyboardManager keyboardHeight] + [CMKeyboardManager toolbarHeight] + [CMKeyboardManager keyBoardTipStackHeight];
    }else{
        self.keyboardWholeHeight = [CMKeyboardManager keyboardHeight] + [CMKeyboardManager toolbarHeight];
    }

    self.toolbarHeight = [CMKeyboardManager toolbarHeight];
    
    if (self.keyboardHeightConstraints == nil) {
        self.keyboardHeightConstraints = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.keyboardWholeHeight];
        self.keyboardHeightConstraints.priority = 999;
        [self.view addConstraint:self.keyboardHeightConstraints];
    }
    else if (self.keyboardHeightConstraints.constant != self.keyboardWholeHeight){
        self.keyboardHeightConstraints.constant = self.keyboardWholeHeight;
    }
    
    [self.view setNeedsUpdateConstraints];
    if (coordinator) {
        if (_waveToolbarBgView && _waveToolbarBgView.superview) {
            [_waveToolbarBgView defaultConfig:self.toolbarHeight];
        }
        
        if (_lightKeyboardBgView && _lightKeyboardBgView.superview) {
            [_lightKeyboardBgView defaultConfig:CGSizeMake([CMBizHelper adapterScreenWidth]*2, self.keyboardHeight*3.5)];
        }
        
//        if ([self.currentThemeName isEqualToString:@"default"]) {
//            [self.ribbonView setupRect:CGRectMake(0.0f, [CMKeyboardManager toolbarHeight], [CMBizHelper adapterScreenWidth], [CMKeyboardManager keyboardHeight])];
//        }

        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.view updateConstraintsIfNeeded];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.currentKeyboardView setNeedsLayout];
            [self.currentToolBar setNeedsLayout];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated
    kLogInfo(@"[TRACE1] %@", self);
    [[CMKeyboardManager sharedInstance] handleMemoryWarning];
    if (_settingView && !_settingView.superview) {
        _settingView = nil;
    }
    
    [self.emojiKeyboardSwitcher didReceiveMemoryWarning];
    
    if (_keyboardView && !_keyboardView.superview) {
        _keyboardView = nil;
    }
    if (_toolBarView && !_toolBarView.superview) {
        _toolBarView = nil;
    }
    if (_emojiToolBarView && !_emojiToolBarView.superview) {
        _emojiToolBarView = nil;
    }
    if(_predictView && ! _predictView.superview){
        _predictView = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    kLogTrace();
    // The app has just changed the document's contents, the document context has been updated.
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadKeyboard) object:nil];
    [self performSelector:@selector(loadKeyboard) withObject:nil afterDelay:self.startData ? 0.02-[[NSDate date] timeIntervalSinceDate:self.startData] : 0.02];
//    NSTimeInterval tmp = self.startData ? 0.02-[[NSDate date] timeIntervalSinceDate:self.startData] : 0.02;
    self.startData = [NSDate date];
//    CMTextInputModel* model = [CMTextInputModel modelWithProxy:self.textDocumentProxy];
//    kLogInfo(@"!!!!!4...model=%@, time=%f", model, tmp);
}

- (void)loadKeyboard {
    @autoreleasepool {
        self.startData = nil;
        //    kLogTrace();
        CMTextInputModel* model = [CMTextInputModel modelWithProxy:self.textDocumentProxy];
        
        if (model.keyboardType == UIKeyboardTypeURL || model.keyboardType == UIKeyboardTypeEmailAddress)
        {
            [self.tipsManager removeTipsView:self.cloudPredictTipView];
            self.cloudPredictTipView = nil;
        }
        
        BOOL modelisEqual = [model isEqualToModel:self.currentInputModel];
        if (!modelisEqual) {
            if (model.keyboardType == UIKeyboardTypeURL || model.keyboardType == UIKeyboardTypeEmailAddress)
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShouldShowDeleteAllSuggest];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDeleteAllSuggestHasClicked];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self updateSuggestionStrip];
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowDeleteAllSuggest];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            self.currentInputModel = model;
            CMKeyboardType layoutType = (model.keyboardType == UIKeyboardTypeNumbersAndPunctuation ||model.keyboardType == UIKeyboardTypeDecimalPad ||model.keyboardType ==UIKeyboardTypeNumberPad) ? CMKeyboardTypeNumber : CMKeyboardTypeLetter;
            @weakify(self)
            [[CMKeyboardManager sharedInstance] loadKeyboardByLayoutType:layoutType inputModel:model completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
                @stronglize(self)
                if (viewModel && error == nil) {
                    [self showAlphabetKeyboardView:viewModel];
                    [self reset];
                    if(viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter){
                        [self.shiftState singleTap:nil];
                        self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
                    }
                    
                    self.startData = nil;
//                    NSPredicate *filter = [NSPredicate predicateWithFormat:@"keyboardType = %d AND returnType = %d", model.keyboardType, model.returnKeyType];
//                    InputModel* inputModel = [InputModel MR_findFirstWithPredicate:filter inContext:self.coreDataContext];
//                    if (!inputModel) {
//                        inputModel = [InputModel MR_createEntityInContext:self.coreDataContext];
//                    }
//                    inputModel.keyboardType = model.keyboardType;
//                    inputModel.returnType = model.returnKeyType;
//                    inputModel.count = inputModel.count + 1;
//                    [self.coreDataContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
//                        if (error) {
//                            kLogError(@"[LoadKeyboard]存储失败, error(%@)", error);
//                        }
//                        else {
//                            kLogInfo(@"[LoadKeyboard]存储成功");
//                        }
//                    }];
                }
            }];
        }
        
        kCMKeyboardManager.inputLogic.keyboardType = model.keyboardType;
        
        if (![NSString stringIsEmpty:self.forceInputStr] && [[self.textDocumentProxy documentContextBeforeInput] isEqualToString:self.forceInputStr]) {
            for (int i=0; i < self.forceInputStr.length; i++) {
                [self.textDocumentProxy deleteBackward];
            }
            [self resetKeyboardTopView];
        }
        [kCMKeyboardManager.inputLogic restartSuggestionsOnWordTouchedByCursorWithCompleteInputTransaction:self.completeInputTransaction textInputModel:model];
        
        if(modelisEqual){
            [self.shiftState singleTap:nil];
            self.shiftState.autocapitalizationType = model.autocapitalizationType;
        }
        if(modelisEqual){
            [self updateSuggestionStrip];
        }
        if(self.activeReport){
            [CMInfoc activeReport:kCMKeyboardManager.inputLogic.keyboardType language:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType] dictver:[kCMKeyboardManager.inputLogic dictionaryVersion] themeName:self.currentThemeName];
            self.activeReport = NO;
        }
    }
}

- (void)coordinateWithString:(NSString*)str xArr:(NSMutableArray*)xArr yArr:(NSMutableArray*)yArr{
    
    for (int i = 0; i<str.length; i++) {
        ProximityInfoKey* infoKey = [[CMKeyboardManager sharedInstance] proximityInfo:[str characterAtIndex:i]];
        
        int x = -1;
        int y = -1;
        if(infoKey){
            x =infoKey.btnSize.origin.x + infoKey.btnSize.size.width/2;
            y = infoKey.btnSize.origin.y + infoKey.btnSize.size.height/2;
        }
        
        [xArr addObject:@(x)];
        [yArr addObject:@(y)];
    }
}

- (void)commit:(CMEvent *)event{
    CMKeyModel *key = event.key;
    if(!key)return;
    switch (key.keyType){
        case CMKeyTypeLetter:
            [self.textDocumentProxy insertText:key.key];
            break;
        case CMKeyTypeEmoji:
        case CMKeyTypeSwitchKeyboard:
        case CMKeyTypePunctuationSlider:
        {
            [self.textDocumentProxy insertText:key.key];
        }
            break;
        case CMKeyTypeSpace:
            [self.textDocumentProxy insertText:@" "];
            break;
        case CMKeyTypeReturn:
            [self.textDocumentProxy insertText:@"\n"];
            break;
        case CMKeyTypeDel:
            [self.textDocumentProxy deleteBackward];
            break;
        default:
            break;
    }
    
}

#pragma mark -
- (void)setupCurrentLanguageType
{
    CMKeyboardLanguageType languageType = kCMSettingManager.languageType;
    if (languageType == CMKeyboardLanguageTypeUndefined || ![self.languages containsObject:@(kCMSettingManager.languageType)]) {
        NSString *preferredLanguage = [CMBizHelper getPreferredLanguage];
        if ([preferredLanguage hasPrefix:@"en"] && [self.languages containsObject:@(CMKeyboardLanguageTypeEnglishUnitedState)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeEnglishUnitedState;
        }else if ([preferredLanguage hasPrefix:@"es"] && [self.languages containsObject:@(CMKeyboardLanguageTypeSpanish)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeSpanish;
        }else if ([preferredLanguage hasPrefix:@"id"] && [self.languages containsObject:@(CMKeyboardLanguageTypeIndonesian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeIndonesian;
        }else if ([preferredLanguage hasPrefix:@"az"] && [self.languages containsObject:@(CMKeyboardLanguageTypeAzerbaijani)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeAzerbaijani;
        }else if ([preferredLanguage hasPrefix:@"ca"] && [self.languages containsObject:@(CMKeyboardLanguageTypeCatalan)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeCatalan;
        }else if ([preferredLanguage hasPrefix:@"cs"] && [self.languages containsObject:@(CMKeyboardLanguageTypeCzech)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeCzech;
        }else if ([preferredLanguage hasPrefix:@"da"] && [self.languages containsObject:@(CMKeyboardLanguageTypeDanish)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeDanish;
        }else if ([preferredLanguage hasPrefix:@"de"] && [self.languages containsObject:@(CMKeyboardLanguageTypeGerman)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeGerman;
        }else if ([preferredLanguage hasPrefix:@"et"] && [self.languages containsObject:@(CMKeyboardLanguageTypeEstonian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeEstonian;
        }else if ([preferredLanguage hasPrefix:@"fi"] && [self.languages containsObject:@(CMKeyboardLanguageTypeFinnish)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeFinnish;
        }else if ([preferredLanguage hasPrefix:@"fr"] && [self.languages containsObject:@(CMKeyboardLanguageTypeFrench)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeFrench;
        }else if ([preferredLanguage hasPrefix:@"hr"] && [self.languages containsObject:@(CMKeyboardLanguageTypeCroatian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeCroatian;
        }else if ([preferredLanguage hasPrefix:@"hu"] && [self.languages containsObject:@(CMKeyboardLanguageTypeHungarian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeHungarian;
        }else if ([preferredLanguage hasPrefix:@"pt"] && [self.languages containsObject:@(CMKeyboardLanguageTypePortuguese)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypePortuguese;
        }else if ([preferredLanguage hasPrefix:@"ms"] && [self.languages containsObject:@(CMKeyboardLanguageTypeMalay)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeMalay;
        }else if ([preferredLanguage hasPrefix:@"tl"] && [self.languages containsObject:@(CMKeyboardLanguageTypeFilipino)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeFilipino;
        }else if ([preferredLanguage hasPrefix:@"tr"] && [self.languages containsObject:@(CMKeyboardLanguageTypeTurkish)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeTurkish;
        }else if ([preferredLanguage hasPrefix:@"it"] && [self.languages containsObject:@(CMKeyboardLanguageTypeItalian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeItalian;
        }else if ([preferredLanguage hasPrefix:@"pl"] && [self.languages containsObject:@(CMKeyboardLanguageTypePolish)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypePolish;
        }else if ([preferredLanguage hasPrefix:@"ro"] && [self.languages containsObject:@(CMKeyboardLanguageTypeRomanian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeRomanian;
        }else if ([preferredLanguage hasPrefix:@"nl"] && [self.languages containsObject:@(CMKeyboardLanguageTypeDutch)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeDutch;
        }else if ([preferredLanguage hasPrefix:@"sk"] && [self.languages containsObject:@(CMKeyboardLanguageTypeSlovak)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeSlovak;
        }else if ([preferredLanguage hasPrefix:@"lv"] && [self.languages containsObject:@(CMKeyboardLanguageTypeLatvian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeLatvian;
        }else if ([preferredLanguage hasPrefix:@"nb"] && [self.languages containsObject:@(CMKeyboardLanguageTypeNorwegianBokmal)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeNorwegianBokmal;
        }else if ([preferredLanguage hasPrefix:@"sv"] && [self.languages containsObject:@(CMKeyboardLanguageTypeSwedish)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeSwedish;
        }else if ([preferredLanguage hasPrefix:@"ru"] && [self.languages containsObject:@(CMKeyboardLanguageTypeRussian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeRussian;
        }else if ([preferredLanguage hasPrefix:@"be"] && [self.languages containsObject:@(CMKeyboardLanguageTypeBelarusian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeBelarusian;
        }else if ([preferredLanguage hasPrefix:@"uk"] && [self.languages containsObject:@(CMKeyboardLanguageTypeUkrainian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeUkrainian;
        }else if ([preferredLanguage hasPrefix:@"sr"] && [self.languages containsObject:@(CMKeyboardLanguageTypeSerbian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeSerbian;
        }else if ([preferredLanguage hasPrefix:@"bg"] && [self.languages containsObject:@(CMKeyboardLanguageTypeBulgarian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeBulgarian;
        }else if ([preferredLanguage hasPrefix:@"mk"] && [self.languages containsObject:@(CMKeyboardLanguageTypeMacedonian)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeMacedonian;
        }else if ([preferredLanguage hasPrefix:@"ar"] && [self.languages containsObject:@(CMKeyboardLanguageTypeArabic)]){
            kCMSettingManager.languageType = CMKeyboardLanguageTypeArabic;
        }

        else if ([self.languages containsObject:@(CMKeyboardLanguageTypeEnglishUnitedState)]) {
            kCMSettingManager.languageType = CMKeyboardLanguageTypeEnglishUnitedState;
        }else{
            if (self.languages.count > 0 && [self.languages[0] integerValue] != CMKeyboardLanguageTypeUndefined) {
                kCMSettingManager.languageType = (CMKeyboardLanguageType)[self.languages[0] intValue];
            }else{
                kCMSettingManager.languageType = CMKeyboardLanguageTypeEnglishUnitedState;
            }
        }
    }
}

- (void)setupNeedKeyboardExpandAnimation
{
    NSNumber *lastKeyboardAnimationTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastKeyboardAnimationTime];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    if (lastKeyboardAnimationTime) {
        // 3600 = 1 * 60 * 60 代表一小时
        if (timeInterval - lastKeyboardAnimationTime.doubleValue >= 3600) {
            [CMKeyboardManager sharedInstance].needKeyboardExpandAnimation = YES;
        }else{
            [CMKeyboardManager sharedInstance].needKeyboardExpandAnimation = NO;
        }
    }else{
        [CMKeyboardManager sharedInstance].needKeyboardExpandAnimation = YES;
    }
    
    if ([CMKeyboardManager sharedInstance].needKeyboardExpandAnimation) {
        [[NSUserDefaults standardUserDefaults] setObject:@(timeInterval) forKey:kLastKeyboardAnimationTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)isFullAccessAllowed {
    BOOL result = NO;
    if (@available(iOS 11.0, *)) {
        result = self.hasFullAccess;
    } else {
        // Fallback on earlier versions
        result = kCMSettingManager.isAllowFullAccess;
    }
    kCMKeyboardManager.isFullAccessAllowed = result;
    return result;
}

#pragma mark - setter/getter

- (CMRibbonView *)ribbonView {
    if (!_ribbonView) {
        _ribbonView = [[CMRibbonView alloc] initWithFrame:CGRectMake(0.0f, [CMKeyboardManager toolbarHeight], [CMBizHelper adapterScreenWidth], [CMKeyboardManager keyboardHeight])];
    }
    return _ribbonView;
}

- (CMEmojiKeyboardSwitcher *)emojiKeyboardSwitcher{
    if(!_emojiKeyboardSwitcher){
        _emojiKeyboardSwitcher = [[CMEmojiKeyboardSwitcher alloc] initWithDelegate:self] ;
    }
    return _emojiKeyboardSwitcher;
}

//- (NSManagedObjectContext *)coreDataContext {
//    if (!_coreDataContext) {
//        _coreDataContext = [NSManagedObjectContext MR_defaultContext];
//    }
//    return _coreDataContext;
//}

- (dispatch_queue_t)audioSerialQueue {
    if (!_audioSerialQueue) {
        _audioSerialQueue = dispatch_queue_create("audio_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _audioSerialQueue;
}

- (dispatch_queue_t)inputLogicSerialQueue {
    if (!_inputLogicSerialQueue) {
        _inputLogicSerialQueue = dispatch_queue_create("keyboardviewcontroller.inputlogic.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _inputLogicSerialQueue;
}

#ifdef DEBUG
- (CMFPSLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [CMFPSLabel new];
        _fpsLabel.layer.zPosition = CGFLOAT_MAX;
    }
    return _fpsLabel;
}

#endif

- (CMBlackThemeKeyboardView *)lightKeyboardBgView{
    if(!_lightKeyboardBgView){
        _lightKeyboardBgView = [CMBlackThemeKeyboardView new];
        _lightKeyboardBgView.isCircleBackground = [kCMKeyboardManager isDefaultTheme];
    }
    return _lightKeyboardBgView;
}

- (CMTipsViewManager *)tipsManager {
    if (!_tipsManager) {
        _tipsManager = [CMTipsViewManager new];
    }
    return _tipsManager;
}

- (void)setCurrentToolBar:(UIView *)currentToolBar {
    if (_currentToolBar != currentToolBar) {
        _currentToolBar = currentToolBar;
    }
}

- (void)setCurrentKeyboardView:(CMBaseKeyboardView *)currentKeyboardView {
    if (_currentKeyboardView != currentKeyboardView) {
        _currentKeyboardView = currentKeyboardView;
    }
}

- (CMKeyboardShiftState *)shiftState{
    if(!_shiftState){
        _shiftState = [CMKeyboardShiftState new];
        _shiftState.delegate = self;
    }
    return _shiftState;
}

- (CMKeyboardView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [CMKeyboardView new];
        _keyboardView.delegate = self;
        _keyboardView.dataSource = self;
    }
    return _keyboardView;
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

- (CMSettingView *)settingView
{
    if (!_settingView) {
        _settingView = [CMSettingView new];
        _settingView.pDelegate = self;
    }
    return _settingView;
}

- (CMCursorMoveView *)cursorMoveView {
    if (!_cursorMoveView) {
        _cursorMoveView = [CMCursorMoveView new];
        _cursorMoveView.delegate = self;
    }
    return _cursorMoveView;
}

- (CMSuggestionStripView *)predictView {
    if (!_predictView) {
        _predictView = [CMSuggestionStripView new];
        _predictView.delegate = self;
    }
    return _predictView;
}

- (CMToolBarView *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [CMToolBarView new];
        _toolBarView.delegate = self;
    }
    return _toolBarView;
}

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

- (UIVisualEffectView *)wholeKeyboardBgEffectView
{
    if (!_wholeKeyboardBgEffectView)
    {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _wholeKeyboardBgEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        for (UIView *view in _wholeKeyboardBgEffectView.subviews)
        {
            if ([view isMemberOfClass:NSClassFromString(@"_UIVisualEffectFilterView")]|| [view isMemberOfClass:NSClassFromString(@"_UIVisualEffectSubview")] )
            {
                // iOS 11 需要 _UIVisualEffectSubview
                view.backgroundColor = [UIColor colorWithRed:0.1/255.0 green:0.1/255.0 blue:0.1/255.0 alpha:0.40];
                break;
            }
        }
//        _wholeKeyboardBgEffectView.alpha = 0.9f;
        _wholeKeyboardBgEffectView.hidden = YES;
    }
    
    return _wholeKeyboardBgEffectView;
}

- (CMEmojiToolBarView *)emojiToolBarView {
    if (!_emojiToolBarView) {
        _emojiToolBarView = [CMEmojiToolBarView new];
        _emojiToolBarView.delegate = self;
    }
    return _emojiToolBarView;
}

#ifndef SCHEME
-(CMFullAccessTipStackView *)fullAccessCloudStackView{
    
    if (!_fullAccessCloudStackView) {
        _fullAccessCloudStackView = [[CMFullAccessTipStackView alloc]init];
        _fullAccessCloudStackView.priority = fullAccessTipCloud;
        _fullAccessCloudStackView.tipDelegate = self;
        _fullAccessCloudStackView.tipsType = CMTipsTypeCloudPrediction;
        _fullAccessCloudStackView.duration = 10.0f;
        _fullAccessCloudStackView.layer.zPosition = CGFLOAT_MAX;

    }
    return _fullAccessCloudStackView;
}

- (CMFullAccessTipView *)fullAccessCloudView
{
    if (!_fullAccessCloudView) {
        _fullAccessCloudView = [[CMFullAccessTipView alloc] init];
        _fullAccessCloudView.priority = fullAccessTipCloud;
        _fullAccessCloudView.duration = 7.0f;
        _fullAccessCloudView.tipsType = CMTipsTypeCloudPrediction;
        _fullAccessCloudView.tipDelegate = self;
        _fullAccessCloudView.layer.zPosition = CGFLOAT_MAX;
    }
    return _fullAccessCloudView;
}

- (CMFullAccessTipView *)fullAccessSoundView {
    if (!_fullAccessSoundView) {
        _fullAccessSoundView = [[CMFullAccessTipView alloc] init];
        _fullAccessSoundView.priority = fullAccessTipSound;
        _fullAccessSoundView.duration = 7.0f;
        _fullAccessSoundView.tipsType = CMTipsTypeKeyboardSound;
        _fullAccessSoundView.tipDelegate = self;
        _fullAccessSoundView.layer.zPosition = CGFLOAT_MAX;
    }
    return _fullAccessSoundView;
}

- (CMFullAccessTipView *)fullAccessCursorMoveView
{
    if (!_fullAccessCursorMoveView) {
        _fullAccessCursorMoveView = [[CMFullAccessTipView alloc] init];
        _fullAccessCursorMoveView.priority = fullAccessTipCursorMove;
        _fullAccessCursorMoveView.duration = 7.0f;
        _fullAccessCursorMoveView.tipsType = CMTipsTypeCursorMove;
        _fullAccessCursorMoveView.tipDelegate = self;
        _fullAccessCursorMoveView.layer.zPosition = CGFLOAT_MAX;
    }
    return _fullAccessCursorMoveView;
}

#endif

- (CMInputTransaction *)completeInputTransaction {
    if (!_completeInputTransaction) {
        _completeInputTransaction = [CMInputTransaction new];
    }
    return _completeInputTransaction;
}


- (void)setCurrentThemeName:(NSString *)currentThemeName {
    if (_currentThemeName != currentThemeName) {
        _currentThemeName = [currentThemeName copy];
        [kCMKeyboardManager.themeManager switchTo:_currentThemeName];
        if ([_currentThemeName isEqualToString:@"default"]) {
            [kCMKeyboardManager.themeManager cacheRibbonAnimate];
        }
        else {
            [kCMKeyboardManager.themeManager resetRibbonAnimateCache];
        }
    }
}

- (id)appContext {
    UIResponder* responder = self;
    Class theClass = NSClassFromString([NSString stringWithFormat:@"UIAp%@n", @"plicatio"]);
    while (responder != nil) {
        if ([responder isMemberOfClass:[theClass class]]) {
            return responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

-(CGFloat)keyboardReminderHeight{
    
    return 40;
}

#pragma mark - open URL

/**
 打开container app
 
 @param pageIdentifier 要打开的页面标识 详见CMPageIdentify枚举
 */
- (void)openContainerApp:(NSString *)pageIdentifier
{
    NSString* scheme = [NSString stringWithFormat:@"%@://%@", [CMAppConfig appURLScheme], pageIdentifier];
    NSString* mainAppScheme = [NSString stringWithFormat:@"CMKeyboard://%@", pageIdentifier];
    [self openURL:mainAppScheme alternativeURL:scheme];
}

// 优先打开第一个参数url，若打不开则尝试打开alternativeURL
- (void)openURL:(NSString *)url alternativeURL:(NSString *)alternativeURL
{
    Class theClass = NSClassFromString([NSString stringWithFormat:@"UIAp%@n", @"plicatio"]);
    id context = [self appContext];
    SEL sel1 = NSSelectorFromString([NSString stringWithFormat:@"canO%@L:", @"penUR"]);
    SEL sel2 = NSSelectorFromString([NSString stringWithFormat:@"ope%@L:%@:co%@andler:", @"nUR", @"options", @"mpletionH"]);
    SEL sel3 = NSSelectorFromString([NSString stringWithFormat:@"op%@RL:", @"enU"]);
    
    if (context && [context isMemberOfClass:[theClass class]]) {
        if ([context respondsToSelector:sel1]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            // 此处特殊处理，因为extension是依附于container app的，所以此处不判断canOpenUrl，直接尝试打开(iOS 9中判断canOpenUrl会报-canOpenURL: failed for URL: "CMKeyboard://" - error: "This app is not allowed to query for scheme CMKeyboard"， 加了白名单也没作用, iOS 10中又是正常的)
            if (IOS10_OR_LATER) {
                if ([context performSelector:sel1 withObject:[NSURL URLWithString:url]]) {
                    if ([context respondsToSelector:sel2]) {
                        [context performSelector:sel2 withObject:[NSURL URLWithString:url] withObject:nil];
                    }
                }
                else {
                    if ([context respondsToSelector:sel2]) {
                        [context performSelector:sel2 withObject:[NSURL URLWithString:alternativeURL] withObject:nil];
                    }
                }
            }
            else if (IOS8_OR_LATER) {
                if ([context performSelector:sel1 withObject:[NSURL URLWithString:url]]) {
                    if ([context respondsToSelector:sel3]) {
                        [context performSelector:sel3 withObject:[NSURL URLWithString:url]];
                    }
                }
                else {
                    if ([context respondsToSelector:sel3]) {
                        [context performSelector:sel3 withObject:[NSURL URLWithString:alternativeURL]];
                    }
                }
            }
#pragma clang diagnostic pop
        }
    }
    
}

#pragma mark - CMKeyboardShiftStateDelegate
- (BOOL)switchAlphabetKeyboard{
    if(!_keyboardView && _keyboardView.superview)return NO;
    CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
    [theViewModel shiftStateUnSelected];
    return YES;
}

- (BOOL)switchAlphabetShiftedKeyboard{
    if(!_keyboardView && _keyboardView.superview)return NO;
    CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
    [theViewModel shiftStateSelected];
    return YES;
}

- (BOOL)switchAlphabetShiftedLockKeyboard{
    if(!_keyboardView && _keyboardView.superview)return NO;
    CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
    [theViewModel shiftStateLock];
    return YES;
}

//是否是单词结束
- (BOOL)isWordsEnd{
    return [kCMKeyboardManager.inputLogic isWordsEnd];
}
//是否是句子结束
- (BOOL)isSentencesEnd{
    return [kCMKeyboardManager.inputLogic isSentencesEnd];
}

#pragma mark - CMBaseKeyboardViewDataSource
- (BOOL)isMainDicValidInkeyboardView:(CMBaseKeyboardView *)keyboard {
    return [kCMKeyboardManager.inputLogic isMainDictionaryValid];
}

#pragma mark - CMKeyboardViewDelegate
- (void)onKeyboard:(CMBaseKeyboardView *)keyboard touchDownKeyModel:(CMKeyModel *)keyModel touchPt:(CGPoint)touchPt fromeRepeate:(BOOL)fromRepeate {
    if (!fromRepeate) {
        [self playSoundWithKeyType:keyModel.keyType];
        [CMExtensionBizHelper playVibration:YES];
    }
    
    if (self.currentInputModel.keyboardType == UIKeyboardTypeURL || self.currentInputModel.keyboardType == UIKeyboardTypeEmailAddress) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShouldShowDeleteAllSuggest];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowDeleteAllSuggest];
    }
    
    if (![keyModel shouldUseTouchDownEvent]) {
        return;
    }
    
    if (keyboard == self.keyboardView) {
//        if (keyModel.keyType == CMKeyTypeLayoutSwitch) {
//            @weakify(self)
//            [[CMKeyboardManager sharedInstance] loadKeyboardByLayoutId:keyModel.layoutId inputModel:self.currentInputModel completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
//                @stronglize(self)
//                if (viewModel && error == nil) {
//                    [self showAlphabetKeyboardView:viewModel];
//                    [self reset];
//                    if(viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter){
//                        [self.shiftState singleTap:nil];
//                        self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
//                    }
//                }
//            }];
//            return;
//        }else if (keyModel.keyType == CMKeyTypeMultiLanguage) {
//            CMKeyboardLanguageType nextLanguage = CMKeyboardLanguageTypeEnglishUnitedState;
//            NSUInteger index = [self.languages indexOfObject:@([CMKeyboardManager sharedInstance].currentLanguageType)];
//            if (index == self.languages.count - 1) {
//                nextLanguage = (CMKeyboardLanguageType)[self.languages[0] intValue];
//            }else{
//                nextLanguage = (CMKeyboardLanguageType)[self.languages[index + 1] intValue];
//            }
//            @weakify(self)
//            [[CMKeyboardManager sharedInstance] loadKeyboardToNextLanguage:nextLanguage inputModel:self.currentInputModel completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
//                @stronglize(self)
//                if (viewModel && error == nil) {
//                    self.keyboardView.isLayoutFinish = NO;
//                    [self showAlphabetKeyboardView:viewModel];
//                    [self reset];
//                    if(viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter){
//                        [self.shiftState singleTap:nil];
//                        self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
//                    }
//
//                    [kCMSettingManager switchLanguage:nextLanguage];
//                    [kCMKeyboardManager.cloudManager swichLanguage];
//                    [kCMKeyboardManager.inputLogic resetSuggest];
//                }
//            }];
//            return;
//        }
//
        
        CMEvent* event = [CMEvent obtainEventByCMKeyModel:keyModel];
        event.touchPoint = touchPt;
        
        [kCMKeyboardManager.inputLogic onCodeInput:event completeInputTransaction:self.completeInputTransaction shiftState:self.shiftState.currentShiftState textInputModel:self.currentInputModel];
        self.completeInputTransaction.fromeRepeate = fromRepeate;
        [self updateSuggestionStrip];
        [event recycle];
        
        [self.shiftState singleTap:keyModel];
    }
    else if (keyboard == self.emojiKeyboardSwitcher.emojiKeyboard) {
        if (keyModel.keyType == CMKeyTypeLayoutSwitch) {
            [self showAlphabetKeyboardViewFromEmojiOrSettingView:keyModel.layoutId];
            return;
        }
        
        
        CMEvent* event = [CMEvent obtainEventByCMKeyModel:keyModel];
        event.touchPoint = touchPt;
        
        [kCMKeyboardManager.inputLogic onCodeInput:event completeInputTransaction:self.completeInputTransaction shiftState:self.shiftState.currentShiftState textInputModel:self.currentInputModel];
        self.completeInputTransaction.fromeRepeate = fromRepeate;
        [self updateSuggestionStrip];
        [self.shiftState singleTap:keyModel];
        [event recycle];
    }
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard touchUpInsideKeyModel:(CMKeyModel *)keyModel touchPt:(CGPoint)touchPt fromeRepeate:(BOOL)fromRepeate {
    if (![keyModel shouldUseTouchUnInsideEvent]) {
        return;
    }
    
    if (keyboard == self.keyboardView) {
        if (keyModel.keyType == CMKeyTypeLayoutSwitch) {
            @weakify(self)
            [[CMKeyboardManager sharedInstance] loadKeyboardByLayoutId:keyModel.layoutId inputModel:self.currentInputModel completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
                @stronglize(self)
                if (viewModel && error == nil) {
                    [self showAlphabetKeyboardView:viewModel];
                    [self.shiftState reset];
                    if(viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter){
                        [self.shiftState singleTap:nil];
                        self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
                    }
                }
            }];
            return;
        }else if (keyModel.keyType == CMKeyTypeMultiLanguage) {
            dispatch_async(self.inputLogicSerialQueue, ^{
                dispatch_semaphore_t lock = dispatch_semaphore_create(0);
                kLogInfo(@"[ThreadLog] loadKeyboardToNextLanguage 开始");
                CMKeyboardLanguageType nextLanguage = CMKeyboardLanguageTypeEnglishUnitedState;
                NSUInteger index = [self.languages indexOfObject:@([CMKeyboardManager sharedInstance].currentLanguageType)];
                if (index == self.languages.count - 1) {
                    nextLanguage = (CMKeyboardLanguageType)[self.languages[0] intValue];
                }else{
                    nextLanguage = (CMKeyboardLanguageType)[self.languages[index + 1] intValue];
                }
                @weakify(self)
                [[CMKeyboardManager sharedInstance] loadKeyboardToNextLanguage:nextLanguage inputModel:self.currentInputModel completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
                    @stronglize(self)
                    if (viewModel && error == nil) {
                        self.keyboardView.isLayoutFinish = NO;
                        [self showAlphabetKeyboardView:viewModel];
                        [self reset];
                        if(viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter){
                            [self.shiftState singleTap:nil];
                            self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
                        }
                        [kCMSettingManager switchLanguage:nextLanguage];
                        [kCMKeyboardManager.cloudManager swichLanguage];
                        [kCMKeyboardManager.inputLogic resetSuggest];
                        [self setShowLanguageType];
                    }
                    dispatch_semaphore_signal(lock);
                }];
                dispatch_semaphore_wait(lock, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
                kLogInfo(@"[ThreadLog] loadKeyboardToNextLanguage 结束");
            });

            return;
        }
        
        
        CMEvent* event = [CMEvent obtainEventByCMKeyModel:keyModel];
        event.touchPoint = touchPt;
        
        [kCMKeyboardManager.inputLogic onCodeInput:event completeInputTransaction:self.completeInputTransaction shiftState:self.shiftState.currentShiftState textInputModel:self.currentInputModel];
        self.completeInputTransaction.fromeRepeate = fromRepeate;
        [self updateSuggestionStrip];
        [event recycle];
        
        [self.shiftState singleTap:keyModel];
    }
    else if (keyboard == self.emojiKeyboardSwitcher.emojiKeyboard) {
        if (keyModel.keyType == CMKeyTypeLayoutSwitch) {
            [self showAlphabetKeyboardViewFromEmojiOrSettingView:keyModel.layoutId];
            return;
        }
        
        CMEvent* event = [CMEvent obtainEventByCMKeyModel:keyModel];
        event.touchPoint = touchPt;
        
        [kCMKeyboardManager.inputLogic onCodeInput:event completeInputTransaction:self.completeInputTransaction shiftState:self.shiftState.currentShiftState textInputModel:self.currentInputModel];
        self.completeInputTransaction.fromeRepeate = fromRepeate;
        [self updateSuggestionStrip];
        [self.shiftState singleTap:keyModel];
        [event recycle];
    }
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard selectedInputOption:(NSString *)optionTitle {
    
    CMEvent * event = [CMEvent obtainEventByLetter:optionTitle];
    
    [kCMKeyboardManager.inputLogic onCodeInput:event completeInputTransaction:self.completeInputTransaction shiftState:self.shiftState.currentShiftState textInputModel:self.currentInputModel];
    [self updateSuggestionStrip];
    [event recycle];
    [self.shiftState singleTap:event.key];
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard selectedSwitchOptionIndex:(NSUInteger)index keyModel:(CMKeyModel *)keyModel {
    if (index == 0) {
        if (keyModel.keyType == CMKeyTypeSwitchKeyboard) {
            [CMInfoc report_cheetahkeyboard_switch:1];
            [self advanceToNextInputMode];
        }
    }
    else if (index == 1) {
        [CMInfoc report_cheetahkeyboard_switch:2];
        [self showSettingView];
    }
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard doubleTappedKeyModel:(CMKeyModel *)keyModel {
    
    //    if(keyModel.keyType == CMKeyTypeSpace){
    //        [self.inputLogic doubleTapSpadeWithCompleteInputTransaction:self.completeInputTransaction];
    //        [self updateStateAfterInputTransaction];
    //    }
    //    [self.shiftState doubleTap:keyModel];
    
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard layoutFinished:(NSDictionary *)dimDic {
    //    kLogInfo(@"%@", dimDic);
    //将临近字符更新放入到查询预测词的串行 Queue 中
//    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
//        self.proximityInfo = [CMProximityInfo proximityInfo:dimDic];
////        [[CMKeyboardManager sharedInstance] setupProximityInfo:dimDic];
//    }];
//    [kCMKeyboardManager.inputLogic.queue addOperation:op];
    
    dispatch_async(self.inputLogicSerialQueue, ^{
        self.proximityInfo = [CMProximityInfo proximityInfo:dimDic];
        [[CMKeyboardManager sharedInstance] setupKeyCache:dimDic];
    });
    
    
    BOOL showLongPress = [self shouldShowSpaceLongPressTip];
    self.spaceButton = [dimDic objectForKey:@"spaceButton"];
    if (!self.spaceButton) {
        [self.tipsManager removeTipsView:self.longPressSpaceTipView];
        self.longPressSpaceTipView = nil;
        showLongPress = NO;
    }
    
    if (!showLongPress && ![self shouldShowCloudSuggestionTip]) {
        [self updateSuggestionStrip];
    }
    
    if ([CMKeyboardManager sharedInstance].needKeyboardExpandAnimation) {
        [self performSelector:@selector(showGuides) withObject:nil afterDelay:KeyboardExpandAnimationTime];
    }else{
        [self showGuides];
    }
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard longPressedKeyModel:(CMKeyModel *)keyModel {
    if (!keyModel) {
        return;
    }
    [CMExtensionBizHelper playVibration:YES];
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard startbatchInput:(NSDictionary *)infoDic {
    [kCMKeyboardManager.inputLogic onStartBatchInput];
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard endBatchInputPointerModel:(InputPointers *)inputPointerModel {
    [kCMKeyboardManager.inputLogic onEndBatchInput:inputPointerModel];
    
    if (!_proximityInfo || !_keyboardView || !_keyboardView.superview || !_keyboardView.isLayoutFinish) {
        return;
    }

    if (_batchInputBlock) {
        dispatch_cancel(_batchInputBlock);
        _batchInputBlock = nil;
    }
    
    @weakify(self)
    dispatch_block_t block = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -8, ^{
        @stronglize(self)
        dispatch_semaphore_t lock = dispatch_semaphore_create(0);
        kLogInfo(@"[ThreadLog] perfromBatchInputSuggestion 开始");
        self.completeInputTransaction.mRequiresUpdateSuggestions = YES;
        [kCMKeyboardManager.inputLogic perfromBatchInputSuggestion:self.completeInputTransaction proximityInfo:self.proximityInfo completionBlock:^(SuggesteWords *words, CMError *error, BOOL needUpdate) {
            @stronglize(self)
            if (needUpdate) {
                [self.predictView bindData:words completeBlock:^(CMError *error) {
                    if ([_predictView.viewModel numberOfItemsInSection:0] > 0) {
                        [self showPredictView];
                    }
                    else {
                        [self showToolBarView];
                    }
                    dispatch_semaphore_signal(lock);
                    kLogInfo(@"[ThreadLog] perfromBatchInputSuggestion 结束");
                }];
            }
            else {
                dispatch_semaphore_signal(lock);
                kLogInfo(@"[ThreadLog] perfromBatchInputSuggestion 结束");
            }
        }];
        dispatch_semaphore_wait(lock, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
    });
    
    dispatch_async(self.inputLogicSerialQueue, block);
    self.batchInputBlock = block;
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard upateBatchInputPointerModel:(InputPointers *)inputPointerModel {
}

#pragma mark - CMEmojiKeyboardViewDelegate
- (void)onKeyboard:(CMBaseKeyboardView *)keyboard emojiSectionSelected:(NSUInteger)sectionIndex {
    [self playSoundWithKeyType:CMKeyTypeLetter];
    [CMExtensionBizHelper playVibration:YES];
}

#pragma mark - CMSuggestionViewDelegate
- (void)onPredictView:(CMSuggestionStripView *)predictView tappedSuggestion:(SuggestedWordInfo *)wordInfo {
    [self playSoundWithKeyType:CMKeyTypeLetter];
    [CMExtensionBizHelper playVibration:YES];
    
    [kCMKeyboardManager.inputLogic onPickSuggestionManually:wordInfo completeInputTransaction:self.completeInputTransaction];
    [self updateSuggestionStrip];
    [self.shiftState singleTap:nil];
}

- (void)onPredictView:(CMSuggestionStripView *)predictView emojiBtnMoreTapped:(NSDictionary *)infoDic {
#ifdef DEBUG
//    @weakify(self)
//    [self.fileLogger rollLogFileWithCompletionBlock:^{
//        @stronglize(self)
//        for (NSString *filename in self.fileLogger.logFileManager.sortedLogFilePaths) {
//            [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
//        }
//    }];
#endif
}

- (void)onPredictView:(CMSuggestionStripView *)predictView emojiBtnTapped:(NSDictionary *)infoDic {
#ifdef DEBUG
//    @weakify(self)
//    [self.fileLogger rollLogFileWithCompletionBlock:^{
//        @stronglize(self)
//        [self.inputLogic.mSuggest saveToLog:[CMExtensionBizHelper shouldUseTensorFlow]];
//    }];
#endif
    if (_emojiKeyboardSwitcher && ![self.emojiKeyboardSwitcher isShowEmojiKeyboard]) {
        return;
    }
    [CMExtensionBizHelper playVibration:YES];
    if (_keyboardView) {
        CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
        self.emojiKeyboardSwitcher.inSource = 2;
        [self showEmojiKeyboardView:theViewModel];
        [self.shiftState reset];
    }
    [CMInfoc reportEmojiShow:2 class:self.emojiKeyboardSwitcher.keyboardIndex+1];
}

-(void)onPredictView:(CMSuggestionStripView *)predictView deleteAllSuggestTapped:(NSDictionary *)infoDic
{
    [self showToolBarView];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDeleteAllSuggestHasClicked];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [CMInfoc reportCheetahkeyboard_input_str_clo:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType] inputType:kCMKeyboardManager.inputLogic.keyboardType];
}
#pragma mark - CMToolBarViewDelegate

- (void)onToolBarView:(CMToolBarView *)toolBar settingBtnDownRepeatTapped:(NSDictionary *)infoDic{
#ifdef DEBUG
    [kCMSandboxFileShare showSandboxBrowser:self];
#endif
}

- (void)onToolBarView:(CMToolBarView *)toolBar themeBtnTapped:(NSDictionary *)infoDic {
    kLogTrace();
    [CMExtensionBizHelper playVibration:YES];
    [self openContainerApp:[NSString stringWithFormat:@"%lud",CMPageIdentify_ThemeCenter]];
}

- (void)onToolBarView:(CMToolBarView *)toolBar settingBtnTapped:(NSDictionary *)infoDic {
    kLogTrace();
    [CMExtensionBizHelper playVibration:YES];
    
    if (_settingView && _settingView.superview) {
        CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
        NSString *layoutId = theViewModel.layoutKeyModel.layoutId;
        [self showAlphabetKeyboardViewFromEmojiOrSettingView:layoutId];
        [CMInfoc reportCheetahkeyboard_setting_click:2 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    }else{
        [self showSettingView];
        [CMInfoc reportCheetahkeyboard_setting_click:1 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    }
}

- (void)onToolBarView:(CMToolBarView *)toolBar emojiBtnTapped:(NSDictionary *)infoDic {
    if (_emojiKeyboardSwitcher && [self.emojiKeyboardSwitcher isShowEmojiKeyboard]) {
        return;
    }
    [CMExtensionBizHelper playVibration:YES];
    if (_keyboardView) {
        CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
        self.emojiKeyboardSwitcher.inSource = 1;
        [self.shiftState reset];
        [self showEmojiKeyboardView:theViewModel];
    }
    [CMInfoc reportEmojiShow:1 class:self.emojiKeyboardSwitcher.keyboardIndex+1];
}

- (void)onToolBarView:(CMToolBarView *)toolBar cursorMoveBtnTapped:(NSDictionary *)infoDic {
    kLogTrace();
    [CMExtensionBizHelper playVibration:YES];
    
    if (_cursorMoveView && _cursorMoveView.superview) {
        CMKeyboardViewModel* theViewModel = (CMKeyboardViewModel *)self.keyboardView.viewModel;
        NSString *layoutId = theViewModel.layoutKeyModel.layoutId;
        [self showAlphabetKeyboardViewFromEmojiOrSettingView:layoutId];
        [CMInfoc reportCheetahKeyboard_cursor_click:2 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    }else{
        
        if (kCMSettingManager.isAllowFullAccess || self.cursorMoveView.cursorMoveUseCount <1) {
            [self showCursorMoveView];
        }else{
            // 第二次使用光标移动功能  引导用户full access
            [self.tipsManager addTipsView:self.fullAccessCursorMoveView];
            id<CMTipsViewProtocol> tipsView = [self.tipsManager getTopTipsView];
            [tipsView showInView:self.view anchorView:nil];
            [CMInfoc reportCheetahkeyboard_tip_showWithValue:6];
        }
        //    [self showCursorMoveView];
//        if (self.cursorMoveView.cursorMoveUseCount >= 1 && ![[NSUserDefaults standardUserDefaults] boolForKey:kHasShowedFullAccessTipForCursorMove]) {
//            // 第二次使用光标移动功能  引导用户full access
//            [self.tipsManager addTipsView:self.fullAccessCursorMoveView];
//            id<CMTipsViewProtocol> tipsView = [self.tipsManager getTopTipsView];
//            [tipsView showInView:self.view anchorView:nil];
//        }
        
        [CMInfoc reportCheetahKeyboard_cursor_click:1 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    }
}

- (void)onToolBarView:(CMToolBarView *)toolBar dismissBtnTapped:(NSDictionary *)infoDic {
    [CMExtensionBizHelper playVibration:YES];
    [CMInfoc reportKeyboardDismissBtnTap];
    [self dismissKeyboard];
}

#pragma mark - CMEmojiToolBarViewDelegate
- (void)onEmojiViewToolBarView:(CMEmojiToolBarView *)toolBar emojiBtnTapped:(NSDictionary *)infoDic
{
    if([infoDic objectForKey:@"ChangedIndex"]){
        [CMExtensionBizHelper playVibration:YES];
        _emojiKeyboardSwitcher.keyboardIndex = (int)[infoDic[@"ChangedIndex"] integerValue];
        _currentKeyboardView = _emojiKeyboardSwitcher.emojiKeyboard;
        if(_toolBarView){
            BOOL emotionClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardEmoticonClick];
            BOOL gifClick = [[NSUserDefaults standardUserDefaults] boolForKey:kEmojiBoardGifSegmentClick];
            if(emotionClick && gifClick){
                [_toolBarView removeEmojiRedPoint];
            }
        }
        [CMInfoc report_cheetahkeyboard_emoji_switch:_emojiKeyboardSwitcher.keyboardIndex +1];
    }else if([infoDic objectForKey:@"clickIndex"]){
        if (_emojiKeyboardSwitcher &&  _emojiKeyboardSwitcher.keyboardIndex == (int)[infoDic[@"clickIndex"] integerValue]) {
            CMEmojiKeyboardViewModel* theViewModel = (CMEmojiKeyboardViewModel *)self.emojiKeyboardSwitcher.viewModel;
            NSString *layoutId = theViewModel.layoutKeyModel.layoutId;
            [self showAlphabetKeyboardViewFromEmojiOrSettingView:layoutId];
        }
    }
}

#pragma mark - CMCloudPredictionDelegate
- (BOOL)isComposingWord{
    return [kCMKeyboardManager.inputLogic isComposingWord];
}

- (void)onGetCloudPredictionWord:(SuggestedWordInfo*)suggestWord{
    if(!_predictView|| _predictView.superview == nil)return;
    [self.predictView insertCloudPrediction:suggestWord completeBlock:nil];
    
}
#pragma mark - CMEmoticonKeyboardViewDelegate

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard otherClik:(NSDictionary*)dic{
    if([dic objectForKey:@"gotoFullAccess"]){
        [self gotoFullAccess];
    }
}

- (void)onKeyboard:(CMBaseKeyboardView *)keyboard openMakeEmoticonVC:(int)row{

    [self openContainerApp:[NSString stringWithFormat:@"%lu.%d",(unsigned long)CMPageIdentify_AREmoticon, row]];
}

#pragma mark - CMSettingViewDelegate
- (void)onSettingViewLanguageBtnTapped:(CMSettingView *)settingView
{
    [CMInfoc reportCheetahkeyboard_setting_fun_click:1 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    [self openContainerApp:[NSString stringWithFormat:@"%lud",CMPageIdentify_Language]];
}

- (void)onSettingViewFeedbackBtnTapped:(CMSettingView *)settingView
{
    [CMInfoc reportCheetahkeyboard_setting_fun_click:8 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    [self openContainerApp:[NSString stringWithFormat:@"%lud",CMPageIdentify_Feedback]];
}

- (void)onSettingViewSoundBtnTapped:(CMSettingView *)settingView
{
    [CMInfoc reportCheetahkeyboard_setting_fun_click:2 inputType:kCMKeyboardManager.inputLogic.keyboardType];
}

- (void)onSettingView:(CMSettingView *)settingView vibrationBtnTapped:(BOOL)enable {
    if ([self isFullAccessAllowed]) {
        if (enable) {
            [CMInfoc reportCheetahkeyboard_setting_fun_click:12 inputType:kCMKeyboardManager.inputLogic.keyboardType];
        }
        else {
            [CMInfoc reportCheetahkeyboard_setting_fun_click:13 inputType:kCMKeyboardManager.inputLogic.keyboardType];
        }
    }else{
        [self.tipsManager addTipsView:self.fullAccessSoundView];
        id<CMTipsViewProtocol> tipsView = [self.tipsManager getTopTipsView];
        [tipsView showInView:self.view anchorView:nil];
    }
}

- (void)onSettingViewSoundBtnTapped:(CMSettingView *)settingView openKeyboardSound:(BOOL)openKeyboardSound
{
    if (openKeyboardSound) {
        kCMSettingManager.openKeyboardSound = YES; // 代表用户想开启按键音
        if ([self isFullAccessAllowed]) {
            [CMInfoc reportCheetahkeyboard_setting_fun_click:10 inputType:kCMKeyboardManager.inputLogic.keyboardType];
        }else{
            [self.tipsManager addTipsView:self.fullAccessSoundView];
            id<CMTipsViewProtocol> tipsView = [self.tipsManager getTopTipsView];
            [tipsView showInView:self.view anchorView:nil];
        }
    }else{
        kCMSettingManager.openKeyboardSound = NO;
        [CMInfoc reportCheetahkeyboard_setting_fun_click:11 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    }
}

- (void)onSettingViewSoundVolumeChanged:(CMSettingView *)settingView volume:(float)volume
{
    kCMSettingManager.volume = volume;
    if (volume == 1.0f) {
        [self.settingView makeToast:CMLocalizedString(@"Turn up the phone's volume for a larger sound", nil) duration:1.0f position:CSToastPositionCenter];
    }
}

- (void)onSettingViewRateUsBtnTapped:(CMSettingView *)settingView
{
    [CMInfoc reportCheetahkeyboard_setting_fun_click:7 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    NSString *appStoreUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", [CMAppConfig appleId]];
    [self openURL:appStoreUrl alternativeURL:nil];
}

- (void)onSettingViewAutoCapsBtnTapped:(CMSettingView *)settingView
{
    kCMSettingManager.autoCapitalization = !kCMSettingManager.autoCapitalization;
    NSString *message = kCMSettingManager.autoCapitalization ? @"Auto Capitalization:Enabled" : @"Auto Capitalization:Disabled";
    [self.settingView makeToast:CMLocalizedString(message, nil) duration:1.0f position:CSToastPositionCenter];
    [CMInfoc reportCheetahkeyboard_setting_fun_click:(kCMSettingManager.autoCapitalization ? 3 : 4) inputType:kCMKeyboardManager.inputLogic.keyboardType];
}

- (void)onSettingViewSettingBtnTapped:(CMSettingView *)settingView
{
    [CMInfoc reportCheetahkeyboard_setting_fun_click:9 inputType:kCMKeyboardManager.inputLogic.keyboardType];
    [self openContainerApp:[NSString stringWithFormat:@"%lud",CMPageIdentify_SettingCenter]];
}

- (void)onSettingViewGesureTypingBtnTapped:(CMSettingView *)settingView
{
    kCMSettingManager.slideInputEnable = !kCMSettingManager.slideInputEnable;
    NSString *message = kCMSettingManager.slideInputEnable ? @"Gesture Typing is on" : @"Gesture Typing is off";
    [self.settingView makeToast:CMLocalizedString(message, nil) duration:1.0f position:CSToastPositionCenter];
    [CMInfoc reportCheetahkeyboard_setting_fun_click:(kCMSettingManager.slideInputEnable ? 6 : 5) inputType:kCMKeyboardManager.inputLogic.keyboardType];
    
}

- (void)onSettingViewDiyBtnTapped:(CMSettingView *)settingView
{
    [self openContainerApp:[NSString stringWithFormat:@"%d.3",CMPageIdentify_DiyTheme]];// .3代表是点击键盘设置页的diy按钮进入的diy页面
}

#pragma mark - CMCursorMoveViewDelegate

- (void)onCursorMoveViewMove:(CMCursorMoveView *)cursorMoveView characterOffset:(NSInteger)characterOffset {
    [self.textDocumentProxy adjustTextPositionByCharacterOffset:characterOffset];
    [CMInfoc reportCheetahKeyboard_cursor_action:1 inputType:kCMKeyboardManager.inputLogic.keyboardType];
}

#pragma mark -
- (void)showAlphabetKeyboardView:(CMKeyboardViewModel *)viewModel{
    self.wholeKeyboardBgEffectView.hidden = YES;
    if (viewModel) {
        kCMKeyboardManager.keyboardType = viewModel.keyboadModel.keyboardType;
        self.keyboardView.isLayoutFinish = NO;
        [self.keyboardView bindData:viewModel];
        if(!self.keyboardView.superview){
            [self.view addSubview:self.keyboardView];
            self.currentKeyboardView = self.keyboardView;
            if (_emojiKeyboardSwitcher && _emojiKeyboardSwitcher.emojiKeyboard.superview) {
                [_emojiKeyboardSwitcher removeFromSuperview];
                _emojiKeyboardSwitcher = nil;
            }
            
            if (_settingView && _settingView.superview) {
                [self.settingView removeFromSuperview];
                self.settingView = nil;
            }
            if (_cursorMoveView && _cursorMoveView.superview) {
                [self.cursorMoveView removeFromSuperview];
                self.cursorMoveView = nil;
            }
        }
        
//        [self.keyboardView hidePreView:NO];
        if (_predictView && [_predictView.viewModel numberOfItemsInSection:0] > 0) {
            [self showPredictView];
        }
        else {
            [self showToolBarView];
        }
    }
}

// 从emoji界面 or 设置界面 or 光标移动界面返回字母键盘
- (void)showAlphabetKeyboardViewFromEmojiOrSettingView:(NSString *)layoutId
{
    self.wholeKeyboardBgEffectView.hidden = YES;
    if (self.keyboardView && self.keyboardView.viewModel) {
        [self showAlphabetKeyboardView:(CMKeyboardViewModel *)self.keyboardView.viewModel];
        [self.shiftState reset];
        [self.shiftState singleTap:nil];
        self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
        
    }else{
        [[CMKeyboardManager sharedInstance] loadKeyboardByLayoutId:layoutId inputModel:self.currentInputModel completionHandler:^(CMKeyboardViewModel *viewModel, CMError *error) {
            if (viewModel && error == nil) {
                [self showAlphabetKeyboardView:viewModel];
                if(viewModel.keyboadModel.keyboardType == CMKeyboardTypeLetter){
                    [self.shiftState singleTap:nil];
                    self.shiftState.autocapitalizationType = self.currentInputModel.autocapitalizationType;
                }else{
                    [self.shiftState reset];
                }
            }
        }];
        
    }
}

- (void)showSettingView{
    if (_settingView && _settingView.superview) {
        return;
    }
    self.wholeKeyboardBgEffectView.hidden = NO;
    [self.view addSubview:self.settingView];
    self.currentKeyboardView = (id)self.settingView;
    [self.keyboardView removeFromSuperview];
    if (_cursorMoveView && _cursorMoveView.superview) {
        [self.cursorMoveView removeFromSuperview];
    }
    if (_emojiKeyboardSwitcher && [_emojiKeyboardSwitcher isShowEmojiKeyboard]) {
        [self.emojiKeyboardSwitcher removeFromSuperview];
        self.emojiKeyboardSwitcher = nil;
    }
}

- (void)showCursorMoveView {
    self.wholeKeyboardBgEffectView.hidden = NO;
    [self.view addSubview:self.cursorMoveView];
    self.currentKeyboardView = (id)self.cursorMoveView;
    [self.keyboardView removeFromSuperview];
    if (_settingView && _settingView.superview) {
        [self.settingView removeFromSuperview];
    }
}

- (void)showEmojiKeyboardView:(CMKeyboardViewModel *)viewModel{
    if (viewModel) {
        [self.emojiKeyboardSwitcher setupWithLayoutModel:viewModel.layoutKeyModel deleteModel:viewModel.deleteKeyModel returnModel:viewModel.returnKeyModel];
        [self.emojiKeyboardSwitcher showToParentVeiw:self.view];
        self.currentKeyboardView = self.emojiKeyboardSwitcher.emojiKeyboard;
        [self.keyboardView removeFromSuperview];
        if (_settingView && _settingView.superview) {
            [self.settingView removeFromSuperview];
            self.settingView = nil;
        }
        if (_cursorMoveView && _cursorMoveView.superview) {
            [self.cursorMoveView removeFromSuperview];
            self.cursorMoveView = nil;
        }
        [self showToolBarView];
        self.wholeKeyboardBgEffectView.hidden = NO;
    }
}

- (void)showPredictView{
    if (_keyboardView && _keyboardView.superview){
        if(self.predictView.superview == nil){
            [self.view addSubview:self.predictView];
            [self.toolBarView removeFromSuperview];
            [_emojiToolBarView removeFromSuperview];
            _emojiToolBarView = nil;
            self.currentToolBar = self.predictView;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kShouldShowDeleteAllSuggest] == YES) {
                self.predictView.shouldShowDeleteAllButton = YES;
            }else{
                self.predictView.shouldShowDeleteAllButton = NO;
            }
        }
    }
}

- (void)showToolBarView{
    if ((_keyboardView && _keyboardView.superview) || (_settingView && _settingView.superview)){
        if(self.toolBarView.superview == nil){
            [self.view addSubview:self.toolBarView];
            [_emojiToolBarView removeFromSuperview];
            _emojiToolBarView = nil;
            [_predictView bindData:nil completeBlock:nil];
            [_predictView removeFromSuperview];
            self.currentToolBar = self.toolBarView;
        }
    }
    else if (_emojiKeyboardSwitcher.emojiKeyboard && _emojiKeyboardSwitcher.emojiKeyboard.superview) {
        if(self.emojiToolBarView.superview ==nil){
            [self.view addSubview:self.emojiToolBarView];
            [self.toolBarView removeFromSuperview];
            [_predictView removeFromSuperview];
            self.currentToolBar = self.emojiToolBarView;
        }
    }
}


- (void)resetKeyboardTopView{
    [_predictView bindData:nil completeBlock:nil];
    [self showToolBarView];
}
- (void)reset{
    [_predictView bindData:nil completeBlock:nil];
    [self.shiftState reset];
    kCMKeyboardManager.inputLogic.lastUpdateSuggestionParamInputWords=nil;
}

- (void)updateSuggestionStrip{
    if (!_proximityInfo || !_keyboardView || !_keyboardView.superview || !_keyboardView.isLayoutFinish) {
        return;
    }
    
    if (_nonBatchInputBlock) {
        dispatch_cancel(_nonBatchInputBlock);
        _nonBatchInputBlock = nil;
    }
    
    @weakify(self)
    dispatch_block_t block = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -8, ^{
        @stronglize(self)
        kLogInfo(@"[ThreadLog] updateSuggestionStrip 开始");
        dispatch_semaphore_t lock = dispatch_semaphore_create(0);
        [kCMKeyboardManager.inputLogic perfromUpdateSuggestionStrip:self->_completeInputTransaction proximityInfo:self.proximityInfo completionBlock:^(SuggesteWords *word, CMError *error, BOOL needUpdate) {
            @stronglize(self)
            if (needUpdate) {
                [self.predictView bindData:word completeBlock:^(CMError *error) {
                    @stronglize(self)
                    if ([self.predictView.viewModel numberOfItemsInSection:0] > 0) {
                        [self showPredictView];
                    }
                    else {
                        [self showToolBarView];
                    }
                    dispatch_semaphore_signal(lock);
                }];
            }
            else {
                dispatch_semaphore_signal(lock);
            }
        }];
        dispatch_semaphore_wait(lock, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
        kLogInfo(@"[ThreadLog] updateSuggestionStrip 结束");
    });
    
    dispatch_async(self.inputLogicSerialQueue, block);
    self.nonBatchInputBlock = block;
}

//- (void)updateStateAfterInputTransaction{
//    kLogTrace();
//    [self updateSuggestionStrip];
////
////    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSuggestionStrip) object:nil];
////    [self performSelector:@selector(updateSuggestionStrip) withObject:nil afterDelay:0.1];
//}

#pragma mark - play keyboard sound
- (void)playSoundWithKeyType:(CMKeyType)keyType
{
    if (kCMSettingManager.openKeyboardSound != YES || [self isFullAccessAllowed] == NO) {
        return;
    }
    
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
        self.player.volume = kCMSettingManager.volume;
        [self.player prepareToPlay];
        [self.player play];
    });
}

#pragma mark - LongPressSpaceTip And CloudPredictTip Methods
- (void)showGuides
{
    id<CMTipsViewProtocol> tipView = [self.tipsManager getTopTipsView];
    if (tipView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (tipView.priority == cloudSuggestTip) {
                [self.textDocumentProxy insertText:self.forceInputStr];
                [self forceInputPredictedWithDataArray:self.forceSuggestionsArray];
            }
            else if (tipView.priority == spaceKeyLongPressTip) {
                [tipView showInView:self.view anchorView:self.spaceButton];
            }
            else if (tipView.priority == fullAccessTipCloud || tipView.priority == fullAccessTipSound) {
                [tipView showInView:self.view anchorView:nil];
            }
        });
    }
}

- (CMRemindTipView *)longPressSpaceTipView {
    if (!_longPressSpaceTipView) {
        _longPressSpaceTipView = [[CMRemindTipView alloc] initWithImageName:@"keyboardTip" tipString:CMLocalizedString(@"LongPressSpace_Tip", nil) singleDirection:CMSingleDirectionBottom percent:.5];
        _longPressSpaceTipView.priority = spaceKeyLongPressTip;
        _longPressSpaceTipView.duration = 7.0f;
        _longPressSpaceTipView.tipDelegate = self;
    }
    return _longPressSpaceTipView;
}

- (CMRemindTipView *)cloudPredictTipView {
    if (!_cloudPredictTipView) {
        _cloudPredictTipView = [[CMRemindTipView alloc] initWithImageName:@"cloudPredictTips" tipString:CMLocalizedString(@"This unique suggestion is powered by AI and trained from billions of data. 😎", nil) singleDirection:CMSingleDirectionTop percent:.5];
        _cloudPredictTipView.priority = cloudSuggestTip;
        _cloudPredictTipView.duration = 7.0f;
        _cloudPredictTipView.tipDelegate = self;
    }
    return _cloudPredictTipView;
}

- (void)forceInputPredictedWithDataArray:(NSArray<SuggestedWordInfo*> *)dataArray
{
    SuggesteWords * suggest = [[SuggesteWords alloc] init];
    suggest.suggestionsList = dataArray;
    suggest.willAutoCorrect = 3;
    [self showPredictView];
    @weakify(self)
    [self.predictView bindData:suggest completeBlock:^(CMError *error) {
        @stronglize(self)
        if (!error) {
            if (dataArray.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dataArray enumerateObjectsUsingBlock:^(SuggestedWordInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        CMSuggestionCell * cell = (CMSuggestionCell *)[self.predictView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
                        if (cell) {
                            if (idx == 3) {
                                [self.cloudPredictTipView showInView:self.view anchorView:cell];
                                [cell cloudPredictionImageViewTintColor:kCMKeyboardManager.themeManager.predictCellEmphasizeHighlightTextColor];
                            }else{
                                [cell setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.23]];
                            }
                        }
                    }];
                });
            }
        }else{
            [self showToolBarView];
        }
    }];
}

- (NSArray *)forceSuggestionsArray
{
    if (!_forceSuggestionsArray) {
        NSArray * wordArray = [NSArray arrayWithObjects:@"good",@"few",@"lot",@"reason",@"little",@"bit",@"new",@"great",@"big",@"couple",@"friend",@"long",@"nice", nil];
        NSMutableArray * tempArray = [NSMutableArray array];
        for (int i = 0; i < wordArray.count; i++) {
            SuggestedWordInfo * wordInfo;
            wordInfo = [[SuggestedWordInfo alloc] initWithWord:wordArray[i] prevWordsContext:@"" score:MAX_SCORE sourceDict:nil  kindAndFlags:KIND_TYPED indexOfTouchPointOfSecondWord:NOT_AN_INDEX autoCommitFirstWordConfidence:NOT_A_CONFIDENCE timestamp:NOT_A_TIMESTAMP];
            if (i == 3) {
                wordInfo = [[SuggestedWordInfo alloc] initWithCloudWord:@"reason" upack:@"" score:0 kindAndFlags:KIND_CLOUD_PREDICTION];
            }
            [tempArray addObject:wordInfo];
        }
        _forceSuggestionsArray = [NSArray arrayWithArray:tempArray];
    }
    return _forceSuggestionsArray;
}

#pragma mark - FullAccessTip Methods
#ifndef SCHEME
- (BOOL)shouldShowFullAccessTip
{
    if ([self isFullAccessAllowed]) {
        return NO;
    }
    if (self.isNewInstall) {
        return YES;
    }
    else {
        
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kGlobalUserDefaultsFullAccessFirstDate];
        NSDate *currentDate = [NSDate date];
        if ((int)((([currentDate timeIntervalSinceDate:date] + 60) / (24 * 60 * 60) + 1)) % 2 == 0) {
            NSDate *todayDate = [[NSUserDefaults standardUserDefaults] objectForKey:kGlobalUserDefaultsFullAccessTodayDate];
            if ([[NSCalendar currentCalendar] isDate:todayDate inSameDayAsDate:currentDate]) {
                return NO;
            }
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldShowSpaceLongPressTip
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasShowedLongPressSpaceTip] && self.isNewInstall) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldShowCloudSuggestionTip
{
    if (self.currentInputModel) {
        if (self.currentInputModel.keyboardType == UIKeyboardTypeURL || self.currentInputModel.keyboardType == UIKeyboardTypeEmailAddress) {
            return NO;
        }
    }
        
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasShowedCloudPredictedTip] && self.isNewInstall && kCMSettingManager.languageType == CMKeyboardLanguageTypeEnglishUnitedState && [[CMAppConfig currentLanguage] hasPrefix:@"en"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isNewInstall {
    if ([self isFullAccessAllowed]) {
        NSDictionary* userDefaultDic = [kCMGroupDataManager.shared dictionaryRepresentation];
        if (userDefaultDic && [userDefaultDic.allKeys containsObject:kCloudFetchTimestampKey]) {
            NSDate* cloudTimeDate = [userDefaultDic objectForKey:kCloudFetchTimestampKey];
            if (cloudTimeDate && [[NSDate date] timeIntervalSinceDate:cloudTimeDate] <= 2*60) {
                return YES;
            }
            return NO;
        }
        return YES;
    }
    NSDictionary* userDefaultDic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    // 1.3.0本地NSUserDefaults中加入了kGlobalUserDefaultsFullAccessFirstDate存储，因为长按空格发emoji和云预测都是这个版本添加的，所以用这个记录来判断是否为全新安装是合适的，因为再老的版本覆盖安装了肯定需要提示
    if (userDefaultDic && [userDefaultDic.allKeys containsObject:kGlobalUserDefaultsFullAccessFirstDate]) {
        return NO;
    }
    return YES;
}

- (void)gotoFullAccess{
    
    NSURL *url = [NSURL URLWithString:[CMBizHelper fullAccessUrlFromExtension]];
    UIResponder *responder = self;
    while (responder !=nil) {
        if([responder respondsToSelector:@selector(openURL:)]){
            [NSThread detachNewThreadSelector:@selector(openURL:) toTarget:responder withObject:url];
        }
        responder = responder.nextResponder;
    }
}

#endif

#pragma mark - CMTipsViewDelegate
- (void)tipsView:(id<CMTipsViewProtocol>)view onShowed:(NSDictionary *)infoDic {
    if (view.priority == cloudSuggestTip) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShowedCloudPredictedTip];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:4];
    }
    else if (view.priority == spaceKeyLongPressTip) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShowedLongPressSpaceTip];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:3];
    }
    else if (view.priority == fullAccessTipCloud) {
        NSDate *currentDate = [NSDate date];
        if (self.isNewInstall) {
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kGlobalUserDefaultsFullAccessFirstDate];
        }
        [self updateCurrentConstraintsToSize:CGSizeZero withTransitionCoordinator:nil];
        [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kGlobalUserDefaultsFullAccessTodayDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:1];
    }
    else if (view.priority == fullAccessTipSound) {
        NSDate *currentDate = [NSDate date];
        if (self.isNewInstall) {
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kGlobalUserDefaultsFullAccessFirstDate];
        }
        [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:kGlobalUserDefaultsFullAccessTodayDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:2];
    }else if (view.priority == fullAccessTipCursorMove) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShowedFullAccessTipForCursorMove];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:6];
    }
}

- (void)tipsView:(id<CMTipsViewProtocol>)view onTapped:(NSDictionary *)infoDic {
    
    if (view.priority == fullAccessTipCloud) {
        [self gotoFullAccess];
        [self updateCurrentConstraintsToSize:CGSizeZero withTransitionCoordinator:nil];
        [CMInfoc reportCheetahkeyboard_tip_clickWithValue:1];
    }
    else if (view.priority == fullAccessTipSound) {
        [self gotoFullAccess];
        [CMInfoc reportCheetahkeyboard_tip_clickWithValue:2];
    }
    else if (view.priority == spaceKeyLongPressTip) {
        if (infoDic && [infoDic.allKeys containsObject:@"type"]) {
            NSInteger type = [infoDic integerValueForKey:@"type" defaultValue:1];
            if (type == 1) {
                [CMInfoc reportCheetahkeyboard_tip_clickWithValue:3]; // 4 - 弹窗外; 3 - 弹窗
            }
            else {
                [CMInfoc reportCheetahkeyboard_tip_clickWithValue:4]; // 4 - 弹窗外; 3 - 弹窗
            }
        }
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:3 closeType:4];
    }
    else if (view.priority == cloudSuggestTip) {
        if (infoDic && [infoDic.allKeys containsObject:@"type"]) {
            NSInteger type = [infoDic integerValueForKey:@"type" defaultValue:1];
            if (type == 1) {
                [CMInfoc reportCheetahkeyboard_tip_clickWithValue:5]; // 6 - 弹窗外；5 - 弹窗
            }
            else {
                [CMInfoc reportCheetahkeyboard_tip_clickWithValue:6]; // 6 - 弹窗外；5 - 弹窗
            }
        }
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:4 closeType:4]; // 超时关闭
    }else if (view.priority == fullAccessTipCursorMove) {
        [self gotoFullAccess];
        [CMInfoc reportCheetahkeyboard_tip_clickWithValue:8];
    }
}

- (void)tipsView:(id<CMTipsViewProtocol>)view onSwiped:(NSDictionary *)infoDic {
    if (view.priority == fullAccessTipCloud) {
        [self updateCurrentConstraintsToSize:CGSizeZero withTransitionCoordinator:nil];
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:1 closeType:_fullAccessViewCloseType ? _fullAccessViewCloseType : 0];
    }
    else if (view.priority == fullAccessTipSound) {
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:2 closeType:_fullAccessViewCloseType ? _fullAccessViewCloseType : 0];
    }else if (view.priority == fullAccessTipCursorMove) {
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:6 closeType:_fullAccessViewCloseType ? _fullAccessViewCloseType : 0];
    }
}

-(void)tipsView:(id<CMTipsViewProtocol>)view onRemoved:(NSDictionary *)infoDic {
    if (view.priority == cloudSuggestTip) {
        for (int i=0; i < self.forceInputStr.length; i++) {
            [self.textDocumentProxy deleteBackward];
        }
        [self resetKeyboardTopView];
        [self updateSuggestionStrip];
        [self updateCurrentConstraintsToSize:CGSizeZero withTransitionCoordinator:nil];
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:4 closeType:1]; // 超时关闭
        [CMGroupDataManager shareInstance].isShowingCloudPredictTip = NO;
    }
    else if (view.priority == spaceKeyLongPressTip) {
        if (![self shouldShowCloudSuggestionTip]) {
            [self updateSuggestionStrip];
        }
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:3 closeType:1];
    }
    else if (view.priority == fullAccessTipCloud) {
        [self updateCurrentConstraintsToSize:CGSizeZero withTransitionCoordinator:nil];
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:1 closeType:_fullAccessViewCloseType ? _fullAccessViewCloseType : 0];
    }
    else if (view.priority == fullAccessTipSound) {
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:2 closeType:_fullAccessViewCloseType ? _fullAccessViewCloseType : 0];
    }else if (view.priority == fullAccessTipCursorMove) {
        [CMInfoc reportCheetahkeyboard_tip_closeWithValue:6 closeType:_fullAccessViewCloseType ? _fullAccessViewCloseType : 0];
    }
    
    [self.tipsManager removeTipsView:view];
    view = nil;
    
    id<CMTipsViewProtocol> tipsView = [self.tipsManager getTopTipsView];
    if (tipsView.priority == cloudSuggestTip) {
        self.forceInputStr = @"Everything happens for a ";
        [self.textDocumentProxy insertText:self.forceInputStr];
        [self forceInputPredictedWithDataArray:self.forceSuggestionsArray];
    }
    else if (tipsView.priority == fullAccessTipCloud) {
        [tipsView showInView:self.view anchorView:nil];
    }
}

#pragma mark - 修改键盘语言类型设置
- (void)setShowLanguageType {
    if (kCMSettingManager.languageType == CMKeyboardLanguageTypeArabic) {
        self.primaryLanguage = @"ar";
    }else {
        self.primaryLanguage = @"en-US";
    }
}

@end
