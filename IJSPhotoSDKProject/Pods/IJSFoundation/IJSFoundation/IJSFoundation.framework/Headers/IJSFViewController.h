//
//  IJSFViewController.h
//  IJSPhotoKitDemo
//
//  Created by shan on 2017/6/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  视图控制器工具类
 */
@interface IJSFViewController : NSObject

/**
 *  获取当前视图控制器
 *
 *  @return 视图控制器
 */
+ (UIViewController *)currentViewController;

/**
 *  获取当前视图控制器
 *
 *  @param window 窗口
 *
 *  @return 视图控制器
 */
+ (UIViewController *)currentViewControllerFromWindow:(UIWindow *)window;

/**
 回到跟控制器
 */
+ (void)backToRootViewControllerWhenDidFinish;




@end
