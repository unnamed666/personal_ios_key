//
//  CMDIYThemeViewController.m
//  PandaKeyboard
//
//  Created by duwenyan on 2017/10/31.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMDIYThemeViewController.h"
#import "CMNavigationBar.h"
#import "CMDiySourceCollectionCell.h"
#import "CMDiySourceViewModel.h"
#import "CMRefreshFooter.h"
#import "CMRefreshHeader.h"
#import "CMDIYKeyboardView.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "HMSegmentedControl.h"
#import "CMDiySourceModel.h"
#import "CMErrorRefreshView.h"
#import "CMTipView.h"
#import "MBProgressHUD+Toast.h"
#import "CMCustomThemeAlert.h"
#import "CMImagePickerController.h"
#import "CMCommUtil.h"
#import <SSZipArchive/SSZipArchive.h>
#import "CMTabBarViewController.h"
#import "CMRouterManager.h"

#define ToolbarTag  1000    // 用来标识 toolbar是否展示过，当tag为1000时，代表展示过该toolbar
#define KeyAlphaSliderTag   1000    // 用来标志用户是否滑动过keyAlphaSlider

@interface CMOfficialOriginalImageModel : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isNinePatch;

+ (instancetype)modelWithImagePath:(NSString *)imagePath;
- (instancetype)initWithImagePath:(NSString *)imagePath;

@end

@implementation CMOfficialOriginalImageModel

+ (instancetype)modelWithImagePath:(NSString *)imagePath
{
    CMOfficialOriginalImageModel *model = [[CMOfficialOriginalImageModel alloc] initWithImagePath:imagePath];
    return model;
}

- (instancetype)initWithImagePath:(NSString *)imagePath
{
    if (self = [super init]) {
        self.image = [UIImage imageWithContentsOfFile:imagePath];
        self.isNinePatch = [UIImage isNinePatchImageByName:imagePath];
    }
    return self;
}

@end

typedef void(^GetDiyResourceComplete)(NSString *filePath);

@interface CMDIYThemeViewController ()<CMNavigationBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate,CMErrorRefreshViewDelegate,CMImagePickerControllerDelegate>


@property (nonatomic, strong) CMNavigationBar *navBar;
@property (nonatomic, strong) CMDIYKeyboardView *diyKeyboardView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *bgCollectionView;
@property (nonatomic, strong) UICollectionView *buttonCollectionView;
@property (nonatomic, strong) UICollectionView *fontsCollectionView;
@property (nonatomic, strong) UICollectionView *soundCollectionView;
@property (nonatomic, strong) UIView *bgToolBar;
@property (nonatomic, strong) UIView *buttonToolBar;
@property (nonatomic, strong) UIView *fontsToolBar;
@property (nonatomic, strong) UIView *soundToolBar;
@property (nonatomic, strong) CMErrorRefreshView * errorRefreshView;
@property (nonatomic, strong) UIView * errorRefreshViewContainerView;

@property (nonatomic, strong) UISlider *lightSlider;
@property (nonatomic, strong) UISlider *blurSlider;

@property (nonatomic, strong) NSArray *fontsGradientColor;
@property (nonatomic, strong) UISlider *keyAlphaSlider;

@property (nonatomic, strong) CMDiySourceViewModel *bgSourceViewModel;
@property (nonatomic, strong) CMDiySourceViewModel *buttonSourceViewModel;
@property (nonatomic, strong) CMDiySourceViewModel *fontsSourceViewModel;
@property (nonatomic, strong) CMDiySourceViewModel *soundSourceViewModel;

@property (nonatomic, copy) NSString *bgSelectedId;
@property (nonatomic, copy) NSString *keyBgSelectedId;
@property (nonatomic, copy) NSString *fontsSelectedId;
@property (nonatomic, copy) NSString *soundSelectedId;

@property (nonatomic, strong) NSIndexPath *lastBgIndexPath;
@property (nonatomic, strong) NSIndexPath *lastFontIndexPath;
@property (nonatomic, strong) NSIndexPath *lastSoundIndexPath;

@property (nonatomic, strong) UIImage *originalBKImage;
@property (nonatomic, strong) UIImage *originalKeyBgImage;

@property(nonatomic, strong) NSMutableDictionary<NSString *, CMOfficialOriginalImageModel *> *officialOriginalImages; // 官方主题原图model

@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask*>* downloadTasks;

@property (nonatomic, assign) BOOL hudIsShow;
@property (nonatomic, strong) CMCustomThemeAlert *alertView;

@property (nonatomic, assign) NSInteger bgtime; // 点击更换在线背景的次数
@property (nonatomic, assign) NSInteger bttime; // 点击更换按钮的次数
@property (nonatomic, assign) NSInteger fttime; // 点击更换字体的次数
@property (nonatomic, assign) NSInteger sdtime; // 点击更换音效的次数

@property (nonatomic, copy) NSString *themeName;
@property (nonatomic, assign) CMDiyType diyType;

@property (nonatomic, strong) NSOperationQueue *blurOperationQuene; //

@end

@implementation CMDIYThemeViewController

#pragma mark - init
- (instancetype)init
{
    if (self = [super init]) {
        self.themeName = @"diyTheme";
        self.diyType = CMDiyTypeDefault;
    }
    return self;
}

- (instancetype)initWithDiyThemeName:(NSString *)themeName diyType:(CMDiyType)diyType
{
    if (self = [super init]) {
        self.themeName = themeName;
        self.diyType = diyType;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = rgb(13.0f, 17.0f, 43.0f);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.navBar];
    
    [self.view addSubview:self.diyKeyboardView];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.bgCollectionView];
    [self.scrollView addSubview:self.buttonCollectionView];
    [self.scrollView addSubview:self.fontsCollectionView];
    [self.scrollView addSubview:self.soundCollectionView];
    [self.view addSubview:self.bgToolBar];
    [self.view addSubview:self.buttonToolBar];
    [self.view addSubview:self.fontsToolBar];
    [self.view addSubview:self.soundToolBar];
    
    CGFloat keyboardViewWidth = self.view.frame.size.width;
    CGFloat diyKeyboardViewMarginTop;
    if(![UIDevice isHeight896]){
        diyKeyboardViewMarginTop = 55.0f;
    } else {
        diyKeyboardViewMarginTop = 55.0f + 15.0f;
    }
    self.diyKeyboardView.frame = CGRectMake(0.0f, diyKeyboardViewMarginTop, keyboardViewWidth, [CMKeyboardManager keyboardHeight] + [CMKeyboardManager toolbarHeight]);
    self.segmentedControl.frame = CGRectMake(0, CGRectGetMaxY(self.diyKeyboardView.frame), self.view.frame.size.width, KScalePt(50.0f));
    self.scrollView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.segmentedControl.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.segmentedControl.frame));
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 4, CGRectGetHeight(self.scrollView.frame));
    self.bgCollectionView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, CGRectGetHeight(self.scrollView.frame));
    self.buttonCollectionView.frame = CGRectMake(CGRectGetMaxX(self.bgCollectionView.frame), 0.0f, self.view.frame.size.width, CGRectGetHeight(self.scrollView.frame));
    self.fontsCollectionView.frame = CGRectMake(CGRectGetMaxX(self.buttonCollectionView.frame), 0.0f, self.view.frame.size.width, CGRectGetHeight(self.scrollView.frame));
    self.soundCollectionView.frame = CGRectMake(CGRectGetMaxX(self.fontsCollectionView.frame), 0.0f, self.view.frame.size.width, CGRectGetHeight(self.scrollView.frame));
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, self.segmentedControl.frame.size.height - KScalePt(0.70f), self.segmentedControl.frame.size.width, KScalePt(0.70f));
    layer.backgroundColor = [UIColor colorWithRed:38 / 255.0f green:44 / 255.0f blue:64 / 255.0f alpha:1.0f].CGColor;
    [self.segmentedControl.layer addSublayer:layer];
    
    [self.segmentedControl setSelectedSegmentIndex:0 animated:NO notify:YES];
    
    _hudIsShow = NO;
    switch (self.diyType) {
        case CMDiyTypeDefault:
        {
            self.bgSelectedId = @"default";
            self.originalBKImage = [UIImage imageNamed:@"diy_defaultwhole_keyboard_background"];
            self.lastBgIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            self.keyBgSelectedId = @"non";
            self.fontsSelectedId = @"sys";
            self.soundSelectedId = @"non";
            [self.buttonCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
            break;
        case CMDiyTypeOfficial:
        case CMDiyTypeDiy:
        {
            self.bgSelectedId = @"official";
            self.keyBgSelectedId = @"official";
            self.fontsSelectedId = @"official";
            self.soundSelectedId = @"official";
            if (kCMKeyboardManager.themeManager.predictViewBgImage && kCMKeyboardManager.themeManager.keyboardViewBgImage) {
                // 合成一张图片
                self.originalBKImage = [UIImage compoundImage:kCMKeyboardManager.themeManager.predictViewBgImage image:kCMKeyboardManager.themeManager.keyboardViewBgImage];
            }else if (kCMKeyboardManager.themeManager.predictViewBgImage && !kCMKeyboardManager.themeManager.keyboardViewBgImage) {
                // 合成一张图片
                self.originalBKImage = [UIImage addImage:kCMKeyboardManager.themeManager.predictViewBgImage toImageTop:kCMKeyboardManager.themeManager.wholeBoardBgImage];
            }else{
                self.originalBKImage = kCMKeyboardManager.themeManager.wholeBoardBgImage;
            }
            
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.letterKeyNormalBgImagePath] forKey:@"letterKeyNormalBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.letterKeyHighlightBgImagePath] forKey:@"letterKeyHighlightBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.funcKeyNormalBgImagePath] forKey:@"funcKeyNormalBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.funcKeyHighlightBgImagePath] forKey:@"funcKeyHighlightBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.spaceKeyNormalBgImagePath] forKey:@"spaceKeyNormalBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.spaceKeyHighlightBgImagePath] forKey:@"spaceKeyHighlightBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.preInputBgImagePath] forKey:@"preInputBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.inputOptionBgImagePath] forKey:@"inputOptionBgImage"];
            [self.officialOriginalImages setObject:[CMOfficialOriginalImageModel modelWithImagePath:kCMKeyboardManager.themeManager.inputOptionHighlightBgImagePath] forKey:@"inputOptionHighlightBgImage"];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.bgSourceViewModel cancelTask];
    [self.fontsSourceViewModel cancelTask];
    [self.soundSourceViewModel cancelTask];
    
    [self.downloadTasks enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task cancel];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - setter/getter
