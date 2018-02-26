//
//  UITextField+IJSUTextField.m
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UITextField+IJSUTextField.h"

@implementation UITextField (IJSUTextField)

// 重写 set get方法
- (UIColor *)js_placeholderColor
{
    return self.js_placeholderColor;
}

- (void)setJs_placeholderColor:(UIColor *)js_placeholderColor
{
    // 设置真正的占位文字的暗色
    UILabel *placeholderLabel = [self valueForKey:@"placeholderLabel"];
    placeholderLabel.textColor = js_placeholderColor;
}

@end
