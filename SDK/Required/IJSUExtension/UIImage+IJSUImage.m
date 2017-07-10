//
//  UIImage+IJSUImage.m
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UIImage+IJSUImage.h"

@implementation UIImage (IJSUImage)


// 在周边加一个边框为1的透明像素
- (UIImage *)imageAntialias
{
    if (self)
    {
        CGFloat border = 1.0f;
        CGRect rect = CGRectMake(border, border, self.size.width-2*border, self.size.height-2*border);
        UIImage *img = nil;
        UIGraphicsBeginImageContext(CGSizeMake(rect.size.width,rect.size.height));
        [self drawInRect:CGRectMake(-1, -1, self.size.width, self.size.height)];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContext(self.size);
        [img drawInRect:rect];
        UIImage* antiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return antiImage;
    }
    return nil;
}
// 返回一张圆形图
+ (UIImage *) imageCircleFromOriginImage:(UIImage *)originImage
{
    // 2,裁剪图片,--> 图形上下文可以进行图片裁剪生成新图
    // 1 开启图形上下文    // 上下文值/设置透明/比例因素: 当前点与像素的比例,写0自动适配
    UIGraphicsBeginImageContextWithOptions(originImage.size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, originImage.size.width, originImage.size.height)];                      // 2, 描述裁剪区域
    [path addClip];                                              // 3, 设置裁剪区域
    [originImage drawAtPoint:CGPointZero];   // 4, 画图
    originImage = UIGraphicsGetImageFromCurrentImageContext();  // 5, 取出图片
    UIGraphicsEndPDFContext();   // 6, 关闭上下文
    [originImage imageAntialias];   // 抗锯齿
    
    return originImage;
}

// 根据图片的名字返回需要的圆形图片
+ (UIImage *) imageCircleFromImageName:(NSString *)imageName
{
    return  [UIImage imageCircleFromOriginImage:[UIImage imageNamed:imageName]];
}








@end
