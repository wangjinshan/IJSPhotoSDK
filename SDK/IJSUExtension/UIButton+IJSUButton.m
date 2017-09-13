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
    CASpringAnimation *spring = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
    //    spring.damping = 5;
    //    //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大
    //    spring.mass = 1;
    //    //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快
    //    spring.stiffness = 50;
    //    //初始速率，动画视图的初始速度大小  速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
    //    spring.initialVelocity = 10;
    spring.toValue = @(2);
    //settlingDuration 结算时间 返回弹簧动画到停止时的估算时间，根据当前的动画参数估算 通常弹簧动画的时间使用结算时间比较准确
    spring.removedOnCompletion = NO;
    if (iOS9_1Later)
        spring.duration = spring.settlingDuration;
    [self.layer addAnimation:spring forKey:nil];
    spring.toValue = @(1);
    //settlingDuration 结算时间 返回弹簧动画到停止时的估算时间，根据当前的动画参数估算 通常弹簧动画的时间使用结算时间比较准确
    if (iOS9_1Later)
        spring.duration = spring.settlingDuration;
    [self.layer addAnimation:spring forKey:nil];
}

// 划圆
- (void)drawCirleWithRadius:(CGFloat)radius fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor isClick:(BOOL)isClick
{
    for (CALayer *layer in self.layer.sublayers)
    {
        if (!layer.hidden)
            [layer removeFromSuperlayer];
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
