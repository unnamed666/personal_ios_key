//
//  CMEmoticonKeyboardView.m
//  PandaKeyboard Extension
//
//  Created by yanzhao on 2017/10/19.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMEmoticonKeyboardView.h"
#import "UIDevice+Util.h"
#import "CMKeyButton.h"
#import "CMKeyModel.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "UIImage+Util.h"
#import "UIView+Toast.h"
#import "MobileCoreServices/UTCoreTypes.h"
#import "CMFullAccessTipView.h"
#import "CMEmoticonPasteTip.h"
#import "YYAnimatedImageView.h"
#import <YYImage/YYImage.h>
#import "CMNotificationConstants.h"
#import "CMInfoc.h"
@interface CMEmoticonCollectionModel:NSObject
@property (nonatomic, strong)UIImage * image;
@property (nonatomic, assign)BOOL  deleteBtnHide;
@property (nonatomic, strong)NSString *  imagePath;
@property (nonatomic, strong)UIColor *backgroundColor;
@end

@implementation CMEmoticonCollectionModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _deleteBtnHide = YES;
    }
    return self;
}
@end
@class CMEmoticonCell;
@protocol CMEmoticonCellDelegate <NSObject>

- (void)onDeleteCell:(CMEmoticonCell *)cell;

@end

@interface CMEmoticonCell:UICollectionViewCell
@property (nonatomic, strong)YYAnimatedImageView * imageView;
@property (nonatomic, strong)UIButton * deleteBtn;
@property (nonatomic, weak)id<CMEmoticonCellDelegate> delegate;
@end

@implementation CMEmoticonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = rgba(255, 255, 255, 0.8);
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 8;
        _imageView = [[YYAnimatedImageView alloc] init];
//        _imageView.image = [UIImage imageNamed:@"Camera"];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _deleteBtn.frame = CGRectMake(self.bounds.size.width-15, 0, 15, 15);
}

- (UIButton *)deleteBtn{
    if(!_deleteBtn){
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"emoticon_cell_close"] forState:UIControlStateNormal];
        _deleteBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _deleteBtn.layer.borderWidth = 2;
        _deleteBtn.layer.cornerRadius = 8;
//        _deleteBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _deleteBtn.frame = CGRectMake(self.bounds.size.width-15, 0, 15, 15);
        [_deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBtn];
    }
    return _deleteBtn;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject] ;
    CGPoint position =   [touch locationInView:self];
//    NSLog(@"%@",NSStringFromCGPoint(position));
    if(position.x > self.bounds.size.width - 20 && position.y < 20){
        [self deleteClick:nil];
    }
}

-(void)deleteClick:(UIButton*)btn{
    if(!_deleteBtn.hidden){
        [self.delegate onDeleteCell:self];
    }
}

@end


@interface CMEmoticonKeyboardView()<UICollectionViewDelegate,UICollectionViewDataSource,CMEmoticonCellDelegate,CMTipsViewDelegate>
@property (nonatomic, strong)UICollectionView * collectionView;
@property (nonatomic, strong)UIView * bottomView;
@property (nonatomic)        CGSize   itemSize;
@property (nonatomic, strong)CMKeyButton * layoutBtn;
@property (nonatomic, strong)CMKeyButton * deleteBtn;
@property (nonatomic, strong)CMEmoticonPasteTip * pasteTip;
@property (nonatomic, strong)NSMutableArray<CMEmoticonCollectionModel*>* modelArray;
@end