- (CMNavigationBar *)navBar
{
    if (!_navBar) {
        _navBar = [[CMNavigationBar alloc] initWithNavigationBarType:CMNavigationBarTypeRightItem centerYOffset:0];
        _navBar.title = CMLocalizedString(@"Custome Theme", nil);
        _navBar.rightItemTitleNormal = CMLocalizedString(@"Done", nil);
        _navBar.backgroundColor = rgb(13.0f, 17.0f, 43.0f);
        _navBar.delegate = self;
    }
    return _navBar;
}

- (CMDIYKeyboardView *)diyKeyboardView
{
    if (!_diyKeyboardView) {
        [kCMKeyboardManager.themeManager switchTo:self.themeName];
        _diyKeyboardView = [CMDIYKeyboardView new];
    }
    return _diyKeyboardView;
}

- (HMSegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        NSArray *imageArray = @[[UIImage imageNamed:@"diy_background_normal"], [UIImage imageNamed:@"diy_button_normal"], [UIImage imageNamed:@"diy_font_normal"],[UIImage imageNamed:@"diy_stepicon_sound_normal"]];
        NSArray *imageSelectedArray = @[[UIImage imageNamed:@"diy_background_selected"], [UIImage imageNamed:@"diy_button_selected"], [UIImage imageNamed:@"diy_font_selected"],[UIImage imageNamed:@"diy_stepicon_sound_selected"]];
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:imageArray sectionSelectedImages:imageSelectedArray];
        _segmentedControl.backgroundColor = [UIColor clearColor];
        _segmentedControl.type = HMSegmentedControlTypeImages;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectionIndicatorHeight = 3.0f;
        _segmentedControl.selectionIndicatorColor = rgb(84, 243, 238);
        @weakify(self)
        [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
            @stronglize(self);
            [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * index, 0) animated:YES];
            [self changedSegment];
        }];
    }
    return _segmentedControl;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UICollectionView *)bgCollectionView {
    if (!_bgCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _bgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_bgCollectionView registerClass:[CMDiySourceCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([CMDiySourceCollectionCell class])];
        _bgCollectionView.backgroundColor = [UIColor clearColor];
        _bgCollectionView.dataSource = self;
        _bgCollectionView.delegate = self;
        CMRefreshHeader *header = [CMRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadBackgroundSources)];
        _bgCollectionView.mj_header = header;
        CMRefreshFooter *footer = [CMRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreBackgroundSources)];
        _bgCollectionView.mj_footer = footer;
    }
    return _bgCollectionView;
}

- (UICollectionView *)buttonCollectionView
{
    if (!_buttonCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _buttonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_buttonCollectionView registerClass:[CMDiySourceCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([CMDiySourceCollectionCell class])];
        _buttonCollectionView.backgroundColor = [UIColor clearColor];
        _buttonCollectionView.dataSource = self;
        _buttonCollectionView.delegate = self;
    }
    return _buttonCollectionView;
}

- (UICollectionView *)fontsCollectionView
{
    if (!_fontsCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _fontsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_fontsCollectionView registerClass:[CMDiySourceCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([CMDiySourceCollectionCell class])];
        _fontsCollectionView.backgroundColor = [UIColor clearColor];
        _fontsCollectionView.dataSource = self;
        _fontsCollectionView.delegate = self;
        CMRefreshHeader *header = [CMRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFontsSources)];
        _fontsCollectionView.mj_header = header;
        CMRefreshFooter *footer = [CMRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFontsSources)];
        _fontsCollectionView.mj_footer = footer;
    }
    return _fontsCollectionView;
}

-(UICollectionView *)soundCollectionView{
    if (!_soundCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _soundCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_soundCollectionView registerClass:[CMDiySourceCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([CMDiySourceCollectionCell class])];
        _soundCollectionView.backgroundColor = [UIColor clearColor];
        _soundCollectionView.delegate = self;
        _soundCollectionView.dataSource = self;
        CMRefreshHeader *header = [CMRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadSoundResources)];
        CMRefreshFooter *footer = [CMRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSoundResources)];
        _soundCollectionView.mj_header = header;
        _soundCollectionView.mj_footer = footer;
    }
    return _soundCollectionView;
}

- (UIView *)bgToolBar
{
    if (!_bgToolBar) {
        _bgToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, CGRectGetWidth(self.view.bounds), 120.0f)];
        _bgToolBar.backgroundColor = rgb(13.0f, 17.0f, 43.0f);
        _bgToolBar.alpha = 0.94f;
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.70f);
        layer.backgroundColor = [UIColor colorWithRed:38 / 255.0f green:44 / 255.0f blue:64 / 255.0f alpha:1.0f].CGColor;
        [_bgToolBar.layer addSublayer:layer];
        
        UIImageView *blurImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, 26.0f, 26.0f, 26.0f)];
        blurImageView.image = [UIImage imageNamed:@"diy_icon_blur"];
        [_bgToolBar addSubview:blurImageView];

        _blurSlider = [[UISlider alloc] initWithFrame:CGRectMake(84.0f, 26.0f, self.view.bounds.size.width - 100.0f, 26.0f)];
        _blurSlider.minimumValue = 0.8f;
        _blurSlider.maximumValue = 1.0f;
        _blurSlider.minimumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:1.0f];
        _blurSlider.maximumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:0.3f];
        _blurSlider.value = 1.0f;
        [_blurSlider setThumbImage:[UIImage imageNamed:@"diy_slider_button"] forState:UIControlStateNormal];
//        [_blurSlider addTarget:self action:@selector(blurChangedEnd:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        [_blurSlider addTarget:self action:@selector(blurChangedEnd:) forControlEvents:UIControlEventValueChanged];

        [_bgToolBar addSubview:_blurSlider];
        
        UIImageView *lightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, 68.0f, 26.0f, 26.0f)];
        lightImageView.image = [UIImage imageNamed:@"diy_icon_light"];
        [_bgToolBar addSubview:lightImageView];
        
        _lightSlider = [[UISlider alloc] initWithFrame:CGRectMake(84.0f, 68.0f, self.view.bounds.size.width - 100.0f, 26.0f)];
        _lightSlider.minimumValue = 0.5f;
        _lightSlider.maximumValue = 1.5f;
        _lightSlider.minimumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:1.0f];
        _lightSlider.maximumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:0.3f];
        _lightSlider.value = 1.0f;
        [_lightSlider setThumbImage:[UIImage imageNamed:@"diy_slider_button"] forState:UIControlStateNormal];
//        [_lightSlider addTarget:self action:@selector(lightChangedEnd:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        [_lightSlider addTarget:self action:@selector(lightChangedEnd:) forControlEvents:UIControlEventValueChanged];
        [_bgToolBar addSubview:_lightSlider];
    }
    return _bgToolBar;
}

- (UIView *)buttonToolBar
{
    if (!_buttonToolBar) {
        _buttonToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, CGRectGetWidth(self.view.bounds), 82.0f)];
        _buttonToolBar.backgroundColor = rgb(13.0f, 17.0f, 43.0f);
        _buttonToolBar.alpha = 0.94f;
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.70f);
        layer.backgroundColor = [UIColor colorWithRed:38 / 255.0f green:44 / 255.0f blue:64 / 255.0f alpha:1.0f].CGColor;
        [_buttonToolBar.layer addSublayer:layer];
        
        UIImageView *opacityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, 28.0f, 26.0f, 26.0f)];
        opacityImageView.image = [UIImage imageNamed:@"diy_icon_opacity"];
        [_buttonToolBar addSubview:opacityImageView];
        
        UISlider *opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(98.0f, 28.0f, self.view.bounds.size.width - 114.0f, 26.0f)];
        opacitySlider.minimumValue = 0.2f;
        opacitySlider.maximumValue = 1.0f;
        opacitySlider.minimumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:1.0f];
        opacitySlider.maximumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:0.3f];
        if (self.diyType != CMDiyTypeDefault) {
            opacitySlider.value = 1.0f;
        }else{
            opacitySlider.value = 0.5f;
        }
        [opacitySlider setThumbImage:[UIImage imageNamed:@"diy_slider_button"] forState:UIControlStateNormal];
//        [opacitySlider addTarget:self action:@selector(opacityChangedEnd:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        [opacitySlider addTarget:self action:@selector(opacityChangedEnd:) forControlEvents:UIControlEventValueChanged];
        self.keyAlphaSlider = opacitySlider;
        [_buttonToolBar addSubview:opacitySlider];
    }
    return _buttonToolBar;
}

