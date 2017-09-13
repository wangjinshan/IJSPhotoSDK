//
//  IJSIPath.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSIPath.h"

@interface IJSIPath ()
@property (nonatomic, strong) UIBezierPath *bezierPath; // 贝塞尔路径
@property (nonatomic, assign) CGPoint beginPoint;       // 起点
@property (nonatomic, assign) CGFloat pathWidth;        // 线宽
@end

@implementation IJSIPath
+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath]; // 线的路径
    bezierPath.lineWidth = pathWidth;                     //线宽
    bezierPath.lineCapStyle = kCGLineCapRound;            //线条拐角
    bezierPath.lineJoinStyle = kCGLineJoinRound;          //终点处理
    [bezierPath moveToPoint:beginPoint];

    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineCap = kCALineCapRound;   // 边缘线的类型
    shapeLayer.lineJoin = kCALineJoinRound; //贝塞尔线段连接点格式
    shapeLayer.lineWidth = pathWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath; //线路赋值

    IJSIPath *path = [[IJSIPath alloc] init];
    path.beginPoint = beginPoint;
    path.pathWidth = pathWidth;
    path.bezierPath = bezierPath;
    path.shape = shapeLayer;

    return path;
}

//曲线
- (void)pathLineToPoint:(CGPoint)movePoint;
{
    //判断绘图类型
    [self.bezierPath addLineToPoint:movePoint];
    self.shape.path = self.bezierPath.CGPath;
}

- (void)drawPath
{
    [self.pathColor set];
    [self.bezierPath stroke]; // 根据坐标点连线
}

@end
