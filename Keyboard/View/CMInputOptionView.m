//
//  CMInputOptionView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/9/9.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMInputOptionView.h"
#import "CMThemeManager.h"
#import "CMKeyboardManager.h"
#import "CMKeyModel.h"
#import "UIImage+Util.h"
#import "UIView+Util.h"
#import "UIDevice+Util.h"
#import "CMInputLogic.h"

@interface CMInputOptionCellView ()
@property (nonatomic, strong)UIImageView* bgView;
@property (nonatomic, assign)BOOL isSpaceType;
@property (nonatomic, strong)UILabel* textLabel;
@property (nonatomic, strong)CMKeyModel* keyModel;

@end

@implementation CMInputOptionCellView

- (instancetype)initWithFrame:(CGRect)frame option:(NSString *)option isSpaceType:(BOOL)isSpace{
    if (self = [super initWithFrame:frame]) {
        self.textLabel.text = option;
        self.isSpaceType = isSpace;
        [self addSubview:self.bgView];
        [self addSubview:self.textLabel];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@(frame.size.width));
            make.height.equalTo(@(frame.size.height));
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bgView);
        }];
    }
    return self;
}

- (void)setHighlight:(BOOL)highlight font:(UIFont *)font {
    [self.bgView setHighlighted:highlight];
    [self.textLabel setHighlighted:highlight];
    if (font) {
        [self.textLabel setFont:font];
    }
    [self setNeedsDisplay];
}

#pragma mark - getter/setter
- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [UIImageView new];
        _bgView.backgroundColor = [UIColor clearColor];
        [_bgView setImage:nil];
        UIImage* image = kCMKeyboardManager.themeManager.inputOptionHighlightBgImage;
        if (!self.isSpaceType)
        {
            if (image) {
                [_bgView setHighlightedImage:image];
            }
            else {
                [_bgView setHighlightedImage:[UIImage imageWithColor:kCMKeyboardManager.themeManager.inputOptionHighlightBgColor]];
            }
        }
    }
    return _bgView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        [_textLabel setTextColor:kCMKeyboardManager.themeManager.inputOptionTextColor];
        [_textLabel setHighlightedTextColor:kCMKeyboardManager.themeManager.inputOptionHighlightTextColor];
        [_textLabel setFont:[UIFont fontWithName:kCMKeyboardManager.themeManager.keyTextFontName size:18.0f]];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _textLabel;
}

@end


@interface CMInputOptionView ()
@property (nonatomic, strong)UIImageView* bgView;
@property (nonatomic, strong)UIStackView* stackView;
@property (nonatomic, strong)NSMutableArray<CMInputOptionCellView *> *inputOptionCellArray;
@property (nonatomic, copy)NSArray *inputOptions;
@property (nonatomic, assign)NSInteger selectedInputIndex;
@property (nonatomic, assign)CMKeyBtnPosition keyPosition;
@property (nonatomic, assign)UIEdgeInsets contentInset;
@property (nonatomic, assign)CGFloat spaceMoreViewScale;

@end

@implementation CMInputOptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if ([UIDevice currentDevice].isScreenPortrait) {
            self.contentInset = [CMBizHelper isiPhone] ? UIEdgeInsetsMake(-1, -5.2f, -10.1f, -5.2f) : UIEdgeInsetsMake(0, -14.0f, -18.0f, -14.0f);
        }
        else {
            self.contentInset = [CMBizHelper isiPhone] ? UIEdgeInsetsMake(0, -14.0f, -18.0f, -14.0f) : UIEdgeInsetsMake(0, -18.0f, -18.0f, -18.0f);
        }
        if ([[CMKeyboardManager sharedInstance] multiLanguage])
        {
            if ([[CMKeyboardManager sharedInstance].inputLogic keyboardType] == UIKeyboardTypeEmailAddress)
            {
                self.spaceMoreViewScale = 2.3;
            }
            else
            {
                self.spaceMoreViewScale = 1.8;
            }
        }
        else
        {
            if ([[CMKeyboardManager sharedInstance].inputLogic keyboardType] == UIKeyboardTypeEmailAddress)
            {
                self.spaceMoreViewScale = 1.855;
            }
            else
            {
                self.spaceMoreViewScale = 1.455;
            }
        }

        [self addSubview:self.bgView];
        [self addSubview:self.stackView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.stackView).insets(self.contentInset);
        }];
    }
    return self;
}