- (UIView *)fontsToolBar
{
    if (!_fontsToolBar) {
        _fontsToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, CGRectGetWidth(self.view.bounds), 120.0f)];
        _fontsToolBar.backgroundColor = rgb(13.0f, 17.0f, 43.0f);
        _fontsToolBar.alpha = 0.94f;
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.70f);
        layer.backgroundColor = [UIColor colorWithRed:38 / 255.0f green:44 / 255.0f blue:64 / 255.0f alpha:1.0f].CGColor;
        [_fontsToolBar.layer addSublayer:layer];
        
        UIImageView *textColorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, 26.0f, 26.0f, 26.0f)];
        textColorImageView.image = [UIImage imageNamed:@"diy_icon_textcolor"];
        [_fontsToolBar addSubview:textColorImageView];
        
        UISlider *textColorSlider = [[UISlider alloc] initWithFrame:CGRectMake(84.0f, 26.0f, self.view.bounds.size.width - 100.0f, 26.0f)];
        textColorSlider.minimumValue = 0;
        textColorSlider.maximumValue = 9.0f;
        textColorSlider.minimumTrackTintColor = [UIColor clearColor];
        textColorSlider.maximumTrackTintColor = [UIColor clearColor];
        textColorSlider.value = 0;
        [textColorSlider setThumbImage:[[UIImage imageNamed:@"diy_slider_button"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        [textColorSlider addTarget:self action:@selector(textColorChangedEnd:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        [textColorSlider addTarget:self action:@selector(textColorChangedEnd:) forControlEvents:UIControlEventValueChanged];

        [_fontsToolBar addSubview:textColorSlider];
        
        // 渐变
        CAGradientLayer *textGradientLayer = [CAGradientLayer layer];
        textGradientLayer.colors = self.fontsGradientColor;
        textGradientLayer.locations = @[@0.0, @(1/9.0), @(2/9.0), @(3/9.0), @(4/9.0), @(5/9.0), @(6/9.0), @(7/9.0), @(8/9.0), @1.0];
        textGradientLayer.startPoint = CGPointMake(0, 0);
        textGradientLayer.endPoint = CGPointMake(1.0, 0);
        textGradientLayer.frame = CGRectMake(0.0f, textColorSlider.layer.bounds.size.height / 2 - 3.0f, textColorSlider.layer.bounds.size.width, 6.0f);
        textGradientLayer.cornerRadius = 3.0f;
        [textColorSlider.layer addSublayer:textGradientLayer];
        
        UIImageView *buttonColorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, 68.0f, 26.0f, 26.0f)];
        buttonColorImageView.image = [UIImage imageNamed:@"diy_icon_buttoncolor"];
        [_fontsToolBar addSubview:buttonColorImageView];
        
        UISlider *buttonColorSlider = [[UISlider alloc] initWithFrame:CGRectMake(84.0f, 68.0f, self.view.bounds.size.width - 100.0f, 26.0f)];
        buttonColorSlider.minimumValue = 0;
        buttonColorSlider.maximumValue = 9.0f;
        buttonColorSlider.minimumTrackTintColor = [UIColor clearColor];
        buttonColorSlider.maximumTrackTintColor = [UIColor clearColor];
        buttonColorSlider.value = 0;
        [buttonColorSlider setThumbImage:[[UIImage imageNamed:@"diy_slider_button"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        [buttonColorSlider addTarget:self action:@selector(buttonColorChangedEnd:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        [buttonColorSlider addTarget:self action:@selector(buttonColorChangedEnd:) forControlEvents:UIControlEventValueChanged];

        [_fontsToolBar addSubview:buttonColorSlider];
        
        // 渐变
        CAGradientLayer *buttonGradientLayer = [CAGradientLayer layer];
        buttonGradientLayer.colors = self.fontsGradientColor;
        buttonGradientLayer.locations = @[@0.0, @(1/9.0), @(2/9.0), @(3/9.0), @(4/9.0), @(5/9.0), @(6/9.0), @(7/9.0), @(8/9.0), @1.0];
        buttonGradientLayer.startPoint = CGPointMake(0, 0);
        buttonGradientLayer.endPoint = CGPointMake(1.0, 0);
        buttonGradientLayer.frame = CGRectMake(0.0f, textColorSlider.layer.bounds.size.height / 2 - 3.0f, textColorSlider.layer.bounds.size.width, 6.0f);
        buttonGradientLayer.cornerRadius = 3.0f;
        [buttonColorSlider.layer addSublayer:buttonGradientLayer];
    }
    return _fontsToolBar;
}

-(UIView *)soundToolBar{
    if (!_soundToolBar) {
        _soundToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds), CGRectGetWidth(self.view.bounds), 82.0f)];
        _soundToolBar.backgroundColor = rgb(13.0f, 17.0f, 43.0f);
        _soundToolBar.alpha = 0.94f;
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.70f);
        layer.backgroundColor = [UIColor colorWithRed:38 / 255.0f green:44 / 255.0f blue:64 / 255.0f alpha:1.0f].CGColor;
        [_soundToolBar.layer addSublayer:layer];
        
        UIImageView *soundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, 28.0f, 24.0f, 24.0f)];
        soundImageView.image = [UIImage imageNamed:@"diy_icon_sound"];
        [_soundToolBar addSubview:soundImageView];
        
        UISlider *soundSlider = [[UISlider alloc] initWithFrame:CGRectMake(98.0f, 28.0f, self.view.bounds.size.width - 114.0f, 26.0f)];
        soundSlider.minimumValue = 0.0f;
        soundSlider.maximumValue = 1.0f;
        soundSlider.minimumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:1.0f];
        soundSlider.maximumTrackTintColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:252/255.0 alpha:0.3f];
        soundSlider.value = 1.0f;
        [soundSlider setThumbImage:[UIImage imageNamed:@"diy_slider_button"] forState:UIControlStateNormal];
//        [soundSlider addTarget:self action:@selector(soundVolumeChange:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
        [soundSlider addTarget:self action:@selector(soundVolumeChange:) forControlEvents:UIControlEventValueChanged];
        [_soundToolBar addSubview:soundSlider];
    }
    return _soundToolBar;
}

- (NSArray *)fontsGradientColor
{
    if (!_fontsGradientColor) {
        _fontsGradientColor = @[(__bridge id)rgb(255, 255, 255).CGColor, (__bridge id)rgb(132, 132, 132).CGColor, (__bridge id)rgb(0, 0, 0).CGColor, (__bridge id)rgb(244, 44, 16).CGColor, (__bridge id)rgb(255, 0, 233).CGColor, (__bridge id)rgb(24, 0, 255).CGColor, (__bridge id)rgb(0, 255, 245).CGColor, (__bridge id)rgb(1, 255, 22).CGColor, (__bridge id)rgb(252, 255, 0).CGColor, (__bridge id)rgb(251, 170, 0).CGColor];
    }
    return _fontsGradientColor;
}

- (CMDiySourceViewModel *)bgSourceViewModel
{
    if (!_bgSourceViewModel) {
        _bgSourceViewModel = [CMDiySourceViewModel new];
        _bgSourceViewModel.diySourceType = CMDiySourceTypeBackground;
    }
    return _bgSourceViewModel;
}

- (CMDiySourceViewModel *)buttonSourceViewModel
{
    if (!_buttonSourceViewModel) {
        _buttonSourceViewModel = [[CMDiySourceViewModel alloc] initWithPlist:@"diyButtonStyle"];
        _buttonSourceViewModel.diySourceType = CMDiySourceTypeButton;
        
    }
    return _buttonSourceViewModel;
}

- (CMDiySourceViewModel *)fontsSourceViewModel
{
    if (!_fontsSourceViewModel) {
        _fontsSourceViewModel = [CMDiySourceViewModel new];
        _fontsSourceViewModel.diySourceType = CMDiySourceTypeFonts;
    }
    return _fontsSourceViewModel;
}

-(CMDiySourceViewModel *)soundSourceViewModel{
    if (!_soundSourceViewModel) {
        _soundSourceViewModel = [[CMDiySourceViewModel alloc]init];
        _soundSourceViewModel.diySourceType = CMDiySourceTypeSounds;
    }
    return _soundSourceViewModel;
}

- (NSMutableDictionary<NSString *,CMOfficialOriginalImageModel *> *)officialOriginalImages
{
    if (!_officialOriginalImages) {
        _officialOriginalImages = [NSMutableDictionary dictionary];
    }
    return _officialOriginalImages;
}

- (NSMutableArray<NSURLSessionDownloadTask *> *)downloadTasks
{
    if (!_downloadTasks) {
        _downloadTasks = [NSMutableArray new];
    }
    return _downloadTasks;
}

- (CMCustomThemeAlert *)alertView
{
    if (!_alertView) {
        _alertView = [[CMCustomThemeAlert alloc] init];
    }
    return _alertView;
}

- (void)setInway:(NSInteger)inway
{
    _inway = inway;
    NSInteger xy = 0;
    if (self.diyType == CMDiyTypeDefault) {
        xy = 1;
    }else if (self.diyType == CMDiyTypeDiy) {
        xy = 2;
    }else{
        xy = 3;
    }
    [CMHostInfoc reportCheetahkeyboard_diy:_inway xy:xy];
}

-(NSOperationQueue * )blurOperationQuene{
    if (!_blurOperationQuene) {
        _blurOperationQuene = [[NSOperationQueue alloc]init];
        _blurOperationQuene.maxConcurrentOperationCount = 1;
    }
    return _blurOperationQuene;
}

