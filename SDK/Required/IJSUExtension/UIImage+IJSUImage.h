//
//  UIImage+IJSUImage.h
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  UIImage 分类
 */
@interface UIImage (IJSUImage)


/**
 *  返回一张抗锯齿图片
 *  @return 本质：在图片生成一个透明为1的像素边框
 */
- (UIImage *)imageAntialias;

/**
 *  圆形图
 *
 *  @param originImage 原始图
 *
 *  @return 处理好的圆形图
 */

+ (UIImage *) imageCircleFromOriginImage:(UIImage *)originImage;

/**
 *  根据图片名字返回圆形图
 *
 *  @param imageName 图片名字
 *
 *  @return 处理好的圆形图
 */
+ (UIImage *) imageCircleFromImageName:(NSString *)imageName;
@end
