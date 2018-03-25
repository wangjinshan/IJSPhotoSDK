//
//  IJSIPanDrawingView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 画笔工具
 */
#import "IJSImageEditController.h"

@interface IJSIPanDrawingView : UIView

@property (nonatomic, copy) void (^panDrawingViewDidTap)(void);                    // 单击的回调
@property (nonatomic, copy) void (^panDrawingViewdrawingCallBack)(BOOL isDrawing); // 正在绘制的回调
@property (nonatomic, copy) void (^panDrawingViewEndDrawCallBack)(BOOL isEndDraw); // 结束绘制

@property(nonatomic,strong) UIImage *backImage;  // 需要设置的背景图片
@property(nonatomic,assign) CGFloat panWidth;  // 绘制的宽度
@property(nonatomic,strong) UIColor *panColor;  // 绘制的颜色

/**
 *  清楚最后一个路径
 */
- (void)cleanLastDrawPath;

/**
 *  清楚所有的
 */
- (void)cleanAllDrawPath;

/**
 *  完成绘制
 */
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