@implementation CMEmoticonKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//                _bottomView = [[UIView alloc] init];
//                _bottomView.backgroundColor = rgb(0, 42, 67);
//                [self addSubview:_bottomView];
        
        [self addSubview:self.collectionView];
        [self setupModel];
    }
    return self;
}
- (void)setupModel{
    _modelArray = [NSMutableArray new];
    CMEmoticonCollectionModel* model = [CMEmoticonCollectionModel new];
    model.backgroundColor = rgba(13, 17, 41, 0.6);
    model.image = [UIImage imageNamed:@"Camera"];
    [_modelArray addObject:model];
    
    UIColor * color = rgba(255, 255, 255, 0.8);
    NSString * filePath = kCMGroupDataManager.EmoGifPath.path;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> * arr =  [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    if(arr.count>0){//判断有无用户创建的 gif
        [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([[obj pathExtension] isEqualToString:@"gif"]){
//                UIImage * image = [UIImage imageWithContentsOfFile:[filePath stringByAppendingPathComponent:obj]];
//                if(image){
                    CMEmoticonCollectionModel* model = [CMEmoticonCollectionModel new];
                    model.backgroundColor = color;
//                    model.image = image;
                    model.imagePath = [filePath stringByAppendingPathComponent:obj];
                    [_modelArray addObject:model];
//                }
            }
        }];
        
    }
    if(_modelArray.count<=1){
        for (int i=1; i<3; i++) {
            CMEmoticonCollectionModel* model = [CMEmoticonCollectionModel new];
            model.backgroundColor = color;
            NSString * path =  [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Animoji%d",i] ofType:@"gif"];
            YYImage* image = [YYImage imageWithContentsOfFile:path];
            model.image = image;
            [_modelArray addObject:model];
        }
    }
    
    
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)setupWithLayoutModel:(CMKeyModel *)layoutKeyModel{
    if(!layoutKeyModel)return;
    CMKeyModel * btnModel = [layoutKeyModel copy];
    btnModel.key = @"ABC";
    btnModel.layoutId = @"primary";
    [self.layoutBtn removeFromSuperview];
    @weakify(self)
    self.layoutBtn = [[CMKeyButton alloc] initWithKeyModel:btnModel];
    self.layoutBtn.userInteractionEnabled = YES;
    [self.layoutBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        [self hidePreView:NO];
        if (self.delegate) {
            [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
        }
    }];
    [self addSubview:self.layoutBtn];

//    iconImageView

    [self.deleteBtn removeFromSuperview];
    CMKeyModel * deleteModel = [[CMKeyModel alloc] init];
    deleteModel.keyType = CMKeyTypeDel;
    self.deleteBtn = [[CMKeyButton alloc] initWithKeyModel:deleteModel];
    self.deleteBtn.iconImageView.image = [[UIImage imageNamed:@"emoticon_delete"] imageWithTintColor:kCMKeyboardManager.themeManager.funcKeyTextColor ];
    self.deleteBtn.iconImageView.highlightedImage = nil;
    self.deleteBtn.userInteractionEnabled = YES;
    [self.deleteBtn setKeyTouchUpInsideHandler:^(CMKeyButton *keyButton, CGPoint touchPt) {
        @stronglize(self);
        [self hidePreView:NO];
        [self.modelArray enumerateObjectsUsingBlock:^(CMEmoticonCollectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx!=0){
                obj.deleteBtnHide = !obj.deleteBtnHide;
            }
        }];
        if(self.modelArray.count>1){
            self.deleteBtn.iconImageView.image =self.modelArray[1].deleteBtnHide ? [[UIImage imageNamed:@"emoticon_delete"] imageWithTintColor:kCMKeyboardManager.themeManager.funcKeyTextColor ]: [[UIImage imageNamed:@"emoticon_ok"] imageWithTintColor:kCMKeyboardManager.themeManager.funcKeyTextColor ];
        }else{
            self.deleteBtn.iconImageView.image =[[UIImage imageNamed:@"emoticon_delete"] imageWithTintColor:kCMKeyboardManager.themeManager.funcKeyTextColor ];
        }

        [self.collectionView reloadData];
//        if (self.delegate) {
//            [self.delegate onKeyboard:self touchUpInsideKeyModel:keyButton.keyModel touchPt:touchPt fromeRepeate:NO];
//        }
    }];
    [self addSubview:self.deleteBtn];
    
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    if(CGRectGetWidth(self.bounds)==0 || CGRectGetHeight(self.bounds)==0)return;
    int btnY = self.bounds.size.height - [CMKeyboardManager keyHeight];
    int btnWidth = [kCMKeyboardManager getRealWidthByRatio:self.layoutBtn.keyModel.keyWidthRatio];
    _bottomView.frame = CGRectMake(0, btnY , self.bounds.size.width, 40);
    _collectionView.frame = CGRectMake(0,  0, self.bounds.size.width, btnY);
    _layoutBtn.frame =CGRectMake(4, btnY , btnWidth, [CMKeyboardManager keyHeight]);
    _deleteBtn.frame =CGRectMake(self.bounds.size.width-btnWidth-4, btnY , btnWidth, [CMKeyboardManager keyHeight]);
    if(kScreenWidth<kScreenHeight){
        int col = 3;
        kLogInfo(@"view宽度 %f,屏幕宽度:%f",self.bounds.size.width,kScreenWidth);
        int itemWidth = (self.bounds.size.width - (col+1)* 5)/col;
        self.itemSize = CGSizeMake(itemWidth, (int)(itemWidth*0.68));
////        int row = 2;
//        int itemHight = (_collectionView.bounds.size.height-14)/2;
//        self.itemSize = CGSizeMake(itemHight*1.45, itemHight);
    }else{
        int itemHight = _collectionView.bounds.size.height-20;
        self.itemSize = CGSizeMake(itemHight*1.45, itemHight);
    }
    [self.collectionView reloadData];
}

- (void)didMoveToWindow {
    if (self.window) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:kNotificationOrientationTransit object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - update constraints
- (void)handleOrientationNotification:(NSNotification *)notify {
    id<UIViewControllerTransitionCoordinator> coordinator = [notify object];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self layoutIfNeeded];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        }];
    }
    else {
        [self layoutIfNeeded];
    }
}

#pragma mark - CMTipsViewDelegate
- (void)tipsView:(id<CMTipsViewProtocol>)view onShowed:(NSDictionary *)infoDic{
    if(view.priority == fullAccessTipEmoticon){
        [CMInfoc reportCheetahkeyboard_tip_showWithValue:7];
    }
}

