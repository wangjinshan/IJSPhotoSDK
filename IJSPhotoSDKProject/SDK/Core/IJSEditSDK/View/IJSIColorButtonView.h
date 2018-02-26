//
//  IJSIColorButtonView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/13.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 颜色调工具
 */

@interface IJSIColorButtonView : UIView

/* 颜色回调 */
@property (nonatomic, copy) void (^colorCallBack)(UIColor *color);
/* 宽度的回调 */
@property (nonatomic, copy) void (^sliderCallBack)(CGFloat width);
/* 撤销 */
@property (nonatomic, copy) void (^cancleCallBack)(void);
/* 撤销按钮 */
@property (nonatomic, strong) UIButton *canclePathButton;

@end
