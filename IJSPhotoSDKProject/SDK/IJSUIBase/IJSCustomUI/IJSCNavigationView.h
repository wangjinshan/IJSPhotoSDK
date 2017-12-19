//
//  IJSCNavigationView.h
//  IJSPhotoSDKProject
//
//  Created by 山神 on 2017/12/18.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJSCNavigationView : UIView

@property(nonatomic,weak) UIButton *leftButton;  // 左边的按钮
@property(nonatomic,weak) UIButton *rightButton;  // 右边的按钮
@property(nonatomic,weak) UILabel *titleLabel;  // 中间的title
@property(nonatomic,copy) void(^leftButtonAction)(UIButton *button);  // 左边的按钮事件
@property(nonatomic,copy) void(^rightButtonAction)(UIButton *button);  // 右边的按钮事件
@property(nonatomic,strong) NSString *title;  //中间的文字

/**
 初始化

 @param frame 大小
 @param title 中间的文字
 @param backColor 背景颜色
 @return 控件自己
 */
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title backColor:(UIColor *)backColor;






@end
