//
//  CMFPSLabel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/4.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMFPSLabel.h"
#import "UIDevice+Util.h"

#define kSize CGSizeMake(200, 20)

@implementation CMFPSLabel {
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    UIFont *_font;
    UIFont *_subFont;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size = kSize;
    }
    self = [super initWithFrame:frame];
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    
    _font = [UIFont systemFontOfSize:14];
    _subFont = [UIFont systemFontOfSize:4];
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    return self;
}

- (void)didMoveToWindow {
    if (self.window) {
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else {
        [_link invalidate];
    }
}

- (void)dealloc {
    [_link invalidate];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS, %dMB, %dMB",(int)round(fps), (int)round([UIDevice residentSizeOfMemory]), (int)round([UIDevice usedSizeOfMemory])]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    
    self.attributedText = text;
}

@end
