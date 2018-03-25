//
//  IJSImageToolBase.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IJSImageEditController.h"
/*
 *  工具基类
 */
@interface IJSImageToolBase : NSObject
/* 控制器 */
@property (nonatomic, weak) IJSImageEditController *editorController;
/**
 *  初始化
 */
- (instancetype)initToolWithViewController:(IJSImageEditController *)controller;
/**
 *  设置基本参数
 */
- (void)setupTool;
/**
 *  清楚
 */
- (void)cleanupTool;
/**
 *  导出数据
 */
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

/**
 *  撤销绘画
 */
- (void)cleanLastDrawPath;

/*-----------------------------------公共方法回调-------------------------------------------------------*/
@property (nonatomic, copy) void (^drawToolDidTap)(void);            // 单击的回调
@property (nonatomic, copy) void (^drawingCallBack)(BOOL isDrawing); // 正在绘制的回调
@property (nonatomic, copy) void (^drawEndCallBack)(BOOL isEndDraw); // 结束绘制

/*-----------------------------------公共属性-------------------------------------------------------*/
@property (nonatomic, assign) CGSize originalImageSize;   // 原始图片的大小
@property (nonatomic, weak) UIImageView *drawingView;     // 绘制的背景
@property (nonatomic, strong) NSMutableArray *allLineArr; // 所有的线
@property(nonatomic,assign) CGFloat panWidth;  // 绘制的宽度
@property(nonatomic,strong) UIColor *panColor;  // 绘制的颜色
@property(nonatomic,strong) UIImage *backImage;  // 需要设置的背景图片

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture; // 画笔
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture; //轻点

@end
