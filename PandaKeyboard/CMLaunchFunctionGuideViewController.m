//
//  CMLaunchFunctionGuideViewController.m
//  PandaKeyboard
//
//  Created by zhoujing on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMLaunchFunctionGuideViewController.h"
#import "CMCustomPageControl.h"
static int const kCMLauchGuideNumber = 3;
@interface CMLaunchFunctionGuideViewController ()<UIScrollViewDelegate>

@end

@implementation CMLaunchFunctionGuideViewController {
    CGFloat screenWidth;
    CGFloat screenHeight;
    UIScrollView *backGroundScrollView ;
    UIButton *startButton;
    CMCustomPageControl *lanuchPageControl;
    NSTimer *loopTimer;
    int currentPage;
    UIView *firstPage;
    UIView *middlePage;
    UIView *lastPage;
    NSMutableArray *viewsArray;
    BOOL      isUserDrag;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([UIDevice isIpad])
    {
        [UIDevice orientationToPortrait:UIInterfaceOrientationPortrait];
    }
    [self buildUI];
}

- (void)buildUI{
     screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    currentPage = 0;
    isUserDrag = NO;
    UIImageView *imageView1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Launch_Guide_1"]];
    UIImageView *imageView2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Launch_Guide_2"]];
    UIImageView *imageView3=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Launch_Guide_3"]];
    viewsArray = [[NSMutableArray alloc]initWithObjects:imageView1,imageView2,imageView3,nil];
    BOOL isPad = [UIDevice isIpad];
    backGroundScrollView = [[UIScrollView alloc] init];
    backGroundScrollView.showsVerticalScrollIndicator = NO;
    backGroundScrollView.showsHorizontalScrollIndicator = NO;
    backGroundScrollView.pagingEnabled = YES;
    backGroundScrollView.bounces = NO;
    backGroundScrollView.contentSize = CGSizeMake(screenWidth * kCMLauchGuideNumber, screenHeight);
    backGroundScrollView.delegate = self;
    [self.view addSubview:backGroundScrollView];
    [backGroundScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    startButton = [[UIButton alloc]init];
    [startButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:84/255.0 green:243/255.0 blue:238/255.0 alpha:255.0]] forState:UIControlStateNormal];
    [startButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:70.0/255.0 green:157.0/255.0 blue:161.0/255.0 alpha:255.0]] forState:UIControlStateHighlighted];
    [startButton setTitle:CMLocalizedString(@"Get Start", nil) forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
    startButton.titleLabel.font = [CMBizHelper getFontWithSize:24];
    [startButton setTitleColor:COLOR_WITH_RGBA(1, 3, 25, 1) forState:UIControlStateNormal];
    CGFloat startBthHeight = KScalePt(50);
    if (isPad) {
        startBthHeight = KScalePt(40);
    }
    startButton.layer.cornerRadius = startBthHeight/2;
    startButton.layer.masksToBounds = YES;
    [self.view addSubview:startButton];
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(KScalePt(46));
        make.right.equalTo(self.view).offset(KScalePt(-46));
        make.bottom.equalTo(self.view).offset(-100);
        make.height.mas_equalTo(startBthHeight);
    }];
    lanuchPageControl = [[CMCustomPageControl alloc] init];
    lanuchPageControl.numberOfPages = kCMLauchGuideNumber;
    lanuchPageControl.currentPage = 0;
    lanuchPageControl.pageIndicatorTintColor = COLOR_WITH_RGBA(1, 3, 25, 1);
    lanuchPageControl.currentPageIndicatorTintColor = COLOR_WITH_RGBA(84, 243, 238, 1);
    [self.view addSubview:lanuchPageControl];
    [lanuchPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.equalTo(startButton.mas_top).offset(KScalePt(-25));
    }];
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = CMLocalizedString(@"Express your styles in more than words", nil);
    titleLabel.numberOfLines = 3;
    titleLabel.font =[CMBizHelper getFontWithSize:21];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(KScalePt(40));
        make.right.equalTo(self.view).offset(KScalePt(-40));
        make.bottom.equalTo(lanuchPageControl.mas_top);
    }];
    [self addTimer];
    [self reloadData];
    [self addTimer];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self removeTimer];
}
- (void)startButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissGuidIntroduce)]) {
                [self.delegate dismissGuidIntroduce];
    }
}
#define mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
    isUserDrag = YES;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self reloadData];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //手动滑动自动替换，悬停timer
    if (!isUserDrag) {
        [self removeTimer];
        [self addTimer];
    }
    int x = scrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*screenWidth)) {
        if (currentPage+1==[viewsArray count]) {
            currentPage=0;
        }else
            currentPage++;
    }
    
    //往上翻
    if(x <= 0) {
        if (currentPage-1<0) {
            currentPage=[viewsArray count]-1;
        }else
            currentPage--;
    }
    
    [self reloadData];
}
- (void)addTimer {
    if (![loopTimer isValid]) {
        loopTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(nextBanner) userInfo:nil repeats:YES];
    }
}
- (void)removeTimer {
    [loopTimer invalidate];
    loopTimer = nil;
}
- (void)nextBanner {
    if (currentPage+1>=[viewsArray count]) {
        currentPage=0;
    }
    else{
        currentPage++;
    }
    [backGroundScrollView setContentOffset:CGPointMake(screenWidth*2, 0) animated:YES];
}
-(void)reloadData {
    [firstPage removeFromSuperview];
    [middlePage removeFromSuperview];
    [lastPage removeFromSuperview];
    
    if (currentPage==0) {
        firstPage=[viewsArray lastObject];
        middlePage=[viewsArray objectAtIndex:currentPage];
        lastPage=[viewsArray objectAtIndex:currentPage+1];
    }else if (currentPage==[viewsArray count]-1){
        firstPage=[viewsArray objectAtIndex:currentPage-1];
        middlePage=[viewsArray objectAtIndex:currentPage];
        lastPage=[viewsArray objectAtIndex:0];
    }else {
        firstPage=[viewsArray objectAtIndex:currentPage-1];
        middlePage=[viewsArray objectAtIndex:currentPage];
        lastPage=[viewsArray objectAtIndex:currentPage+1];
    }
    
    [lanuchPageControl setCurrentPage:currentPage];
    
    [firstPage setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [middlePage setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    [lastPage setFrame:CGRectMake(screenWidth*2, 0, screenWidth, screenHeight)];
    [backGroundScrollView addSubview:firstPage];
    [backGroundScrollView addSubview:middlePage];
    [backGroundScrollView addSubview:lastPage];
    
    //自动timer滑行后自动替换，不再动画
    //移动到中间页，然后再做动画到最后一页
    [backGroundScrollView setContentOffset:CGPointMake(screenWidth, 0) animated:NO];
}
- (BOOL)shouldAutorotate {
    return NO;
}
@end
