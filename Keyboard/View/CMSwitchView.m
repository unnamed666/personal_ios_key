//
//  CMSwitchView.m
//  PandaKeyboard Extension
//
//  Created by 姚宗超 on 2017/11/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMSwitchView.h"
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "CMKeyButton.h"

@interface CMSwitchCellView ()
@property (nonatomic, strong)UIImageView* bgView;
@property (nonatomic, strong)UIStackView* stackView;
@property (nonatomic, strong)UIImageView* iconImageView;
@property (nonatomic, strong)UILabel* textLabel;

@end

@implementation CMSwitchCellView

- (instancetype)initWithFrame:(CGRect)frame icon:(UIImage *)iconImg description:(NSString *)description {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        [self addSubview:self.stackView];
        
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.height.greaterThanOrEqualTo(@(KScalePt(39)));
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.iconImageView.image = iconImg;
        [self.iconImageView setImage:[iconImg imageWithTintColor:kCMKeyboardManager.themeManager.inputOptionTextColor]];
        [self.iconImageView setHighlightedImage:[iconImg imageWithTintColor:kCMKeyboardManager.themeManager.inputOptionHighlightTextColor]];

        self.textLabel.text = description;
        [self.stackView addArrangedSubview:self.iconImageView];
        [self.stackView addArrangedSubview:self.textLabel];
    }
    return self;
}

- (void)dealloc {
    kLogTrace();
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.textLabel.preferredMaxLayoutWidth = self.textLabel.frame.size.width;
//    [super layoutSubviews];
//}

- (void)setHighlight:(BOOL)highlight {
    [self.bgView setHighlighted:highlight];
    [self.iconImageView setHighlighted:highlight];
    [self.textLabel setHighlighted:highlight];
    [self setNeedsDisplay];
}

#pragma mark - getter/setter
- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [UIImageView new];
        _bgView.backgroundColor = [UIColor clearColor];
        [_bgView setImage:nil];
        UIImage* image = kCMKeyboardManager.themeManager.inputOptionHighlightBgImage;
        if (image) {
            [_bgView setHighlightedImage:image];
        }
        else {
            [_bgView setHighlightedImage:[UIImage imageWithColor:kCMKeyboardManager.themeManager.inputOptionHighlightBgColor]];
        }
    }
    return _bgView;
}


- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [UIStackView new];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionFill;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.layoutMargins = UIEdgeInsetsMake(KScalePt(0), KScalePt(11), KScalePt(0), KScalePt(11));
        [_stackView setLayoutMarginsRelativeArrangement:YES];
        _stackView.spacing = KScalePt(7.5);
    }
    return _stackView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KScalePt(19), KScalePt(19))];
        [_iconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _iconImageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        [_textLabel setTextColor:kCMKeyboardManager.themeManager.inputOptionTextColor];
        [_textLabel setHighlightedTextColor:kCMKeyboardManager.themeManager.inputOptionHighlightTextColor];
        [_textLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:KScalePt(13.0f)]];
//        [_textLabel setFont:[UIFont fontWithName:kCMKeyboardManager.themeManager.keyTextFontName size:13.0f]];
        _textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textLabel;
}

@end

@interface CMSwitchView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong)UIImageView* bgView;
@property (nonatomic, strong)UIStackView* stackView;
@property (nonatomic, strong)NSMutableArray<CMSwitchCellView *>* cellViewArray;
@property (nonatomic, assign)NSInteger selectedInputIndex;
@property (nonatomic, strong)UITapGestureRecognizer* tapGesture;
@property (nonatomic, strong)UIPanGestureRecognizer* panGesture;

@end

@implementation CMSwitchView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _selectedInputIndex = 0;
        
        [self addSubview:self.bgView];
        [self addSubview:self.stackView];
                
        CMSwitchCellView* switchCell = [[CMSwitchCellView alloc] initWithFrame:CGRectZero icon:[UIImage imageNamed:@"switch_icon_language"] description:CMLocalizedString(@"Switch to next keyboard", nil)];
        CMSwitchCellView* settingCell = [[CMSwitchCellView alloc] initWithFrame:CGRectZero icon:[UIImage imageNamed:@"switch_icon_setting"] description:CMLocalizedString(@"Setting", nil)];
        [self.cellViewArray addObject:switchCell];
        [self.cellViewArray addObject:settingCell];
        
        [self.cellViewArray enumerateObjectsUsingBlock:^(CMSwitchCellView * _Nonnull cellView, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.stackView addArrangedSubview:cellView];
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.stackView);
        }];
        
        [self addGestureRecognizer:self.tapGesture];
        [self addGestureRecognizer:self.panGesture];
        
        [self.tapGesture requireGestureRecognizerToFail:self.panGesture];
    }
    return self;
}

- (void)dealloc {
    kLogTrace();
}