- (void)tipsView:(id<CMTipsViewProtocol>)view onTapped:(NSDictionary *)infoDic{
    if(view.priority == fullAccessTipEmoticon){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onKeyboard:otherClik:)]){
            [(id<CMEmoticonKeyboardViewDelegate>)self.delegate onKeyboard:self otherClik:@{@"gotoFullAccess":@""}];
            
            [CMInfoc reportCheetahkeyboard_tip_clickWithValue:9];
            [CMInfoc reportCheetahkeyboard_tip_closeWithValue:7 closeType:4];
        }
    }
}
- (void)tipsView:(id<CMTipsViewProtocol>)view onSwiped:(NSDictionary *)infoDic{
    if(view.priority == fullAccessTipEmoticon){
    [CMInfoc reportCheetahkeyboard_tip_closeWithValue:7 closeType:2];
    }
}
-(void)tipsView:(id<CMTipsViewProtocol>)view onRemoved:(NSDictionary *)infoDic {
    if(view.priority == fullAccessTipEmoticon){
    [CMInfoc reportCheetahkeyboard_tip_closeWithValue:7 closeType:1];
    }
}

#pragma mark - CMEmoticonCellDelegate
//点击了 cell 上的删除按钮
- (void)onDeleteCell:(CMEmoticonCell *)cell{
    NSIndexPath *indexPath =  [self.collectionView indexPathForCell:cell];
    CMEmoticonCollectionModel* model =  [_modelArray objectAtIndex:indexPath.row];
    [_modelArray removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath] ];
    if(model.imagePath){
        [[NSFileManager defaultManager] removeItemAtPath:model.imagePath error:nil];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!_modelArray[indexPath.row].deleteBtnHide)return;
    if(kCMKeyboardManager.isFullAccessAllowed){
        
        if(_modelArray[indexPath.row].deleteBtnHide){
            if(!_modelArray[indexPath.row].imagePath){
                if (self.delegate && [self.delegate respondsToSelector:@selector(onKeyboard:openMakeEmoticonVC:)]){
                    [(id<CMEmoticonKeyboardViewDelegate>)self.delegate onKeyboard:self openMakeEmoticonVC:indexPath.row];
                }
            }else{
                NSString * gifPath = _modelArray[indexPath.row].imagePath;
                [CMBizHelper sendGifPath:gifPath];
                [self.pasteTip showInView:self anchorView:nil];
                [CMInfoc reportEmojiTapped:self.inSource emoji:@"ar-emoji"];
                [self.pasteTip mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.collectionView);
                }];
            }
        }
        
    }else{
        CMFullAccessTipView * fullAccessView = [[CMFullAccessTipView alloc] initWithFrame:CGRectZero];
        fullAccessView.priority = fullAccessTipEmoticon;
        fullAccessView.duration = 7.0f;
        fullAccessView.tipsType = CMTipsTypeEmoticons;
        fullAccessView.tipDelegate = self;
        fullAccessView.layer.zPosition = CGFLOAT_MAX;
        [fullAccessView showInView:self.superview anchorView:nil];
        [fullAccessView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.collectionView);
        }];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _modelArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CMEmoticonCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMEmoticonCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.deleteBtn.hidden = _modelArray[indexPath.row].deleteBtnHide;
    cell.backgroundColor = _modelArray[indexPath.row].backgroundColor;
    if(_modelArray[indexPath.row].imagePath){
        YYImage* image = [YYImage imageWithContentsOfFile:_modelArray[indexPath.row].imagePath];
        cell.imageView.image = image;
//        NSData * data = [NSData dataWithContentsOfFile:_modelArray[indexPath.row].imagePath];
//        cell.imageView.image = [YYImage imageWithData:data scale:0.1];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }else{
        cell.imageView.image = _modelArray[indexPath.row].image;
        if(indexPath.row == 0){
            cell.imageView.contentMode = UIViewContentModeCenter;
        }else{
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if([cell isKindOfClass:[CMEmoticonCell class]]){
        ((CMEmoticonCell*)cell).imageView.image= nil;
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(50, 6, 50, 6);
}
#pragma mark - get\set

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CMEmoticonCell class] forCellWithReuseIdentifier:NSStringFromClass([CMEmoticonCell class])];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.decelerationRate = 0.4f;
        if (IOS10_OR_LATER) {
            [_collectionView setPrefetchingEnabled:NO];
        }
    }
    return _collectionView;
}

- (CMEmoticonPasteTip *)pasteTip{
    if(!_pasteTip){
        _pasteTip = [[CMEmoticonPasteTip alloc] initWithFrame:CGRectZero];
        _pasteTip.priority = 0;
        _pasteTip.duration = 7.0f;
//        _pasteTip.tipsType = CMTipsTypeEmoticons;
        _pasteTip.tipDelegate = self;
        _pasteTip.layer.zPosition = CGFLOAT_MAX;
        _pasteTip.label.text = CMLocalizedString(@"Emoticon Paste", nil);
    }
    return _pasteTip;
}
@end
