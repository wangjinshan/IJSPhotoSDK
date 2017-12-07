//
//  IJSVideoDrawingView.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/28.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSDToolBarView.h"
#import "IJSDColorView.h"
#import "IJSDrawingView.h"

@interface IJSVideoDrawingView : UIView

@property (nonatomic, strong) UIImage *originImage;                 // 原始图
@property (nonatomic, copy) void (^finishCallBack)(UIImage *image); // 完成
@property (nonatomic, weak) id controller;                          // 控制器
///
@property (nonatomic, weak) IJSDToolBarView *toolBarView; // 工具条
@property (nonatomic, weak) IJSDColorView *colorView;     // 颜色板子
@property (nonatomic, weak) IJSDrawingView *drawingView;  // 画板,调整视图UI的位置,直接调整此UI

@property (nonatomic, copy) void (^didTapCallBack)(BOOL isDidTap); // 单机
@property (nonatomic, copy) void (^isDrawing)(void);               // 正在绘制
@property (nonatomic, copy) void (^isEndDrawing)(void);            // 结束绘制
/**
 *  特殊初始化方法
 *
 *  @param frame       控件的大小 参考区域是 全屏除去导航条工具条
 *  @param size    绘画区域
 */
- (instancetype)initWithFrame:(CGRect)frame drawingViewSize:(CGSize)size;

@end
