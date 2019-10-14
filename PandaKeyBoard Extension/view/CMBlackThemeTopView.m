//
//  CMBlackThemeTopView.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/8/3.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMBlackThemeTopView.h"
#import "CMSimmeringMaskLayer.h"
#import "CMBizHelper.h"

@interface CMBlackThemeTopView ()

@property (nonatomic, strong)CMSimmeringMaskLayer* maskLayer;
@property (nonatomic, strong)CMSimmeringMaskLayer* maskLayer2;

@property (nonatomic, strong)CAEmitterLayer * emitterLayer;
@property (nonatomic, strong)CAEmitterLayer * foundtainEmitter;


@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAShapeLayer *waveLayer;  // 绘制波形

// 绘制波形的变量定义，使用波形曲线y=Asin(ωx+φ)+k进行绘制
@property (nonatomic, assign) CGFloat waveAmplitude;  // 波纹振幅，A
@property (nonatomic, assign) CGFloat waveCycle;      // 波纹周期，T = 2π/ω

@property (nonatomic, assign) CGFloat offsetX;        // 波浪x位移，φ
@property (nonatomic, assign) CGFloat waveSpeed;      // 波纹速度，用来累加到相位φ上，达到波纹水平移动的效果

// 用来计算波峰一定范围内的波动值
@property (nonatomic, assign) BOOL increase;
@property (nonatomic, assign) CGFloat variable;

@property (nonatomic, assign) BOOL waveStop;


@end


@implementation CMBlackThemeTopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.offsetX = 0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.offsetX = 0;
    }
    return self;
}


- (void)dealloc {
    kLogTrace();
}


- (void)defaultConfig:(CGFloat)toolbarHeight {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds =YES;
    self.toolbarHeight = toolbarHeight;
    
    [self setupWaveLine];
    [self startWave];
//    [self performSelector:@selector(startWave) withObject:nil afterDelay:0.2];
    self.waveSpeed = 0.02;
    
    self.emitterLayer.birthRate = 2;
    self.emitterLayer.frame = CGRectMake(0, _toolbarHeight-6, kScreenWidth, 0);
    _foundtainEmitter.frame = CGRectMake(0, _toolbarHeight-6, kScreenWidth, 0);

    CGFloat length = kScreenWidth;
    
    self.layer.mask = self.maskLayer2;
    _maskLayer2.frame =  CGRectMake(0.0, 0.0, length, _toolbarHeight);
    _maskLayer.frame =  CGRectMake(0.0, 0.0, length*3, _toolbarHeight);
    
}


- (void)setupWaveLine{

    
    self.waveCycle = 2.66 * M_PI / kScreenWidth;     // 影响波长
    self.waveSpeed = 0.2 / M_PI;
    self.variable = 1.5;
    self.waveAmplitude = 3.0;
    if(!_waveLayer){
        _waveLayer = [CAShapeLayer layer];
        _waveLayer.strokeColor = [UIColor colorWithRed:64.0f/255 green:226.0f/255 blue:237.0f/255 alpha:1.0].CGColor;
        _waveLayer.fillColor = nil;
        _waveLayer.lineWidth =1.5f;
        [self.layer addSublayer:_waveLayer];
    }

    [self setCurrentWaveLayerPath];
    
}

#pragma mark - public
- (void)stopWave{
    self.waveStop = YES;
    self.displayLink.paused = YES;
    self.emitterLayer.birthRate = 0;
}
- (void)toucheBeganX:(int)x{
    if(!self.superview)return;
    
    if (self.waveSpeed > 0){
        
    }else{
        self.offsetX = x;
    }
    
   [self startWave];
    
    if(self.emitterLayer.birthRate != 2){
        self.emitterLayer.birthRate = 2;
    }
    if(self.foundtainEmitter.birthRate != 5){
        self.foundtainEmitter.birthRate = 5;
    }
    _foundtainEmitter.emitterPosition = CGPointMake(x, 0);
    
    
    
    self.layer.mask = self.maskLayer;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:nil];
    _maskLayer.locations = @[@(0.45),
                             @(0.5),
                             @(0.55)];
    _maskLayer.position =  CGPointMake(-kScreenWidth +x-kScreenWidth/2, 0);
    [CATransaction commit];
    
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(foundtainEmitterBirthRateZero) withObject:nil afterDelay:0.2];
    
}
- (void)toucheMoveDistanceX:(int)x{
    if(!self.superview)return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _maskLayer.position = CGPointMake(_maskLayer.position.x+x, 0);
    [CATransaction commit];
}
- (void)toucheEnded{
    self.waveStop = YES;
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:0.6];
        [CATransaction setCompletionBlock:^{
            self.layer.mask = _maskLayer2;
        }];
        _maskLayer.locations = @[@(0.48),
                                 @(0.5),
                                 @(0.52)];
    }
    [CATransaction commit];
//    self.layer.mask = _maskLayer2;
    [self performSelector:@selector(changeEmitterBirthRate) withObject:nil afterDelay:0.5];
}


