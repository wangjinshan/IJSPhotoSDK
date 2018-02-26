//
//  IJSAlertViewController.h
//  yidaojia
//
//  Created by 山神 on 2017/12/28.
//  Copyright © 2017年 山神. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJSAlertViewController : NSObject

/**
 警告--只有确定按钮

 @param controller 控制器
 @param title 标题
 @param message 描述
 @param actionTitle 行为
 @param actionHandle 回调
 */
+ (void)addAlertViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle actionHandle:(void (^)(void))actionHandle;
/**
 加警告 -----有取消和确定

 @param controller 控制器
 @param title 标题
 @param message 信息
 @param oneTitle 左标题
 @param twoTitle 右标题
 @param oneHandle 左标题回调
 @param twoHandle 右标题回调
 */
+ (void)addAlertViewController:(UIViewController *)controller
                         title:(NSString *)title
                       message:(NSString *)message
                actionOneTitle:(NSString *)oneTitle
                actionTwoTitle:(NSString *)twoTitle
               actionOneHandle:(void (^)(void))oneHandle
               actionTwoHandle:(void (^)(void))twoHandle;

/**
 添加输入框---有账号

 @param controller 控制器
 @param title 标题
 @param message 描述
 @param placeholder 站位文字
 @param oneTitle 左边的按钮
 @param twoTitle 右边的按钮
 @param oneHandle 左边的回调
 @param twoHandle 右边的回调
 */
+(void)addAlertViewController:(UIViewController *)controller
                        title:(NSString *)title
                      message:(NSString *)message
                  placeholder:(NSString *)placeholder
               actionOneTitle:(NSString *)oneTitle
               actionTwoTitle:(NSString *)twoTitle
              actionOneHandle:(void (^)(void))oneHandle
              actionTwoHandle:(void (^)(NSString *text))twoHandle;

/**
 添加账号密码的输入框 --- 账号密码

 @param controller 控制器
 @param title 标题
 @param message 描述
 @param oneplaceholder 第一个站位
 @param twoplaceholder 第二个站位
 @param oneTitle 左边的按钮文字
 @param twoTitle 右边的按钮文字
 @param oneHandle 左边的回调
 @param twoHandle 右边的回调
 */
+(void)addAlertViewController:(UIViewController *)controller
                        title:(NSString *)title
                      message:(NSString *)message
               oneplaceholder:(NSString *)oneplaceholder
               twoplaceholder:(NSString *)twoplaceholder
               actionOneTitle:(NSString *)oneTitle
               actionTwoTitle:(NSString *)twoTitle
              actionOneHandle:(void (^)(void))oneHandle
              actionTwoHandle:(void (^)(NSString *userName, NSString *password))twoHandle;

@end
