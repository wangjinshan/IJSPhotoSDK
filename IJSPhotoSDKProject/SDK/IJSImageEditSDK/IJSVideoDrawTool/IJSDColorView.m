//
//  IJSDColorView.m
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSDColorView.h"

@interface IJSDColorView ()
@property (nonatomic, weak) UIImageView *colorWidthImage; // 宽度
@property (nonatomic, assign) CGFloat r;                  // r
@property (nonatomic, assign) CGFloat g;                  // g
@property (nonatomic, assign) CGFloat b;                  // b
@property (nonatomic, weak) UISlider *rSlide;             // r
@property (nonatomic, weak) UISlider *gSlide;             // r
@property (nonatomic, weak) UISlider *bSlide;             // r
@property (nonatomic, assign) CGFloat width;              // 宽度
@property (nonatomic, weak) UIImageView *widthImage;      // 宽度条
@end

@implementation IJSDColorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _createdUI];
    }
    return self;
}

- (void)_createdUI
{
    UISlider *r = [[UISlider alloc] init];
    r.minimumValue = 1;
    r.maximumValue = 255;
    r.value = 255 / 2;
    self.r = r.value;
    r.minimumTrackTintColor = [UIColor redColor];
    [r addTarget:self action:@selector(rAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:r];
    r.frame = CGRectMake(10, 2, self.frame.size.width - 110, 20);
    self.rSlide = r;

    UISlider *g = [[UISlider alloc] init];
    g.minimumValue = 1;
    g.maximumValue = 255;
    g.value = 255 / 2;
    self.g = g.value;
    g.minimumTrackTintColor = [UIColor greenColor];
    [g addTarget:self action:@selector(gAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:g];
    g.frame = CGRectMake(10, CGRectGetMaxY(self.rSlide.frame) + 10, self.frame.size.width - 110, 20);
    self.gSlide = g;

    UISlider *b = [[UISlider alloc] init];
    b.minimumValue = 1;
    b.maximumValue = 255;
    b.value = 255 / 2;
    self.b = b.value;
    b.minimumTrackTintColor = [UIColor blueColor];
    [b addTarget:self action:@selector(bAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:b];
    b.frame = CGRectMake(10, CGRectGetMaxY(self.gSlide.frame) + 10, CGRectGetWidth(self.rSlide.frame), 20);
    self.bSlide = b;

    // 动态指示图
    UIImageView *widthImage = [[UIImageView alloc] initWithFrame:self.bounds];
    widthImage.userInteractionEnabled = YES;
    widthImage.backgroundColor = [UIColor clearColor];
    self.width = 25;
    self.widthImage = widthImage;
    widthImage.image = [self widthSliderBackgroundWithRadius:10];
    [self addSubview:widthImage];
    widthImage.frame = CGRectMake(10, CGRectGetMaxY(self.bSlide.frame) + 15, CGRectGetWidth(self.rSlide.frame), 20);

    UISlider *widthSlide = [[UISlider alloc] init];
    widthSlide.minimumValue = 1;
    widthSlide.maximumValue = 50;
    widthSlide.value = 25;
    [widthImage addSubview:widthSlide];
    widthSlide.minimumTrackTintColor = [UIColor clearColor];
    widthSlide.maximumTrackTintColor = [UIColor clearColor];
    [widthSlide addTarget:self action:@selector(widthSlideAction:) forControlEvents:UIControlEventValueChanged];
    widthSlide.frame = CGRectMake(0, 0, CGRectGetWidth(widthImage.frame), 20);

    UIImageView *colorWidthImage = [[UIImageView alloc] init];
    colorWidthImage.backgroundColor = [UIColor clearColor];
    colorWidthImage.frame = CGRectMake(CGRectGetMaxX(self.rSlide.frame), CGRectGetMaxY(self.rSlide.frame), 100, 100);
    [self addSubview:colorWidthImage];
    self.colorWidthImage = colorWidthImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.colorWidthImage.image = [self drawRoundImageWithView:self.colorWidthImage radius:self.width color:[UIColor colorWithRed:self.r / 256.0 green:self.g / 256.0 blue:self.b / 256.0 alpha:1]];
}
// 改变颜色
- (void)rAction:(UISlider *)r
{
    self.r = r.value;
    UIColor *color = [UIColor colorWithRed:self.r / 256.0 green:self.g / 256.0 blue:self.b / 256.0 alpha:1];
    self.colorWidthImage.image = [self drawRoundImageWithView:self.colorWidthImage radius:self.width color:color];
    if (self.rCallBack)
        self.rCallBack(self.width, color);
}
- (void)gAction:(UISlider *)g
{
    self.g = g.value;
    UIColor *color = [UIColor colorWithRed:self.r / 256.0 green:self.g / 256.0 blue:self.b / 256.0 alpha:1];
    self.colorWidthImage.image = [self drawRoundImageWithView:self.colorWidthImage radius:self.width color:color];
    if (self.gCallBack)
        self.gCallBack(self.width, color);
}

- (void)bAction:(UISlider *)b
{
    self.b = b.value;
    UIColor *color = [UIColor colorWithRed:self.r / 256.0 green:self.g / 256.0 blue:self.b / 256.0 alpha:1];
    self.colorWidthImage.image = [self drawRoundImageWithView:self.colorWidthImage radius:self.width color:color];
    if (self.bCallBack)
        self.bCallBack(self.width, color);
}
- (void)widthSlideAction:(UISlider *)slide
{
    self.width = slide.value;
    UIColor *color = [UIColor colorWithRed:self.r / 256.0 green:self.g / 256.0 blue:self.b / 256.0 alpha:1];
    self.colorWidthImage.image = [self drawRoundImageWithView:self.colorWidthImage radius:self.width color:color];
    if (self.widthCallBack)
        self.widthCallBack(self.width, color);
}
// 绘制一个自定义的路径
- (UIImage *)widthSliderBackgroundWithRadius:(CGFloat)radius
{
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 10 - 100, 20);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(0, 10);
    CGPoint endPoint = CGPointMake([[UIScreen mainScreen] bounds].size.width - 10 - 100 - 10, 10);
    [path moveToPoint:startPoint]; //起点
    [path addArcWithCenter:startPoint radius:5 startAngle:-M_PI / 2 endAngle:M_PI / 2 clockwise:NO];
    [path addLineToPoint:CGPointMake(endPoint.x, 20)];
    [path addArcWithCenter:endPoint radius:radius startAngle:M_PI / 2 endAngle:-M_PI / 2 clockwise:NO];
    [path addLineToPoint:startPoint];
    [[UIColor redColor] set];
    [path fill];
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmp;
}
#pragma mark 划圆
- (UIImage *)drawRoundImageWithView:(UIView *)view radius:(CGFloat)radius color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
    CGPoint center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);

    UIBezierPath *round = [UIBezierPath bezierPath];
    [round moveToPoint:CGPointZero];
    [round addArcWithCenter:center radius:view.frame.size.height / 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [[color colorWithAlphaComponent:0.3] set];
    [round fill];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addArcWithCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [[UIColor blackColor] set];
    [path fill];

    UIBezierPath *minPath = [UIBezierPath bezierPath];
    [minPath moveToPoint:CGPointZero];
    [minPath addArcWithCenter:center radius:radius - 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [color set];
    [minPath fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