#pragma mark - get/set

- (CMSimmeringMaskLayer *)maskLayer{
    if(!_maskLayer){
        _maskLayer = [CMSimmeringMaskLayer layer];
        CGFloat length = kScreenWidth;
        
        UIColor *maskedColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        UIColor *unmaskedColor = [UIColor colorWithWhite:1.0 alpha:1];
    
        // Create a gradient from masked to unmasked to masked.
        _maskLayer.colors = @[(__bridge id)maskedColor.CGColor, (__bridge id)unmaskedColor.CGColor, (__bridge id)maskedColor.CGColor];
        _maskLayer.locations = @[@(0.45),
                                 @(0.5),
                                 @(0.55)];
        
        _maskLayer.anchorPoint = CGPointZero;
        _maskLayer.startPoint = CGPointMake(0, 0.0);
        _maskLayer.endPoint = CGPointMake(1, 0.0);
        _maskLayer.position = CGPointMake(0, 0.0);
        _maskLayer.bounds = CGRectMake(0.0, 0.0, length*3, _toolbarHeight);
        _maskLayer.position = CGPointMake(-length*2, 0);
        _maskLayer.fadeLayer.opacity = 0.0;
        _maskLayer.opacity = 1.0;
    }
    return _maskLayer;
}

- (CMSimmeringMaskLayer *)maskLayer2{
    if(!_maskLayer2){
        _maskLayer2 = [CMSimmeringMaskLayer layer];
        
        UIColor *maskedColor = [UIColor colorWithWhite:0.5 alpha:0.4];
//        UIColor *unmaskedColor = [UIColor colorWithWhite:1.0 alpha:1];
        
        _maskLayer2.colors =  @[(__bridge id)maskedColor.CGColor, (__bridge id)maskedColor.CGColor, (__bridge id)maskedColor.CGColor];
        _maskLayer2.locations = @[@(0.4),
                                  @(0.5),
                                  @(0.6)];
        _maskLayer2.anchorPoint = CGPointZero;
        _maskLayer2.startPoint = CGPointMake(0, 0.0);
        _maskLayer2.endPoint = CGPointMake(1, 0.0);
        _maskLayer2.position = CGPointMake(0, 0);
        _maskLayer2.fadeLayer.opacity = 0.0;
        _maskLayer2.opacity = 1.0;
    }
    return _maskLayer2;
}

