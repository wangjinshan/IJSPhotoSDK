//
//  IJSImageMosaicView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 马赛克绘图
 */
@interface IJSImageMosaicView : UIView

//顶部的图片为原图，底部的图片为原图处理后的马赛克图片
@property (nonatomic, weak) UIImage *mosaicImage;  // 马赛克图
@property (nonatomic, weak) UIImage *surfaceImage; // 涂鸦层
/**
 *  撤销绘画
 */
- (void)cleanLastDrawPath;
/**
 *  清除所有的绘制
 */
- (void)cleanAllDrawPath;

@property (nonatomic, copy) void (^mosaicViewDidTap)(void);                    // 单击的回调
@property (nonatomic, copy) void (^mosaicViewdrawingCallBack)(BOOL isDrawing); // 正在绘制的回调
@property (nonatomic, copy) void (^mosaicViewEndDrawCallBack)(BOOL isEndDraw); // 结束绘制

/**
 *  完成绘制
 */
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
