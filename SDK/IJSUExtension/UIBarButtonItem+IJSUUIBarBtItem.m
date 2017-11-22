//
//  UIBarButtonItem+IJSUUIBarBtItem.m
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UIBarButtonItem+IJSUUIBarBtItem.h"

@implementation UIBarButtonItem (IJSUUIBarBtItem)

+ (UIBarButtonItem *)setBarButtonItem:(UIImage *)image heightImage:(UIImage *)heightImage addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    //    左边的按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image
            forState:UIControlStateNormal];
    [button setImage:heightImage
            forState:UIControlStateHighlighted];
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:controlEvents];
    UIView *contentView = [[UIView alloc] initWithFrame:button.bounds]; // 解决 button点击范围扩大的问题
    [contentView addSubview:button];
    return [[UIBarButtonItem alloc] initWithCustomView:contentView];
}

+ (UIBarButtonItem *)setBarButtonItem:(UIImage *)image selectImage:(UIImage *)selectImage addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    //    左边的按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image
            forState:UIControlStateNormal];
    [button setImage:selectImage
            forState:UIControlStateSelected];
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:controlEvents];
    UIView *contentView = [[UIView alloc] initWithFrame:button.bounds]; // 解决 button点击范围扩大的问题
    [contentView addSubview:button];
    return [[UIBarButtonItem alloc] initWithCustomView:contentView];
}

+ (UIButton *)setBackButtonImage:(UIImage *)image imageHeight:(UIImage *)imageHeight selectImage:(UIImage *)selectImage addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image
            forState:UIControlStateNormal];
    [button setImage:imageHeight
            forState:UIControlStateHighlighted];
    [button setImage:selectImage forState:UIControlStateSelected];
    [button sizeToFit];
    //    设置文字颜色
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:controlEvents];
    //    添加额外的间距
    button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    return button;
}

@end
