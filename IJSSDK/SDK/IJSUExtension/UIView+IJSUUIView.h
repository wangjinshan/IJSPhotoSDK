//
//  UIView+IJSUUIView.h
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  UIView的延展
 */
@interface UIView (IJSUUIView)

/*宽度*/
@property (nonatomic, assign) CGFloat js_width;
/*高度*/
@property (nonatomic, assign) CGFloat js_height;
/*x*/
@property (nonatomic, assign) CGFloat js_x;
/*y*/
@property (nonatomic, assign) CGFloat js_y;
/*中心点X*/
@property (nonatomic, assign) CGFloat js_centerX;
/*中心点Y*/
@property (nonatomic, assign) CGFloat js_centerY;
@property (nonatomic) CGFloat js_left;   // 左
@property (nonatomic) CGFloat js_top;    // 上
@property (nonatomic) CGFloat js_right;  // 右
@property (nonatomic) CGFloat js_bottom; //下
@property (nonatomic) CGPoint js_origin; // 原始大
@property (nonatomic) CGSize js_size;    //大小
/**
 *  根据类名字创建xib
 *
 *  @return 创建好的xib
 */
+ (instancetype)viewFromXib;

@end