#pragma mark - load resources
- (void)loadBackgroundSources
{
    if (self.bgSourceViewModel.fetchStatus == CMDiySourceFetchMore) {
        [self.bgCollectionView.mj_header endRefreshing];
        return;
    }
    @weakify(self)
    [self.bgSourceViewModel fetchNetDiySourcesFirstPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [self.bgCollectionView.mj_header endRefreshing];
        
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.bgCollectionView];
            if ([self.bgSourceViewModel numberOfItems] == 0) {
                [self hideErrorRefreshView];
                [self showErrorRefreshViewOnContainerView:self.bgCollectionView];
            }
        }else{
            [self.bgCollectionView reloadData];
            if ([self.bgSelectedId isEqualToString:@"default"]) {
                [self.bgCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else if ([self.bgSelectedId isEqualToString:@"official"]) {
                // do nothing
            }else if ([self.bgSelectedId isEqualToString:@"sys"]) {
                [self.bgCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else{
                NSInteger numberOfItems = [self.bgSourceViewModel numberOfItems];
                for (NSInteger i = 0; i < numberOfItems; i++) {
                    CMDiySourceModel *sourceModel = [self.bgSourceViewModel sourceModelAtIndex:i];
                    if ([sourceModel.sourceId isEqualToString:self.bgSelectedId]) {
                        [self.bgCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:i + 2 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        break;
                    }else if (i == numberOfItems - 1){
                        [self.bgCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        [self diyApplyDefaultBackground];
                    }
                }
            }
            
        }
        
        if (hasMore == NO) {
            [self.bgCollectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.bgCollectionView.mj_footer setState:MJRefreshStateIdle];
        }
    }];
}

- (void)loadMoreBackgroundSources
{
    if (self.bgSourceViewModel.fetchStatus == CMDiySourceFetchNew) {
        [self.bgCollectionView.mj_footer endRefreshing];
        return;
    }
    
    @weakify(self)
    [self.bgSourceViewModel fetchNetDiySourcesNextPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [self.bgCollectionView.mj_footer endRefreshing];
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.bgCollectionView];
        }else{
            if (hasMore == NO) {
                [self.bgCollectionView.mj_footer endRefreshingWithNoMoreData];
            }
            NSIndexPath *selectedPath = self.bgCollectionView.indexPathsForSelectedItems.firstObject;
            [self.bgCollectionView reloadData];
            [self.bgCollectionView selectItemAtIndexPath:selectedPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

- (void)loadFontsSources
{
    if (self.fontsSourceViewModel.fetchStatus == CMDiySourceFetchMore) {
        [self.fontsCollectionView.mj_header endRefreshing];
        return;
    }
    
    @weakify(self)
    [self.fontsSourceViewModel fetchNetDiySourcesFirstPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [self.fontsCollectionView.mj_header endRefreshing];
        
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.fontsCollectionView];
            if (self.fontsSourceViewModel.numberOfItems == 0) {
                [self hideErrorRefreshView];
                [self showErrorRefreshViewOnContainerView:self.fontsCollectionView];
            }
        }else{
            [self.fontsCollectionView reloadData];
            
            if ([self.fontsSelectedId isEqualToString:@"sys"]) {
                [self.fontsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                [kCMKeyboardManager.themeManager setStandardDirFont:nil];
                [self.diyKeyboardView switchTheme];
            }else if ([self.fontsSelectedId isEqualToString:@"official"]) {
                // do nothing
            }else{
                NSInteger numberOfItems = [self.fontsSourceViewModel numberOfItems];
                for (NSInteger i = 0; i < numberOfItems; i++) {
                    CMDiySourceModel *sourceModel = [self.fontsSourceViewModel sourceModelAtIndex:i];
                    if ([sourceModel.sourceId isEqualToString:self.fontsSelectedId]) {
                        [self.fontsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        break;
                    }else if (i == numberOfItems - 1){
                        [self.fontsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//                        [kCMKeyboardManager.themeManager setFont:nil forKeyPath:@"viewAttr.keyTextFontName"];
                        [kCMKeyboardManager.themeManager setStandardDirFont:nil];
                        [self.diyKeyboardView switchTheme];
                        self.fontsSelectedId = @"sys";
                    }
                }
            }
            self.lastFontIndexPath = self.fontsCollectionView.indexPathsForSelectedItems.firstObject;
        }
        
        if (hasMore == NO) {
            [self.fontsCollectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.fontsCollectionView.mj_footer setState:MJRefreshStateIdle];
        }
    }];
}

- (void)loadMoreFontsSources
{
    if (self.fontsSourceViewModel.fetchStatus == CMDiySourceFetchMore) {
        [self.fontsCollectionView.mj_footer endRefreshing];
        return;
    }
    
    @weakify(self)
    [self.fontsSourceViewModel fetchNetDiySourcesNextPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [self.fontsCollectionView.mj_footer endRefreshing];
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.bgCollectionView];
        }else{
            if (hasMore == NO) {
                [self.fontsCollectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
            NSIndexPath *selectedPath = self.fontsCollectionView.indexPathsForSelectedItems.firstObject;
            [self.fontsCollectionView reloadData];
            [self.fontsCollectionView selectItemAtIndexPath:selectedPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

-(void)loadSoundResources{
    if (self.soundSourceViewModel.fetchStatus == CMDiySourceFetchMore) {
        [self.soundCollectionView.mj_header endRefreshing];
        return;
    }
    
    @weakify(self);
    [self.soundSourceViewModel fetchNetDiySourcesFirstPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [self.soundCollectionView.mj_header endRefreshing];

        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.bgCollectionView];
            if ([self.soundSourceViewModel numberOfItems] == 0) {
                [self hideErrorRefreshView];
                [self showErrorRefreshViewOnContainerView:self.soundCollectionView];
            }
        }else{
            [self.soundCollectionView reloadData];
            
            if ([self.soundSelectedId isEqualToString:@"non"]) {
                [self.soundCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UICollectionViewScrollPositionNone];
            }else if ([self.soundSelectedId isEqualToString:@"official"]) {
                // do nothing
            }else{
                NSInteger numberOfItems= [self.soundSourceViewModel numberOfItems];
                for (NSInteger i = 0; i < numberOfItems; i ++) {
                    CMDiySourceModel *sourceModel = [self.soundSourceViewModel sourceModelAtIndex:i];
                    if ([sourceModel.sourceId isEqualToString:self.soundSelectedId]) {
                        [self.soundCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        break;
                    }else if (i == numberOfItems - 1){
                        [self.soundCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        [kCMKeyboardManager.themeManager setStandardDirSound:nil];
//                        [self.diyKeyboardView switchTheme];
                        self.soundSelectedId = @"non";
                    }
                }
            }
            self.lastSoundIndexPath = self.soundCollectionView.indexPathsForSelectedItems.firstObject;
        }
        
        if (hasMore == NO) {
            [self.soundCollectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.soundCollectionView.mj_footer setState:MJRefreshStateIdle];
        }
    }];
}

-(void)loadMoreSoundResources{
    if (self.soundSourceViewModel.fetchStatus == CMDiySourceFetchMore) {
        [self.soundCollectionView.mj_footer endRefreshing];
        return;
    }
    @weakify(self);
    [self.soundSourceViewModel fetchNetDiySourcesNextPageWithBlock:^(CMError *errorMsg, BOOL hasMore) {
        @stronglize(self);
        [self.soundCollectionView.mj_footer endRefreshing];
        if (errorMsg) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.bgCollectionView];
        }else{
            if (hasMore == NO) {
                [self.soundCollectionView.mj_footer endRefreshingWithNoMoreData];
            }else{
                NSIndexPath *selectedPath = self.soundCollectionView.indexPathsForSelectedItems.firstObject;
                [self.soundCollectionView reloadData];
                [self.soundCollectionView selectItemAtIndexPath:selectedPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    }];

}

#pragma mark - get diy resource
- (void)getDiyResourceWithURL:(NSString *)url diySourceType:(CMDiySourceType)diySourceType sourceModel:(CMDiySourceModel *)sourceModel indexPath:(NSIndexPath *)indexPath completeBlock:(GetDiyResourceComplete)complete
{
    NSURL *filePath = nil;
    NSString *fileName = nil;
    if (diySourceType == CMDiySourceTypeBackground) {
        filePath = [NSURL fileURLWithPath:[CMDirectoryHelper diyBackgroundResourceDir]];
        if ([url hasPrefix:@"http://files-keyboard.cmcm.com/diy/bg/"]) {
            fileName = [url substringFromIndex:44];
        }else{
            fileName = url;
        }
        fileName = [sourceModel.sourceId stringByAppendingFormat:@"_%@", [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    }else if (diySourceType == CMDiySourceTypeFonts) {
//        filePath = [NSURL fileURLWithPath:[CMDirectoryHelper diyFontsResourceDir]];
        filePath = [kCMGroupDataManager ThemeFontPath];
        if ([url hasPrefix:@"http://files-keyboard.cmcm.com/diy/fonts/src/"]) {
            fileName = [url lastPathComponent];
        }else{
            fileName = url;
        }
    }else if (diySourceType == CMDiySourceTypeSounds){
        filePath = [NSURL fileURLWithPath:[CMDirectoryHelper diySoundResourceDir]];
        if ([url hasPrefix:@"http://files-keyboard.cmcm.com/diy/sounds/src/"]) {
            fileName = [url lastPathComponent];
        }else{
            fileName = url;
        }
    }
    
    
    filePath = [filePath URLByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
        complete(filePath.path);
    }else{
        if (!sourceModel.isFetching) {
            sourceModel.isFetching = YES;
            @weakify(self)
            [self downloadDiyResourceWithURL:url targetFile:filePath diySourceType:diySourceType indexPath:indexPath complete:^(NSString *filePath) {
                @stronglize(self)
                sourceModel.isFetching = NO;
                complete(filePath);
            }];
        }
    }
}

- (void)downloadDiyResourceWithURL:(NSString *)url targetFile:(NSURL *)filePath diySourceType:(CMDiySourceType)diySourceType indexPath:(NSIndexPath *)indexPath complete:(GetDiyResourceComplete)complete
{
    __block CGFloat fakeProgress = 0.1f;
    [self drawProgressCircle:fakeProgress indexPath:indexPath diySourceType:diySourceType];

    NSURLSessionDownloadTask *task = [CMRequestFactory downloadDiyResourceRequestWithURL:url targetFilePath:filePath progressBlock:^(NSProgress *downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 下载进度小于80%时，显示假的进度条（为了让用户感觉下载速度很快）
            CGFloat progress = downloadProgress.fractionCompleted;
            if (downloadProgress.fractionCompleted < 0.8) {
                if (fakeProgress < 0.8) {
                    fakeProgress += 0.1;
                    progress = fakeProgress;
                }else{
                    progress = 0.8;
                }
            }
            [self drawProgressCircle:progress indexPath:indexPath diySourceType:diySourceType];
        });
    } completeBlock:^(NSURLResponse *response, NSURL *filePath, CMError *error) {
        if (error) {
            [self showErrorTipWithIcon:@"icon_warning" errorMessage:CMLocalizedString(@"Net_Error", nil) containerView:self.bgCollectionView];
            if (diySourceType == CMDiySourceTypeBackground) {
                [self.bgCollectionView selectItemAtIndexPath:self.lastBgIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else if (diySourceType == CMDiySourceTypeFonts) {
                [self.fontsCollectionView selectItemAtIndexPath:self.lastFontIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else if (diySourceType == CMDiySourceTypeSounds){
                [self.soundCollectionView selectItemAtIndexPath:self.lastSoundIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }else{
            complete(filePath.path);
        }
    }];
    
    [self.downloadTasks addObject:task];
    [task resume];
}

- (void)drawProgressCircle:(double)downloadProgress indexPath:(NSIndexPath *)indexPath diySourceType:(CMDiySourceType)diySourceType
{
    CMDiySourceCollectionCell *cell = nil;
    if (diySourceType == CMDiySourceTypeBackground) {
        cell = (CMDiySourceCollectionCell *)[self.bgCollectionView cellForItemAtIndexPath:indexPath];
    }else if (diySourceType == CMDiySourceTypeFonts) {
        cell = (CMDiySourceCollectionCell *)[self.fontsCollectionView cellForItemAtIndexPath:indexPath];
    }else if (diySourceType == CMDiySourceTypeSounds){
        cell = (CMDiySourceCollectionCell*)[self.soundCollectionView cellForItemAtIndexPath:indexPath];
    }
    else{
        return;
    }
    
    CGFloat endAngle = 360 * downloadProgress - 90.0f;
    if (endAngle >= 270) {
        endAngle = -90;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(cell.progressLayer.bounds.size.width / 2, cell.progressLayer.bounds.size.height / 2) radius:cell.progressLayer.bounds.size.width / 2 - 8.0f startAngle:(M_PI * (-90) / 180.0) endAngle:(M_PI * endAngle / 180.0) clockwise:YES];
    cell.progressLayer.path = path.CGPath;
}

#pragma mark - segment changed
- (void)changedSegment
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            if (self.bgToolBar.tag != ToolbarTag) {
                [self showToolBar];
            }
            [self.diyKeyboardView bindData: nil];
            if (self.bgSourceViewModel.numberOfItems == 0) {
                @weakify(self)
                [self.bgSourceViewModel loadLocalSourcesWithBlock:^(CMError *errorMsg, BOOL hasMore) {
                    @stronglize(self);
                    if (!errorMsg) {
                        [self.bgCollectionView reloadData];
                        if (self.diyType == CMDiyTypeDefault) {
                            [self.bgCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    }
                    [self.bgCollectionView.mj_header beginRefreshing];
                }];
            }
            self.bgToolBar.hidden = NO;
            self.buttonToolBar.hidden = YES;
            self.fontsToolBar.hidden = YES;
            self.soundToolBar.hidden = YES;
        }
            break;
        case 1:
            if (self.buttonToolBar.tag != ToolbarTag) {
                [self showToolBar];
            }
            [self.diyKeyboardView bindData: nil];
            self.bgToolBar.hidden = YES;
            self.buttonToolBar.hidden = NO;
            self.fontsToolBar.hidden = YES;
            self.soundToolBar.hidden = YES;
            break;
        case 2:
            {
                if (self.fontsToolBar.tag != ToolbarTag) {
                    [self showToolBar];
                }
                [self.diyKeyboardView bindData: @[@"Cheetah",@"Keyboard",@"Type",@"Less",@"Say",@"More"]];
                if ([self.fontsSourceViewModel numberOfItems] == 0) {
                    @weakify(self)
                    [self.fontsSourceViewModel loadLocalSourcesWithBlock:^(CMError *errorMsg, BOOL hasMore) {
                        @stronglize(self);
                        if (!errorMsg) {
                            [self.fontsCollectionView reloadData];
                            if (self.diyType == CMDiyTypeDefault) {
                                [self.fontsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                            }
                        }
                        [self.fontsCollectionView.mj_header beginRefreshing];
                    }];
                }
            }
            self.bgToolBar.hidden = YES;
            self.buttonToolBar.hidden = YES;
            self.fontsToolBar.hidden = NO;
            self.soundToolBar.hidden = YES;
            break;
        case 3:
            if (self.soundToolBar.tag != ToolbarTag) {
                [self showToolBar];
            }
            [self.diyKeyboardView bindData: nil];
            
            if (self.soundSourceViewModel.numberOfItems == 0) {
                @weakify(self)
                [self.soundSourceViewModel loadLocalSourcesWithBlock:^(CMError *errorMsg, BOOL hasMore) {
                    @stronglize(self);
                    if (!errorMsg) {
                        [self.soundCollectionView reloadData];
                        if (self.diyType == CMDiyTypeDefault) {
                            [self.soundCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    }
                    [self.soundCollectionView.mj_header beginRefreshing];
                }];
            }
            
            self.bgToolBar.hidden = YES;
            self.buttonToolBar.hidden = YES;
            self.fontsToolBar.hidden = YES;
            self.soundToolBar.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - show toobar
- (void)showToolBar
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            if (self.bgToolBar.frame.origin.y >= self.view.frame.size.height) {
                if (self.bgCollectionView.indexPathsForSelectedItems.count > 0) {
                    NSIndexPath *selectdIndexPath = self.bgCollectionView.indexPathsForSelectedItems.firstObject;
                    CGRect frame = [self.bgCollectionView cellForItemAtIndexPath:selectdIndexPath].frame;
                    CGPoint point = [self.bgCollectionView convertPoint:frame.origin toView:self.view];
                    if (point.y > self.view.frame.size.height - self.bgToolBar.frame.size.height - frame.size.height) {
                        CGFloat moveUpDistance = point.y - self.view.frame.size.height + self.bgToolBar.frame.size.height + frame.size.height;
                        CGPoint contentOffset = self.bgCollectionView.contentOffset;
                        [self.bgCollectionView setContentOffset:CGPointMake(contentOffset.x, contentOffset.y + moveUpDistance) animated:YES];
                    }
                }
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect rect = self.bgToolBar.frame;
                    rect.origin.y -= rect.size.height;
                    self.bgToolBar.frame = rect;
                }completion:^(BOOL finished) {
                    self.bgToolBar.tag = ToolbarTag;
                }];
            }
            break;
        case 1:
            if (self.buttonToolBar.frame.origin.y >= self.view.frame.size.height) {
                if (self.buttonCollectionView.indexPathsForSelectedItems.count > 0) {
                    NSIndexPath *selectdIndexPath = self.buttonCollectionView.indexPathsForSelectedItems.firstObject;
                    CGRect frame = [self.buttonCollectionView cellForItemAtIndexPath:selectdIndexPath].frame;
                    CGPoint point = [self.buttonCollectionView convertPoint:frame.origin toView:self.view];
                    if (point.y > self.view.frame.size.height - self.buttonToolBar.frame.size.height - frame.size.height) {
                        CGFloat moveUpDistance = point.y - self.view.frame.size.height + self.buttonToolBar.frame.size.height + frame.size.height;
                        CGPoint contentOffset = self.buttonCollectionView.contentOffset;
                        [self.buttonCollectionView setContentOffset:CGPointMake(contentOffset.x, contentOffset.y + moveUpDistance) animated:YES];
                    }
                }
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect rect = self.buttonToolBar.frame;
                    rect.origin.y -= rect.size.height;
                    self.buttonToolBar.frame = rect;
                }completion:^(BOOL finished) {
                    self.buttonToolBar.tag = ToolbarTag;
                }];
            }
            break;
        case 2:
            if (self.fontsToolBar.frame.origin.y >= self.view.frame.size.height) {
                if (self.fontsCollectionView.indexPathsForSelectedItems.count > 0) {
                    NSIndexPath *selectdIndexPath = self.fontsCollectionView.indexPathsForSelectedItems.firstObject;
                    CGRect frame = [self.fontsCollectionView cellForItemAtIndexPath:selectdIndexPath].frame;
                    CGPoint point = [self.fontsCollectionView convertPoint:frame.origin toView:self.view];
                    if (point.y > self.view.frame.size.height - self.fontsToolBar.frame.size.height - frame.size.height) {
                        CGFloat moveUpDistance = point.y - self.view.frame.size.height + self.fontsToolBar.frame.size.height + frame.size.height;
                        CGPoint contentOffset = self.fontsCollectionView.contentOffset;
                        [self.fontsCollectionView setContentOffset:CGPointMake(contentOffset.x, contentOffset.y + moveUpDistance) animated:YES];
                    }
                }
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect rect = self.fontsToolBar.frame;
                    rect.origin.y -= rect.size.height;
                    self.fontsToolBar.frame = rect;
                }completion:^(BOOL finished) {
                    self.fontsToolBar.tag = ToolbarTag;
                }];
            }

            break;
            
        case 3:
            if (self.soundToolBar.frame.origin.y >= self.view.frame.size.height) {
                if (self.soundCollectionView.indexPathsForSelectedItems.count > 0) {
                    NSIndexPath *selectdIndexPath = self.soundCollectionView.indexPathsForSelectedItems.firstObject;
                    CGRect frame = [self.soundCollectionView cellForItemAtIndexPath:selectdIndexPath].frame;
                    CGPoint point = [self.soundCollectionView convertPoint:frame.origin toView:self.view];
                    if (point.y > self.view.frame.size.height - self.soundToolBar.frame.size.height - frame.size.height) {
                        CGFloat moveUpDistance = point.y - self.view.frame.size.height + self.soundToolBar.frame.size.height + frame.size.height;
                        CGPoint contentOffset = self.soundCollectionView.contentOffset;
                        [self.soundCollectionView setContentOffset:CGPointMake(contentOffset.x, contentOffset.y + moveUpDistance) animated:YES];
                    }
                }
                
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect rect = self.soundToolBar.frame;
                    rect.origin.y -= rect.size.height;
                    self.soundToolBar.frame = rect;
                } completion:^(BOOL finished) {
                    self.soundToolBar.tag = ToolbarTag;
                }];
            }
    
            break;
        default:
            break;
    }
}

#pragma mark - private method
-(void)openThePhotoAlbum{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusDenied) {
        //明确拒绝
        self.alertView = [[CMCustomThemeAlert alloc] init];
        [self.alertView showAlertWithTitle:CMLocalizedString(@"Allow access to your photos to customize themes with CheetahKey?", nil) confirmTitle:CMLocalizedString(@"OK", nil) andCancelTitle:CMLocalizedString(@"Cancel", nil)];//CMLocalizedString(@"Cancel", nil)
        self.alertView.confirmBlock = ^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        };
        
    }else{
        CMImagePickerController *pickerVC = [[CMImagePickerController alloc]initWithCropImageColumnNumber:0 delegate:self pushPhotoPicker:true];
        [self.navigationController presentViewController:pickerVC animated:true completion:nil];
    }
    
}

-(void)refreshKeyboardBackgroundIamge:(UIImage *)image{
    if (!image) {
        return;
    }
    [kCMKeyboardManager.themeManager setKeyboardViewBgImage:nil];
    [kCMKeyboardManager.themeManager setPredictViewBgImage:nil];
    kCMKeyboardManager.themeManager.wholeBoardBgImage = image;
    [self.diyKeyboardView switchTheme];
    
}

-(void)changeBKImageBlurAlpha{

    if (!_originalBKImage) {
        return;
    }
    [self.blurOperationQuene cancelAllOperations];
    //创建操作
    CGFloat blurValue = 1.0f - _blurSlider.value;
    CGFloat lightValue = _lightSlider.value -1.0;
    if (lightValue > 0.0f) {
        lightValue = lightValue * 0.2;
    }
    NSBlockOperation *blurOption = [NSBlockOperation blockOperationWithBlock:^{
        kLogInfo(@"[Thread] current thread = %@,light value : %f,blurValue : %f", [NSThread currentThread],lightValue,lightValue);
        [UIImage applyBlurImage:_originalBKImage blur:blurValue light:lightValue completion:^(UIImage *image) {
            if (image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [self refreshKeyboardBackgroundIamge:image];
                }];
            }
        }];
    }];
    [self.blurOperationQuene addOperation:blurOption];
}

-(void)changeKeyBgImageAlpha{
    //修改key背景图
    if (!self.originalKeyBgImage) {
        return;
    }
    [self.blurOperationQuene cancelAllOperations];
    CGFloat alphaVlaue = self.keyAlphaSlider.value;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        kLogInfo(@"[Thread] current thread = %@", [NSThread currentThread]);
        [UIImage applyAlphaImage:self.originalKeyBgImage alpha:alphaVlaue completion:^(UIImage *image) {
            if (image) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.letterKeyNormalBgImage = image;
                    kCMKeyboardManager.themeManager.funcKeyNormalBgImage = image;
                    kCMKeyboardManager.themeManager.spaceKeyNormalBgImage = image;
                    [kCMKeyboardManager.themeManager setPreInputBgImage:image];
                    kCMKeyboardManager.themeManager.letterKeyHighlightBgImage = nil;
                    kCMKeyboardManager.themeManager.funcKeyHighlightBgImage = nil;
                    kCMKeyboardManager.themeManager.spaceKeyHighlightBgImage = nil;
                    
                    kCMKeyboardManager.themeManager.inputOptionBgImage = image;

                    if (self.keyAlphaSlider.value >= 0.2) {
                        kCMKeyboardManager.themeManager.inputOptionBgImage = image;
                        kCMKeyboardManager.themeManager.inputOptionHighlightBgImage = nil;
                        if (!CGColorEqualToColor(kCMKeyboardManager.themeManager.inputOptionTextColor.CGColor, kCMKeyboardManager.themeManager.letterKeyTextColor.CGColor)) {
                            NSString *colorStr = [UIColor hexValuesFromUIColor:kCMKeyboardManager.themeManager.letterKeyTextColor];
                            [kCMKeyboardManager.themeManager inputOptionTextColorHexString:colorStr];
                            [kCMKeyboardManager.themeManager inputOptionHighlightTextColorHexString:colorStr];
                            [kCMKeyboardManager.themeManager setInputOptionHighlightBgImage:[kCMKeyboardManager.themeManager.inputOptionHighlightBgImage imageWithTintColor:kCMKeyboardManager.themeManager.letterKeyTextColor]];
                        }
                    }
                    [self.diyKeyboardView switchTheme];
                }];
            }
        }];
    }];
    
    [self.blurOperationQuene addOperation:operation];

}


