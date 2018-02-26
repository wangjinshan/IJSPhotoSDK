//
//  UIButton+IJSUButton.h
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  UIButton的扩展类
 */
@interface UIButton (IJSUButton)

/**
 *  给button的image添加弹跳的动画
 */
- (void)addSpringAnimation;

/**
 *  画空心圆
 *
 *  @param radius         半径
 *  @param fillColor      填充颜色
 *  @param strokeColor   边缘颜色
 *  @param isClick   被点击
 *
 */
- (void)drawCirleWithRadius:(CGFloat)radius fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor isClick:(BOOL)isClick;

@end
