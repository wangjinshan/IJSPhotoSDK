//
//  UIBarButtonItem+IJSUUIBarBtItem.h
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  UIBarButtonItem的延展
 */
@interface UIBarButtonItem (IJSUUIBarBtItem)
/**
 *  创建自定义的 导航条button
 *
 *  @param image 默认图片
 *  @param heightImage 高亮图片
 *  @param target 方法执行者
 *  @param action 方法名
 *  @param controlEvents 方法执行模式
 *
 *  @return 自定义的 UIBarButtonItem
 */
+ (UIBarButtonItem *)setBarButtonItem:(UIImage *)image heightImage:(UIImage *)heightImage addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 *  创建自定义的 导航条button
 *
 *  @param image 默认图片
 *  @param selectImage 选中图片
 *  @param target 方法执行者
 *  @param action 方法名
 *  @param controlEvents 方法执行模式
 *
 *  @return 自定义的 UIBarButtonItem
 */
+ (UIBarButtonItem *)setBarButtonItem:(UIImage *)image selectImage:(UIImage *)selectImage addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 *  快速创建一个 button
 *
 *  @param title 按钮标题
 *  @param image 默认图片
 *  @param imageHeight 高亮图
 *  @param selectImage 选中图
 *  @param target 方法执行者
 *  @param action 方法名
 *  @param controlEvents 方法执行模式
 *
 *  @return 自定义的 UIButton
 */

+ (UIButton *)setBackButtonImage:(UIImage *)image imageHeight:(UIImage *)imageHeight selectImage:(UIImage *)selectImage addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents title:(NSString *)title;

@end
