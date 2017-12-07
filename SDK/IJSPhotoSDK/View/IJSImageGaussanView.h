//
//  IJSImageGaussanView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 高斯UI
 */
@interface IJSImageGaussanView : UIView

@property (nonatomic, weak) UIImage *originImage;             // 原图
@property (nonatomic, weak) UIImage *gaussanViewGaussanImage; // 提前绘制好高斯图
/**
 * 撤销绘画
 */
- (void)cleanLastDrawPath;
/**
 *  清除所有的绘画
 */
- (void)cleanAllDrawPath;

@property (nonatomic, copy) void (^gaussanViewDidTap)(void);                    // 单击的回调
@property (nonatomic, copy) void (^gaussanViewdrawingCallBack)(BOOL isDrawing); // 正在绘制的回调
@property (nonatomic, copy) void (^gaussanViewEndDrawCallBack)(BOOL isEndDraw); // 结束绘制

/**
 *  完成绘制
 */
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
