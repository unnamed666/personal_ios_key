//
//  CMAssetModel.m
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMAssetModel.h"
#import "UIView+Util.h"
#import "CMImageManger.h"

@implementation CMAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset{
    CMAssetModel *model = [[CMAssetModel alloc]init];
    model.asset = asset;
    model.isSelected = false;
    return model;
}

@end

@implementation CMAlbumModel

-(void)setResult:(PHFetchResult *)result{
    _result = result;
    [[CMImageManger  sharedInstance]getAssetsFromFetchResult:result completionBlock:^(NSArray<CMAssetModel *> *arr) {
        _models = arr;
//        if (_selectedModels) {
//            [self checkSelectedModels];
//        }
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (CMAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (CMAssetModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

-(NSString *)name{
    if(_name){
        return _name;
    }
    return @"";
}


@end

@interface CMAlbumCell ()
@property (weak, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@end

@implementation CMAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return self;
}

- (void)setModel:(CMAlbumModel *)model {
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    [[CMImageManger sharedInstance] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger titleHeight = ceil(self.titleLabel.font.lineHeight);
    self.titleLabel.frame = CGRectMake(80, (self.height - titleHeight) / 2, self.width - 80 - 50, titleHeight);
    self.posterImageView.frame = CGRectMake(0, 0, 70, 70);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)selectedCountButton {
    if (!_selectedCountButton) {
        _selectedCountButton = [[UIButton alloc] init];
        _selectedCountButton.layer.cornerRadius = 12;
        _selectedCountButton.clipsToBounds = YES;
        _selectedCountButton.backgroundColor = [UIColor redColor];
        [_selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _selectedCountButton;
}

@end