#pragma mark - Toolbar Action
- (void)blurChangedEnd:(UISlider *)slider
{
    [self changeBKImageBlurAlpha];
}

- (void)lightChangedEnd:(UISlider *)slider
{
    [self changeBKImageBlurAlpha];
}

- (void)opacityChangedEnd:(UISlider *)slider
{
    self.keyAlphaSlider.tag = KeyAlphaSliderTag;
    
    [self.blurOperationQuene cancelAllOperations];

    if (self.diyType != CMDiyTypeDefault && self.buttonCollectionView.indexPathsForSelectedItems.count == 0) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [UIImage applyAlphaImage:self.officialOriginalImages[@"letterKeyNormalBgImage"].image isNinePatch:self.officialOriginalImages[@"letterKeyNormalBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.letterKeyNormalBgImage = image;
                }];
            }];
            [UIImage applyAlphaImage:self.officialOriginalImages[@"spaceKeyNormalBgImage"].image isNinePatch:self.officialOriginalImages[@"spaceKeyNormalBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.spaceKeyNormalBgImage = image;
                }];
            }];
            [UIImage applyAlphaImage:self.officialOriginalImages[@"funcKeyNormalBgImage"].image isNinePatch:self.officialOriginalImages[@"funcKeyNormalBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.funcKeyNormalBgImage = image;
                    [self.diyKeyboardView switchTheme];
                }];
            }];
            
            [UIImage applyAlphaImage:self.officialOriginalImages[@"letterKeyHighlightBgImage"].image isNinePatch:self.officialOriginalImages[@"letterKeyHighlightBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.letterKeyHighlightBgImage = image;
                }];
            }];
            
            [UIImage applyAlphaImage:self.officialOriginalImages[@"funcKeyHighlightBgImage"].image isNinePatch:self.officialOriginalImages[@"funcKeyHighlightBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.funcKeyHighlightBgImage = image;
                }];
            }];
            
            [UIImage applyAlphaImage:self.officialOriginalImages[@"spaceKeyHighlightBgImage"].image isNinePatch:self.officialOriginalImages[@"spaceKeyHighlightBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.spaceKeyHighlightBgImage = image;
                }];
            }];
            
            [UIImage applyAlphaImage:self.officialOriginalImages[@"preInputBgImage"].image isNinePatch:self.officialOriginalImages[@"preInputBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.preInputBgImage = image;
                }];
            }];
                                       
            [UIImage applyAlphaImage:self.officialOriginalImages[@"inputOptionBgImage"].image isNinePatch:self.officialOriginalImages[@"inputOptionBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.inputOptionBgImage = image;
                }];
            }];
                                       
            [UIImage applyAlphaImage:self.officialOriginalImages[@"inputOptionHighlightBgImage"].image isNinePatch:self.officialOriginalImages[@"inputOptionHighlightBgImage"].isNinePatch alpha:slider.value completion:^(UIImage *image) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    kCMKeyboardManager.themeManager.inputOptionHighlightBgImage = image;
                    [self.diyKeyboardView switchTheme];
                }];
            }];
        }];
        [self.blurOperationQuene addOperation:operation];
        return;
    }
    
    if (!self.originalKeyBgImage) {
        return;
    }

    CGFloat alphaVlaue = self.keyAlphaSlider.value;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [UIImage applyAlphaImage:self.originalKeyBgImage alpha:alphaVlaue  completion:^(UIImage *image) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                if (image) {
                    kCMKeyboardManager.themeManager.letterKeyNormalBgImage = image;
                    kCMKeyboardManager.themeManager.funcKeyNormalBgImage = image;
                    kCMKeyboardManager.themeManager.spaceKeyNormalBgImage = image;
                    [kCMKeyboardManager.themeManager setPreInputBgImage:image];
                    kCMKeyboardManager.themeManager.letterKeyHighlightBgImage = nil;
                    kCMKeyboardManager.themeManager.funcKeyHighlightBgImage = nil;
                    kCMKeyboardManager.themeManager.spaceKeyHighlightBgImage = nil;
                    kCMKeyboardManager.themeManager.inputOptionBgImage = image;
                    NSString *colorStr = [UIColor hexValuesFromUIColor:kCMKeyboardManager.themeManager.letterKeyTextColor];
                    [kCMKeyboardManager.themeManager inputOptionTextColorHexString:colorStr];
                    [kCMKeyboardManager.themeManager inputOptionHighlightTextColorHexString:colorStr];
                    [kCMKeyboardManager.themeManager setInputOptionHighlightBgImage:[kCMKeyboardManager.themeManager.inputOptionHighlightBgImage imageWithTintColor:kCMKeyboardManager.themeManager.letterKeyTextColor]];
                    [self.diyKeyboardView switchTheme];
                }
            }];
        }];
    }];
    [self.blurOperationQuene addOperation:operation];
}