- (void)updateSelectedInputIndexForPoint:(CGPoint)point {
    __block NSInteger selectedInputIndex = NSNotFound;

    [self.cellViewArray enumerateObjectsUsingBlock:^(CMSwitchCellView*  _Nonnull cellView, NSUInteger idx, BOOL * _Nonnull stop) {
        [cellView setHighlight:NO];

        CGRect cellFrame = cellView.frame;
        CGRect keyRect = [self.superview convertRect:cellFrame fromView:cellView.superview];
        CGRect infiniteKeyRect = CGRectMake(0, CGRectGetMinY(keyRect), NSIntegerMax, CGRectGetHeight(keyRect));

        if (CGRectContainsPoint(infiniteKeyRect, point)) {
            selectedInputIndex = idx;
//            *stop = YES;
        }
    }];
    
    // 不需要默认值，先注掉
//    if (selectedInputIndex == NSNotFound) {
//        CGRect firstRect = [self.cellViewArray firstObject].frame;
//        CGRect firstKeyRect = [self.superview convertRect:firstRect fromView:[self.cellViewArray firstObject].superview];
//
//        CGRect lastRect = [self.cellViewArray lastObject].frame;
//        CGRect lastKeyRect = [self.superview convertRect:lastRect fromView:[self.cellViewArray lastObject].superview];
//
//        if (point.y <= CGRectGetMinY(firstKeyRect)) {
//            selectedInputIndex = 0;
//        }
//        else if (point.y >= CGRectGetMaxY(lastKeyRect)) {
//            selectedInputIndex = self.cellViewArray.count-1;
//        }
//    }
//
//    if (selectedInputIndex == NSNotFound) {
//        selectedInputIndex = 0;
//    }
    
    if (selectedInputIndex != NSNotFound) {
        CMSwitchCellView* newCellView = [self.cellViewArray objectAtIndex:selectedInputIndex];
        [newCellView setHighlight:YES];
    }
    self.selectedInputIndex = selectedInputIndex;
    
//    if (self.selectedInputIndex != selectedInputIndex) {
//        CMSwitchCellView* oldCellView = [self.cellViewArray objectAtIndex:self.selectedInputIndex];
//        [oldCellView setHighlight:NO];
//        CMSwitchCellView* newCellView = [self.cellViewArray objectAtIndex:selectedInputIndex];
//        [newCellView setHighlight:YES];
//        self.selectedInputIndex = selectedInputIndex;
//    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint pt = [tapGesture locationInView:self];
    if (!CGRectContainsPoint(self.bgView.frame, pt)) {
        self.selectedInputIndex = NSNotFound;
    }
    else {
        [self updateSelectedInputIndexForPoint:pt];
    }
    if (self.delegate) {
        [self.delegate onSwitchView:self selectedIndex:self.selectedInputIndex keyModel:self.button.keyModel];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    }else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint pt = [panGesture locationInView:self];
        [self updateSelectedInputIndexForPoint:pt];
    }else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        if (self.delegate) {
            [self.delegate onSwitchView:self selectedIndex:self.selectedInputIndex keyModel:self.button.keyModel];
        }
    }
}

#pragma mark - setter/getter
- (UIImageView *)bgView {
    if (!_bgView) {
        UIImage* image = kCMKeyboardManager.themeManager.inputOptionBgImage;
        if (image) {
            _bgView = [[UIImageView alloc] initWithImage:kCMKeyboardManager.themeManager.inputOptionBgImage];
        }
        else {
            _bgView = [UIImageView new];
            _bgView.backgroundColor = kCMKeyboardManager.themeManager.inputOptionBgColor;
        }
    }
    return _bgView;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [UIStackView new];
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.alignment = UIStackViewAlignmentFill;
        if ([kCMKeyboardManager.themeManager.currentThemeName isEqualToString:@"default"]) {
            _stackView.layoutMargins = UIEdgeInsetsMake(KScalePt(4.5), KScalePt(4), KScalePt(10), KScalePt(4));
        }
        else {
            _stackView.layoutMargins = UIEdgeInsetsMake(KScalePt(4.5), KScalePt(4), KScalePt(4.5), KScalePt(4));
        }
        [_stackView setLayoutMarginsRelativeArrangement:YES];
        _stackView.spacing = KScalePt(5);
    }
    return _stackView;
}

- (NSMutableArray<CMSwitchCellView *> *)cellViewArray {
    if (!_cellViewArray) {
        _cellViewArray = [NSMutableArray array];
    }
    return _cellViewArray;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (void)setButton:(CMKeyButton *)button {
    if (button != _button) {
        _button = button;
        CGRect keyRect = [self convertRect:self.button.frame fromView:self.button.superview];
        
        self.selectedInputIndex = NSNotFound;

        [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.mas_leading).offset(keyRect.origin.x);
            make.trailing.lessThanOrEqualTo(self.mas_trailing).offset(KScalePt(5));
            make.bottom.equalTo(self.mas_top).offset(keyRect.origin.y);
            make.height.greaterThanOrEqualTo(@(0));
        }];
        
        [self.cellViewArray enumerateObjectsUsingBlock:^(CMSwitchCellView * _Nonnull cellView, NSUInteger idx, BOOL * _Nonnull stop) {
            [cellView setHighlight:NO];
//            if (idx == self.selectedInputIndex) {
//                [cellView setHighlight:YES];
//            }
//            else {
//                [cellView setHighlight:NO];
//            }
        }];
    }
}

@end
