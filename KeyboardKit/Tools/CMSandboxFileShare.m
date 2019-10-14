//
//  CMSandboxFileShare.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/26.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMSandboxFileShare.h"
#import <UIKit/UIKit.h>
#define CMWindowPadding 20
#import "CMGroupDataManager.h"
#import "CMBizHelper.h"
#pragma mark- CMFileItem

typedef enum : NSUInteger {
    CMFileItemUp,
    CMFileItemDirectory,
    CMFileItemFile,
} CMFileItemType;

@interface CMFileItem : NSObject
@property (nonatomic, copy) NSString*                 name;
@property (nonatomic, copy) NSString*                 path;
@property (nonatomic, assign) CMFileItemType          type;
@end

@implementation CMFileItem
@end

#pragma mark- CMTableViewCell
@interface CMSandboxCell : UITableViewCell
@property (nonatomic, strong) UILabel*                 lbName;
@end

@implementation CMSandboxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        int cellWidth = [CMBizHelper adapterScreenWidth] - 20;
        
        _lbName = [UILabel new];
        _lbName.backgroundColor = [UIColor clearColor];
        _lbName.font = [UIFont systemFontOfSize:13];
        _lbName.textAlignment = NSTextAlignmentLeft;
        _lbName.frame = CGRectMake(10, 10, cellWidth , 15);
        _lbName.textColor = [UIColor blackColor];
        [self addSubview:_lbName];
        
        UIView* line = [UIView new];
        line.frame = CGRectMake(10, 37, cellWidth , 1);
        line.backgroundColor = [UIColor grayColor];
        [self addSubview:line];
    }
    return self;
}

- (void)renderWithItem:(CMFileItem*)item
{
    _lbName.text = item.name;
}

@end

#pragma mark - CMSandboxViewController

@interface CMSandboxViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UIButton * btnClose;
@property (nonatomic, strong)UILabel * lable;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSArray* items;
@property (nonatomic, strong)NSString * rootPath;
@property (nonatomic, strong)NSString * rootGroupPath;

@end

@implementation CMSandboxViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    _btnClose = [UIButton new];
    [self.view addSubview:_btnClose];
    [_btnClose setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [_btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _lable = [UILabel new];
    [self.view addSubview:_lable];
    _lable.font = [UIFont systemFontOfSize:13];
    
    _tableView = [UITableView new];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _rootPath = NSHomeDirectory();
    _rootGroupPath = kCMGroupDataManager.containerURL.path;
    [self loadPath:nil];
}

- (void)btnCloseClick
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    int viewWidth = [CMBizHelper adapterScreenWidth] - 2*CMWindowPadding;
    int closeWidth = 60;
    int closeHeight = 38;
    
    _btnClose.frame = CGRectMake(viewWidth-closeWidth-4, 4, closeWidth, closeHeight);
    _lable.frame = CGRectMake(0, 4, 100, 28);
    
    
    CGRect tableFrame = self.view.frame;
    tableFrame.origin.y += (closeHeight+4);
    tableFrame.size.height -= (closeHeight+4);
    _tableView.frame = tableFrame;
}


#pragma mark- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > _items.count-1) {
        return [UITableViewCell new];
    }
    
    CMFileItem* item = [_items objectAtIndex:indexPath.row];
    
    static NSString* cellIdentifier = @"CMSandboxCell";
    CMSandboxCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CMSandboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell renderWithItem:item];
    
    return cell;
}

#pragma mark- UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > _items.count-1) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    CMFileItem* item = [_items objectAtIndex:indexPath.row];
    if (item.type == CMFileItemUp) {
        [self loadPath:[item.path stringByDeletingLastPathComponent]];
    }
    else if(item.type == CMFileItemFile) {
        [self sharePath:item.path];
    }
    else if(item.type == CMFileItemDirectory) {
        [self loadPath:item.path];
    }
}


- (void)loadPath:(NSString*)filePath
{
    NSMutableArray* files = @[].mutableCopy;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if( [filePath isEqualToString:_rootPath]){
        
        _lable.text = @"本地目录";
    }else if( [filePath isEqualToString:_rootGroupPath]){
        
        _lable.text = @"app组目录";
    }
    
    NSString* targetPath = filePath;
    if (targetPath.length == 0 || [targetPath isEqualToString:[_rootGroupPath stringByDeletingLastPathComponent]] ||
        [targetPath isEqualToString:[_rootPath stringByDeletingLastPathComponent]]) {
        CMFileItem * file1 = [CMFileItem new];
        file1.name = @"本地目录";
        file1.type = CMFileItemDirectory;
        file1.path = _rootPath;
        
        
        CMFileItem * file2 = [CMFileItem new];
        file2.name = @"app组目录";
        file2.type = CMFileItemDirectory;
        file2.path = _rootGroupPath;
        _items = @[file1,file2];
        [_tableView reloadData];
        _lable.text = @"";
        return;
    }
    else
    {
        CMFileItem* file = [CMFileItem new];
        file.name = @"⬅︎..";
        file.type = CMFileItemUp;
        file.path = filePath;
        [files addObject:file];
    }
    
    NSError* err = nil;
    NSArray* paths = [fm contentsOfDirectoryAtPath:targetPath error:&err];
    for (NSString* path in paths) {
        
        if ([[path lastPathComponent] hasPrefix:@"."]) {
            continue;
        }
        
        BOOL isDir = false;
        NSString* fullPath = [targetPath stringByAppendingPathComponent:path];
        [fm fileExistsAtPath:fullPath isDirectory:&isDir];
        
        CMFileItem* file = [CMFileItem new];
        file.path = fullPath;
        if (isDir) {
            file.type = CMFileItemDirectory;
            file.name = [NSString stringWithFormat:@"%@ %@", @"📁", path];
        }
        else
        {
            file.type = CMFileItemFile;
            file.name = [NSString stringWithFormat:@"%@ %@", @"📄", path];
        }
        [files addObject:file];
        
    }
    _items = files.copy;
    [_tableView reloadData];
}


- (void)sharePath:(NSString*)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,UIActivityTypeOpenInIBooks];
    controller.excludedActivityTypes = excludedActivities;
    
    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = CGRectMake([CMBizHelper adapterScreenWidth] * 0.5, [CMBizHelper adapterScreenHeight], 10, 10);
    }
    [self presentViewController:controller animated:YES completion:nil];
}


@end

#pragma mark - CMSandboxFileShare

@interface CMSandboxFileShare ()
@property (nonatomic, strong)CMSandboxViewController * viewController;
@end

@implementation CMSandboxFileShare

static CMSandboxFileShare* _instance = nil;

+(instancetype) shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (void)showSandboxBrowser:(UIViewController *)viewController{
    [viewController presentViewController:self.viewController animated:NO completion:nil];
}
- (CMSandboxViewController *)viewController{
    if (!_viewController) {
        _viewController = [CMSandboxViewController new] ;
    }
    return _viewController;
}
@end