- (void)buttonColorChangedEnd:(UISlider *)slider
{
    NSInteger colorStartIndex = (NSInteger)floorf(slider.value);
    if (colorStartIndex == 9) {
        colorStartIndex = 8;
    }
    long colorInteger = [CMCommUtil evaluate:slider.value - colorStartIndex
                                       startColor:(__bridge CGColorRef _Nonnull)(self.fontsGradientColor[colorStartIndex])
                                         endColor:(__bridge CGColorRef _Nonnull)(self.fontsGradientColor[colorStartIndex + 1])];
    NSString *hexString = [NSString getHexByDecimal:colorInteger];
    [kCMKeyboardManager.themeManager funcKeyTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager letterKeyTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager letterKeyHighlightTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager spaceKeyTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager keyHintTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager inputOptionTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager inputOptionHighlightTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager preInputTextColorHexString:hexString];
    
    [kCMKeyboardManager.themeManager setInputOptionHighlightBgImage:[kCMKeyboardManager.themeManager.inputOptionHighlightBgImage imageWithTintColor:[UIColor colorWithHexString:hexString]]];

    if (!kCMKeyboardManager.themeManager.letterKeyNormalBgImage) {
        if ([hexString isEqualToString:@"FFFFFF"]) {
            [kCMKeyboardManager.themeManager inputOptionTextColorHexString:@"000000"];
            [kCMKeyboardManager.themeManager inputOptionHighlightTextColorHexString:@"000000"];
            [kCMKeyboardManager.themeManager setInputOptionHighlightBgImage:[kCMKeyboardManager.themeManager.inputOptionHighlightBgImage imageWithTintColor:[UIColor colorWithHexString:@"000000"]]];
        }
        
        [kCMKeyboardManager.themeManager setColor:@"FFFFFF" forKeyPath:@"imageAttr.inputOptionViewBackgroundColor"];

        kCMKeyboardManager.themeManager.inputOptionBgImage = nil;
        kCMKeyboardManager.themeManager.inputOptionHighlightBgImage = nil;
    }
    
    
    [self.diyKeyboardView switchTheme];
}

