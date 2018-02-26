//
//  IJSDrawingView.h
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSDrawingModel.h"
/*
 * 画板
 */
typedef void (^finishCallBack)(UIImage *image);

@interface IJSDrawingView : UIView

@property (nonatomic, strong) UIColor *pathColor;       // 路径颜色
@property (nonatomic, assign) CGFloat pathWidth;        // 路径宽度
@property (nonatomic, copy) void (^isDrawing)(void);    // 正在绘制
@property (nonatomic, copy) void (^isEndDrawing)(void); // 结束绘制
@property (nonatomic, strong) IJSDrawingModel *model;   // 模型

- (void)cleanAllPath;
- (void)cleanLastPath;
- (void)erasePath;
/**
 *  完成绘制
 */
- (void)didFinishDrawImage:(finishCallBack)finishCallBack;

@end
