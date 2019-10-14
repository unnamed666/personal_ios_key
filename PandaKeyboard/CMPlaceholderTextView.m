//
//  CMPlaceholderTextView.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/5/30.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMPlaceholderTextView.h"

@implementation CMPlaceholderTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 5;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
        
    }
    return self;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    [self setNeedsDisplay];
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

-(void)textDidChange
{
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    if ([self hasText]) return;
    NSMutableDictionary * attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = self.placeholderColor ? self.placeholderColor : [UIColor grayColor];
    attrs[NSFontAttributeName] = self.font ? self.font : [UIFont systemFontOfSize:18];
    
    CGFloat x = 5;
    CGFloat y = 8;
    CGFloat w = self.frame.size.width - 2 * x;
    CGFloat h = self.frame.size.height - 2 * y;
    CGRect placeholderRect = CGRectMake(x, y, w, h);
    [self.placeholder drawInRect:placeholderRect withAttributes:attrs];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