- (void)textColorChangedEnd:(UISlider *)slider
{
    NSInteger colorStartIndex = (NSInteger)floorf(slider.value);
    if (colorStartIndex == 9) {
        colorStartIndex = 8;
    }
    long colorInteger = [CMCommUtil evaluate:slider.value - colorStartIndex
                                  startColor:(__bridge CGColorRef _Nonnull)(self.fontsGradientColor[colorStartIndex])
                                    endColor:(__bridge CGColorRef _Nonnull)(self.fontsGradientColor[colorStartIndex + 1])];
    NSString *hexString = [NSString getHexByDecimal:colorInteger];
    [kCMKeyboardManager.themeManager dismissBtnTintColorHexString:hexString];
    [kCMKeyboardManager.themeManager tintColorHexString:hexString];
    [kCMKeyboardManager.themeManager predictCellTextColorHexString:hexString];
    [kCMKeyboardManager.themeManager predictCellEmphasizeTextColorHexString:hexString];
    [self.diyKeyboardView switchTheme];
    
}

-(void)soundVolumeChange:(UISlider *)slider{
    kCMGroupDataManager.volume = slider.value;
}

#pragma mark - apply sound
-(void)diyApplySound:(NSIndexPath *)indexPath{
    
    CMDiySourceModel *sourceModel = [self.soundSourceViewModel sourceModelAtIndex:indexPath.item - 1];
    if ([sourceModel.sourceId isEqualToString:self.soundSelectedId]) {
        return;
    }
    self.soundSelectedId = sourceModel.sourceId;
    self.lastSoundIndexPath = indexPath;
    
//    NSString *archSoundPath = [[CMDirectoryHelper diySoundResourceDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",sourceModel.sourceId]];
    
    NSString *archSoundPath = [kCMGroupDataManager.ThemeSoundPath.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",sourceModel.sourceId]];

    if ([CMDirectoryHelper fileExists:archSoundPath]) {
        [kCMKeyboardManager.themeManager setStandardDirSound:archSoundPath];
    }else{
        @weakify(self);
        [self getDiyResourceWithURL:sourceModel.download_url diySourceType:CMDiySourceTypeSounds sourceModel:sourceModel indexPath:indexPath completeBlock:^(NSString *filePath) {
            //改变音效
            @stronglize(self);
            [SSZipArchive unzipFileAtPath:filePath toDestination:archSoundPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                
            } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                
                NSIndexPath *selectedIndexPath = self.soundCollectionView.indexPathsForSelectedItems.firstObject;
                if ([indexPath isEqual:selectedIndexPath]) {
                    if (!error && succeeded) {
                        kLog(@"音效解压成功,path:%@",path);
                        [kCMKeyboardManager.themeManager setStandardDirSound:archSoundPath];
                    }else{
                        kLog(@"音效解压失败,path:%@",path);
                    }
                    [self showToolBar];
                }        
            }];
            
        }];
    }
}

#pragma mark - apply background
- (void)diyApplyBackground:(NSIndexPath *)indexPath
{
    CMDiySourceModel *sourceModel = [self.bgSourceViewModel sourceModelAtIndex:indexPath.row - 2];
    if ([sourceModel.sourceId isEqualToString:self.bgSelectedId]) {
        return;
    }
    self.lastBgIndexPath = indexPath;
    
    @weakify(self)
    [self getDiyResourceWithURL:sourceModel.download_url diySourceType:CMDiySourceTypeBackground sourceModel:sourceModel indexPath:indexPath completeBlock:^(NSString *filePath){
        @stronglize(self);
        NSIndexPath *selectedIndexPath = self.bgCollectionView.indexPathsForSelectedItems.firstObject;
        if ([indexPath isEqual:selectedIndexPath]) {
            self.originalBKImage = [UIImage imageWithContentsOfFile:filePath];
            if (self.lightSlider.value != 1.0 || self.blurSlider.value != 1.0f ) {
                [self changeBKImageBlurAlpha];
            }else{
                [kCMKeyboardManager.themeManager setKeyboardViewBgImage:nil];
                [kCMKeyboardManager.themeManager setPredictViewBgImage:nil];
                [kCMKeyboardManager.themeManager wholeBoardBgImagePath:filePath];
                [self.diyKeyboardView switchTheme];
            }
            self.bgSelectedId = sourceModel.sourceId;
            [self showToolBar];
        }
    }];
}

- (void)diyApplyDefaultBackground
{
    self.bgSelectedId = @"default";
    self.lastBgIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    self.originalBKImage = [UIImage imageNamed:@"diy_defaultwhole_keyboard_background"];
    if (self.lightSlider.value < 1.0f || self.blurSlider.value < 1.0f ) {
        [self changeBKImageBlurAlpha];
    }else{
        [kCMKeyboardManager.themeManager setKeyboardViewBgImage:nil];
        [kCMKeyboardManager.themeManager setPredictViewBgImage:nil];
        kCMKeyboardManager.themeManager.wholeBoardBgImage = self.originalBKImage;
        [self.diyKeyboardView switchTheme];
    }
}