- (instancetype)initWithkeyButton:(CMKeyButton *)button {
    self = [self init];
    self.button = button;
    return self;
}

- (void)dealloc {
    kLogTrace();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.bgView.top <= 0) {
        self.bgView.top = 2;
        self.stackView.top = self.bgView.top - self.contentInset.top;
    }
    
    if (self.bgView.right >= self.boundRight) {
        self.bgView.right = self.boundRight - 2;
        self.stackView.right = self.bgView.right + self.contentInset.right;
    }
    
    if (self.bgView.left <= 0) {
        self.bgView.left = 2;
        self.stackView.left = self.bgView.left - self.contentInset.left;
    }
}

- (void)updateSelectedInputIndexForPoint:(CGPoint)point {
    if (self.button.keyModel.keyType == CMKeyTypeSwitchKeyboard) return;
    __block NSInteger selectedInputIndex = NSNotFound;
    CGPoint location = [self convertPoint:point fromView:self.button.superview];
    
    [self.inputOptionCellArray enumerateObjectsUsingBlock:^(CMInputOptionCellView*  _Nonnull cellView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect cellFrame = cellView.frame;
        CGRect keyRect = [self convertRect:cellFrame fromView:cellView.superview];
        CGRect infiniteKeyRect = CGRectMake(CGRectGetMinX(keyRect), 0, CGRectGetWidth(keyRect), NSIntegerMax);
        
        if (CGRectContainsPoint(infiniteKeyRect, location)) {
            selectedInputIndex = idx;
            *stop = YES;
        }
    }];
    
    if (selectedInputIndex == NSNotFound) {
        CGRect firstRect = [self.inputOptionCellArray firstObject].frame;
        CGRect firstKeyRect = [self convertRect:firstRect fromView:[self.inputOptionCellArray firstObject].superview];

        CGRect lastRect = [self.inputOptionCellArray lastObject].frame;
        CGRect lastKeyRect = [self convertRect:lastRect fromView:[self.inputOptionCellArray lastObject].superview];

        if (location.x <= CGRectGetMinX(firstKeyRect)) {
            selectedInputIndex = 0;
        }
        else if (location.x >= CGRectGetMaxX(lastKeyRect)) {
            selectedInputIndex = self.inputOptionCellArray.count-1;
        }
    }
    
    if (selectedInputIndex == NSNotFound) {
        selectedInputIndex = 0;
    }
    
    UIFont* normalFont = self.button.inputOptionsFont;
    UIFont* highlightFont = self.button.inputOptionsHighlightFont;
    if (self.button.keyModel.keyType == CMKeyTypeSpace)
    {
        normalFont = [UIFont systemFontOfSize:28.0f];
        highlightFont = [UIFont systemFontOfSize:45.0f];
    }
    
    if (self.selectedInputIndex != selectedInputIndex) {
        CMInputOptionCellView* oldCellView = [self.inputOptionCellArray objectAtIndex:self.selectedInputIndex];
        [oldCellView setHighlight:NO font:normalFont];
        CMInputOptionCellView* newCellView = [self.inputOptionCellArray objectAtIndex:selectedInputIndex];
        [newCellView setHighlight:YES font:highlightFont];
        self.selectedInputIndex = selectedInputIndex;
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
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.alignment = UIStackViewAlignmentCenter;
    }
    return _stackView;
}

- (NSMutableArray<CMInputOptionCellView *> *)inputOptionCellArray {
    if (!_inputOptionCellArray) {
        _inputOptionCellArray = [NSMutableArray array];
    }
    return _inputOptionCellArray;
}


