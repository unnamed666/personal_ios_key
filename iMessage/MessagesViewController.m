//
//  MessagesViewController.m
//  iMessage
//
//  Created by yanzhao on 2017/9/28.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "MessagesViewController.h"
#import "CustomCollectionViewLayout.h"
#import "CMCollectionViewCell.h"
#import "CMGiphy.h"
#import <YYWebImage/YYWebImage.h>
#import<CommonCrypto/CommonDigest.h>

// Fabric
#import "CMCollectionRefreshFooter.h"
#import "CMInfociMessage.h"

@interface MessagesViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,CustomCollectionViewLayoutDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) CGSize size;//根据宽高判断横竖屏的
@property (nonatomic, strong) NSMutableArray<CMGiphy *> * browArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) CMCollectionRefreshFooter * footer;
@property (nonatomic, strong) UIImage *  placeholder;
@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CMAppConfig setupFabric];
    self.size = [UIScreen mainScreen].bounds.size;
    
    [CMOReachability start];
    YYImageCache *imageCache = [YYWebImageManager sharedManager].cache;
    imageCache.diskCache.costLimit = 100*1024*1024;
    // Do any additional setup after loading the view.
     self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.center =self.view.center;
    self.indicator.color = [UIColor blackColor];
    [self.view addSubview:_indicator];
    
    self.footer = [[CMCollectionRefreshFooter alloc] init];
    [self.footer setRefreshingTarget:self refreshingAction:@selector(footerLoad)];
    [self.collectionView addSubview:self.footer];
    
    self.browArray = [[NSMutableArray alloc] init];
    CustomCollectionViewLayout * layout = [[CustomCollectionViewLayout alloc] init];
    layout.layoutDelegate = self;
    self.collectionView.collectionViewLayout = layout;
    
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    [_indicator startAnimating];
    [CMGiphy giphyTrendingRequestWithLimit:20 offset:0 completion:^(NSArray<CMGiphy *> * giphyArry, NSError *error) {
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        kLog(@"返回耗时 %f",end- start);
        kLog(@"%d  %@",(int)giphyArry.count,giphyArry);
        self.placeholder = [UIImage imageWithColor:rgb(48, 55, 83)];
        [self.browArray addObjectsFromArray:  giphyArry];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicator stopAnimating];
            [self.collectionView reloadData];
        });
    }];
    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    kLog(@"耗时 %f",end- start);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CMInfociMessage activeReport];
    });
//    [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.indicator.center =self.view.center;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    kLog(@"%@",NSStringFromCGSize(size));
    self.size = size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)footerLoad{
    kLog(@"刷新");
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    [CMGiphy giphyTrendingRequestWithLimit:20 offset:self.browArray.count completion:^(NSArray<CMGiphy *> * giphyArry, NSError *error) {
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        kLog(@"返回耗时 %f",end- start);
        kLog(@"%d  %@",(int)giphyArry.count,giphyArry);
        [self.browArray addObjectsFromArray:  giphyArry];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.footer endRefreshing];
            [self.collectionView reloadData];
        });
    }];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    return self.browArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:}}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"topCell" forIndexPath:indexPath];
        return  cell;
    }
    CMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CMCollectionViewCell" forIndexPath:indexPath];
    //    cell.sticker = self.browArray[indexPath.row];
//    [cell.imageView yy_setImageWithURL:self.browArray[indexPath.row].fixedWidthSmall.url options:YYWebImageOptionProgressive];
    [cell.imageView yy_setImageWithURL:self.browArray[indexPath.row].fixedWidthSmall.url  placeholder:self.placeholder options:YYWebImageOptionProgressive completion:nil];
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    if([cell isKindOfClass:[CMCollectionViewCell class]]){
//        ((CMCollectionViewCell*)cell).imageView.image= nil;
//    }
//}

#pragma mark - CustomCollectionViewLayoutDelegate

- (int)flowLayoutStartSection{
    return 1;
}

- (int)fixedCount{
    if([UIDevice isIpad]){
        return  4;
    }else if(_size.width > _size.height){
       return 3;
    }
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView collectionViewLayout:(CustomCollectionViewLayout *)collectionViewLayout sizeOfItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0){
        return CGSizeMake(self.size.width, 50);
    }
    return CGSizeMake(self.browArray[indexPath.row].fixedWidthSmall.width, self.browArray[indexPath.row].fixedWidthSmall.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    kLog(@"点击 %@",indexPath);
    if(indexPath.section == 0)return;
    [self sendGifWithIndexPath:indexPath];
}

#pragma mark - private

- (void)sendGifWithIndexPath:(NSIndexPath *)indexPath{
     NSString *tmpDir =  [NSTemporaryDirectory() stringByAppendingPathComponent:@"giftem"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:tmpDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:self.browArray[indexPath.row].fixedWidthImageDownsampled.url];
    NSString *ext = [key pathExtension];
    NSString *keyid = self.browArray[indexPath.row].gifID;
    NSString *gifPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",keyid,ext]];
    if([[NSFileManager defaultManager] fileExistsAtPath:gifPath]){
        [self.activeConversation insertAttachment:[NSURL fileURLWithPath:gifPath] withAlternateFilename:nil completionHandler:^(NSError * _Nullable error) {
            kLog(@"发送 diskCash %@",error);
        }];
        [self requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
    }else{
         [_indicator startAnimating];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = self.browArray[indexPath.row].fixedWidthImageDownsampled.url;
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        NSURLSessionTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [_indicator stopAnimating];
                                                [self requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
                                            });
                                            if (error) {
                                                
                                            } else {
                                                [data writeToFile:gifPath atomically:YES];
                                                [self.activeConversation insertAttachment:[NSURL fileURLWithPath:gifPath] withAlternateFilename:nil completionHandler:^(NSError * _Nullable error) {
                                                    kLog(@"发送  %@",error);
                                                }];
                                            }
                                        }];
        
        // 启动任务
        [task resume];
    }
    [CMInfociMessage gifClickReport:(int)indexPath.row link:[self.browArray[indexPath.row].fixedWidthImageDownsampled.url absoluteString]];
    
}

#pragma mark - Conversation Handling

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    
    // Use this method to configure the extension and restore previously stored state.
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user taps the send button.
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
    self.indicator.center = self.view.center;
}

@end