- (CADisplayLink *)displayLink{
    if(!_displayLink){
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setCurrentWave:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (CAEmitterLayer *)emitterLayer{
    if(!_emitterLayer){
        _emitterLayer=[[CAEmitterLayer alloc] init];
        _emitterLayer.frame = CGRectMake(0, _toolbarHeight-8, kScreenWidth, 0);
        _emitterLayer.birthRate = 0;
        _emitterLayer.preservesDepth = YES;
        _emitterLayer.emitterSize= CGSizeMake(kScreenWidth*2, 0);
        _emitterLayer.emitterShape = kCAEmitterLayerLine;
        _emitterLayer.emitterMode = kCAEmitterLayerOutline;
        _emitterLayer.renderMode = kCAEmitterLayerUnordered;
        
        CGColorRef  color =  [UIColor colorWithRed:64.0f/255 green:226.0f/255 blue:237.0f/255 alpha:1.0].CGColor;
        UIImage * image = [UIImage imageNamed:@"snowflake"];
        
        CAEmitterCell * snow = [CAEmitterCell emitterCell];
        snow.birthRate			= 1;
        snow.emissionLongitude =-M_PI_2;
        snow.emissionRange = M_PI_2 ;
        snow.lifetime			= 5;
        snow.lifetimeRange     = 2;
        snow.velocity			= 5;
        snow.velocityRange		= 5;
        snow.xAcceleration		= -5;
        snow.yAcceleration		= -5;
        snow.contents			= (id) [image CGImage];
        snow.scale				= 1.0;
        snow.alphaSpeed		= -0.12;
        snow.color =  color;
        
        
        CAEmitterCell * snowSmall = [CAEmitterCell emitterCell];
        
        
        
        snowSmall.birthRate			= 1;
        snowSmall.emissionLongitude =-M_PI_2;
        snowSmall.emissionRange = M_PI_2 ;
        snowSmall.lifetime			= 5;
        snowSmall.lifetimeRange     = 2;
        snowSmall.velocity			= 5;
        snowSmall.velocityRange		= 5;
        snowSmall.xAcceleration		= 5;
        snowSmall.yAcceleration		= -5;
        snowSmall.contents			= (id) [image CGImage];
        snowSmall.scale				= 0.5;
        snowSmall.alphaSpeed		= -0.12;
        
        snowSmall.color = color;
        
        _emitterLayer.emitterCells=@[snow,snowSmall];
        
        [self.layer addSublayer:_emitterLayer];
    }
        
    return _emitterLayer;
}


- (CAEmitterLayer *)foundtainEmitter{
    if(!_foundtainEmitter){
        _foundtainEmitter = [CAEmitterLayer layer];
        _foundtainEmitter.frame = CGRectMake(0, _toolbarHeight-6, kScreenWidth, 0);
        _foundtainEmitter.preservesDepth = YES;
        _foundtainEmitter.emitterSize = CGSizeMake(10, 0);
        _foundtainEmitter.emitterShape = kCAEmitterLayerRectangle;
        
//        _foundtainEmitter.emitterMode = kCAEmitterLayerOutline;
//        _foundtainEmitter.renderMode = kCAEmitterLayerUnordered;
        
//        CGColorRef  color =  [UIColor colorWithRed:64.0f/255 green:226.0f/255 blue:237.0f/255 alpha:0.8].CGColor;
        UIImage * image = [UIImage imageNamed:@"snowflake"];
        
        CAEmitterCell * circle = [CAEmitterCell emitterCell];
        circle.birthRate			= 1;
        circle.emissionLongitude =1.5;
        circle.lifetime			= 1.3;
        circle.velocity			= -30;
        circle.velocityRange    = 30;
        circle.emissionRange		= 1.1;
        circle.yAcceleration		= -5;
        circle.contents			= (id) [image CGImage];
        circle.scale				= 1.5;
        circle.alphaSpeed		= -0.2;
        circle.color = [UIColor colorWithRed:64.0f/255 green:226.0f/255 blue:237.0f/255 alpha:0.3].CGColor;
        
        CAEmitterCell * circle2 = [CAEmitterCell emitterCell];
        circle2.birthRate			= 1;
        circle2.emissionLongitude = 1.5;
        circle2.lifetime			= 1.3;
        circle2.velocity			= -30;
        circle2.velocityRange    = 30;
        circle2.emissionRange		= 1.1;
        circle2.yAcceleration		= -5;
        circle2.contents			= (id) [image CGImage];
        circle2.scale				= 1.0;
        circle2.alphaSpeed		= -0.2;
        circle2.color = [UIColor colorWithRed:64.0f/255 green:226.0f/255 blue:237.0f/255 alpha:0.8].CGColor;
        
        CAEmitterCell * circle3 = [CAEmitterCell emitterCell];
        circle3.birthRate			= 1;
        circle3.emissionLongitude = 1.5;
        circle3.lifetime			= 1.3;
        circle3.velocity			= -30;
        circle3.velocityRange    = 30;
        circle3.emissionRange		= 1.1;
        circle3.yAcceleration		= -5;
        circle3.contents			= (id) [image CGImage];
        circle3.scale				= 0.5;
        circle3.alphaSpeed		= -0.2;
        circle3.color = [UIColor colorWithRed:64.0f/255 green:226.0f/255 blue:237.0f/255 alpha:1.0].CGColor;
        
        _foundtainEmitter.emitterCells = @[circle,circle2,circle3];
        [self.layer addSublayer:_foundtainEmitter];
    }
    return _foundtainEmitter;
}

#pragma mark - private

- (void)startWave{
    self.waveStop = NO;
    self.waveSpeed = 0.2 / M_PI;
    self.displayLink.paused = NO;
}

- (void)foundtainEmitterBirthRateZero{
    _foundtainEmitter.birthRate = 0;
}
- (void)changeEmitterBirthRate{
    _emitterLayer.birthRate =1;
}


- (void)setCurrentWave:(CADisplayLink *)displayLink
{
    
    if(self.waveStop){
        [self amplitudeReduce];
        if (self.waveSpeed <= 0)
        {
            self.displayLink.paused = YES;
            return;
        }
    }else{
        [self amplitudeChanged];
        
    }
    self.offsetX += self.waveSpeed;
    [self setCurrentWaveLayerPath];
}

- (void)setCurrentWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = self.bounds.size.height;
    CGFloat width = kScreenWidth;
    for (float x = 0.0f; x <= width; x++)
    {
        // 正弦波浪公式
        double s = sin(self.waveCycle * x + self.offsetX);
        double w = self.waveAmplitude * s;
//                NSLog(@"%f",w);
        y = self.bounds.size.height - 4 +w;
        if(x==0){
            CGPathMoveToPoint(path, nil, x, y);
        }else{
            CGPathAddLineToPoint(path, nil, x, y);
        }
        
    }
    
    _waveLayer.path = path;
    CGPathRelease(path);
}
- (void)amplitudeChanged
{
    // 波峰在一定范围之内进行轻微波动
    
    // 波峰该继续增大或减小
    if (self.increase)
    {
        self.variable += 0.01;
    }
    else
    {
        self.variable -= 0.01;
    }
    
    // 变化的范围
    if (self.variable <= 1)
    {
        self.increase = YES;
    }
    
    if (self.variable >= 1.6)
    {
        self.increase = NO;
    }
    
    // 根据variable值来决定波峰
    self.waveAmplitude = self.variable * 2;
}

- (void)amplitudeReduce
{
    if(self.waveSpeed >0.02){
        self.waveSpeed -= 0.0002;
    }
}
@end
