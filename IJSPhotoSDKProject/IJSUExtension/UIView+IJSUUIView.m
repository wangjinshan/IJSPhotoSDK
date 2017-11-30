//
//  UIView+IJSUUIView.m
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UIView+IJSUUIView.h"

@implementation UIView (IJSUUIView)

- (void)setJs_width:(CGFloat)js_width
{
    CGRect rect = self.frame;
    rect.size.width = js_width;
    self.frame = rect;
}
- (CGFloat)js_width
{
    return self.frame.size.width;
}

- (void)setJs_height:(CGFloat)js_height
{
    CGRect rect = self.frame;
    rect.size.height = js_height;
    self.frame = rect;
}
- (CGFloat)js_height
{
    return self.frame.size.height;
}

- (void)setJs_x:(CGFloat)js_x
{
    CGRect rect = self.frame;
    rect.origin.x = js_x;
    self.frame = rect;
}
- (CGFloat)js_x
{
    return self.frame.origin.x;
}

- (void)setJs_y:(CGFloat)js_y
{
    CGRect rect = self.frame;
    rect.origin.y = js_y;
    self.frame = rect;
}

- (CGFloat)js_y
{
    return self.frame.origin.y;
}
//重写 set get 方法
- (void)setJs_centerX:(CGFloat)js_centerX
{
    CGPoint center = self.center;
    center.x = js_centerX;
    self.center = center;
}
- (CGFloat)js_centerX
{
    return self.center.x;
}

- (void)setJs_centerY:(CGFloat)js_centerY
{
    CGPoint center = self.center;
    center.y = js_centerY;
    self.center = center;
}

- (CGFloat)js_centerY
{
    return self.center.y;
}

- (void)setJs_origin:(CGPoint)js_origin
{
    CGRect frame = self.frame;
    frame.origin = js_origin;
    self.frame = frame;
}
- (CGPoint)js_origin
{
    return self.frame.origin;
}
- (void)setJs_size:(CGSize)js_size
{
    CGRect frame = self.frame;
    frame.size = js_size;
    self.frame = frame;
}

- (CGSize)js_size
{
    return self.frame.size;
}

- (CGFloat)js_left
{
    return self.frame.origin.x;
}
- (void)setJs_left:(CGFloat)js_left
{
    CGRect frame = self.frame;
    frame.origin.x = js_left;
    self.frame = frame;
}

- (CGFloat)js_top
{
    return self.frame.origin.y;
}
- (void)setJs_top:(CGFloat)js_top
{
    CGRect frame = self.frame;
    frame.origin.y = js_top;
    self.frame = frame;
}

- (CGFloat)js_right
{
    return self.frame.origin.x + self.frame.size.width;
}
- (void)setJs_right:(CGFloat)js_right
{
    CGRect frame = self.frame;
    frame.origin.x = js_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)js_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
- (void)setJs_bottom:(CGFloat)js_bottom
{
    CGRect frame = self.frame;
    frame.origin.y = js_bottom - frame.size.height;
    self.frame = frame;
}

/*-----------------------------------方法-------------------------------------------------------*/

#pragma mark 根据类名创建xib
+ (instancetype)viewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

@end