#pragma mark - apply key background
- (void)diyApplyKeyBackground:(NSIndexPath *)indexPath {
    CMDiySourceModel *sourceModel = [self.buttonSourceViewModel sourceModelAtIndex:indexPath.row - 1];
    if ([self.keyBgSelectedId isEqualToString:sourceModel.sourceId]) {
        return;
    }
    self.keyBgSelectedId = sourceModel.sourceId;

    self.originalKeyBgImage = [UIImage imageWithContentsOfFile:sourceModel.download_url];
    if (self.originalKeyBgImage) {
        [self changeKeyBgImageAlpha];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.bgCollectionView) {
        return [self.bgSourceViewModel numberOfItems] + 2;
    }else if (collectionView == self.buttonCollectionView) {
        return [self.buttonSourceViewModel numberOfItems] + 1;
    }else if (collectionView == self.fontsCollectionView) {
        return [self.fontsSourceViewModel numberOfItems] + 1;
    }else if (collectionView == self.soundCollectionView){
        return [self.soundSourceViewModel numberOfItems] + 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMDiySourceCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMDiySourceCollectionCell class]) forIndexPath:indexPath];
    CMDiySourceModel *sourceModel = nil;
    if (collectionView == self.bgCollectionView) {
        if (indexPath.row == 0) {
            [cell setCoverImage:[UIImage imageNamed:@"diy_bg_default_icon"]];
        }else if (indexPath.row == 1) {
            [cell setCoverImage:[UIImage imageNamed:@"diy_bg_default"]];
        }else{
            sourceModel = [self.bgSourceViewModel sourceModelAtIndex:indexPath.row - 2];
        }
    }else if (collectionView == self.buttonCollectionView) {
        if (indexPath.row == 0) {
            [cell setCoverImage:[UIImage imageNamed:@"diy_default_icon"]];
        }else{
            [cell setCoverImage:[UIImage imageNamed:[NSString stringWithFormat:@"diy_button_cover%ld", (long)indexPath.row]]];
        }
    }else if (collectionView == self.fontsCollectionView) {
        if (indexPath.row == 0) {
            [cell setCoverImage:[UIImage imageNamed:@"diy_default_icon"]];
        }else{
            sourceModel = [self.fontsSourceViewModel sourceModelAtIndex:indexPath.row - 1];
        }
    }else if (collectionView == self.soundCollectionView){
        if (indexPath.row == 0) {
            [cell setCoverImage:[UIImage imageNamed:@"diy_default_icon"]];
        }else{
            sourceModel = [self.soundSourceViewModel sourceModelAtIndex:indexPath.row - 1];
        }
    }
    [cell bindingDiySourceModel:sourceModel];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(58.0f, 58.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(16.0f, 18.0f, 16.0f, 18.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.bgCollectionView) {
        if (indexPath.row == 0) {
            [self showToolBar];
            // 打开相册
            [self openThePhotoAlbum];
        }else if (indexPath.row == 1) {
            [self showToolBar];
            // 应用默认背景
            if (![self.bgSelectedId isEqualToString:@"default"]) {
                self.bgtime++;
                [self diyApplyDefaultBackground];
            }
        }else{
            CMDiySourceModel *sourceModel = [self.bgSourceViewModel sourceModelAtIndex:indexPath.row - 2];
            if (![self.bgSelectedId isEqualToString:sourceModel.sourceId]) {
                [self diyApplyBackground:indexPath];
                self.bgtime++;
            }else{
                [self showToolBar];
            }
        }
    }else if (collectionView == self.buttonCollectionView) {
        [self showToolBar];
        if (self.diyType != CMDiyTypeDefault && self.keyAlphaSlider.tag != KeyAlphaSliderTag) {
            self.keyAlphaSlider.tag = KeyAlphaSliderTag;
            self.keyAlphaSlider.value = 0.5f;
        }
        if (indexPath.row == 0) {
            if (![self.keyBgSelectedId isEqualToString:@"non"]) {
                self.bttime++;
                self.keyBgSelectedId = @"non";
                self.originalKeyBgImage = nil;
                kCMKeyboardManager.themeManager.letterKeyNormalBgImage = nil;
                kCMKeyboardManager.themeManager.funcKeyNormalBgImage = nil;
                kCMKeyboardManager.themeManager.spaceKeyNormalBgImage = nil;
                kCMKeyboardManager.themeManager.inputOptionBgImage = nil;
                [kCMKeyboardManager.themeManager setPreInputBgImage:nil];
                kCMKeyboardManager.themeManager.letterKeyHighlightBgImage = nil;
                kCMKeyboardManager.themeManager.funcKeyHighlightBgImage = nil;
                kCMKeyboardManager.themeManager.spaceKeyHighlightBgImage = nil;
                kCMKeyboardManager.themeManager.inputOptionHighlightBgImage = nil;
                if (CGColorEqualToColor(kCMKeyboardManager.themeManager.letterKeyTextColor.CGColor, [UIColor colorWithHexString:@"FFFFFF"].CGColor)) {
                    [kCMKeyboardManager.themeManager setColor:@"000000" forKeyPath:@"imageAttr.inputOptionViewBackgroundColor"];
                    [kCMKeyboardManager.themeManager inputOptionTextColorHexString:@"000000"];
                }else{
                    [kCMKeyboardManager.themeManager setColor:@"FFFFFF" forKeyPath:@"imageAttr.inputOptionViewBackgroundColor"];
                }
                [self.diyKeyboardView switchTheme];
            }
        }else{
            CMDiySourceModel *sourceModel = [self.buttonSourceViewModel sourceModelAtIndex:indexPath.row - 1];
            if (![self.keyBgSelectedId isEqualToString:sourceModel.sourceId]) {
                self.bttime++;
                [self diyApplyKeyBackground:indexPath];
            }
        }
        
    }else if (collectionView == self.fontsCollectionView) {
        if (indexPath.row == 0) {
            // 使用默认字体
            if (![self.fontsSelectedId isEqualToString:@"sys"]) {
                self.fttime++;
                [kCMKeyboardManager.themeManager setStandardDirFont:nil];
                [self.diyKeyboardView switchTheme];
                self.fontsSelectedId = @"sys";
            }
            [self showToolBar];
        }else{
            CMDiySourceModel *sourceModel = [self.fontsSourceViewModel sourceModelAtIndex:indexPath.row - 1];
            if (![self.fontsSelectedId isEqualToString:sourceModel.sourceId]) {
                self.fttime++;

                self.fontsSelectedId = sourceModel.sourceId;
                
                [self getDiyResourceWithURL:sourceModel.download_url diySourceType:CMDiySourceTypeFonts sourceModel:sourceModel indexPath:indexPath completeBlock:^(NSString *filePath){
                    self.lastFontIndexPath = indexPath;
                    [kCMKeyboardManager.themeManager setStandardDirFont:filePath];
                    [self.diyKeyboardView switchTheme];
                    [self showToolBar];
                }];
            }else{
                [self showToolBar];
            }
        }
    }else if (collectionView == self.soundCollectionView){
        //音效选择
        if (indexPath.row == 0) {
            //默认音效
            if (![self.soundSelectedId isEqualToString:@"non"]) {
                self.sdtime ++;
                //更换音效
                [kCMKeyboardManager.themeManager setStandardDirSound:nil];
                [self.diyKeyboardView switchTheme];
                self.soundSelectedId = @"non";
            }
            [self showToolBar];
        }else{
            CMDiySourceModel *model = [self.soundSourceViewModel sourceModelAtIndex:indexPath.item - 1];
            if (![model.sourceId isEqualToString:self.soundSelectedId]) {
                [self diyApplySound:indexPath];
                self.sdtime ++;
            }else{
                [self showToolBar];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.bgCollectionView) {
        if (self.bgToolBar.frame.origin.y < self.view.frame.size.height) {
            [UIView animateWithDuration:0.5f animations:^{
                CGRect rect = self.bgToolBar.frame;
                rect.origin.y += rect.size.height;
                self.bgToolBar.frame = rect;
            }];
        }
    }else if (scrollView == self.buttonCollectionView) {
        if (self.buttonToolBar.frame.origin.y < self.view.frame.size.height) {
            [UIView animateWithDuration:0.5f animations:^{
                CGRect rect = self.buttonToolBar.frame;
                rect.origin.y += rect.size.height;
                self.buttonToolBar.frame = rect;
            }];
        }
    }else if (scrollView == self.fontsCollectionView) {
        if (self.fontsToolBar.frame.origin.y < self.view.frame.size.height) {
            [UIView animateWithDuration:0.5f animations:^{
                CGRect rect = self.fontsToolBar.frame;
                rect.origin.y += rect.size.height;
                self.fontsToolBar.frame = rect;
            }];
        }
    }else if (scrollView == self.soundCollectionView){
        if (self.soundToolBar.frame.origin.y < self.view.frame.size.height) {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect rect = self.soundToolBar.frame;
                rect.origin.y += rect.size.height;
                self.soundToolBar.frame = rect;
            }];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        NSInteger page = round(self.scrollView.contentOffset.x / self.scrollView.width);
        if (page < 0)   page = 0;
        else if (page > 3)  page = 3;
        [self.segmentedControl setSelectedSegmentIndex:page animated:YES notify:YES];
    }
}

#pragma mark - photo picker delegate
-(void)cmImagePicker:(CMImagePickerController *)picker didFinishCropPhoto:(UIImage *)photo asset:(PHAsset *)asset isOriginal:(BOOL)isOriginal{
     kLog(@"图片选择器返回成功");
    self.bgSelectedId = @"sys";
    self.originalBKImage = photo;

    if (self.lightSlider.value < 1.0f || self.blurSlider.value < 1.0f ) {
        
        [self changeBKImageBlurAlpha];
    }else{
        [self refreshKeyboardBackgroundIamge:photo];
    }
}

-(void)cmImagePickerCancle:(CMImagePickerController *)picker
{
    [self.bgCollectionView selectItemAtIndexPath:self.lastBgIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    kLog(@"取消图片选择");
}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Navigation Bar Touched
- (void)navBarBackButtonDidClick
{
    [self.alertView showAlertWithTitle:CMLocalizedString(@"Do you want to cancel this theme?", nil) confirmTitle:CMLocalizedString(@"OK", nil) andCancelTitle:CMLocalizedString(@"Cancel", nil)];
    @weakify(self)
    self.alertView.cancelBlock = ^{
        @stronglize(self);
        [CMHostInfoc reportCheetahkeyboard_cancel:self.inway action:0];

    };
    
    self.alertView.confirmBlock = ^{
        @stronglize(self);
        [kCMKeyboardManager.themeManager cancelChangeDiyTheme];
        [CMHostInfoc reportCheetahkeyboard_cancel:self.inway action:1];
        [kCMKeyboardManager.themeManager resetThemeCache];
        [self.navigationController popViewControllerAnimated:YES];

    };
}

- (void)navBarRightItemDidClick:(UIButton *)rightItem
{
    [self.alertView showAlertWithTitle:CMLocalizedString(@"Do you want to save this theme?", nil) confirmTitle:CMLocalizedString(@"OK", nil) andCancelTitle:CMLocalizedString(@"Cancel", nil)];
    @weakify(self)
    self.alertView.cancelBlock = ^{
        @stronglize(self);
        [CMHostInfoc reportCheetahkeyboard_diy_done:self.bgSelectedId bgtime:self.bgtime btname:self.keyBgSelectedId bttime:self.bttime ftname:self.fontsSelectedId fttime:self.fttime voicname:self.soundSelectedId voictime:self.sdtime action:0 inway:self.inway];
        [kCMKeyboardManager.themeManager resetThemeCache];
        [self.navigationController popViewControllerAnimated:YES];
    };
    self.alertView.confirmBlock = ^{
        @stronglize(self);
        [CMHostInfoc reportCheetahkeyboard_diy_done:self.bgSelectedId bgtime:self.bgtime btname:self.keyBgSelectedId bttime:self.bttime ftname:self.fontsSelectedId fttime:self.fttime voicname:self.soundSelectedId voictime:self.sdtime action:1 inway:self.inway];

        UIImage * image = [UIImage convertViewToImage:self.diyKeyboardView];
        [kCMKeyboardManager.themeManager saveDiyThemeWithCoverImage:image];
        [self.navigationController popViewControllerAnimated:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(doneButtonClickWith:)]) {
            [self.delegate doneButtonClickWith:nil];
        }
    };
}

#pragma mark - ErrorTip Method
- (void)showErrorTipWithIcon:(NSString *)iconString errorMessage:(NSString *)errorMessage containerView:(UIView *)containerView
{
    if (_hudIsShow == NO) {
        _hudIsShow = YES;
        CMTipView * tipView = [[CMTipView alloc] initWithIcon:iconString message:errorMessage];
        MBProgressHUD * hud = [MBProgressHUD showCustomView:tipView toView:self.view seconds:3.0 completion:^(BOOL finished) {
            _hudIsShow = NO;
        }] ;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = COLOR_WITH_RGBA(48, 54, 83, 1);
        hud.bezelView.layer.cornerRadius = 20;
        hud.userInteractionEnabled = NO;
        
        if (self.errorRefreshViewContainerView == self.bgCollectionView) {
            [self.bgCollectionView.mj_footer endRefreshingWithNoMoreData];
        }else if (self.errorRefreshViewContainerView == self.fontsCollectionView){
            [self.fontsCollectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }
}

- (void)showErrorRefreshViewOnContainerView:(UIView *)containerView
{
    self.errorRefreshViewContainerView = containerView;
    _errorRefreshView = [[CMErrorRefreshView alloc] init];
    _errorRefreshView.delegate = self;
    [containerView addSubview:_errorRefreshView];
    [_errorRefreshView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView.mas_centerX);
        make.centerY.equalTo(containerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 100));
    }];
}

- (void)hideErrorRefreshView
{
    if (_errorRefreshView) {
        _errorRefreshView.hidden = YES;
        [_errorRefreshView removeFromSuperview];
    }
}

#pragma mark - CMErrorRefreshViewDelegate Method
- (void)refreshDidClick
{
    [self hideErrorRefreshView];
    if (self.errorRefreshViewContainerView == self.bgCollectionView) {
        [self.bgCollectionView.mj_header beginRefreshing];
    }else if (self.errorRefreshViewContainerView == self.fontsCollectionView){
        [self.fontsCollectionView.mj_header beginRefreshing];
    }else if (self.errorRefreshViewContainerView == self.soundCollectionView){
        [self.soundCollectionView.mj_header beginRefreshing];
    }
}

#pragma mark - swipe back
- (BOOL)shouldSwipeBack
{
    return NO;
}

#pragma mark - dealloc
- (void)dealloc
{
    kLogTrace();
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

