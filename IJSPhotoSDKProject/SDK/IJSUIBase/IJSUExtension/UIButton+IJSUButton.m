//
//  UIButton+IJSUButton.m
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UIButton+IJSUButton.h"
#import "IJSUConst.h"

@implementation UIButton (IJSUButton)

// 添加弹跳动画
- (void)addSpringAnimation
{
    if (@available(iOS 9.0, *))
    {
        CASpringAnimation *spring = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
        spring.toValue = @(2);
        spring.removedOnCompletion = NO;
        spring.duration = spring.settlingDuration;
        [self.layer addAnimation:spring forKey:nil];
        spring.toValue = @(1);
        spring.duration = spring.settlingDuration;
        [self.layer addAnimation:spring forKey:nil];
    }
}

// 划圆
- (void)drawCirleWithRadius:(CGFloat)radius fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor isClick:(BOOL)isClick
{
    for (CALayer *layer in self.layer.sublayers)
    {
        if (!layer.hidden)
        {
            [layer removeFromSuperlayer];
        }
    }

    UIGraphicsBeginImageContext(self.bounds.size);
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f) radius:isClick ? radius + 2 : radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    layer.fillColor = fillColor.CGColor; //填充色
    layer.allowsEdgeAntialiasing = YES;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    if (isClick)
    {
        layer.strokeColor = strokeColor.CGColor; //边缘的颜色 描边
        layer.lineWidth = 2.f;                   //线宽
    }
    layer.path = path.CGPath; //从贝塞尔曲线获得形状
    [path fill];              //此方法为填充圆的方法
    UIGraphicsEndImageContext();
    [self.layer addSublayer:layer];
}

@end