- (void)setButton:(CMKeyButton *)button {
    if (button != _button) {
        _button = button;
        CGRect keyRect = [self.superview convertRect:self.button.frame fromView:self.button.superview];

        [self.inputOptionCellArray enumerateObjectsUsingBlock:^(CMInputOptionCellView * _Nonnull cellView, NSUInteger idx, BOOL * _Nonnull stop) {
            [cellView removeFromSuperview];
        }];
        [self.inputOptionCellArray removeAllObjects];
        
        if (button.position != CMKeyBtnPositionInner) {
            _keyPosition = button.position;
        } else {
            if(button.keyModel.keyType == CMKeyTypeSpace){
                _keyPosition = CMKeyBtnPositionInner;
            }else{
                CGFloat leftPadding = CGRectGetMinX(button.frame);
                CGFloat rightPadding = CGRectGetMaxX(button.superview.frame) - CGRectGetMaxX(button.frame);
                _keyPosition = (leftPadding > rightPadding ? CMKeyBtnPositionLeft : CMKeyBtnPositionRight);
            }
        }
        
        if (button.keyModel.parent.shiftKeyState != CMShiftKeyStateNormal) {
            // 当前为大写状态
            NSMutableArray *mArray = [NSMutableArray array];
            [button.keyModel.inputOptionArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:[[obj uppercaseString] lowercaseString]]) {
                    [mArray addObject:[obj uppercaseString]];
                }
            }];
            self.inputOptions = [mArray copy];
        }else{
            // 当前为小写状态
            self.inputOptions = button.keyModel.inputOptionArray;
        }
        CGFloat cellWidth = CGRectGetWidth(keyRect);
        CGFloat cellHeight = CGRectGetHeight(keyRect)*1.34;
        UIFont* normalFont = self.button.inputOptionsFont;
        UIFont* highlightFont = self.button.inputOptionsHighlightFont;

        if (self.button.keyModel.keyType == CMKeyTypeSpace) {
            cellWidth = ((CGRectGetWidth(keyRect) - 0.5) * self.spaceMoreViewScale) / (self.inputOptions.count);
            cellHeight = CGRectGetHeight(keyRect)*1.2;
            normalFont = [UIFont systemFontOfSize:28.0f];
            highlightFont = [UIFont systemFontOfSize:45.0f];
        }
        NSArray* options = self.inputOptions;
        NSInteger index = button.keyModel.inputOptionDefaultSelected < button.keyModel.inputOptionArray.count ? button.keyModel.inputOptionDefaultSelected : 0;

        if (self.button.keyModel.keyType == CMKeyTypeSpace) {
            [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.leading.greaterThanOrEqualTo(self.mas_leading);
                make.trailing.lessThanOrEqualTo(self.mas_trailing);
                make.bottom.equalTo(self.mas_top).offset(keyRect.origin.y-40.0);
                make.height.equalTo(@(cellHeight));
            }];
        }
        else if (_keyPosition == CMKeyBtnPositionLeft) {
            options = [[self.inputOptions reverseObjectEnumerator] allObjects];
            index = options.count - index - 1;
            
            [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self.mas_leading).offset(keyRect.origin.x + keyRect.size.width);
                make.bottom.equalTo(self.mas_top).offset(keyRect.origin.y-2);
                make.height.equalTo(@(cellHeight));
            }];
        }
        else if (_keyPosition == CMKeyBtnPositionRight) {
            [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.mas_leading).offset(keyRect.origin.x);
                make.bottom.equalTo(self.mas_top).offset(keyRect.origin.y-2);
                make.height.equalTo(@(cellHeight));
            }];
        }
        self.inputOptions = options;
        self.selectedInputIndex = index;
        [self.inputOptions enumerateObjectsUsingBlock:^(NSString *option, NSUInteger idx, BOOL * _Nonnull stop) {
            CMInputOptionCellView* cellView = [[CMInputOptionCellView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cellWidth, cellHeight) option:option isSpaceType:(self.button.keyModel.keyType == CMKeyTypeSpace)];
            [self.stackView addArrangedSubview:cellView];
            [self.inputOptionCellArray addObject:cellView];
            if (idx == _selectedInputIndex) {
                [cellView setHighlight:YES font:highlightFont];
            }
            else {
                [cellView setHighlight:NO font:normalFont];
            }
        }];
    }
}

@end
