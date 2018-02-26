//
//  IJSAlertViewController.m
//  yidaojia
//
//  Created by 山神 on 2017/12/28.
//  Copyright © 2017年 山神. All rights reserved.
//

#import "IJSAlertViewController.h"

@implementation IJSAlertViewController

+ (void)addAlertViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle actionHandle:(void (^)(void))actionHandle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        if (actionHandle)
        {
            actionHandle();
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    }]];
    [controller presentViewController:alertController animated:YES completion:nil];
}

// 两种风格
+ (void)addAlertViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message actionOneTitle:(NSString *)oneTitle actionTwoTitle:(NSString *)twoTitle actionOneHandle:(void (^)(void))oneHandle actionTwoHandle:(void (^)(void))twoHandle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:oneTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        if (oneHandle)
        {
            oneHandle();
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:twoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        if (twoHandle)
        {
            twoHandle();
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    }]];
    [controller presentViewController:alertController animated:YES completion:nil];
}

/// 添加输入框的警告窗口
+(void)addAlertViewController:(UIViewController *)controller  title:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder  actionOneTitle:(NSString *)oneTitle actionTwoTitle:(NSString *)twoTitle actionOneHandle:(void (^)(void))oneHandle actionTwoHandle:(void (^)(NSString *text))twoHandle
{
    
    // 1.创建UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder;
    }];
 
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:oneTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (oneHandle)
        {
            oneHandle();
             [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:twoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *userName = alertController.textFields.firstObject;
        if (twoHandle)
        {
            twoHandle(userName.text);
             [controller dismissViewControllerAnimated:YES completion:nil];
        }
        // 输出用户名 密码到控制台
    }];
    
    // 2.3 添加按钮
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    
    // 3.显示警报控制器
    [controller presentViewController:alertController animated:YES completion:nil];
}


+(void)addAlertViewController:(UIViewController *)controller  title:(NSString *)title message:(NSString *)message oneplaceholder:(NSString *)oneplaceholder twoplaceholder:(NSString *)twoplaceholder  actionOneTitle:(NSString *)oneTitle actionTwoTitle:(NSString *)twoTitle actionOneHandle:(void (^)(void))oneHandle actionTwoHandle:(void (^)(NSString *userName, NSString *password))twoHandle
{
    // 1.创建UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = oneplaceholder;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = twoplaceholder;
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:oneTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel Action");
        if (oneHandle)
        {
            oneHandle();
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:twoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *userName = alertController.textFields.firstObject;
        UITextField *password = alertController.textFields.lastObject;
        if (twoHandle)
        {
            twoHandle(userName.text,password.text);
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    // 2.3 添加按钮
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    // 3.显示警报控制器
    [controller presentViewController:alertController animated:YES completion:nil];
}















@end
