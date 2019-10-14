//
//  CMCollectionViewCell.m
//  iMessage
//
//  Created by yanzhao on 2017/9/23.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMCollectionViewCell.h"
#import "YYAnimatedImageView.h"
#import <Messages/Messages.h>
@interface CMCollectionViewTopCell()
@property (weak, nonatomic) IBOutlet UILabel *tipLable;

@end
@implementation CMCollectionViewTopCell
- (void)awakeFromNib{
    [super awakeFromNib];
    self.tipLable.text = CMLocalizedString(@"iMessage_Tip", nil);
    
}
@end

@interface CMCollectionViewCell()
//@property (nonatomic, strong)MSStickerView * stickerView;
//@property (nonatomic ,strong)YYAnimatedImageView * imageView;
@end

@implementation CMCollectionViewCell
//- (void)awakeFromNib{
//    [super awakeFromNib];
//}
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
////        self.stickerView = [[MSStickerView alloc] initWithFrame:frame];
////        [self addSubview:_stickerView];
//        
////        [self.contentView  addSubview:self.imageView];
////        self.imageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);;
//    }
//    return self;
//}
//
//- (void)layoutSubviews{
//    [super layoutSubviews];
////    self.imageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);;
//}

//- (YYAnimatedImageView *)imageView{
//    if(!_imageView){
//        _imageView = [YYAnimatedImageView new];
//        _imageView.layer.borderColor=[UIColor redColor].CGColor;
//        _imageView.layer.borderWidth =  1;
//    }
//    return _imageView;
//}

//- (void)setSticker:(MSSticker *)sticker{
//    _stickerView.sticker = sticker;
//    [_stickerView startAnimating];
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
//}
//
//- (MSStickerView *)stickerView{
//    return  _stickerView.sticker;
//}
@end
